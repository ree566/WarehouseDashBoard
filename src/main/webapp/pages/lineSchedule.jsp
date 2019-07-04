<%-- 
    Document   : index
    Created on : 2019/1/2, 下午 03:47:44
    Author     : Wei.Cheng
--%>

<%@page contentType="text/html" pageEncoding="UTF-8"%>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>
<title>${initParam.pageTitle}</title>
<link href="<c:url value="/libs/datatables.net-dt/jquery.dataTables.css" />" rel="stylesheet">
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

<script src="<c:url value="/libs/jQuery/jquery.js" />"></script> 
<script src="<c:url value="/libs/bootstrap/bootstrap.js" />"></script>
<script src="https://cdnjs.cloudflare.com/ajax/libs/jquery-sortable/0.9.13/jquery-sortable-min.js"></script>
<script src="<c:url value="/libs/datatables.net/jquery.dataTables.js" />"></script>
<script src="https://cdn.datatables.net/fixedheader/3.1.5/js/dataTables.fixedHeader.min.js"></script>
<script src="<c:url value="/libs/spring-friendly/jquery.spring-friendly.js" />"></script>
<script src="<c:url value="/libs/CellEdit/dataTables.cellEdit.js" />"></script>

<script>
    $(function () {
        $.fn.dataTable.ext.errMode = 'none';

        var floor_id = '${param.floor_id}';

        var table;
        initTable();
//        initTable(table2);

        $('#favourable tbody').on('click', 'tr', function () {
            if ($(this).hasClass('selected')) {
                $(this).removeClass('selected');
            } else {
                table.$('tr.selected').removeClass('selected');
                $(this).addClass('selected');
            }
        });


        function connectToServer() {
            var ws;
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
                    {data: "remark", title: "治具"},
                    {data: "lineScheduleStatus.name", title: "狀態"},
                    {data: "storageSpace.name", title: "位置"},
                    {data: "floor.name", title: "樓層"},
                    {data: "createDate", title: "上線日"}
                ],
                "columnDefs": [
                    {
                        "type": "html",
                        "targets": [4, 5, 6],
                        'render': function (data, type, full, meta) {

                            return data == null ? "N/A" : data;
                        }
                    },
                    {
                        "type": "html",
                        "targets": [7],
                        'render': function (data, type, full, meta) {
                            var content = "<a class='storage-faq' data-toggle=''><span class='fa fa-question-sign' title='Location'></span></a><div id='po_content_' class='po_content form-inline'></div>";
                            return data == null ? "N/A" : (data + content);
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
                    $('body').on('click', '.storage-faq, #dashboard label', function () {
//                        var labelName = $(this).attr("data-toggle");
//                        var target = $("#imagemodal #polygon-" + labelName);
//                        highlightSelectArea(target);
                        $('#imagemodal').modal('show');
                    });
                    connectToServer();
                    //Disabled undefined index exception
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

            var lineOptions = getLineOption();
            var floorOptions = getFloorOption();

            table.MakeCellsEditable({
                "onUpdate": function (updatedCell, updatedRow, oldValue) {
                    var data = updatedRow.data();
                    if (data.line && !isNaN(data.line.name)) {
                        data.line.id = data.line.name;
                        delete data.line.name;
                    }
                    if(data.floor && !isNaN(data.floor.name)){
                        data.floor.id = data.floor.name;
                        delete data.floor.name;
                    }
                    
                    console.log(data);

                    $.ajax({
                        type: "POST",
                        url: "<c:url value="/LineScheduleController/update" />",
                        data: data,
                        dataType: "json",
                        success: function (response) {
                            alert("success");
                            refreshTable();
                        },
                        error: function (xhr, ajaxOptions, thrownError) {
                            alert(xhr.responseText);
                        }
                    });
                },
                "inputCss": 'form-control',
                "columns": [4, 8],
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
//                    {
//                        "column": 5,
//                        "type": "text",
//                        "options": null
//                    },
                    {
                        "column": 8,
                        "type": "list",
                        "options": floorOptions
                    }
                ]
            });
        }

        function refreshTable() {
            table.ajax.reload();
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
    });
</script>

<div class="modal fade" id="imagemodal" tabindex="-1" role="dialog" aria-labelledby="myModalLabel" aria-hidden="true">
    <div class="modal-dialog modal-lg">
        <div class="modal-content">              
            <div class="modal-body">
                <button type="button" class="close" data-dismiss="modal"><span aria-hidden="true">&times;</span><span class="sr-only">Close</span></button>
                <c:import url="/images/svg_areaMap_${param.floor_id}f.jsp" />
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



