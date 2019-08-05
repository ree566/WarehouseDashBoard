/*
 * To change this license header, choose License Headers in Project Properties.
 * To change this template file, choose Tools | Templates
 * and open the template in the editor.
 */
package com.advantech.controller;

import com.advantech.model.LineScheduleStatus;
import com.advantech.service.LineScheduleStatusService;
import java.util.List;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Controller;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RequestMethod;
import org.springframework.web.bind.annotation.ResponseBody;

/**
 *
 * @author Wei.Cheng
 */
@Controller
@RequestMapping("/LineScheduleStatusController")
public class LineScheduleStatusController {

    @Autowired
    private LineScheduleStatusService lineScheduleStatusService;

    @ResponseBody
    @RequestMapping(value = "findAll", method = {RequestMethod.GET})
    protected List<LineScheduleStatus> findAll() {
        return lineScheduleStatusService.findAll();
    }

}
