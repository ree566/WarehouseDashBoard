/*
 * To change this license header, choose License Headers in Project Properties.
 * To change this template file, choose Tools | Templates
 * and open the template in the editor.
 */
package com.advantech.job;

import com.advantech.helper.WorkDateUtils;
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

    @Autowired
    private WorkDateUtils workDateUtils;

    @Transactional
    public void execute() {

        logger.info("Begin update unfinished schedule date to next day.");

        //Update lineSchedule to plus two days
        DateTime nextDay = workDateUtils.findNextDay();

        //Find today unfinished job and set date to nextDay
        LineScheduleStatus onboard = statusRepo.getOne(4);
        DateTime sD = new DateTime(nextDay).withTime(0, 0, 0, 0);
        DateTime eD = new DateTime(nextDay).withTime(23, 59, 0, 0);

        //Find un-finished po schedules
        List<LineSchedule> lineSchedules = lineScheduleRepo.findByLineScheduleStatusNotAndCreateDateBetween(onboard, sD.toDate(), eD.toDate());

        logger.info("Update " + lineSchedules.size() + " datas.");

        DateTime nextTargetDay = new DateTime(nextDay).plusDays(1);

        lineSchedules.forEach(s -> {
            s.setCreateDate(nextTargetDay.toDate());
        });

        lineScheduleRepo.saveAll(lineSchedules);

        logger.info("Update finish.");
    }

}
