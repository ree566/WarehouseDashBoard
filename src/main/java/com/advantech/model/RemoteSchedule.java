/*
 * To change this license header, choose License Headers in Project Properties.
 * To change this template file, choose Tools | Templates
 * and open the template in the editor.
 */
package com.advantech.model;

import java.util.Date;

/**
 *
 * @author Wei.Cheng
 */
public interface RemoteSchedule {

    public String getFloorName();

    public String getPo();

    public String getModelName();

    public int getQuantity();

    public Date getOnDateTime();

    public Date getInputTime();
}
