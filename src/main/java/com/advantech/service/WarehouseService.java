/*
 * To change this license header, choose License Headers in Project Properties.
 * To change this template file, choose Tools | Templates
 * and open the template in the editor.
 */
package com.advantech.service;

import com.advantech.model.Floor;
import com.advantech.model.LineScheduleStatus;
import com.advantech.model.User;
import com.advantech.model.Warehouse;
import com.advantech.model.WarehouseEvent;
import com.advantech.repo.WarehouseRepository;
import java.util.List;
import java.util.Optional;
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

    public List<Warehouse> findAll() {
        return repo.findAll();
    }

    public Optional<Warehouse> findById(Integer id) {
        return repo.findById(id);
    }

    public List<Warehouse> findByFlag(int flag) {
        return repo.findByFlag(flag);
    }

    public List<Warehouse> findByFloorAndFlag(Floor floor, int flag) {
        return repo.findByFloorAndFlag(floor, flag);
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
        this.lineScheduleService.updateStatus(w.getPo(), status, w.getStorageSpace());
    }

}
