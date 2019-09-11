<%-- 
    Document   : index
    Created on : 2019/1/2, 下午 03:47:44
    Author     : Wei.Cheng
--%>

<%@page contentType="text/html" pageEncoding="UTF-8"%>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>
<title>${initParam.pageTitle}</title>
<link href="<c:url value="/libs/datatables.net-dt/jquery.dataTables.css" />" rel="stylesheet">
<link href="<c:url value="/libs/datatables.net-fixedheader-dt/fixedHeader.dataTables.css" />" rel="stylesheet">
<link href="<c:url value="/libs/jquery-ui/jquery-ui.css" />"  rel="stylesheet">

<style>
    body.dragging, body.dragging * {
        cursor: move !important;
    }

    .dragged {
        position: absolute;
        top: 0;
        opacity: .5;
        z-index: 2000;
    }

    ol.example{
        margin: 0 0 9px 0;
        min-height: 10px;
    }

    ol.example li{
        display: block;
        margin: 5px;
        padding: 5px;
        border: 1px solid #CCC;
        color: blue;
        background: lightgrey;
        position: relative;
    }

    ol.example li.placeholder, table.sorted_table tr.placeholder {
        position: relative;
        margin: 0;
        padding: 0;
        border: none;
        /** More li styles **/
    }
    ol.example li.placeholder:before, table.sorted_table tr.placeholder:before {
        position: absolute;
        content: "";
        width: 0;
        height: 0;
        margin-top: -5px;
        left: -5px;
        top: -4px;
        border: 5px solid transparent;
        border-left-color: red;
        border-right: none;
        /** Define arrowhead **/
    }
    .red {
        color: red
    }

    #items > * {transition: fill 0.2s, fill-opacity 0.2s, stroke 0.2s, stroke-opacity 0.2s;cursor: pointer;}body {margin:0;padding:0;}
    /**/
    #items > .polygon{fill:#d60404;fill-opacity:0.40;stroke:none;stroke-opacity:0.50}
    #items > .polygon:hover{fill:#f5d416;fill-opacity:0.60;stroke:;stroke-opacity:0.50}
    #items > .polygon.active{fill:#f5d416;fill-opacity:0.60;stroke:;stroke-opacity:0.50}
</style>

<script src="<c:url value="/libs/jQuery/jquery.js" />"></script> 
<script src="<c:url value="/libs/jquery-ui/jquery-ui.min.js" />"></script>
<script src="<c:url value="/libs/bootstrap/bootstrap.js" />"></script>
<script src="<c:url value="/libs/jquery-sortable/jquery-sortable-min.js" />"></script>
<script src="<c:url value="/libs/datatables.net/jquery.dataTables.js" />"></script>
<script src="<c:url value="/libs/datatables.net-fixedheader/dataTables.fixedHeader.js" />"></script>
<script src="<c:url value="/libs/spring-friendly/jquery.spring-friendly.js" />"></script>
<script src="<c:url value="/libs/CellEdit/dataTables.cellEdit.js" />"></script>

<script src="<c:url value="/libs/block-ui/jquery.blockUI.js" />"></script>

