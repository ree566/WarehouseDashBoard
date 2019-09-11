/*
 * To change this license header, choose License Headers in Project Properties.
 * To change this template file, choose Tools | Templates
 * and open the template in the editor.
 */
package com.advantech.job;

import com.advantech.helper.WorkDateUtils;
import com.advantech.model.Line;
import com.advantech.model.LineSchedule;
import com.advantech.model.LineScheduleStatus;
import com.advantech.repo.LineRepository;
import com.advantech.repo.LineScheduleRepository;
import com.advantech.repo.LineScheduleStatusRepository;
import static com.google.common.collect.Lists.newArrayList;
import java.util.ArrayList;
import java.util.List;
import java.util.Objects;
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

    @Autowired
    private LineRepository lineRepo;

    @Transactional
    public void execute() {

        LineScheduleStatus onboard = statusRepo.getOne(4);

        //Auto update status to onBoard when user set data to spec line
        List lineIds = newArrayList(29, 30, 31, 32);
        List<Line> lines = lineRepo.findAllById(lineIds);

        List<LineSchedule> needUpdateSchedule = new ArrayList();

        lines.forEach(l -> {
            List<LineSchedule> lineSchedules = lineScheduleRepo.findByLine(l);
            lineSchedules.forEach(sche -> {
                if (Objects.equals(sche.getLineScheduleStatus(), onboard)) {
                    sche.setLineScheduleStatus(onboard);
                    needUpdateSchedule.add(sche);
                }
            });

        });

        if (!needUpdateSchedule.isEmpty()) {
            logger.info("Update " + needUpdateSchedule.size() + " datas.");
            lineScheduleRepo.saveAll(needUpdateSchedule);
            logger.info("Update finish.");
        }
    }

}
