/*
 * To change this license header, choose License Headers in Project Properties.
 * To change this template file, choose Tools | Templates
 * and open the template in the editor.
 */
package com.advantech.job;

import com.advantech.helper.WorkDateUtils;
import com.advantech.model.Floor;
import com.advantech.model.LineSchedule;
import com.advantech.model.LineScheduleStatus;
import com.advantech.model.RemoteSchedule;
import com.advantech.model.Warehouse;
import com.advantech.repo.FloorRepository;
import com.advantech.repo.LineScheduleRepository;
import com.advantech.repo.LineScheduleStatusRepository;
import com.advantech.repo.WarehouseRepository;
import com.advantech.webservice.port.PartMappingVarietyQueryPort;
import com.advantech.webservice.root.PartMappingVarietyQueryRoot;
import com.advantech.webservice.unmarshallclass.PartMappingVariety;
import java.util.ArrayList;
import java.util.List;
import static java.util.stream.Collectors.toList;
import org.joda.time.DateTime;
import org.slf4j.Logger;
import org.slf4j.LoggerFactory;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Component;
import org.springframework.transaction.annotation.Transactional;

/**
 *
 */
@Component
public class SyncData {

    private static final Logger logger = LoggerFactory.getLogger(SyncData.class);

    @Autowired
    private LineScheduleRepository lineScheduleRepo;

    @Autowired
    private LineScheduleStatusRepository statusRepo;

    @Autowired
    private WarehouseRepository warehouseRepo;

    @Autowired
    private FloorRepository floorRepo;

    @Autowired
    private WorkDateUtils workDateUtils;

    @Autowired
    private PartMappingVarietyQueryPort pmvPort;

    @Transactional
    public void execute() {

        DateTime nextDay = workDateUtils.findNextDay();

        List<Floor> floors = floorRepo.findAll();
        LineScheduleStatus defaultStatus = statusRepo.getOne(1);
        LineScheduleStatus inWarehouse = statusRepo.getOne(2);

        List<RemoteSchedule> remoteSchedules = lineScheduleRepo.getPrepareSchedule(nextDay.toDate());
        if (remoteSchedules.size() < 0) {
            logger.info("Empty remote schedule, abort mission.");
            return;
        }
        List<LineSchedule> lineSchedules = new ArrayList();

        PartMappingVarietyQueryRoot root = new PartMappingVarietyQueryRoot();
        PartMappingVarietyQueryRoot.PARTMAPPINGVARIETY pmv = root.getPARTMAPPINGVARIETY();

        remoteSchedules.forEach(s -> {
            String floorName = s.getFloorName();
            if ("M2".equals(floorName)) {
                floorName = "5F";
            } else if ("M6".equals(floorName)) {
                floorName = "7F";
            }
            final String floor = floorName;
            Floor filterFloor = floors.stream().filter(f -> f.getName().equals(floor)).findFirst().orElse(null);
            if (filterFloor != null) {
                LineSchedule sche = new LineSchedule(s.getPo(), s.getModelName(), s.getQuantity(), filterFloor, defaultStatus);
                sche.setCreateDate(s.getOnDateTime());
                sche.setOnBoardDate(s.getOnDateTime());

                try {
                    pmv.setITEMNO(s.getModelName());
                    List l = pmvPort.query(root);
                    String remark = this.combinePartMappingVarietyMessages(l);
                    sche.setRemark(remark);
                } catch (Exception ex) {
                    logger.error(ex.getMessage(), ex);
                }

                lineSchedules.add(sche);
            }
        });
        
        //object can't references an unsaved transient instance
        lineScheduleRepo.saveAll(lineSchedules);

        List<Warehouse> needUpdateWarehouses = new ArrayList();
        //When schedule's po is already in warehouse, set status to complete.
        floors.forEach(f -> {
            List<Warehouse> warehouses = warehouseRepo.findByFloorAndFlag(f, 0);
            warehouses.forEach(w -> {
                LineSchedule s = lineSchedules.stream()
                        .filter(ls -> ls.getFloor().equals(f) && ls.getPo().equals(w.getPo()))
                        .findFirst()
                        .orElse(null);
                if (s != null) {
                    w.setLineSchedule(s);
                    needUpdateWarehouses.add(w);
                    s.setLineScheduleStatus(inWarehouse);
                }
            });
        });

        if (!needUpdateWarehouses.isEmpty()) {
            logger.info("Begin update " + needUpdateWarehouses.size() + " data in warehouse");
            warehouseRepo.saveAll(needUpdateWarehouses);
        }
        
        logger.info("Begin save " + lineSchedules.size() + " data into lineSchedule");
        lineScheduleRepo.saveAll(lineSchedules);
    }

    private String combinePartMappingVarietyMessages(List<PartMappingVariety> l) {
        if (l.isEmpty()) {
            return null;
        }
        StringBuilder sb = new StringBuilder();
        List<PartMappingVariety> filterList = l.stream().filter(p -> p.getStationId() == 2 || p.getStationId() == 20).collect(toList());
        if (filterList.isEmpty()) {
            return null;
        }
        filterList.forEach(p -> {
            sb.append(p.getVarietyName());
            sb.append(": ");
            sb.append(p.getQty());
            sb.append(", ");
        });
        return sb.toString();
    }

}
