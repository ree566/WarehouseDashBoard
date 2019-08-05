/*
 * To change this license header, choose License Headers in Project Properties.
 * To change this template file, choose Tools | Templates
 * and open the template in the editor.
 */
package com.advantech.repo;

import com.advantech.model.Floor;
import com.advantech.model.StorageSpace;
import com.advantech.model.StorageSpaceGroup;
import java.util.List;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.data.jpa.repository.Query;
import org.springframework.data.repository.query.Param;
import org.springframework.stereotype.Repository;

/**
 *
 * @author Wei.Cheng
 */
@Repository
public interface StorageSpaceRepository extends JpaRepository<StorageSpace, Integer> {
    
    @Query("select s from StorageSpace s join s.storageSpaceGroup sg where sg.floor = :floor")
    public List<StorageSpace> findByFloor(@Param("floor") Floor f);
    
    public List<StorageSpace> findByStorageSpaceGroupOrderByName(StorageSpaceGroup group);
    
}
