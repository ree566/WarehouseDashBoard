<%@page contentType="text/html" pageEncoding="UTF-8"%>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core"%>
<!DOCTYPE HTML PUBLIC "-//W3C//DTD HTML 4.01 Transitional//EN">
<html>
    <head>
        <!--<META HTTP-EQUIV="REFRESH" CONTENT="10">-->
        <meta http-equiv="refresh" content="${pageContext.session.maxInactiveInterval};url="/>
        <meta name="viewport" content="width=device-width, initial-scale=1.0, maximum-scale=1, user-scalable=0">
        <title>${initParam.pageTitle}</title>
        <link rel="shortcut icon" href="<c:url value="/images/favicon.ico" />"/>
        <link rel="stylesheet" href="<c:url value="/libs/bootstrap/bootstrap.css" />">
        <style>
            body {
                padding-top: 90px;
            }
            .error{
                color: red;
            }
            .system-environment-checkMsg{
                text-align:center; 
                color: red;
            }
            .noscript input{
                display: none;
            }

            .panel-login {
                border-color: #ccc;
                -webkit-box-shadow: 0px 2px 3px 0px rgba(0,0,0,0.2);
                -moz-box-shadow: 0px 2px 3px 0px rgba(0,0,0,0.2);
                box-shadow: 0px 2px 3px 0px rgba(0,0,0,0.2);
            }

            .panel-login>.panel-heading {
                color: #00415d;
                background-color: #fff;
                border-color: #fff;
                text-align:center;
            }
            /* Bordered form */
            /*            form {
                            border: 3px solid #f1f1f1;
                        }*/

            /* Avatar image */
            img.avatar {
                width: 40%;
                border-radius: 10%;
            }

            .panel-login input[type="text"], .panel-login input[type="password"] {
                height: 45px;
                border: 1px solid #ddd;
                font-size: 16px;
                -webkit-transition: all 0.1s linear;
                -moz-transition: all 0.1s linear;
                transition: all 0.1s linear;
            }

            .panel-login input:hover,
            .panel-login input:focus {
                outline:none;
                -webkit-box-shadow: none;
                -moz-box-shadow: none;
                box-shadow: none;
                border-color: #ccc;
            }
            #btnSubmit {
                background-color: #59B2E0;
                outline: none;
                color: #fff;
                font-size: 14px;
                height: auto;
                font-weight: normal;
                padding: 14px 0;
                text-transform: uppercase;
                border-color: #59B2E6;
            }
            #btnSubmit:hover,
            #btnSubmit:focus {
                color: #fff;
                background-color: #53A3CD;
                border-color: #53A3CD;
            }

        </style>
        <script src="<c:url value="/libs/jQuery/jquery.js" />"></script> 
        <script src="<c:url value="/libs/jquery-validation/jquery.validate.min.js" />"></script> 
        <script src="<c:url value="/libs/block-ui/jquery.blockUI.js" />"></script>
        <script>
            var isCommitted = false;//表单是否已经提交标识，默认为false
            function dosubmit() {
                if (!isCommitted) {
                    isCommitted = true;//提交表单后，将表单是否已经提交标识设置为true
                    return true;//返回true让表单正常提交
                } else {
                    return false;//返回false那么表单将不提交
                }
            }
            $.validator.addMethod("regex", //addMethod第1个参数:方法名称
                    function (value, element, params) {     //addMethod第2个参数:验证方法，参数（被验证元素的值，被验证元素，参数）
                        var exp = new RegExp(params);     //实例化正则对象，参数为传入的正则表达式
                        return exp.test(value);                    //测试是否匹配
                    }, "格式錯誤");    //addMethod第3个参数:默认错误信息
            var rule = {required: true, regex: "^[0-9a-zA-Z-]+$"};
            var msg = {required: "必须填寫", regex: "格式錯誤"};
            $(function () {
                $("#login-form").validate({
                    rules: {
                        jobnumber: rule, //密码1必填
                        password: rule
                    },
                    messages: {
                        jobnumber: msg,
                        password: msg
                    },
                    errorPlacement: function (error, element) {                             //错误信息位置设置方法  
                        error.appendTo(element.next());                            //这里的element是录入数据的对象  
                    },
                    submitHandler: function (form) {
                        block();
                        form.submit();
                    }
                });
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
                    fadeIn: 0
                    , overlayCSS: {
                        backgroundColor: '#FFFFFF',
                        opacity: .3
                    }
                });
            }
        </script>
    </head>
    <body class="noscript">
        <script>
            $('body').removeClass('noscript');
        </script>
        <c:if test="${sessionScope.SPRING_SECURITY_CONTEXT != null}">
            <c:redirect url="pages/"/>
        </c:if>
        <div class="system-environment-checkMsg">
            <noscript>For full functionality of this page it is necessary to enable JavaScript. Here are the <a href="http://www.enable-javascript.com" target="_blank"> instructions how to enable JavaScript in your web browser</a></noscript>
        </div>
        <div id="not_detect_jquery" class="system-environment-checkMsg"></div>

        <div class="container">
            <div class="row">
                <div class="col">
                    <div class="panel panel-login">
                        <div class="panel-heading text-center">
                            <div class="row">
                                <div class="col">
                                    <h2>${initParam.pageTitle}</h2>
                                </div>
                            </div>
                            <hr>
                        </div>
                        <div class="panel-body">

                            <div class="row">
                                <div class="col">
                                    <c:url var="loginUrl" value="/login" />
                                    <form action="${loginUrl}" method="post" onsubmit="dosubmit()" id="login-form">
                                        <div class="form-group">
                                            <input type="text" tabindex="1" class="form-control" placeholder="Enter Username" name="username" maxlength="20" autocomplete="off" required>
                                            <div class="validMessage"></div>
                                        </div>

                                        <div class="form-group">
                                            <input type="password" tabindex="2" class="form-control" placeholder="Enter Password" name="password" maxlength="20" required>
                                            <div class="validMessage"></div>
                                        </div>

                                        <div class="form-group text-center">
                                            <input type="checkbox" tabindex="3" class="" name="remember-me" id="remember">
                                            <label for="remember"> Remember Me</label>
                                        </div>
                                        <div class="form-group">
                                            <div class="row">
                                                <div class="col">
                                                    <input type="submit" name="login-submit" id="btnSubmit" tabindex="4" class="form-control btn btn-info" value="Login">
                                                </div>
                                            </div>
                                        </div>

                                        <input type="hidden" name="${_csrf.parameterName}"  value="${_csrf.token}" />

                                        <div class="form-group">
                                            <c:if test="${param.error != null}">
                                                <div class="alert alert-danger">
                                                    <p>Invalid username or password.</p>
                                                </div>
                                            </c:if>
                                            <c:if test="${param.logout != null}">
                                                <div class="alert alert-success">
                                                    <p>You have been logged out successfully.</p>
                                                </div>
                                            </c:if>
                                        </div>
                                    </form>
                                </div>
                            </div>
                        </div>
                    </div>
                </div>
            </div>
        </div>
    </body>
</html>
