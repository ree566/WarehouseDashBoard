/*
 * To change this license header, choose License Headers in Project Properties.
 * To change this template file, choose Tools | Templates
 * and open the template in the editor.
 */
package com.advantech.repo;

import com.advantech.model.Floor;
import com.advantech.model.Line;
import com.advantech.model.LineSchedule;
import com.advantech.model.LineScheduleStatus;
import com.advantech.model.RemoteSchedule;
import java.util.Date;
import java.util.List;
import org.springframework.data.jpa.datatables.repository.DataTablesRepository;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.data.jpa.repository.Query;
import org.springframework.data.repository.query.Param;
import org.springframework.stereotype.Repository;

/**
 *
 * @author Wei.Cheng
 */
@Repository
public interface LineScheduleRepository extends JpaRepository<LineSchedule, Integer>, DataTablesRepository<LineSchedule, Integer> {

    public LineSchedule findFirstByPoAndLineScheduleStatusNot(String po, LineScheduleStatus status);

    public LineSchedule findFirstByPoAndFloorAndOnBoardDateBetweenAndLineScheduleStatusNot(String po, Floor f, Date sD, Date eD, LineScheduleStatus status);

    @Query(value = "{CALL usp_GetPrepareSchedule(:sD)}", nativeQuery = true)
    public List<RemoteSchedule> getPrepareSchedule(@Param("sD") Date sD);

    public List<LineSchedule> findByOnBoardDateBetween(Date sD, Date eD);

    public List<LineSchedule> findByLineScheduleStatusAndOnBoardDateBetween(LineScheduleStatus status, Date sD, Date eD);

    public List<LineSchedule> findByLineScheduleStatusNotAndOnBoardDateBetween(LineScheduleStatus status, Date sD, Date eD);

    public List<LineSchedule> findByLineAndOnBoardDateBetweenAndLineScheduleStatusNot(Line line, Date sD, Date eD, LineScheduleStatus status);

    public List<LineSchedule> findByLineAndOnBoardDateBetweenAndLineScheduleStatusNotAndLineSchedulePriorityOrderNotNull(Line line, Date sD, Date eD, LineScheduleStatus status);
}
