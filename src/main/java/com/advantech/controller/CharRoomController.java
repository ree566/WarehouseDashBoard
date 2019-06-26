/*
 * To change this license header, choose License Headers in Project Properties.
 * To change this template file, choose Tools | Templates
 * and open the template in the editor.
 */
package com.advantech.controller;

import com.advantech.websocket.ChatClientModel;
import com.advantech.websocket.ServerResponseModel;
import org.springframework.messaging.handler.annotation.DestinationVariable;
import org.springframework.messaging.handler.annotation.MessageMapping;
import org.springframework.messaging.handler.annotation.SendTo;
import org.springframework.stereotype.Controller;

/**
 *
 * @author Wei.Cheng
 * https://stackoverflow.com/questions/27047310/path-variables-in-spring-websockets-sendto-mapping
 */
@Controller
public class CharRoomController {

    @MessageMapping("/messageControl/{floorId}")
    @SendTo("/topic/getResponse/{floorId}")
    public ServerResponseModel said(ChatClientModel responseMessage, @DestinationVariable String floorId) throws InterruptedException {
        Thread.sleep(3000);
        System.out.println(responseMessage.getName());
        return new ServerResponseModel("歡迎來到," + responseMessage.getName());
    }
}
