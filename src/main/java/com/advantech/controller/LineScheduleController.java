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
import com.advantech.service.LineScheduleService;
import java.util.Date;
import javax.persistence.criteria.CriteriaBuilder;
import javax.persistence.criteria.CriteriaQuery;
import javax.persistence.criteria.Path;
import javax.persistence.criteria.Root;
import javax.servlet.http.HttpServletRequest;
import javax.validation.Valid;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.data.jpa.datatables.mapping.DataTablesInput;
import org.springframework.data.jpa.datatables.mapping.DataTablesOutput;
import org.springframework.http.ResponseEntity;
import org.springframework.stereotype.Controller;
import org.springframework.validation.BindingResult;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RequestMethod;
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

    @ResponseBody
    @RequestMapping(value = "findAll", method = {RequestMethod.GET})
    protected DataTablesOutput<LineSchedule> findAll(@Valid DataTablesInput input, HttpServletRequest request) throws Exception {
        if (request.isUserInRole("ROLE_ADMIN")) {
            return lineScheduleService.findAll(input);
        } else {
            User user = SecurityPropertiesUtils.retrieveAndCheckUserInSession();
            return lineScheduleService.findAll(input, (Root<LineSchedule> root, CriteriaQuery<?> cq, CriteriaBuilder cb) -> {
                Path<Floor> entryPath = root.get(LineSchedule_.FLOOR);
                return cb.equal(entryPath, user.getFloor());
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
