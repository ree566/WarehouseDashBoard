/*
 * To change this license header, choose License Headers in Project Properties.
 * To change this template file, choose Tools | Templates
 * and open the template in the editor.
 */
package com.advantech.webservice.root;

/**
 *
 * @author Wei.Cheng
 */
public enum Section {
    PREASSY("A"),
    BAB("B"),
    TEST("T"),
    PACKAGE("P");

    private final String code;

    private Section(final String code) {
        this.code = code;
    }

    public String getCode() {
        return this.code;
    }

    public static Section getByCode(String code) {
        for (Section v : values()) {
            if (v.getCode().equals(code)) {
                return v;
            }
        }
        return null;
    }
}
