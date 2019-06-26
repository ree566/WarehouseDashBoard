/*
 * To change this license header, choose License Headers in Project Properties.
 * To change this template file, choose Tools | Templates
 * and open the template in the editor.
 */
package com.advantech.service;

import com.advantech.model.LineSchedule;
import com.advantech.model.LineScheduleStatus;
import com.advantech.model.StorageSpace;
import com.advantech.repo.LineScheduleRepository;
import static com.google.common.base.Preconditions.checkState;
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
        LineScheduleStatus lineOperated = stateService.getOne(3);
        LineScheduleStatus onBoard = stateService.getOne(4);
        if (s.getLineScheduleStatus().getId() != onBoard.getId()) {
            s.setLineScheduleStatus(lineOperated);
        }
        return repo.save(s);
    }

    public void updateStatus(String po, LineScheduleStatus status, StorageSpace storageSpace) {
        DateTime sD = new DateTime().plusDays(1).withTime(0, 0, 0, 0);
        DateTime eD = new DateTime().plusDays(1).withTime(23, 59, 59, 0);
        LineScheduleStatus onBoard = stateService.getOne(4);
        LineSchedule schedule = repo.findFirstByPoAndCreateDateBetweenAndLineScheduleStatusNot(po, sD.toDate(), eD.toDate(), onBoard);
        if (schedule != null) {
            checkState(!(schedule.getLine() == null && status.getId() == 4), "Can't pull out when po's line is not setting");
            schedule.setLineScheduleStatus(status);
            if (status.getId() != 4) {
                schedule.setStorageSpace(storageSpace);
            }
            repo.save(schedule);
        }
    }

    public void delete(LineSchedule t) {
        repo.delete(t);
    }

}
