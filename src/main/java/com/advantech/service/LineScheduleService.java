/*
 * To change this license header, choose License Headers in Project Properties.
 * To change this template file, choose Tools | Templates
 * and open the template in the editor.
 */
package com.advantech.service;

import com.advantech.helper.WorkDateUtils;
import com.advantech.model.Floor;
import com.advantech.model.Line;
import com.advantech.model.LineSchedule;
import com.advantech.model.LineScheduleStatus;
import com.advantech.model.StorageSpace;
import com.advantech.model.Warehouse;
import com.advantech.repo.LineScheduleRepository;
import static com.google.common.base.Preconditions.checkState;
import java.util.Date;
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

    @Autowired
    private StorageSpaceService storageSpaceService;

    @Autowired
    private LineService lineService;

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
        if (isFloorChanged(s)) {
            LineScheduleStatus defaultState = stateService.getOne(1);
            s.setLine(null);
            s.setLineSchedulePriorityOrder(null);
            s.setLineScheduleStatus(defaultState);
            List<Warehouse> l = warehouseService
                    .findByPoAndFloorAndFlag(s.getPo(), s.getFloor(), 0);
            if (!l.isEmpty()) {
                Warehouse w = l.get(0);
                w.setFlag(1);
                warehouseService.save(w);
            }
        } else if (isLineChanged(s)) {
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
            
            if (s.getLineScheduleStatus().getId() != onBoard.getId()) {
                DateTime nextDay = workDateUtils.findNextDay();
                DateTime sD = new DateTime(nextDay).withTime(0, 0, 0, 0);
                DateTime eD = new DateTime(nextDay).withTime(23, 59, 59, 0);
                Line line = lineService.getOne(s.getLine().getId());
                List<LineSchedule> dataInLine = repo.findByLineAndOnBoardDateBetweenAndLineScheduleStatusNotAndLineSchedulePriorityOrderNotNull(line, sD.toDate(), eD.toDate(), onBoard);
                int priorityOrder = 1;
                if (!dataInLine.isEmpty()) {
                    Integer maxPriorityOrder = dataInLine.stream().mapToInt(LineSchedule::getLineSchedulePriorityOrder).max().getAsInt();
                    priorityOrder = maxPriorityOrder + 1;
                }
                s.setLineSchedulePriorityOrder(priorityOrder);
            }
        } else if (isPriorityOrderChanged(s)) {

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

    private boolean isFloorChanged(LineSchedule pojo) {
        LineSchedule prevPojo = repo.getOne(pojo.getId());
        Floor prev = prevPojo.getFloor();
        Floor check = pojo.getFloor();
        Integer prevId = (prev == null ? null : prev.getId());
        Integer checkId = (check == null ? null : check.getId());

        return !Objects.equals(prevId, checkId);
    }

    private boolean isPriorityOrderChanged(LineSchedule pojo) {
        LineSchedule prevPojo = repo.getOne(pojo.getId());
        Integer prevPriorityOrder = prevPojo.getLineSchedulePriorityOrder();
        Integer priorityOrder = pojo.getLineSchedulePriorityOrder();
        return !Objects.equals(prevPriorityOrder, priorityOrder);
    }

    public List<LineSchedule> findByLine(Line line) {
        LineScheduleStatus onBoard = stateService.getOne(4);
        DateTime nextDay = workDateUtils.findNextDay();
        DateTime sD = new DateTime(nextDay).withTime(0, 0, 0, 0);
        DateTime eD = new DateTime(nextDay).withTime(23, 59, 59, 0);
        return repo.findByLineAndOnBoardDateBetweenAndLineScheduleStatusNot(line, sD.toDate(), eD.toDate(), onBoard);
    }

    public void updateStatus(Warehouse w, LineScheduleStatus status) {
        DateTime nextDay = workDateUtils.findNextDay();
        DateTime sD = new DateTime(nextDay).withTime(0, 0, 0, 0);
        DateTime eD = new DateTime(nextDay).withTime(23, 59, 59, 0);
        LineScheduleStatus onBoard = stateService.getOne(4);
        Floor f = getWarehouseFloor(w);
        LineSchedule schedule = repo.findFirstByPoAndFloorAndOnBoardDateBetweenAndLineScheduleStatusNot(w.getPo(), f, sD.toDate(), eD.toDate(), onBoard);
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

    public LineSchedule findFirstByPoAndFloorAndOnBoardDateBetweenAndLineScheduleStatusNot(String po, Floor f, Date sD, Date eD, LineScheduleStatus status) {
        return repo.findFirstByPoAndFloorAndOnBoardDateBetweenAndLineScheduleStatusNot(po, f, sD, eD, status);
    }

    private Floor getWarehouseFloor(Warehouse w) {
        StorageSpace ss = storageSpaceService.findById(w.getStorageSpace().getId()).get();
        return ss.getStorageSpaceGroup().getFloor();
    }

    public void delete(LineSchedule t) {
        repo.delete(t);
    }

}
