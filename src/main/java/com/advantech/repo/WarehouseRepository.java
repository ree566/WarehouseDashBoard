/*
 * To change this license header, choose License Headers in Project Properties.
 * To change this template file, choose Tools | Templates
 * and open the template in the editor.
 */
package com.advantech.repo;

import com.advantech.model.Floor;
import com.advantech.model.Warehouse;
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
public interface WarehouseRepository extends JpaRepository<Warehouse, Integer> {

    @Query("select w from Warehouse w join w.storageSpace sp where sp.floor = :floor and w.flag = :flag")
    public List<Warehouse> findByFloorAndFlag(@Param("floor") Floor floor,@Param("flag") int flag);
}
