/**
 * Alipay.com Inc.
 * Copyright (c) 2005-2009 All Rights Reserved.
 */
package com.alipay.sofa3.web.web.home;

import javax.servlet.http.HttpServletRequest;

import org.springframework.stereotype.Controller;
import org.springframework.ui.ModelMap;
import org.springframework.web.bind.annotation.RequestMapping;

/**
 * Ä¬ÈÏµÄÒì³£controller
 * @author duwei@alipay.com
 *
 */
@Controller
public class Error {

    @RequestMapping(value = "/error.htm")
    public void renderError(ModelMap modelMap, HttpServletRequest request) {
        initModelMap(modelMap, request);
    }

    @RequestMapping(value = "/errorXbox.htm")
    public void renderErrorXBox(ModelMap modelMap, HttpServletRequest request) {
        initModelMap(modelMap, request);
    }

   
    /**
     * @param modelMap
     * @param request
     */
    private void initModelMap(ModelMap modelMap, HttpServletRequest request) {
    }
}
