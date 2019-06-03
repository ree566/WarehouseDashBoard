<%-- 
    Document   : index
    Created on : 2019/1/2, 下午 03:47:44
    Author     : Wei.Cheng
--%>

<%@page contentType="text/html" pageEncoding="UTF-8"%>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core"%>

<title>ws-test-page</title>

<meta name="viewport" content="width=device-width, initial-scale=1.0, maximum-scale=1, user-scalable=0">

    <script src="https://code.jquery.com/jquery-3.3.1.min.js"></script>
    <script src="https://stackpath.bootstrapcdn.com/bootstrap/4.2.1/js/bootstrap.min.js"></script>

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

        .adjustPosition{
            position: absolute;
        }
        .row>div{
            border:1px black solid;
        }

        #items > * {transition: fill 0.2s, fill-opacity 0.2s, stroke 0.2s, stroke-opacity 0.2s;cursor: pointer;}body {margin:0;padding:0;}
        /**/
        #items > .polygon{fill:#d60404;fill-opacity:0.40;stroke:none;stroke-opacity:0.50}
        #items > .polygon:hover{fill:#f5d416;fill-opacity:0.60;stroke:;stroke-opacity:0.50}
        #items > .polygon.active{fill:#f5d416;fill-opacity:0.60;stroke:;stroke-opacity:0.50}

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
                            dashboard.append("<div id='STORAGE_" + str.id + "' class='col-6 po-list' data-toggle='" + str.name + "'><label for='" + str.name + "'>" + str.name +
                                    "</label><a class='storage-faq'><span class='fa fa-question-sign' title='Location'></span></a><div id='po_content_" +
                                    str.id + "' class='po_content'></div></div>");
                        }
                        getWarehouse();

                        //regist faq button event
                        $('body').on('click', '.storage-faq, #dashboard label', function () {
                            highlightSelectArea();
                            $('#imagemodal').modal('show');
                        });

                        //                            initHintCoverGroup(areas);
                    },
                    error: function (xhr, ajaxOptions, thrownError) {
                        showMsg(xhr.responseText);
                    }
                });
            }

            function highlightSelectArea() {
                var interval;
                var area = $("#imagemodal #polygon-7");
                area.trigger("hover");
                interval = setInterval(function () {
                    area.toggleClass("active");
                }, 1000);

                $('#imagemodal').on('hidden.bs.modal', function () {
                    clearInterval(interval);
                });

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
                if (confirm("Confirm submit?")) {
                    var text = $("#po").val();
                    if (text == "") {
                        alert("Please insert po number.");
                        return;
                    }
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
                }
            });

            $(document).on("click", ".pull-out", function () {
                if (confirm("Confirm pull out?")) {
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
                }
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

            $("input[type='text']").on("click", function () {
                $(this).select();
            });

            $("#area-select").change(function () {
                $("#po").focus();
            });

            var ws;
            var hostname = window.location.host;//Get the host ipaddress to link to the server.
            function connectToServer() {

                try {
                    ws = new WebSocket("ws://" + hostname + "/WarehouseDashBoard/myHandler1");

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

    <div class="modal fade" id="imagemodal" tabindex="-1" role="dialog" aria-labelledby="myModalLabel" aria-hidden="true">
        <div class="modal-dialog modal-lg">
            <div class="modal-content">              
                <div class="modal-body">
                    <button type="button" class="close" data-dismiss="modal"><span aria-hidden="true">&times;</span><span class="sr-only">Close</span></button>
                    <svg version="1.1" xmlns="http://www.w3.org/2000/svg" xmlns:xlink="http://www.w3.org/1999/xlink" x="0px" y="0px" width="100%" viewBox="0 0 326 904" xml:space="preserve">
                        <image overflow="visible" width="326" height="904" style="opacity: 0.3" xlink:href="https://i.imgur.com/curHYeL.png"></image>
                        <g id="items" class="">
                            <polygon id="polygon-1" class="polygon" points=" 27.53,402.35 27.05,436.99 41.00,436.99 41.96,404.76" transform="translate(0,0) scale(1,1)"></polygon>
                            <polygon id="polygon-2" class="polygon" points=" 48.69,404.28 47.73,435.54 61.20,436.03 61.68,405.72" transform="translate(0,0) scale(1,1)"></polygon>
                            <polygon id="polygon-3" class="polygon" points=" 68.90,405.24 67.94,436.03 80.92,436.03 79.48,403.79" transform="translate(0,0) scale(1,1)"></polygon>
                            <polygon id="polygon-4" class="polygon" points=" 87.18,407.16 87.66,436.99 100.64,436.99 101.13,407.16" transform="translate(0,0) scale(1,1)"></polygon>
                            <polygon id="polygon-5" class="polygon" points=" 13.10,455.27 13.10,486.05 26.09,486.54 26.09,457.67" transform="translate(0,0) scale(1,1)"></polygon>
                            <polygon id="polygon-6" class="polygon" points=" 34.26,454.31 33.78,485.57 47.25,485.09 46.77,454.31" transform="translate(0,0) scale(1,1)"></polygon>
                            <polygon id="polygon-7" class="polygon" points=" 55.91,455.27 54.95,485.57 67.45,485.09 67.45,454.79" transform="translate(0,0) scale(1,1)"></polygon>
                            <polygon id="polygon-8" class="polygon" points=" 75.63,454.79 76.11,484.13 89.58,485.09 89.10,453.82" transform="translate(0,0) scale(1,1)"></polygon>
                            <polygon id="polygon-9" class="polygon" points=" 95.83,454.31 95.35,483.17 109.30,484.13 110.26,454.79" transform="translate(0,0) scale(1,1)"></polygon>
                        </g>
                    </svg>
                    <button type="button" class="close" data-dismiss="modal"><span aria-hidden="true">&times;</span><span class="sr-only">Close</span></button>
                </div>
            </div>
        </div>
    </div>

    <div class="col-md-8">
        <div class="row">
            <div class="col-12">
                <div id="connectionStatus">Disconnected</div>
            </div>

            <div class="po col-12">
                <div class="name"></div>
                <input type="hidden" value="" class="data-id">
                    <div class="widget">
                        <input type="button" class="pull-out" value="Pull out" />
                    </div>
            </div>

            <div class="input-area col-12">
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
                    <svg version="1.1" xmlns="http://www.w3.org/2000/svg" xmlns:xlink="http://www.w3.org/1999/xlink" x="0px" y="0px" width="100%" viewBox="0 0 1337 481" xml:space="preserve" class="">

                        <image overflow="visible" width="1337" height="481" xlink:href="https://i.imgur.com/p3pfNkx.png" />
                        <g id="items" class="">
                            <polygon id="polygon-1" class="polygon" points=" 596.79,336.18 597.24,357.01 649.99,359.23 647.78,338.39" transform="translate(0,0) scale(1,1)"></polygon>
                            <polygon id="polygon-2" class="polygon" points=" 598.57,364.55 599.45,378.74 647.33,380.51 646.89,364.55" transform="translate(0,0) scale(1,1)"></polygon>
                            <polygon id="polygon-3" class="polygon" points=" 599.90,388.49 600.34,401.79 646.45,404.45 647.33,389.82" transform="translate(0,0) scale(1,1)"></polygon>
                            <polygon id="polygon-4" class="polygon" points=" 599.90,410.66 600.78,423.52 649.55,426.18 648.22,409.77" transform="translate(0,0) scale(1,1)"></polygon>
                            <polygon id="polygon-5" class="polygon" points=" 599.01,433.72 600.34,444.80 648.66,447.46 648.22,432.83" transform="translate(0,0) scale(1,1)"></polygon>
                            <polygon id="polygon-6" class="polygon" points=" 667.73,338.84 668.61,355.24 714.72,356.13 716.05,337.06" transform="translate(0,0) scale(1,1)"></polygon>
                            <polygon id="polygon-7" class="polygon" points=" 668.61,364.55 668.17,380.07 716.94,381.84 717.38,365.44" transform="translate(0,0) scale(1,1)"></polygon>
                            <polygon id="polygon-8" class="polygon" points=" 669.94,387.61 669.50,401.79 717.38,403.57 717.38,388.05" transform="translate(0,0) scale(1,1)"></polygon>
                            <polygon id="polygon-9" class="polygon" points=" 669.50,408.00 668.61,426.62 716.94,424.85 714.72,410.66 673.93,408.00" transform="translate(0,0) scale(1,1)"></polygon>
                            <polygon id="polygon-10" class="polygon" points=" 668.61,431.94 669.06,445.69 715.61,447.46 715.61,434.16" transform="translate(0,0) scale(1,1)"></polygon>
                        </g>
                        <g id="board"></g>
                    </svg>
                </div>
            </div>

        </div>
    </div>

    <div class="col-md-4">
        <div class="row">
            <iframe src="<c:url value="/poDashboard.jsp" />" frameborder="0" width="100%" height="700"></iframe>
        </div>
    </div>


