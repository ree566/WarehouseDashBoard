/*
 * To change this license header, choose License Headers in Project Properties.
 * To change this template file, choose Tools | Templates
 * and open the template in the editor.
 */

import com.advantech.model.Floor;
import com.advantech.service.FloorService;
import com.advantech.service.LineScheduleService;
import java.util.List;
import static org.junit.Assert.assertEquals;
import org.junit.Test;
import org.junit.runner.RunWith;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.data.jpa.datatables.mapping.DataTablesInput;
import org.springframework.test.annotation.Rollback;
import org.springframework.test.context.ContextConfiguration;
import org.springframework.test.context.junit4.SpringJUnit4ClassRunner;
import org.springframework.test.context.web.WebAppConfiguration;
import org.springframework.transaction.annotation.Transactional;

/**
 *
 * @author Wei.Cheng
 */
@WebAppConfiguration
@ContextConfiguration(locations = {
    "classpath:servlet-context.xml"
})
@RunWith(SpringJUnit4ClassRunner.class)
public class TestService {
    
    @Autowired
    private LineScheduleService lineScheduleService;
    
    @Autowired
    private FloorService floorService;
    
    @Test
    @Transactional
    @Rollback(true)
    public void testUserNotification() {
        Floor f = floorService.getOne(1);
        DataTablesInput input = new DataTablesInput();
        input.setLength(-1);
        List l = lineScheduleService.findSchedule(input, f).getData();
        assertEquals(74, l.size());
        
    }
    
}
