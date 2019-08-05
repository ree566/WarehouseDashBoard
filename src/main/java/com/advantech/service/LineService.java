/*
 * To change this license header, choose License Headers in Project Properties.
 * To change this template file, choose Tools | Templates
 * and open the template in the editor.
 */
package com.advantech.service;

import com.advantech.model.Floor;
import com.advantech.model.Line;
import com.advantech.repo.LineRepository;
import java.util.List;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

/**
 *
 * @author Wei.Cheng
 */
@Service
@Transactional
public class LineService {

    @Autowired
    private LineRepository repo;

    public List<Line> findByFloor(Floor floor) {
        return repo.findByFloor(floor);
    }

    public Line getOne(Integer id) {
        return repo.getOne(id);
    }

}
