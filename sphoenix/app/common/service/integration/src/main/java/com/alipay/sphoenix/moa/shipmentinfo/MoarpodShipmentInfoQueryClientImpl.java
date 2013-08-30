/**
 * 
 */
package com.alipay.sphoenix.moa.shipmentinfo;

import com.alipay.moaprod.common.query.MoaOrderExtQueryFacade;
import com.alipay.moaprod.common.query.domain.OrderLogisticsQueryResult;

/**
 * @author wb-shazh
 *
 */
public class MoarpodShipmentInfoQueryClientImpl implements MoarpodShipmentInfoQueryClient {

	MoaOrderExtQueryFacade MoaOrderExtQueryFacade;
	OrderLogisticsQueryResult OrderLogisticsQueryResult;
	public String getShipmentInfo(String orderId){
		
		OrderLogisticsQueryResult shipmentinfo=MoaOrderExtQueryFacade.queryShipmentInfo(orderId);
		
		return shipmentinfo.toString();
	}
}
