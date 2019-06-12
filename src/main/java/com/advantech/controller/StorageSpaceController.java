/*
 * To change this license header, choose License Headers in Project Properties.
 * To change this template file, choose Tools | Templates
 * and open the template in the editor.
 */
package com.advantech.controller;

import com.advantech.helper.SecurityPropertiesUtils;
import com.advantech.model.Floor;
import com.advantech.model.StorageSpace;
import com.advantech.model.User;
import com.advantech.model.Warehouse;
import com.advantech.service.FloorService;
import com.advantech.service.StorageSpaceService;
import static com.google.common.base.Preconditions.checkArgument;
import java.util.List;
import javax.servlet.http.HttpServletRequest;
import org.springframework.beans.factory.annotation.Autowired;
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
@RequestMapping("/StorageSpaceController")
public class StorageSpaceController extends CrudController<Warehouse> {

    @Autowired
    private StorageSpaceService storageSpaceService;

    @ResponseBody
    @RequestMapping(value = "findAll", method = {RequestMethod.GET})
    protected List<StorageSpace> findAll(HttpServletRequest request) throws Exception {
        if (request.isUserInRole("ROLE_ADMIN")) {
            return storageSpaceService.findAll();
        } else {
            User user = SecurityPropertiesUtils.retrieveAndCheckUserInSession();
            Floor f = user.getFloor();
            checkArgument(f != null, "No storageSpace in setting, please try again.");
            return storageSpaceService.findByFloor(f);
        }
    }

    @Override
    @ResponseBody
    @RequestMapping(value = INSERT_URL, method = {RequestMethod.POST})
    protected ResponseEntity insert(Warehouse pojo, BindingResult bindingResult) throws Exception {
        throw new UnsupportedOperationException();
    }

    @Override
    @ResponseBody
    @RequestMapping(value = UPDATE_URL, method = {RequestMethod.POST})
    protected ResponseEntity update(Warehouse pojo, BindingResult bindingResult) throws Exception {
        throw new UnsupportedOperationException();
    }

    @Override
    @ResponseBody
    @RequestMapping(value = DELETE_URL, method = {RequestMethod.POST})
    protected ResponseEntity delete(int id) throws Exception {
        throw new UnsupportedOperationException("Not supported yet."); //To change body of generated methods, choose Tools | Templates.
    }

}
