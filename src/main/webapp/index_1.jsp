<%-- 
    Document   : index
    Created on : 2019/1/2, 下午 03:47:44
    Author     : Wei.Cheng
--%>

<%@page contentType="text/html" pageEncoding="UTF-8"%>
<!DOCTYPE html>
<html lang="en">
    <head>
        <meta charset="utf-8">
        <meta http-equiv="X-UA-Compatible" content="IE=edge">
        <meta name="viewport" content="width=device-width, initial-scale=1">
        <meta name="description" content="">
        <meta name="author" content="">
        <link rel="icon" href="../../favicon.ico">

        <title>ws-test-page</title>
        <!-- Bootstrap core CSS -->
        <link href="https://stackpath.bootstrapcdn.com/bootstrap/4.2.1/css/bootstrap.min.css" rel="stylesheet">

        <!-- Custom styles for this template -->
        <link href="jumbotron-narrow.css" rel="stylesheet">

        <script src="https://code.jquery.com/jquery-3.3.1.min.js"></script>
        <script src="https://stackpath.bootstrapcdn.com/bootstrap/4.2.1/js/bootstrap.min.js"></script>

        <!-- Just for debugging purposes. Don't actually copy these 2 lines! -->
        <!--[if lt IE 9]>
        <script src="./assets/bootstrap/js/ie8-responsive-file-warning.js"></script><![endif]-->
        <script src="bootstrap/js/ie-emulation-modes-warning.js"></script>

        <!-- IE10 viewport hack for Surface/desktop Windows 8 bug -->
        <script src="bootstrap/js/ie10-viewport-bug-workaround.js"></script>


        <!-- HTML5 shim and Respond.js IE8 support of HTML5 elements and media queries -->
        <!--[if lt IE 9]>
        <script src="https://oss.maxcdn.com/html5shiv/3.7.2/html5shiv.min.js"></script>
        <script src="https://oss.maxcdn.com/respond/1.4.2/respond.min.js"></script>
        <![endif]-->

        <script>
            $(function () {

                var ws;
                function connectToServer() {
                    var icon = $("#connection_error_icon");

                    try {
                        ws = new WebSocket($("#serverSelected").val());

                        ws.onopen = function () {
                            $("#connectionStatus").html("Connected");
                        };
                        ws.onmessage = function (event) {
                            console.log(event);
                            $("#responseFromServer").val(event.data);
                        };
                        ws.onclose = function () {
                            $("#connectionStatus").html("Disconnected");
                        };
                        icon.hide();
                        icon.attr("title", '');
                    } catch (e) {
                        icon.show();
                        icon.attr("title", e.message);
                    }


                }
                function disconnectToServer() {
                    ws.close();
                }
                function sendMessage() {
                    var icon = $("#error_icon");
                    try {
                        ws.send($("#msgToServer").val());
                        icon.hide();
                        icon.attr("title", '');
                    } catch (e) {
                        icon.show();
                        icon.attr("title", e.message);
                        console.log(e);
                    }
                }
                
                $("#sendMessage").click(sendMessage);
                $("#connectToServer").click(connectToServer);
                $("#disconnectToServer").click(disconnectToServer);
            });
        </script>
    </head>

    <body>

        <div class="container">
            <div class="header">
                <h3 class="text-muted">WS Test Page Client</h3>
            </div>

            <div class="jumbotron_">
                <form class="form-horizontal">
                    <div class="form-group">
                        <label for="serverSelected" class="col-sm-1 control-label">URL:</label>
                        <div class="col-sm-7">
                            <input type="text" id="serverSelected" class="form-control" placeholder="ws://domain/path"/>

                        </div>
                        <div class="col-sm-1" style="margin-right: 10px;">
                            <button type="button" class="btn btn-sm btn-primary" id="connectToServer">
                                Connect
                            </button>
                        </div>
                        <div class="col-sm-1">
                            <button type="button" class="btn btn-sm btn-danger" id="disconnectToServer">
                                Disconnect
                            </button>
                        </div>
                    </div>
                </form>

            </div>
            <!-- /.row -->
            <div class="input-group">
                Connection Status:
                <span id="connectionStatus">
                    Disconnected
                </span>
                <span class="glyphicon glyphicon-exclamation-sign" aria-hidden="true" id="connection_error_icon" style="color:#c9302c; visibility: hidden"></span>
            </div>
            <!-- /.row -->

            <textarea id="msgToServer" style="width: 700px; height: 300px" placeholder="Put your Message Here"></textarea>

            <button type="button" class="btn btn-sm btn-success" id="sendMessage">
                Send Message
            </button>
            <span class="glyphicon glyphicon-exclamation-sign" aria-hidden="true" id="error_icon" style="color:#c9302c; visibility: hidden"></span>

            <br><br>
            <textarea id="responseFromServer" placeholder="Response From Server" style="width: 700px; height: 300px"
                      readonly>
            </textarea>

        </div>
        <!-- /container -->
    </body>
</html>

