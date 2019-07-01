/*
 * To change this license header, choose License Headers in Project Properties.
 * To change this template file, choose Tools | Templates
 * and open the template in the editor.
 */
package com.advantech.helper;

import org.joda.time.DateTime;
import org.joda.time.DateTimeConstants;
import org.springframework.stereotype.Component;

/**
 *
 * @author Wei.Cheng
 */
@Component
public class WorkDateUtils {

    public DateTime findNextDay() {
        DateTime today = new DateTime();

        //Set nextDay to Monday when Friday
        int nextDayCnt = today.getDayOfWeek() == DateTimeConstants.FRIDAY ? 3 : 1;

        DateTime nextDay = new DateTime().plusDays(nextDayCnt).withTime(0, 0, 0, 0);

        return nextDay;
    }
}
