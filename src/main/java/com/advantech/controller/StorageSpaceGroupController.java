/*
 * To change this license header, choose License Headers in Project Properties.
 * To change this template file, choose Tools | Templates
 * and open the template in the editor.
 */
package com.advantech.controller;

import com.advantech.helper.SecurityPropertiesUtils;
import com.advantech.model.Floor;
import com.advantech.model.StorageSpaceGroup;
import com.advantech.model.User;
import com.advantech.service.FloorService;
import com.advantech.service.StorageSpaceGroupService;
import static com.google.common.base.Preconditions.checkArgument;
import java.util.List;
import javax.servlet.http.HttpServletRequest;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Controller;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RequestMethod;
import org.springframework.web.bind.annotation.RequestParam;
import org.springframework.web.bind.annotation.ResponseBody;

/**
 *
 * @author Wei.Cheng
 */
@Controller
@RequestMapping("/StorageSpaceGroupController")
public class StorageSpaceGroupController {

    @Autowired
    private StorageSpaceGroupService storageSpaceGroupService;

    @Autowired
    private FloorService floorService;

    @ResponseBody
    @RequestMapping(value = "findAll", method = {RequestMethod.GET})
    protected List<StorageSpaceGroup> findAll(
            @RequestParam(required = false) Integer floor_id,
            HttpServletRequest request) throws Exception {
        /*
                Re-assign default user's sitefloor location 
                when request param not contains "floor_id"
         */
        Floor f;
        if (floor_id == null) {
            User user = SecurityPropertiesUtils.retrieveAndCheckUserInSession();
            f = user.getFloor();
        } else {
            f = floorService.getOne(floor_id);
        }
        checkArgument(f != null, "No storageSpace in setting, please try again.");
        return storageSpaceGroupService.findByFloorOrderByName(f);

    }

}
