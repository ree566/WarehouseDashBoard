
import org.joda.time.DateTime;
import org.joda.time.DateTimeConstants;
import org.junit.Test;
import org.junit.runner.RunWith;
import org.springframework.test.context.ContextConfiguration;
import org.springframework.test.context.junit4.SpringJUnit4ClassRunner;
import org.springframework.test.context.web.WebAppConfiguration;

/*
 * To change this license header, choose License Headers in Project Properties.
 * To change this template file, choose Tools | Templates
 * and open the template in the editor.
 */
/**
 *
 * @author Wei.Cheng
 */
@WebAppConfiguration
@ContextConfiguration(locations = { //    "classpath:servlet-context.xml"
})
@RunWith(SpringJUnit4ClassRunner.class)
public class TestClass {
    
    @Test
    public void testSyncData() {
        DateTime lastDayOfPrevWeek = new DateTime().minusWeeks(1).withDayOfWeek(DateTimeConstants.SATURDAY);
        DateTime sDOW = new DateTime(lastDayOfPrevWeek).minusWeeks(4).withTime(0, 0, 0, 0);
        DateTime eDOW = new DateTime(lastDayOfPrevWeek).withTime(23, 0, 0, 0);
        System.out.println(sDOW);
        System.out.println(eDOW);
    }
}
