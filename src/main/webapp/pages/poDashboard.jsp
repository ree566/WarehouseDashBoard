<%-- 
    Document   : index
    Created on : 2019/1/2, 下午 03:47:44
    Author     : Wei.Cheng
--%>

<%@page contentType="text/html" pageEncoding="UTF-8"%>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>
<title>poDashboard</title>
<link href="https://cdn.datatables.net/1.10.19/css/jquery.dataTables.min.css" rel="stylesheet">
<link href="https://cdn.datatables.net/1.10.19/css/jquery.dataTables.min.css" rel="stylesheet">
<link href="https://cdn.datatables.net/fixedheader/3.1.5/css/fixedHeader.dataTables.min.css" rel="stylesheet">

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

</style>

<script src="https://code.jquery.com/jquery-3.3.1.min.js"></script>
<script src="https://cdnjs.cloudflare.com/ajax/libs/jquery-sortable/0.9.13/jquery-sortable-min.js"></script>
<script src="https://cdn.datatables.net/1.10.19/js/jquery.dataTables.min.js"></script>
<script src="https://cdn.datatables.net/fixedheader/3.1.5/js/dataTables.fixedHeader.min.js"></script>
<script src="<c:url value="/libs/spring-friendly/jquery.spring-friendly.js" />"></script>
<script src="<c:url value="/libs/CellEdit/dataTables.cellEdit.js" />"></script>

<script>
    var table, table2;
    $(function () {
        $.fn.dataTable.ext.errMode = 'none';

        table = $('#favourable'), table2 = $('#favourable2');
        initTable(table);
//        initTable(table2);

        $('#favourable tbody').on('click', 'tr', function () {
            if ($(this).hasClass('selected')) {
                $(this).removeClass('selected');
            } else {
                table.$('tr.selected').removeClass('selected');
                $(this).addClass('selected');
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
                        table.ajax.reload();
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

        function initTable(table) {
            table = table.DataTable({
                "processing": true,
                "serverSide": true,
                "fixedHeader": true,
                "orderCellsTop": true,
                "ajax": {
                    "url": "<c:url value="/LineScheduleController/findAll" />",
                    "type": "GET",
                    "dataSrc": function (json) {
                        return JSOG.decode(json.data);
                    }
                },
                "columns": [
                    {data: "id", title: "id"},
                    {data: "po", title: "工單"},
                    {data: "modelName", title: "機種"},
                    {data: "quantity", title: "數量"},
                    {data: "line.name", title: "線別"},
                    {data: "quantity", title: "治具"},
                    {data: "lineScheduleStatus.name", title: "狀態"}
                ],
                "columnDefs": [
                    {
                        "type": "html",
                        "targets": [4, 6],
                        'render': function (data, type, full, meta) {
//                            return "<select class='form-control'>" +
//                                    "<option>N/A</option>" +
//                                    "<option>LA</option><option>LB</option>" +
//                                    "<option>LC</option><option>LD</option>" +
//                                    "</select>";
                            return data == null ? "N/A" : data;
                        }
                    },
                    {
                        "type": "html",
                        "targets": 5,
                        'render': function (data, type, full, meta) {
                            return "<textarea class='form-control'></textarea>";
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

                    //Disabled undefined index exception

                    connectToServer();
                },
                "bAutoWidth": false,
                "displayLength": -1,
                "lengthChange": true,
                "lengthMenu": [[10, 25, 50, -1], [10, 25, 50, "All"]],
                pageLength: 20,
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
                    var value = updatedCell.data();
                    var data = updatedRow.data();
                    delete data.createDate;
                    delete data.line.name;
                    data.line.id = value;
                    $.ajax({
                        type: "POST",
                        url: "<c:url value="/LineScheduleController/update" />",
                        data: data,
                        dataType: "json",
                        success: function (response) {
                            alert("success");
                            table.ajax.reload();
                        },
                        error: function (xhr, ajaxOptions, thrownError) {
                            alert(xhr.responseText);
                        }
                    });
                },
                "inputCss": 'form-control',
                "columns": [4],
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
                        "options": [
                            {"value": "", "display": "N/A"},
                            {"value": "1", "display": "LD"},
                            {"value": "2", "display": "LB"},
                            {"value": "3", "display": "LA"},
                            {"value": "4", "display": "LF"},
                            {"value": "5", "display": "LG"}
                        ]
                    }
                ]
            });
        }
    });
</script>

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
            <h3>本日上線排程</h3>
            <table id="favourable" class="table table-sm table-bordered sorted_table table-responsive-sm">
            </table>
        </div>
        <!--        <div class="col">
                    <h3>明日上線排程</h3>
                    <table id="favourable2" class="table table-striped table-bordered sorted_table">
                    </table>
                </div>-->
    </div>
    <div class="row">
        <div class="col">
            <div id="connectionStatus">Disconnected</div>
        </div>
    </div>
</div>
<!-- /container -->



