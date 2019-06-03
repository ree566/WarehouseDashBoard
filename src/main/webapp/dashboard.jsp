<%-- 
    Document   : index
    Created on : 2019/1/2, 下午 03:47:44
    Author     : Wei.Cheng
--%>

<%@page contentType="text/html" pageEncoding="UTF-8"%>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core"%>
<c:if test="${param.floor_id == null}">
    <c:redirect url="" />
</c:if>
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
        <script src="https://code.jquery.com/ui/1.12.0/jquery-ui.min.js"></script>

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

        <script src="libs/jsog/JSOG.js"></script>

        <style>
            #dashboard >  .po-list{
                border: 1px solid;
            }

            .po{
                border-bottom: 2px solid red;
            }

            span.highlight {
                background: red
            }
            #mapGroup{
                width: 90%;
                height: 500px;
                background-image: url(images/totalMap_5f.png);
                background-repeat: no-repeat;
                -o-background-size: 100% 100%, auto;
                -moz-background-size: 100% 100%, auto;
                -webkit-background-size: 100% 100%, auto;
                background-size: 100% 100%, auto;
                background-position:center center;
                border:1px red solid;
                /*讓最外層div不要隨視窗變動而改變(不然裏頭的子div會跑掉)*/
                position: absolute; 
            }
            .draggable { 
                width: 25px; 
                height: 25px; 
                padding: 0.3em; 
                float: left;
                /*background-color: red;*/
                margin: 0px;
                cursor: default;
                text-align: center;
                background-color: white;
            }
            .ui-helper {
                /*width: 100% !important;*/
                float: left;
            }
            .adjustPosition{
                position: absolute;
            }
            .row>div{
                border:1px black solid;
            }
        </style>

        <script>
            $(function () {
                var po = $(".po").detach();
                var area_select = $("#area-select");
                var dashboard = $("#dashboard>div");
                var floor_id = ${param.floor_id};

                function setStorageSpace() {
                    $.ajax({
                        type: "GET",
                        url: "<c:url value="/StorageSpaceController/findAll" />",
                        data: {
                            floor_id: floor_id
                        },
                        dataType: "json",
                        success: function (response) {
                            var areas = response;
                            for (var i = 0; i < areas.length; i++) {
                                var str = areas[i];
                                area_select.append("<option value='" + str.id + "'>" + str.name + "</option>");
                                dashboard.append("<div id='STORAGE_" + str.id + "' class='col-3 po-list' data-toggle='" + str.name + "'><label for='" + str.name + "'>" + str.name +
                                        "</label><div id='po_content_" + str.id + "' class='po_content'></div></div>");
                            }
                            getWarehouse();

                            initHintCoverGroup(areas);
                        },
                        error: function (xhr, ajaxOptions, thrownError) {
                            showMsg(xhr.responseText);
                        }
                    });
                }

                function initHintCoverGroup(data) {
                    var areas = [
                        {x: 1000, y: 105, name: "A1"}, // group 1-4
                        {x: 1000, y: 145, name: "A2"}, // group 1-4
                        {x: 1000, y: 185, name: "A3"}, // group 1-4
                        {x: 1000, y: 225, name: "A4"}, // group 1-4
                        {x: 1000, y: 265, name: "A5"}, // group 1-4
                        {x: 1000, y: 305, name: "A6"}, // group 1-4
                        {x: 70, y: 400, name: "A7"}, // group 1-4
                        {x: 170, y: 400, name: "A8"} // group 1-4
                    ];
                    for (var i = 0; i < areas.length; i++) {
                        var area = areas[i];
                        $("#hintCoverArea")
                                .append("<div></div>");
                        $("#hintCoverArea>div")
                                .eq(i)
                                .addClass("wiget draggable blub-empty divCustomBg")
                                .attr("id", area.name)
                                .css({left: area.x, top: area.y})
                                .html(area.name);
                    }

                    $(".draggable").addClass("ui-helper adjustPosition").draggable({
                        drag: function (e) {

                        }
                    });



                    $(".po-list").hover(debounce(function () {
                        var toggleTarget = $(this).attr("data-toggle");
                        var targetHint = $('#' + toggleTarget);
                        targetHint.fadeOut(500).delay(100).fadeIn(500);
                    }, 250));
                }

                function debounce(func, wait, immediate) {
                    var timeout;
                    return function () {
                        var context = this, args = arguments;
                        var later = function () {
                            timeout = null;
                            if (!immediate)
                                func.apply(context, args);
                        };
                        var callNow = immediate && !timeout;
                        clearTimeout(timeout);
                        timeout = setTimeout(later, wait);
                        if (callNow)
                            func.apply(context, args);
                    };
                }

                function getWarehouse() {
                    $.ajax({
                        type: "GET",
                        url: "<c:url value="/WarehouseController/findAll" />",
                        data: {
                            floor_id: floor_id
                        },
                        dataType: "json",
                        success: function (response) {
                            var data = JSOG.decode(response);

                            for (var i = 0; i < data.length; i++) {
                                var d = data[i];
                                var clone_po = po.clone();
                                clone_po.find(".name").html(d.po);
                                clone_po.find(".data-id").val(d.id);
                                $("#po_content_" + d.storageSpace.id).append(clone_po);
                            }
                        },
                        error: function (xhr, ajaxOptions, thrownError) {
                            showMsg(xhr.responseText);
                        }
                    });
                }

                function refreshTable() {
                    $(".po_content").html("");
                    getWarehouse();
                }

                $("#add-po").click(function () {
                    var text = $("#po").val();
                    var area_selected = $("#area-select :selected").val();
                    $.ajax({
                        type: "POST",
                        url: "<c:url value="/WarehouseController/create" />",
                        data: {
                            po: text,
                            "storageSpace.id": area_selected
                        },
                        dataType: "html",
                        success: function (response) {
                            ws.send("ADD");
                        },
                        error: function (xhr, ajaxOptions, thrownError) {
                            console.log(xhr.responseText);
                        }
                    });

                });

                $(document).on("click", ".pull-out", function () {
                    var data_id = $(this).parents(".po").find(".data-id").val();
                    $.ajax({
                        type: "POST",
                        url: "<c:url value="/WarehouseController/delete" />",
                        data: {
                            id: data_id
                        },
                        dataType: "html",
                        success: function (response) {
                            ws.send("REMOVE");
                        },
                        error: function (xhr, ajaxOptions, thrownError) {
                            console.log(xhr.responseText);
                        }
                    });
                });

                $("#po, #po_search").on("keyup change", function () {
                    $(this).val($(this).val().toUpperCase());
                });

                $("#po_search").keyup(function () {
                    var mysearchword = this.value.trim();
                    $('.po > .name').each(function () {
                        $(this).find('span.highlight').contents().unwrap();
                        if (mysearchword) {
                            var re = new RegExp('(' + mysearchword.trim().split(/\s+/).join('|') + ')', "gi");
                            $(this).html(function (i, html) {
                                return html.replace(re, '<span class="highlight">$1</span>');
                            });
                        }
                    });
                });

                $("#clear_search").click(function () {
                    var search = $("#po_search");
                    search.val("");
                    search.trigger("keyup");
                });

                $('input').keypress(function (e) {
                    if (e.which == 13) {
                        $("#add-po").trigger("click");
                    }
                });

                var ws;
                var hostname = window.location.host;//Get the host ipaddress to link to the server.
                function connectToServer() {

                    try {
                        ws = new WebSocket("ws://" + hostname + "/WarehouseDashBoard/myHandler");

                        ws.onopen = function () {
                            $("#connectionStatus").html("Connected");
                        };
                        ws.onmessage = function (event) {
                            var d = event.data;
                            d = d.replace(/\"/g, "");
                            console.log(d);
                            if ("ADD" == d || "REMOVE" == d) {
                                refreshTable();
                            }
                        };
                        ws.onclose = function () {
                            $("#connectionStatus").html("Disconnected");
                        };
                    } catch (e) {
                        console.log(e);
                    }


                }
                function disconnectToServer() {
                    ws.close();
                }

                connectToServer();
                if (ws != null) {
                    setStorageSpace();
                }
            });
        </script>
    </head>

    <body>

        <div class="container-fluid">
            <div class="header row">
                <h3 class="text-muted">WS Test Page Client</h3>
            </div>
            <div class="row">
                <div class="col-md-8">
                    <div class="row">
                        <div class="col-12">
                            <div id="connectionStatus">Disconnected</div>
                        </div>

                        <div class="po col">
                            <div class="name"></div>
                            <input type="hidden" value="" class="data-id">
                            <div class="widget">
                                <input type="button" class="pull-out" value="Pull out" />
                            </div>
                        </div>

                        <div class="input-area col">
                            <table>
                                <tr>
                                    <td>
                                        <label>Area select</label>
                                    </td>
                                    <td>
                                        <select id="area-select"></select>
                                    </td>
                                </tr>
                                <tr>
                                    <td>
                                        <label>Po insert</label>
                                    </td>
                                    <td>
                                        <input type="text" id="po" placeholder="please insert your po" />
                                        <input type="button" value="submit" id="add-po" />
                                    </td>
                                </tr>
                                <tr>
                                    <td>
                                        <label>Po search</label>
                                    </td>
                                    <td>
                                        <input type="text" id="po_search" placeholder="please insert your search" />
                                        <input type="button" id="clear_search" value="Clear search" />
                                    </td>
                                </tr>
                            </table>
                        </div>

                        <div id="dashboard" class="col-12">
                            <div class="row"></div>
                        </div>
                        <div id="totalMap-area" class="col-12">
                            <div class="row">
                                <div id="mapGroup">
                                    <div id="wigetInfo">
                                        <div id="hintCoverArea"></div>
                                    </div>
                                </div>
                            </div>
                        </div>
                    </div>
                </div>
                <div class="col-md-4">
                    <div class="row">
                        <iframe src="<c:url value="/poDashboard.jsp" />" frameborder="0" width="100%" height="700" />
                    </div>
                </div>
            </div>
        </div>
        <!-- /container -->
    </body>
</html>

