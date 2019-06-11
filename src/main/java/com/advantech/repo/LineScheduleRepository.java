/*
 * To change this license header, choose License Headers in Project Properties.
 * To change this template file, choose Tools | Templates
 * and open the template in the editor.
 */
package com.advantech.repo;

import com.advantech.model.LineSchedule;
import java.util.Date;
import org.springframework.data.jpa.datatables.repository.DataTablesRepository;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.stereotype.Repository;

/**
 *
 * @author Wei.Cheng
 */
@Repository
public interface LineScheduleRepository extends JpaRepository<LineSchedule, Integer>, DataTablesRepository<LineSchedule, Integer> {

    public LineSchedule findFirstByPoAndCreateDateBetween(String po, Date sD, Date eD);
}
