/*
 * To change this license header, choose License Headers in Project Properties.
 * To change this template file, choose Tools | Templates
 * and open the template in the editor.
 */
package com.advantech.service;

import com.advantech.helper.WorkDateUtils;
import com.advantech.model.Line;
import com.advantech.model.LineSchedule;
import com.advantech.model.LineScheduleStatus;
import com.advantech.model.StorageSpace;
import com.advantech.model.Warehouse;
import com.advantech.repo.LineScheduleRepository;
import static com.google.common.base.Preconditions.checkState;
import java.util.List;
import java.util.Objects;
import org.joda.time.DateTime;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.data.jpa.datatables.mapping.DataTablesInput;
import org.springframework.data.jpa.datatables.mapping.DataTablesOutput;
import org.springframework.data.jpa.domain.Specification;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

/**
 *
 * @author Wei.Cheng
 */
@Service
@Transactional
public class LineScheduleService {

    @Autowired
    private LineScheduleRepository repo;

    @Autowired
    private LineScheduleStatusService stateService;

    @Autowired
    private WorkDateUtils workDateUtils;

    @Autowired
    private WarehouseService warehouseService;

    public DataTablesOutput<LineSchedule> findAll(DataTablesInput dti) {
        return repo.findAll(dti);
    }

    public DataTablesOutput<LineSchedule> findAll(DataTablesInput dti, Specification<LineSchedule> s) {
        return repo.findAll(dti, s);
    }

    public LineSchedule getOne(Integer id) {
        return repo.getOne(id);
    }

    public <S extends LineSchedule> S save(S s) {
        if (isLineChanged(s)) {
            LineScheduleStatus lineOperated = stateService.getOne(3);
            LineScheduleStatus onBoard = stateService.getOne(4);
            if (s.getLineScheduleStatus().getId() != onBoard.getId()) {
                s.setLineScheduleStatus(lineOperated);
            }
            List<Warehouse> l = warehouseService
                    .findByPoAndFloorAndFlag(s.getPo(), s.getFloor(), 0);
            if (!l.isEmpty()) {
                Warehouse w = l.get(0);
                if (w.getLineSchedule() == null) {
                    w.setLineSchedule(s);
                    warehouseService.save(w);
                }
            }
        }
        return repo.save(s);
    }

    private boolean isLineChanged(LineSchedule pojo) {
        LineSchedule prevPojo = repo.getOne(pojo.getId());
        Line prevLine = prevPojo.getLine();
        Line checkLine = pojo.getLine();
        Integer prevId = (prevLine == null ? null : prevLine.getId());
        Integer checkId = (checkLine == null ? null : checkLine.getId());

        return !Objects.equals(prevId, checkId);
    }

    public void updateStatus(Warehouse w, LineScheduleStatus status) {
        DateTime nextDay = workDateUtils.findNextDay();
        DateTime sD = new DateTime(nextDay).withTime(0, 0, 0, 0);
        DateTime eD = new DateTime(nextDay).withTime(23, 59, 59, 0);
        LineScheduleStatus onBoard = stateService.getOne(4);
        LineSchedule schedule = repo.findFirstByPoAndCreateDateBetweenAndLineScheduleStatusNot(w.getPo(), sD.toDate(), eD.toDate(), onBoard);
        if (schedule != null) {
            checkState(!(schedule.getLine() == null && status.getId() == 4), "Can't pull out when po's line is not setting");
            schedule.setLineScheduleStatus(status);
            if (status.getId() != 4) {
                schedule.setStorageSpace(w.getStorageSpace());
            }
            repo.save(schedule);
            if (w.getLineSchedule() == null) {
                w.setLineSchedule(schedule);
                warehouseService.save(w);
            }
        }
    }

    public void delete(LineSchedule t) {
        repo.delete(t);
    }

}
