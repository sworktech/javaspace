/*
 * Alipay.com Inc.
 * Copyright (c) 2004-2007 All Rights Reserved.
 */
package com.alipay.ant.task;

import java.net.InetAddress;
import java.net.UnknownHostException;

import org.apache.tools.ant.BuildException;
import org.apache.tools.ant.Task;

/**
 * 检测本机IP地址。
 *
 * @author Cheng Li
 *
 * @version $Id$
 */
public class DetectLocalIPAddress extends Task {
    /** IP地址信息放到哪个Property中 */
    private String inproperty;

    /**
     * 构造器。
     */
    public DetectLocalIPAddress() {
    }

    /**
     * @see org.apache.tools.ant.Task${symbol_pound}execute()
     */
    @Override
    public void execute() throws BuildException {
        if (inproperty == null) {
            throw new BuildException("No inProperty has been specified!");
        }
        String ipAddress = null;

        try {
            InetAddress addr = InetAddress.getLocalHost();
            ipAddress = addr.getHostAddress();
        } catch (UnknownHostException e) {
            throw new BuildException("Can't detect localhost ip address.", e);
        }

        getProject().setProperty(inproperty, ipAddress);
    }

    /**
     * 设置inProperty属性。
     * 
     * @param name
     */
    public void setInproperty(String inProperty) {
        this.inproperty = inProperty;
    }
}
