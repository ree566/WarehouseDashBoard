/*
 * To change this license header, choose License Headers in Project Properties.
 * To change this template file, choose Tools | Templates
 * and open the template in the editor.
 */
package com.advantech.service;

import com.advantech.helper.WorkDateUtils;
import com.advantech.model.Floor;
import com.advantech.model.LineSchedule;
import com.advantech.model.LineScheduleStatus;
import com.advantech.model.StorageSpace;
import com.advantech.model.StorageSpaceGroup;
import com.advantech.model.User;
import com.advantech.model.Warehouse;
import com.advantech.model.WarehouseEvent;
import com.advantech.repo.WarehouseRepository;
import java.util.List;
import java.util.Optional;
import org.hibernate.Hibernate;
import org.joda.time.DateTime;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

/**
 *
 * @author Wei.Cheng
 */
@Service
@Transactional
public class WarehouseService {

    @Autowired
    private WarehouseRepository repo;

    @Autowired
    private WarehouseEventService warehouseEventService;

    @Autowired
    private LineScheduleStatusService lineScheduleStatusService;

    @Autowired
    private LineScheduleService lineScheduleService;

    @Autowired
    private WorkDateUtils workDateUtils;

    @Autowired
    private LineScheduleStatusService stateService;

    @Autowired
    private StorageSpaceService storageSpaceService;

    public List<Warehouse> findAll() {
        return repo.findAll();
    }

    public Optional<Warehouse> findById(Integer id) {
        return repo.findById(id);
    }

    public List<Warehouse> findByStorageSpaceGroupAndFlag(StorageSpaceGroup storageSpaceGroup, int flag) {
        List<Warehouse> l = repo.findByStorageSpaceGroupAndFlag(storageSpaceGroup, flag);
        l.forEach(w -> {
            if (w.getLineSchedule() != null) {
                Hibernate.initialize(w.getLineSchedule());
                Hibernate.initialize(w.getLineSchedule().getLine());
            }
        });
        return l;
    }

    public List<Warehouse> findByPoAndFloorAndFlag(String po, Floor floor, int flag) {
        return repo.findByPoAndFloorAndFlag(po, floor, flag);
    }

    public <S extends Warehouse> S save(S s) {
        return repo.save(s);
    }

    public void save(Warehouse w, User user, String action) {
        repo.save(w);
        WarehouseEvent e = new WarehouseEvent(w, user, action);
        warehouseEventService.save(e);

        LineScheduleStatus status = null;
        if (null == action) {

        } else {
            switch (action) {
                case "PUT_IN":
                    status = this.lineScheduleStatusService.getOne(2);
                    break;
                case "PULL_OUT":
                    status = this.lineScheduleStatusService.getOne(4);
                    break;
                default:
                    throw new IllegalArgumentException();
            }
        }
        this.lineScheduleService.updateStatus(w, status);
    }

    public void changeStorageSpace(Warehouse w, User user) {
        repo.save(w);
        WarehouseEvent e = new WarehouseEvent(w, user, "CHANGE_AREA");
        warehouseEventService.save(e);

        DateTime nextDay = workDateUtils.findNextDay();
        DateTime sD = new DateTime(nextDay).withTime(0, 0, 0, 0);
        DateTime eD = new DateTime(nextDay).withTime(23, 59, 59, 0);

        LineScheduleStatus onBoard = stateService.getOne(4);
        StorageSpace ss = storageSpaceService.findById(w.getStorageSpace().getId()).get();
        Floor f = ss.getStorageSpaceGroup().getFloor();
        LineSchedule schedule = lineScheduleService.findFirstByPoAndFloorAndOnBoardDateBetweenAndLineScheduleStatusNot(w.getPo(), f, sD.toDate(), eD.toDate(), onBoard);
        if (schedule != null) {
            schedule.setStorageSpace(w.getStorageSpace());
            lineScheduleService.save(schedule);
        }

    }

}