<script>
    $(function () {
        $(document).ajaxSend(function () {
            block();//Block the screen when ajax is sending, Prevent form submit repeatly.
        });
        $(document).ajaxComplete(function () {
            $.unblockUI();//Unblock the ajax when success
        });

        function block() {
            $.blockUI({
                css: {
                    border: 'none',
                    padding: '15px',
                    backgroundColor: '#000',
                    '-webkit-border-radius': '10px',
                    '-moz-border-radius': '10px',
                    opacity: .5,
                    color: '#fff'
                },
                fadeIn: 0,
                overlayCSS: {
                    backgroundColor: '#FFFFFF',
                    opacity: .3
                }
            });
        }

        $.fn.dataTable.ext.errMode = 'none';

        var floor_id = '${param.floor_id}';

        var table, table2;

        var lineOptions = getLineOption();
        var floorOptions = getFloorOption();
        var numberOptions = getNumberOptions();
        var statusOptions = getStatusOptions();

        initTable();
        initTable2();

//        initTable(table2);
        $.datepicker.setDefaults({dateFormat: "yy-mm-dd'T'24:00:00.000'Z'"});

        $('#favourable tbody').on('click', 'tr', function () {
            if ($(this).hasClass('selected')) {
                $(this).removeClass('selected');
            } else {
                table.$('tr.selected').removeClass('selected');
                $(this).addClass('selected');
            }
        });

        var dateFormat = "yy-mm-dd",
                from = $("#from")
                .datepicker({
                    defaultDate: "+0w",
                    changeMonth: true,
                    numberOfMonths: 1
                })
                .on("change", function () {
                    to.datepicker("option", "minDate", getDate(this));
                }),
                to = $("#to").datepicker({
            defaultDate: "+1d",
            changeMonth: true,
            numberOfMonths: 1
        })
                .on("change", function () {
                    from.datepicker("option", "maxDate", getDate(this));
                });
        from.datepicker("setDate", new Date());
        to.datepicker("setDate", new Date());

        $("#searchOnBoard").click(function () {
            console.log($("#from").val());
            table2.ajax.reload();
        });

        var input_filter_value;
        var input_filter_timeout = 1500;
        $("div.dataTables_filter input").unbind();
        $("div.dataTables_filter input").keyup(function (e) {
            input_filter_value = this.value;
            clearTimeout(input_filter_timeout);
            input_filter_timeout = setTimeout(function () {
                table.search(input_filter_value).draw();
            }, table.context[0].searchDelay);

            // if (e.keyCode == 13) {
            //  usertable.search( this.value ).draw();
            // }
        });

        function getDate(element) {
            var date;
            try {
                date = $.datepicker.parseDate(dateFormat, element.value);
            } catch (error) {
                date = null;
            }

            return date;
        }

        var ws;
        function connectToServer() {
            var hostname = window.location.host;//Get the host ipaddress to link to the server.

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
                        refreshTable(table);
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

        function initTable() {
            table = $('#favourable').DataTable({
                "processing": true,
                "serverSide": true,
                "fixedHeader": true,
                "orderCellsTop": true,
                "ajax": {
                    "url": "<c:url value="/LineScheduleController/findAll" />",
                    "type": "GET",
                    "data": {
                        floor_id: floor_id
                    },
                    "dataSrc": function (json) {
                        return JSOG.decode(json.data);
                    }
                },
                "columns": [
                    {data: "id", title: "id", visible: false},
                    {data: "po", title: "工單"},
                    {data: "modelName", title: "機種"},
                    {data: "quantity", title: "數量"},
                    {data: "line.name", title: "線別"},
                    {data: "lineSchedulePriorityOrder", title: "順序"},
                    {data: "remark", title: "治具"},
                    {data: "lineScheduleStatus.name", title: "狀態"},
                    {data: "storageSpace.name", title: "位置"},
                    {data: "floor.name", title: "樓層"},
                    {data: "createDate", title: "日期"},
                    {data: "onBoardDate", title: "預計上線日", visible: false}
                ],
                "columnDefs": [
                    {
                        "type": "html",
                        "targets": [4, 5, 6, 7],
                        'render': function (data, type, full, meta) {

                            return data == null ? "N/A" : data;
                        }
                    },
                    {
                        "type": "html",
                        "targets": [8],
                        'render': function (data, type, full, meta) {
                            var content = "<a class='storage-faq' data-toggle='" + data + "'><span class='fa fa-map-marker-alt red' title='Location'></span></a><div id='po_content_' class='po_content form-inline'></div>";
                            return data == null ? "N/A" : (data + content);
                        }
                    },
                    {
                        "type": "html",
                        "targets": [10, 11],
                        'render': function (data, type, full, meta) {

                            return data.substring(0, 10);
                        }
                    }
                ],
                "fnRowCallback": function (nRow, aData, iDisplayIndex, iDisplayIndexFull) {
                    var a = aData.lineScheduleStatus.id;
                    var cls;
                    switch (a) {
                        case 1:
                            cls = "table-danger";
                            break;
                        case 2:
                            cls = "table-warning";
                            break;
                        case 3:
                            cls = "table-success";
                            break;
                        case 4:
                            cls = "table-secondary";
                            break;
                        case 5:
                            cls = "text-danger";
                            break;
                        default:
                            cls = "";
                    }

                    $('td', nRow).addClass(cls);
                },
                "oLanguage": {
                    "sLengthMenu": "顯示 _MENU_ 筆記錄",
                    "sZeroRecords": "無符合資料",
                    "sInfo": "目前記錄：_START_ 至 _END_, 總筆數：_TOTAL_"
                },
                "initComplete": function (settings, json) {
                    $('body').on('click', '.storage-faq, #dashboard label', function () {
                        $('#imagemodal').modal('show');
                    });
                    connectToServer();
                    //Disabled undefined index exception

                    //regist faq button event
                    $('body').on('click', '.storage-faq, #dashboard label', function () {
                        var labelName = $(this).attr("data-toggle");
                        var target = $("#imagemodal #polygon-" + labelName);
                        highlightSelectArea(target);
                        $('#imagemodal').modal('show');
                    });
                },
                "bAutoWidth": false,
                "displayLength": -1,
                "lengthChange": true,
                "lengthMenu": [[10, 25, 50, -1], [10, 25, 50, "All"]],
                "pageLength": 20,
                "filter": true,
                "info": true,
                "paginate": true,
                "select": true,
                "searchDelay": 1000,
                "ordering": true
            });

            table.on('error.dt', function (e, settings, techNote, message) {
                console.log('An error has been reported by DataTables: ', message);
            });

            table.MakeCellsEditable({
                "onUpdate": function (updatedCell, updatedRow, oldValue) {
                    var index = updatedCell.index().column;
                    var data = updatedRow.data();
                    if (index == 4) {
                        data.line.id = data.line.name;
                        delete data.line.name;
                    } else if (index == 5) {

                    } else if (index == 7) {
                        data.lineScheduleStatus.id = data.lineScheduleStatus.name;
                        delete data.lineScheduleStatus.name;
                    } else if (index == 9) {
                        data.floor.id = data.floor.name;
                        delete data.floor.name;
                    }
                    $.ajax({
                        type: "POST",
                        url: "<c:url value="/LineScheduleController/update" />",
                        data: data,
                        dataType: "json",
                        success: function (response) {
                            alert("success");
                            refreshTable(table);
                            if (index == 4) {
                                ws.send("ADD");
                            }
                        },
                        error: function (xhr, ajaxOptions, thrownError) {
                            alert(xhr.responseText);
                        }
                    });
                },
                "inputCss": 'form-control',
                "columns": [4, 5, 7, 9, 11],
                "allowNulls": {
                    "columns": [1, 2, 3, 4, 5],
                    "errorClass": 'error'
                },
                "confirmationButton": {
                    "confirmCss": 'btn btn-success',
                    "cancelCss": 'btn btn-danger'
                },
                "inputTypes": [
                    {
                        "column": 4,
                        "type": "list",
                        "options": lineOptions
                    },
                    {
                        "column": 5,
                        "type": "list",
                        "options": numberOptions
                    },
                    {
                        "column": 7,
                        "type": "list",
                        "options": statusOptions
                    },
                    {
                        "column": 9,
                        "type": "list",
                        "options": floorOptions
                    },
                    {
                        "column": 11,
                        "type": "datepicker", // requires jQuery UI: http://http://jqueryui.com/download/
                        "options": {
                            "icon": "http://jqueryui.com/resources/demos/datepicker/images/calendar.gif" // Optional
                        }
                    }
                ]
            });
        }

        function initTable2() {
            table2 = $('#favourable2').DataTable({
                "processing": true,
                "serverSide": true,
                "fixedHeader": true,
                "orderCellsTop": true,
                "ajax": {
                    "url": "<c:url value="/LineScheduleController/findOnBoardByDateBetween" />",
                    "type": "GET",
                    "data": function (d) {
                        d.floor_id = floor_id;
                        d.startDate = $("#from").val();
                        d.endDate = $("#to").val();
                    },
                    "dataSrc": function (json) {
                        return JSOG.decode(json.data);
                    }
                },
                "columns": [
                    {data: "id", title: "id", visible: false},
                    {data: "po", title: "工單"},
                    {data: "modelName", title: "機種"},
                    {data: "quantity", title: "數量"},
                    {data: "line.name", title: "線別"},
                    {data: "lineSchedulePriorityOrder", title: "順序"},
                    {data: "remark", title: "治具"},
                    {data: "lineScheduleStatus.name", title: "狀態"},
                    {data: "storageSpace.name", title: "位置"},
                    {data: "floor.name", title: "樓層"},
                    {data: "createDate", title: "原始上線日"},
                    {data: "onBoardDate", title: "預計上線日"}
                ],
                "columnDefs": [
                    {
                        "type": "html",
                        "targets": [4, 5, 6, 7],
                        'render': function (data, type, full, meta) {

                            return data == null ? "N/A" : data;
                        }
                    },
                    {
                        "type": "html",
                        "targets": [8],
                        'render': function (data, type, full, meta) {
                            var content = "<a class='storage-faq' data-toggle='" + data + "'><span class='fa fa-map-marker-alt red' title='Location'></span></a><div id='po_content_' class='po_content form-inline'></div>";
                            return data == null ? "N/A" : (data + content);
                        }
                    },
                    {
                        "type": "html",
                        "targets": [10, 11],
                        'render': function (data, type, full, meta) {

                            return data.substring(0, 10);
                        }
                    }
                ],
                "fnRowCallback": function (nRow, aData, iDisplayIndex, iDisplayIndexFull) {
                    var a = aData.lineScheduleStatus.id;
                    var cls;
                    switch (a) {
                        case 1:
                            cls = "table-danger";
                            break;
                        case 2:
                            cls = "table-warning";
                            break;
                        case 3:
                            cls = "table-success";
                            break;
                        case 4:
                            cls = "table-secondary";
                            break;
                        default:
                            cls = "";
                    }

                    $('td', nRow).addClass(cls);
                },
                "oLanguage": {
                    "sLengthMenu": "顯示 _MENU_ 筆記錄",
                    "sZeroRecords": "無符合資料",
                    "sInfo": "目前記錄：_START_ 至 _END_, 總筆數：_TOTAL_"
                },
                "initComplete": function (settings, json) {

                },
                "bAutoWidth": false,
                "displayLength": -1,
                "lengthChange": true,
                "lengthMenu": [[10, 25, 50, -1], [10, 25, 50, "All"]],
                "pageLength": 20,
                "filter": true,
                "info": true,
                "paginate": true,
                "select": true,
                "searchDelay": 1000,
                "ordering": true
            });

            table2.MakeCellsEditable({
                "onUpdate": function (updatedCell, updatedRow, oldValue) {
                    var index = updatedCell.index().column;
                    var data = updatedRow.data();
                    if (index == 7) {
                        data.lineScheduleStatus.id = data.lineScheduleStatus.name;
                        delete data.lineScheduleStatus.name;
                    }
                    $.ajax({
                        type: "POST",
                        url: "<c:url value="/LineScheduleController/updateOnboard" />",
                        data: data,
                        dataType: "json",
                        success: function (response) {
                            alert("success");
                            ws.send("ADD");
                            refreshTable(table2);
                        },
                        error: function (xhr, ajaxOptions, thrownError) {
                            alert(xhr.responseText);
                        }
                    });
                },
                "inputCss": 'form-control',
                "columns": [7],
                "allowNulls": {
                    "columns": [1, 2, 3, 4, 5],
                    "errorClass": 'error'
                },
                "confirmationButton": {
                    "confirmCss": 'btn btn-success',
                    "cancelCss": 'btn btn-danger'
                },
                "inputTypes": [
                    {
                        "column": 7,
                        "type": "list",
                        "options": statusOptions
                    }
                ]
            });
        }

        function refreshTable(tb) {
            tb.ajax.reload();
        }

        function getLineOption() {
            var result = [];
            $.ajax({
                type: 'GET',
                url: "<c:url value="/LineController/find" />",
                data: {
                    id: floor_id
                },
                async: false,
                success: function (response) {
                    var arr = response;
                    result.push({"value": "", "display": "N/A"});

                    for (var i = 0; i < arr.length; i++) {
                        var obj = arr[i];
                        result.push({"value": obj.id, "display": obj.name});
                    }
                },
                error: function (xhr, ajaxOptions, thrownError) {
                    console.log(xhr.responseText);
                }
            });
            return result;
        }

        function getFloorOption() {
            var result = [];
            $.ajax({
                type: 'GET',
                url: "<c:url value="/FloorController/findAll" />",
                async: false,
                success: function (response) {
                    var arr = response;
                    result.push({"value": "", "display": "N/A"});

                    for (var i = 0; i < arr.length; i++) {
                        var obj = arr[i];
                        result.push({"value": obj.id, "display": obj.name});
                    }
                },
                error: function (xhr, ajaxOptions, thrownError) {
                    console.log(xhr.responseText);
                }
            });
            return result;
        }

        function getStatusOptions() {
            var result = [];
            $.ajax({
                type: 'GET',
                url: "<c:url value="/LineScheduleStatusController/findAll" />",
                async: false,
                success: function (response) {
                    var arr = response;
                    for (var i = 0; i < arr.length; i++) {
                        var obj = arr[i];
                        result.push({"value": obj.id, "display": obj.name});
                    }
                },
                error: function (xhr, ajaxOptions, thrownError) {
                    console.log(xhr.responseText);
                }
            });
            return result;
        }

        function getNumberOptions() {
            var max = 10;
            var result = [];
            for (var i = 1; i <= max; i++) {
                result.push({"value": i, "display": i});
            }
            return result;
        }

        function highlightSelectArea(target) {
            if (target.length == 0) {
                return;
            }
            var interval;
            var area = target;
            area.trigger("hover");
            interval = setInterval(function () {
                area.toggleClass("active");
            }, 750);

            $('#imagemodal').on('hidden.bs.modal', function () {
                clearInterval(interval);
            });

        }
    });
</script>

<div class="modal fade" id="imagemodal" tabindex="-1" role="dialog" aria-labelledby="myModalLabel" aria-hidden="true">
    <div class="modal-dialog modal-lg">
        <div class="modal-content">              
            <div class="modal-body">
                <button type="button" class="close" data-dismiss="modal"><span aria-hidden="true">&times;</span><span class="sr-only">Close</span></button>
                <c:import url="/images/svg_areaMap_${param.floor_id}.jsp" />
                <button type="button" class="close" data-dismiss="modal"><span aria-hidden="true">&times;</span><span class="sr-only">Close</span></button>
            </div>
        </div>
    </div>
</div>

<div class="container-fluid">
    <div class="row">
        <div class="col">
            <div class="p-3 mb-2 table-danger text-center"><h4>未拉料</h4></div>
        </div>
        <div class="col">
            <div class="p-3 mb-2 table-warning text-center"><h4>已到料</h4></div>
        </div>
        <div class="col">
            <div class="p-3 mb-2 table-success text-center"><h4>設定完成</h4></div>
        </div>
        <div class="col">
            <div class="p-3 mb-2 table-secondary text-center"><h4>預備上線</h4></div>
        </div>
    </div>
    <div class="row">
        <div class="col">
            <h3>拉備料排程</h3>
            <table id="favourable" class="table table-sm table-bordered sorted_table table-responsive-sm">
            </table>
        </div>
    </div>
    <div class="row">
        <div class="col">
            <div id="connectionStatus">Disconnected</div>
        </div>
    </div>
    <hr />
    <div class="row">
        <div class="col">
            <h3>已上線狀態修改</h3>
            <div class="form-inline">
                <label for="from">From: </label>
                <input type="text" id="from" class="form-control" placeholder="請輸入起始日期" />
                <label for="to">to: </label>
                <input type="text" id="to" class="form-control" placeholder="請輸入結束日期"  />
                <input type="button" id="searchOnBoard" class="form-control" value="確定" />
            </div>
            <table id="favourable2" class="table table-sm table-bordered sorted_table table-responsive-sm">
            </table>
        </div>
    </div>
</div>
<!-- /container -->



