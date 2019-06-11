/*
 * To change this license header, choose License Headers in Project Properties.
 * To change this template file, choose Tools | Templates
 * and open the template in the editor.
 */
package com.advantech.controller;

import com.advantech.model.Floor;
import com.advantech.model.Line;
import com.advantech.service.LineService;
import java.util.List;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Controller;
import org.springframework.web.bind.annotation.ModelAttribute;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RequestMethod;
import org.springframework.web.bind.annotation.ResponseBody;

/**
 *
 * @author Wei.Cheng
 */
@Controller
@RequestMapping("/LineController")
public class LineController {

    @Autowired
    private LineService service;

    @ResponseBody
    @RequestMapping(value = "/find", method = {RequestMethod.GET})
    public List<Line> find(@ModelAttribute Floor floor) {
        return service.findByFloor(floor);
    }

}
