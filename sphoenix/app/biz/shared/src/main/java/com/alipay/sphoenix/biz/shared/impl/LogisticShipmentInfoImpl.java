/**
 * 
 */
package com.alipay.sphoenix.biz.shared.impl;

import com.alipay.sphoenix.biz.shared.LogisticShipmentInfo;
import com.alipay.sphoenix.moa.shipmentinfo.MoarpodShipmentInfoQueryClient;
/**
 * @author wb-shazh
 *
 */
public class LogisticShipmentInfoImpl implements LogisticShipmentInfo {

	
	private MoarpodShipmentInfoQueryClient moarpodShipmentInfoQueryClient;
	
	/* (non-Javadoc)
	 * @see com.alipay.sphoenix.biz.shared.LogisticShipmentInfo#getLogisticInfo(java.lang.String)
	 */
	@Override
	public String getLogisticInfo(String orderId) {
		String info=moarpodShipmentInfoQueryClient.getShipmentInfo(orderId);
		return info;
	}

	public String testLogisticInfo(String orderId){
		String info =moarpodShipmentInfoQueryClient.getShipmentInfo(orderId);
		return info;
	}
	
	public void setMoarpodShipmentInfoQueryClient(MoarpodShipmentInfoQueryClient moarpodShipmentInfoQueryClient){
		this.moarpodShipmentInfoQueryClient=moarpodShipmentInfoQueryClient;
	}
}
