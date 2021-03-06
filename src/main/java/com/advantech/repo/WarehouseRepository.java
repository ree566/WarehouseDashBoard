/*
 * To change this license header, choose License Headers in Project Properties.
 * To change this template file, choose Tools | Templates
 * and open the template in the editor.
 */
package com.advantech.repo;

import com.advantech.model.Floor;
import com.advantech.model.StorageSpaceGroup;
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

    /**
     * Flag 0: in warehouse wait for pull out Flag 1: Already pull out
     *
     * @param flag
     * @return
     */
    public List<Warehouse> findByFlag(int flag);

    @Query("select w from Warehouse w join w.storageSpace sp join sp.storageSpaceGroup g where g.floor = :floor and w.flag = :flag")
    public List<Warehouse> findByFloorAndFlag(@Param("floor") Floor floor, @Param("flag") int flag);

    @Query("select w from Warehouse w join w.storageSpace sp join sp.storageSpaceGroup g where g.floor = :floor and w.po = :po and w.flag = :flag")
    public List<Warehouse> findByPoAndFloorAndFlag(@Param("po") String po, @Param("floor") Floor floor, @Param("flag") int flag);

    @Query("select w from Warehouse w join w.storageSpace sp join sp.storageSpaceGroup g where sp.storageSpaceGroup = :storageSpaceGroup and w.flag = :flag")
    public List<Warehouse> findByStorageSpaceGroupAndFlag(@Param("storageSpaceGroup") StorageSpaceGroup storageSpaceGroup, @Param("flag") int flag);
}
