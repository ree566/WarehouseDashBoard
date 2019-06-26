<%-- 
    Document   : stomp-test
    Created on : 2019/6/12, 上午 11:10:04
    Author     : Wei.Cheng
--%>

<%@page contentType="text/html" pageEncoding="UTF-8"%>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core"%>
<!DOCTYPE html>
<html>
    <head>
        <title>Spring Boot簡單聊天室</title>
        <meta charset="utf-8"/>
        <link href="https://stackpath.bootstrapcdn.com/bootstrap/4.2.1/css/bootstrap.min.css" rel="stylesheet">
        <!--<link href="/main.css" rel="stylesheet">-->
        <script src="<c:url value="/libs/jQuery/jquery.js" />"></script> 
        <script src="https://stackpath.bootstrapcdn.com/bootstrap/4.2.1/js/bootstrap.min.js"></script>
        <script src="<c:url value="/libs/sockjs-client/sockjs.min.js" />"></script>
        <script src="<c:url value="/libs/stomp-websocket/stomp.min.js" />"></script>
        <script>
            var stompClient = null;
            var floor_id = ${param.floor_id};

            function setConnected(connected) {
                $("#connect").prop("disabled", connected); //將id = connect 按鈕屬性改為disabled
                $("#disconnect").prop("disabled", !connected);  //將id = disconnect 按鈕屬性改為disabled
                if (connected) {
                    $("#conversation").show();  //當連接上Websocket id = conversation 顯示
                } else {
                    $("#conversation").hide(); // 將 conversation隱藏
                }
                $("#chatRoom").html(""); //將chatRoom內容清空
            }
//連結WebSocket方法
            function connect() {
                var socket = new SockJS('/WarehouseDashBoard/endpointChatRoom'); //建立一個socket物件 名稱為:/endpointChatRoom
                stompClient = Stomp.over(socket);
                stompClient.connect({}, function (frame) {
                    setConnected(true);
                    console.log('Connected: ' + frame);
                    stompClient.subscribe('/topic/getResponse/' + floor_id, function (response) {
                        console.log(response);
                        showConversation(JSON.parse(response.body).responseMessage); //
                    });
                }, stompFailureCallback);
            }

            function stompFailureCallback(error) {
                console.log('STOMP: ' + error);
                setTimeout(connect, 10000);
                console.log('STOMP: Reconecting in 10 seconds');
            }

//關閉WebSocket方法
            function disconnect() {
                if (stompClient !== null) {
                    stompClient.disconnect();
                }
                setConnected(false);
                console.log("Disconnected");
            }

//傳送訊息方法
            function sendName() {
                var name = $("#name").val();
                console.log(name);
                console.log(stompClient);
                stompClient.send("/messageControl/" + floor_id, {}, JSON.stringify({'name': name}));
            }
//顯示接收回來的訊息方法
            function showConversation(responseMessage) {
                console.log("Receive message: " + responseMessage);
                $("#chatRoom").append("<tr><td>" + responseMessage + "</td></tr>");
            }

            $(function () {
                $("form").on('submit', function (e) {
                    e.preventDefault();
                });
                $("#connect").click(function () {
                    connect();
                });
                $("#disconnect").click(function () {
                    disconnect();
                });
                $("#send").click(function () {
                    sendName();
                });
            });
        </script>
    </head>
    <body>

        <div id="main-content" class="container">
            <div class="row">
                <div class="col-md-6">
                    <form class="form-inline">
                        <div class="form-group">
                            <label for="connect">WebSocket 連接:</label>
                            <button id="connect" class="btn btn-default" type="submit">連接</button>
                            <button id="disconnect" class="btn btn-default" type="submit" disabled="disabled">關閉連接
                            </button>
                        </div>
                    </form>
                </div>
                <div class="col-md-6">
                    <form class="form-inline">
                        <div class="form-group">
                            <label for="name">發送訊息</label>
                            <input type="text" id="name" class="form-control" placeholder="請輸入訊息">
                        </div>
                        <button id="send" class="btn btn-default" type="submit">發送</button>
                    </form>
                </div>
            </div>
            <div class="row">
                <div class="col-md-12">
                    <table id="conversation" class="table table-striped">
                        <thead>
                            <tr>
                                <th>小海的聊天室</th>
                            </tr>
                        </thead>
                        <tbody id="chatRoom">
                        </tbody>
                    </table>
                </div>
            </div>
        </div>
    </body>
</html>
