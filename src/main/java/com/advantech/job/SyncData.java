/*
 * To change this license header, choose License Headers in Project Properties.
 * To change this template file, choose Tools | Templates
 * and open the template in the editor.
 */
package com.advantech.job;

import com.advantech.helper.HibernateObjectPrinter;
import com.advantech.model.Floor;
import com.advantech.model.LineSchedule;
import com.advantech.model.LineScheduleStatus;
import com.advantech.model.RemoteSchedule;
import com.advantech.model.Warehouse;
import com.advantech.repo.FloorRepository;
import com.advantech.repo.LineScheduleRepository;
import com.advantech.repo.LineScheduleStatusRepository;
import com.advantech.repo.WarehouseRepository;
import java.util.ArrayList;
import java.util.Date;
import java.util.List;
import org.joda.time.DateTime;
import org.slf4j.Logger;
import org.slf4j.LoggerFactory;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Component;
import org.springframework.transaction.annotation.Transactional;

/**
 *
 * @author Wei.Cheng Sync back excel's data from "MFG-Server (MFG-OAPC-019B)"
 * Every day ※Only sync current years data
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

    @Transactional
    public void execute() {
        DateTime tomorrow = new DateTime().plusDays(1).withTime(0, 0, 0, 0);
        if(isScheduleExists(tomorrow)){
            logger.info("Schedule in spec date is already exist.");
            return;
        }
        
        List<Floor> floors = floorRepo.findAll();
        LineScheduleStatus defaultStatus = statusRepo.getOne(1);
        LineScheduleStatus onboard = statusRepo.getOne(4);

        List<RemoteSchedule> remoteSchedules = lineScheduleRepo.getPrepareSchedule(tomorrow.toDate());
        List<LineSchedule> lineSchedules = new ArrayList();

        remoteSchedules.forEach(s -> {
            String floorName = s.getFloorName();
            if ("M2".equals(floorName)) {
                floorName = "5F";
            }
            final String floor = floorName;
            Floor filterFloor = floors.stream().filter(f -> f.getName().equals(floor)).findFirst().orElse(null);
            if (filterFloor != null) {
                LineSchedule sche = new LineSchedule(s.getPo(), s.getModelName(), s.getQuantity(), filterFloor, defaultStatus);
                sche.setCreateDate(s.getOnDateTime());
                lineSchedules.add(sche);
            }
        });

        //When schedule's po is already in warehouse, set status to complete.
        floors.forEach(f -> {
            List<Warehouse> warehouses = warehouseRepo.findByFloorAndFlag(f, 0);
            warehouses.forEach(w -> {
                LineSchedule s = lineSchedules.stream()
                        .filter(ls -> ls.getFloor().equals(f) && ls.getPo().equals(w.getPo()))
                        .findFirst()
                        .orElse(null);
                if(s != null){
                    s.setLineScheduleStatus(onboard);
                }
            });
        });

        logger.info("Begin save " + lineSchedules.size() + " data into lineSchedule");

        lineScheduleRepo.saveAll(lineSchedules);
    }
    
    private boolean isScheduleExists(DateTime d){
        List l = lineScheduleRepo.getPrepareSchedule(d.toDate());
        return !l.isEmpty();
    }

}
