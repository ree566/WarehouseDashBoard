/*
 * To change this license header, choose License Headers in Project Properties.
 * To change this template file, choose Tools | Templates
 * and open the template in the editor.
 */
package com.advantech.controller;

import com.advantech.model.Floor;
import com.advantech.model.StorageSpace;
import com.advantech.model.StorageSpaceGroup;
import com.advantech.service.StorageSpaceService;
import java.util.List;
import javax.servlet.http.HttpServletRequest;
import javax.validation.Valid;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Controller;
import org.springframework.web.bind.annotation.ModelAttribute;
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
public class StorageSpaceController {

    @Autowired
    private StorageSpaceService storageSpaceService;

    @ResponseBody
    @RequestMapping(value = "findAll", method = {RequestMethod.GET})
    protected List<StorageSpace> findAll() {
        return storageSpaceService.findAll();
    }
    
    @ResponseBody
    @RequestMapping(value = "findByFloor", method = {RequestMethod.GET})
    protected List<StorageSpace> findByFloor(@ModelAttribute Floor f) {
        return storageSpaceService.findByFloor(f);
    }

    @ResponseBody
    @RequestMapping(value = "findByStorageSpaceGroup", method = {RequestMethod.GET})
    protected List<StorageSpace> findByStorageSpaceGroup(
            @Valid @ModelAttribute StorageSpaceGroup storageSpaceGroup,
            HttpServletRequest request) {
        return storageSpaceService.findByStorageSpaceGroupOrderByName(storageSpaceGroup);
    }

}
