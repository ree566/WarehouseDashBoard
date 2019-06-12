/*
 * To change this license header, choose License Headers in Project Properties.
 * To change this template file, choose Tools | Templates
 * and open the template in the editor.
 */
package com.advantech.job;

import com.advantech.model.LineSchedule;
import com.advantech.model.RemoteSchedule;
import com.advantech.repo.LineScheduleRepository;
import java.util.ArrayList;
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

    @Transactional
    public void execute() {
        DateTime tomorrow = new DateTime().plusDays(1).withHourOfDay(0).withMinuteOfHour(0).withSecondOfMinute(0);
        List<RemoteSchedule> remoteSchedules = lineScheduleRepo.getPrepareSchedule(tomorrow.toDate());
        List<LineSchedule> lineSchedules = new ArrayList();
        
    }

   
}
