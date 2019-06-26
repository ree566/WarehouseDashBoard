/*
 * To change this license header, choose License Headers in Project Properties.
 * To change this template file, choose Tools | Templates
 * and open the template in the editor.
 */
package com.advantech.controller;

import com.advantech.helper.SecurityPropertiesUtils;
import com.advantech.model.Floor;
import com.advantech.model.LineSchedule;
import com.advantech.model.LineSchedule_;
import com.advantech.model.User;
import com.advantech.service.FloorService;
import com.advantech.service.LineScheduleService;
import java.util.Date;
import javax.persistence.criteria.CriteriaBuilder;
import javax.persistence.criteria.CriteriaQuery;
import javax.persistence.criteria.Path;
import javax.persistence.criteria.Root;
import javax.servlet.http.HttpServletRequest;
import javax.validation.Valid;
import org.joda.time.DateTime;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.data.jpa.datatables.mapping.DataTablesInput;
import org.springframework.data.jpa.datatables.mapping.DataTablesOutput;
import org.springframework.http.ResponseEntity;
import org.springframework.stereotype.Controller;
import org.springframework.validation.BindingResult;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RequestMethod;
import org.springframework.web.bind.annotation.RequestParam;
import org.springframework.web.bind.annotation.ResponseBody;

/**
 *
 * @author Wei.Cheng
 */
@Controller
@RequestMapping("/LineScheduleController")
public class LineScheduleController extends CrudController<LineSchedule> {

    @Autowired
    private LineScheduleService lineScheduleService;

    @Autowired
    private FloorService floorService;

    @ResponseBody
    @RequestMapping(value = "findAll", method = {RequestMethod.GET})
    protected DataTablesOutput<LineSchedule> findAll(
            @Valid DataTablesInput input,
            @RequestParam(required = false) Integer floor_id,
            HttpServletRequest request) throws Exception {
        DateTime tomorrow = new DateTime().plusDays(1).withTime(0, 0, 0, 0);
        if (request.isUserInRole("ROLE_ADMIN")) {
            return lineScheduleService.findAll(input, (Root<LineSchedule> root, CriteriaQuery<?> cq, CriteriaBuilder cb) -> {
                Path<Date> datePath = root.get(LineSchedule_.CREATE_DATE);
                return cb.equal(datePath, tomorrow.toDate());
            });
        } else {
            Floor f;
            if (floor_id == null) {
                User user = SecurityPropertiesUtils.retrieveAndCheckUserInSession();
                f = user.getFloor();
            } else {
                f = floorService.getOne(floor_id);
            }
            return lineScheduleService.findAll(input, (Root<LineSchedule> root, CriteriaQuery<?> cq, CriteriaBuilder cb) -> {
                Path<Floor> entryPath = root.get(LineSchedule_.FLOOR);
                Path<Date> datePath = root.get(LineSchedule_.CREATE_DATE);
                return cb.and(cb.equal(entryPath, f), cb.equal(datePath, tomorrow.toDate()));
            });
        }
    }

    @Override
    @ResponseBody
    @RequestMapping(value = INSERT_URL, method = {RequestMethod.POST})
    protected ResponseEntity insert(LineSchedule pojo, BindingResult bindingResult) throws Exception {
        lineScheduleService.save(pojo);
        return serverResponse(SUCCESS_MESSAGE);
    }

    @Override
    @ResponseBody
    @RequestMapping(value = UPDATE_URL, method = {RequestMethod.POST})
    protected ResponseEntity update(LineSchedule pojo, BindingResult bindingResult) throws Exception {
        lineScheduleService.save(pojo);
        return serverResponse(SUCCESS_MESSAGE);
    }

    @Override
    @ResponseBody
    @RequestMapping(value = DELETE_URL, method = {RequestMethod.POST})
    protected ResponseEntity delete(int id) throws Exception {
        LineSchedule pojo = this.lineScheduleService.getOne(id);
        lineScheduleService.delete(pojo);
        return serverResponse(SUCCESS_MESSAGE);
    }

}
