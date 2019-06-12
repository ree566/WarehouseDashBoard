/*
 * To change this license header, choose License Headers in Project Properties.
 * To change this template file, choose Tools | Templates
 * and open the template in the editor.
 */
package com.advantech.service;

import com.advantech.model.LineSchedule;
import com.advantech.model.LineScheduleStatus;
import com.advantech.repo.LineScheduleRepository;
import static com.google.common.base.Preconditions.checkState;
import java.util.Date;
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

    public LineSchedule findFirstByPoAndCreateDateBetween(String po, Date sD, Date eD) {
        return repo.findFirstByPoAndCreateDateBetween(po, sD, eD);
    }

    public <S extends LineSchedule> S save(S s) {
        LineScheduleStatus lineOperated = stateService.getOne(3);
        LineScheduleStatus onBoard = stateService.getOne(4);
        checkState(s.getLineScheduleStatus().getId() != onBoard.getId(), "This record is already onboard");
        s.setLineScheduleStatus(lineOperated);
        return repo.save(s);
    }

    public void updateStatus(String po, LineScheduleStatus status) {
        DateTime sD = new DateTime().withHourOfDay(0);
        DateTime eD = new DateTime().withHourOfDay(23);
        LineSchedule schedule = repo.findFirstByPoAndCreateDateBetween(po, sD.toDate(), eD.toDate());
//        checkState(schedule != null, "Can't find po " + po + " in schecule");
        if (schedule != null) {
            schedule.setLineScheduleStatus(status);
            repo.save(schedule);
        }
    }

    public void delete(LineSchedule t) {
        repo.delete(t);
    }

}
