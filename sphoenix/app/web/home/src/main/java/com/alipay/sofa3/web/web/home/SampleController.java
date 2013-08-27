/**
 * Alipay.com Inc.
 * Copyright (c) 2005-2010 All Rights Reserved.
 */
package com.alipay.sofa3.web.web.home;

import org.springframework.stereotype.Controller;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RequestMethod;

/**
 * A sample controller.
 */
@Controller
@RequestMapping("/sample.htm")
public class SampleController {
	@RequestMapping(method = RequestMethod.GET)
	public void doGet() {
	}
}
