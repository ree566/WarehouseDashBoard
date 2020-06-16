///*
// * To change this license header, choose License Headers in Project Properties.
// * To change this template file, choose Tools | Templates
// * and open the template in the editor.
// */
//package com.advantech.sap;
//
//import com.sap.conn.jco.JCoDestination;
//import com.sap.conn.jco.JCoDestinationManager;
//import com.sap.conn.jco.JCoException;
//import com.sap.conn.jco.ext.DestinationDataProvider;
//import java.io.File;
//import java.io.FileOutputStream;
//import java.io.IOException;
//import java.util.Properties;
//
///**
// *
// * @author Wei.Cheng
// */
//public class SAPConn {
//
//    private static final String SAP_MES = "SAPMES";
//
//    static {
//        Properties connectProperties = new Properties();
//        connectProperties.setProperty(DestinationDataProvider.JCO_ASHOST, "172.20.1.63");// 服务器
//        connectProperties.setProperty(DestinationDataProvider.JCO_SYSNR, "06"); // 系统编号
//        connectProperties.setProperty(DestinationDataProvider.JCO_CLIENT, "168"); // SAP集团
//        connectProperties.setProperty(DestinationDataProvider.JCO_USER, "MES.ACL"); // SAP用户名
//        connectProperties.setProperty(DestinationDataProvider.JCO_PASSWD, "MESMES"); // 密码
//        connectProperties.setProperty(DestinationDataProvider.JCO_LANG, "ZF"); // 登录语言:ZH EN
//        connectProperties.setProperty(DestinationDataProvider.JCO_POOL_CAPACITY, "3"); // 最大连接数
//        connectProperties.setProperty(DestinationDataProvider.JCO_PEAK_LIMIT, "10"); // 最大连接线程
//
//        createDataFile(SAP_MES, "jcoDestination", connectProperties);
//    }
//
//    /**
//     * 创建SAP接口属性文件。
//     *
//     * @param name ABAP管道名称
//     * @param suffix 属性文件后缀
//     * @param properties 属性文件内容
//     */
//    private static void createDataFile(String name, String suffix, Properties properties) {
//        File cfg = new File(name + "." + suffix);
//        if (cfg.exists()) {
//            cfg.deleteOnExit();
//        }
//        try {
//            try (FileOutputStream fos = new FileOutputStream(cfg, false)) {
//                properties.store(fos, "for tests only !");
//            }
//        } catch (IOException e) {
//            System.out.println("Create Data file fault, error msg: " + e.toString());
//            throw new RuntimeException("Unable to create the destination file " + cfg.getName(), e);
//        }
//    }
//
//    /*
//      * * 获取SAP连接
//      * 
//      * @return SAP连接对象
//     */
//    public static JCoDestination connect() {
//        JCoDestination destination = null;
//        try {
//            destination = JCoDestinationManager.getDestination(SAP_MES);
//        } catch (JCoException e) {
//            System.out.println("Connect SAP fault, error msg: " + e.toString());
//        }
//        return destination;
//    }
//}
