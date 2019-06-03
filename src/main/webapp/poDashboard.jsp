<%-- 
    Document   : index
    Created on : 2019/1/2, 下午 03:47:44
    Author     : Wei.Cheng
--%>

<%@page contentType="text/html" pageEncoding="UTF-8"%>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>
<!DOCTYPE html>
<html lang="en">
    <head>
        <meta charset="utf-8">
        <meta http-equiv="X-UA-Compatible" content="IE=edge">
        <meta name="viewport" content="width=device-width, initial-scale=1">
        <meta name="description" content="">
        <meta name="author" content="">
        <link rel="icon" href="../../favicon.ico">

        <title>poDashboard</title>
        <!-- Bootstrap core CSS -->
        <link href="https://stackpath.bootstrapcdn.com/bootstrap/4.2.1/css/bootstrap.min.css" rel="stylesheet">

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
        <script src="https://stackpath.bootstrapcdn.com/bootstrap/4.2.1/js/bootstrap.min.js"></script>
        <script src="https://cdnjs.cloudflare.com/ajax/libs/jquery-sortable/0.9.13/jquery-sortable-min.js"></script>
        <script src="https://cdn.datatables.net/1.10.19/js/jquery.dataTables.min.js"></script>
        <script src="https://cdn.datatables.net/fixedheader/3.1.5/js/dataTables.fixedHeader.min.js"></script>

        <script>
            $(function () {

                var table = $('#favourable');
                table.DataTable({
                    "processing": true,
                    "serverSide": false,
                    "fixedHeader": true,
                    "orderCellsTop": true,
                    "ajax": {
                        "url": "<c:url value="/json/poFlow.json" />",
                        "type": "GET"
                    },
                    "columns": [
//                        {
//                            "data": "po",
//                            title: "id", 
//                            render: function (data, type, row, meta) {
//                                return meta.row + meta.settings._iDisplayStart + 1;
//                            }
//                        },
                        {data: "po", title: "工單"},
                        {data: "modelName", title: "機種"},
                        {data: "amount", title: "數量"}
                    ],
                    "oLanguage": {
                        "sLengthMenu": "顯示 _MENU_ 筆記錄",
                        "sZeroRecords": "無符合資料",
                        "sInfo": "目前記錄：_START_ 至 _END_, 總筆數：_TOTAL_"
                    },
                    "initComplete": function (settings, json) {
                        // Sortable rows
//                        table.sortable({
//                            containerSelector: 'table',
//                            itemPath: '> tbody',
//                            itemSelector: 'tr',
//                            placeholder: '<tr class="placeholder"/>'
//                        });
                    },
                    "bAutoWidth": false,
                    "displayLength": -1,
                    "lengthChange": false,
                    "lengthMenu": [[10, 25, 50, -1], [10, 25, 50, "All"]],
                    "filter": false,
                    "info": true,
                    "paginate": true,
                    "select": true,
                    "searchDelay": 1000,
                    "ordering": false
                });

            });
        </script>
    </head>

    <body>

        <div class="container">

            <table id="favourable" class="table table-striped table-bordered sorted_table">

            </table>

        </div>
        <!-- /container -->
    </body>
</html>

