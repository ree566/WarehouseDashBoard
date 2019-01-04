<%-- 
    Document   : index
    Created on : 2019/1/2, 下午 03:47:44
    Author     : Wei.Cheng
--%>

<%@page contentType="text/html" pageEncoding="UTF-8"%>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core"%>
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

        <script src="js/JSOG.js"></script>

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
        </style>

        <script>
            $(function () {
                var po = $(".po").detach();
                var area_select = $("#area-select");
                var dashboard = $("#dashboard");

                function setStorageSpace() {
                    $.ajax({
                        type: "GET",
                        url: "<c:url value="/StorageSpaceController/findAll" />",
                        data: {
                            floor_id: 4
                        },
                        dataType: "json",
                        success: function (response) {
                            var areas = response;
                            for (var i = 0; i < areas.length; i++) {
                                var str = areas[i];
                                area_select.append("<option value='" + str.id + "'>" + str.name + "</option>");
                                dashboard.append("<div id='STORAGE_" + str.id + "' class='col-3 po-list'><label for'" + str.name + "'>" + str.name +
                                        "</label><div id='po_content_" + str.id + "' class='po_content'></div></div>");
                            }
                            getWarehouse();
                        },
                        error: function (xhr, ajaxOptions, thrownError) {
                            showMsg(xhr.responseText);
                        }
                    });
                }

                function getWarehouse() {
                    $.ajax({
                        type: "GET",
                        url: "<c:url value="/WarehouseController/findAll" />",
                        data: {
                            floor_id: 4
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

                var ws;
                function connectToServer() {

                    try {
                        ws = new WebSocket("ws://localhost:8080/WarehouseDashBoard/myHandler");

                        ws.onopen = function () {
                            $("#connectionStatus").html("Connected");
                        };
                        ws.onmessage = function (event) {
                            var d = event.data;
                            d = d.replace(/\"/g,"");
                            console.log(d);
                            if("ADD" == d || "REMOVE" == d){
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

        <div class="container">
            <div class="header row">
                <h3 class="text-muted">WS Test Page Client</h3>
            </div>
            <div class="row">
                <div id="connectionStatus">Disconnected</div>
            </div>

            <div class="po row">
                <div class="name"></div>
                <input type="hidden" value="" class="data-id">
                <div class="widget">
                    <input type="button" class="pull-out" value="Pull out" />
                </div>
            </div>

            <div class="input-area row">
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

            <div id="dashboard" class="row">
            </div>

        </div>
        <!-- /container -->
    </body>
</html>

