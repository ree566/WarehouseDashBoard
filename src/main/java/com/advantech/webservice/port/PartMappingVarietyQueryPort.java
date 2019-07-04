/*
 * To change this license header, choose License Headers in Project Properties.
 * To change this template file, choose Tools | Templates
 * and open the template in the editor.
 */
package com.advantech.webservice.port;

import com.advantech.webservice.root.PartMappingVarietyQueryRoot;
import com.advantech.webservice.unmarshallclass.PartMappingVariety;
import com.advantech.webservice.unmarshallclass.PartMappingVarietys;
import java.util.List;
import javax.xml.bind.JAXBException;
import org.slf4j.Logger;
import org.slf4j.LoggerFactory;
import org.springframework.stereotype.Component;

/**
 *
 * @author Wei.Cheng
 */
@Component
public class PartMappingVarietyQueryPort extends BasicQueryPort {

    private static final Logger logger = LoggerFactory.getLogger(PartMappingVarietyQueryPort.class);

    @Override
    protected void initJaxb() {
        try {
            super.initJaxb(PartMappingVarietyQueryRoot.class, PartMappingVarietys.class);
        } catch (JAXBException e) {
            logger.error(e.toString());
        }
    }

    @Override
    public List query(Object jaxbElement) throws Exception {
        return (List<PartMappingVariety>) super.query(jaxbElement);
    }

}
