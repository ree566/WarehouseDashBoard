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
        <link href="https://bootstrapious.com/tutorial/sidebar/style3.css" rel="stylesheet">

        <!-- Custom styles for this template -->
        <link href="<c:url value="/jumbotron-narrow.css" />" rel="stylesheet">

        <link href="https://cdnjs.cloudflare.com/ajax/libs/malihu-custom-scrollbar-plugin/3.1.5/jquery.mCustomScrollbar.min.css" rel="stylesheet">

        <style>
            #gotop {
                position: fixed;
                right: 20px;
                bottom: 30px;
                padding: 10px 16px;
                font-size: 25px;
                background: rgba(0, 0, 0, 0.6);
                color: #FAFCFD;
                cursor: pointer;
                z-index: 1000;
            }
        </style>

        <script src="https://code.jquery.com/jquery-3.3.1.min.js"></script>
        <script src="https://stackpath.bootstrapcdn.com/bootstrap/4.2.1/js/bootstrap.min.js"></script>
        <script src="https://cdnjs.cloudflare.com/ajax/libs/popper.js/1.14.0/umd/popper.min.js" ></script>
        <script defer src="https://use.fontawesome.com/releases/v5.0.13/js/solid.js" ></script>
        <script defer src="https://use.fontawesome.com/releases/v5.0.13/js/fontawesome.js"></script>
        <script defer src="https://cdnjs.cloudflare.com/ajax/libs/malihu-custom-scrollbar-plugin/3.1.5/jquery.mCustomScrollbar.min.js"></script>

        <script src="<c:url value="/libs/jsog/JSOG.js" />"></script>

        <script>
            $(function () {
                $("#sidebar").mCustomScrollbar({
                    theme: "minimal"
                });

                $('#dismiss, .overlay').on('click', function () {
                    // hide sidebar
                    $('#sidebar').removeClass('active');
                    // hide overlay
                    $('.overlay').removeClass('active');
                });

                $('#sidebarCollapse').on('click', function () {
                    // open sidebar
                    $('#sidebar').addClass('active');
                    // fade in the overlay
                    $('.overlay').addClass('active');
                    $('.collapse.in').toggleClass('in');
                    $('a[aria-expanded=true]').attr('aria-expanded', 'false');
                });

                $("#gotop").click(function () {
                    $("html,body").animate({
                        scrollTop: 0
                    }, 100);
                });
                
                $(window).scroll(function () {
                    if ($(this).scrollTop() > 200) {
                        $('#gotop').fadeIn("fast");
                    } else {
                        $('#gotop').stop().fadeOut("fast");
                    }
                });
            });
        </script>
    </head>

    <body>

        <div class="wrapper">
            <!-- Sidebar -->
            <nav id="sidebar">

                <div id="dismiss">
                    <i class="fas fa-arrow-left"></i>
                </div>

                <div class="sidebar-header">
                    <h3>倉儲看板</h3>
                </div>

                <ul class="list-unstyled components">
                    <p>Dummy Heading</p>
                    <li class="active">
                        <a href="layout.jsp?content=dashboard_2&floor_id=2#">Home</a>
                        <!--<a href="#homeSubmenu" data-toggle="collapse" aria-expanded="false">Home</a>-->
<!--                        <ul class="collapse list-unstyled" id="homeSubmenu">
                            <li>
                                <a href="#">Home 1</a>
                            </li>
                            <li>
                                <a href="#">Home 2</a>
                            </li>
                            <li>
                                <a href="#">Home 3</a>
                            </li>
                        </ul>-->
                    </li>
                    <li>
                        <a href="layout.jsp?content=poDashboard_1&floor_id=2#">排程看板</a>
                        <a href="#pageSubmenu">Pages</a>
                    </li>
                    <li>
                        <a href="#">Portfolio</a>
                    </li>
                    <li>
                        <a href="#">Contact</a>
                    </li>
                </ul>
            </nav>

            <!-- Page Content -->
            <div id="content">
                <nav class="navbar navbar-expand-lg navbar-light bg-light">
                    <div class="container-fluid">

                        <button type="button" id="sidebarCollapse" class="btn btn-info">
                            <i class="fas fa-align-left"></i>
                            <span>Toggle Sidebar</span>
                        </button>

                        <div class="collapse navbar-collapse" id="navbarSupportedContent">
                            <ul class="nav navbar-nav ml-auto">
                                <li class="nav-item active">
                                    <a class="nav-link" href="#">Page</a>
                                </li>
                                <li class="nav-item">
                                    <a class="nav-link" href="#">Page</a>
                                </li>
                                <li class="nav-item">
                                    <a class="nav-link" href="#">Page</a>
                                </li>
                                <li class="nav-item">
                                    <a class="nav-link" href="#">Page</a>
                                </li>
                            </ul>
                        </div>

                    </div>
                </nav>
                <div class="container-fluid">
                    <div class="header row">
                        <h3 class="text-muted">WS Test Page Client</h3>
                    </div>
                    <div class="row">
                        <jsp:include page="${param.content}.jsp"/>
                    </div>
                </div>
            </div>

            <!-- Dark Overlay element -->
            <div class="overlay"></div>

            <div id="gotop">˄</div>
        </div>
    </body>
</html>

