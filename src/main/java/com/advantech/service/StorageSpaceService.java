/*
 * To change this license header, choose License Headers in Project Properties.
 * To change this template file, choose Tools | Templates
 * and open the template in the editor.
 */
package com.advantech.service;

import com.advantech.model.Floor;
import com.advantech.model.StorageSpace;
import com.advantech.repo.StorageSpaceRepository;
import java.util.List;
import java.util.Optional;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

/**
 *
 * @author Wei.Cheng
 */
@Service
@Transactional
public class StorageSpaceService {

    @Autowired
    private StorageSpaceRepository repo;

    public List<StorageSpace> findAll() {
        return repo.findAll();
    }

    public Optional<StorageSpace> findById(Integer id) {
        return repo.findById(id);
    }

    public List<StorageSpace> findByFloor(Floor floor) {
        return repo.findByFloor(floor);
    }

}
