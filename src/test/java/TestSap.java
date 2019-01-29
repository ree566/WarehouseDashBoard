/*
 * To change this license header, choose License Headers in Project Properties.
 * To change this template file, choose Tools | Templates
 * and open the template in the editor.
 */

import com.advantech.sap.SAPConn;
import com.sap.conn.jco.JCoDestination;
import com.sap.conn.jco.JCoException;
import com.sap.conn.jco.JCoFunction;
import com.sap.conn.jco.JCoParameterList;
import com.sap.conn.jco.JCoTable;
import static org.junit.Assert.assertNotNull;
import org.junit.Test;
import org.junit.runner.RunWith;
import org.springframework.test.context.junit4.SpringJUnit4ClassRunner;
import org.springframework.test.context.web.WebAppConfiguration;

/**
 *
 * @author Wei.Cheng
 */
@WebAppConfiguration
@RunWith(SpringJUnit4ClassRunner.class)
public class TestSap {

    @Test
    public void testWarehouse() {
        JCoFunction function;
        JCoDestination destination = SAPConn.connect();

        try {
            //调用ZCHENH001函数
            function = destination.getRepository().getFunction("ZGET_SAP_SODNWO_DATA_CK");

            assertNotNull(function);

            JCoParameterList input = function.getImportParameterList();

            input.setValue("WONO", "PNH1102ZA");
            input.setValue("SDATE", "");
            input.setValue("EDATE", "");
            input.setValue("SPFLG", "");
            input.setValue("PLANT", "TWM3");

            function.execute(destination);

            JCoTable table = function.getTableParameterList().getTable("ZWODETAIL");//调用接口返回结果

            for (int i = 0; i < table.getNumRows(); i++) {

                table.setRow(i);

                System.out.println(table.getString("AUFNR") + '\t' + table.getString("POSNR"));

            }
        } catch (JCoException e) {
            System.out.println(e);
        }

    }

}
