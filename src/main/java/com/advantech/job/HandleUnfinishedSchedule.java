/*
 * To change this license header, choose License Headers in Project Properties.
 * To change this template file, choose Tools | Templates
 * and open the template in the editor.
 */
package com.advantech.job;

import com.advantech.model.LineSchedule;
import com.advantech.model.LineScheduleStatus;
import com.advantech.repo.LineScheduleRepository;
import com.advantech.repo.LineScheduleStatusRepository;
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
public class HandleUnfinishedSchedule {

    private static final Logger logger = LoggerFactory.getLogger(HandleUnfinishedSchedule.class);

    @Autowired
    private LineScheduleRepository lineScheduleRepo;

    @Autowired
    private LineScheduleStatusRepository statusRepo;

    @Transactional
    public void execute() {

        LineScheduleStatus defaultStatus = statusRepo.getOne(1);
        DateTime sD = new DateTime().withHourOfDay(0).withMinuteOfHour(0);
        DateTime eD = new DateTime().withHourOfDay(23).withMinuteOfHour(59);

        //Find un-finished po schedules
        List<LineSchedule> lineSchedules = lineScheduleRepo.findByLineScheduleStatusAndCreateDateBetween(defaultStatus, sD.toDate(), eD.toDate());

        lineSchedules.forEach(s -> {
            s.setCreateDate(new DateTime(s.getCreateDate()).plusDays(1).toDate());
        });

        lineScheduleRepo.saveAll(lineSchedules);
    }

}
