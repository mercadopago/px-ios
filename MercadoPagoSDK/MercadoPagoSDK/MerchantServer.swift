//
//  MerchantServer.swift
//  MercadoPagoSDK
//
//  Created by Matias Gualino on 31/12/14.
//  Copyright (c) 2014 com.mercadopago. All rights reserved.
//

import Foundation
import UIKit

public class MerchantServer : NSObject {
    
    public override init() {
        
    }
    
    public class func getCustomer(success: (customer: Customer) -> Void, failure: ((error: NSError) -> Void)?) {
        let service : MerchantService = MerchantService()
        service.getCustomer(success: {(jsonResult: AnyObject?) -> Void in
            var cust : Customer? = nil
            if let custDic = jsonResult as? NSDictionary {
                if custDic["error"] != nil {
                    if failure != nil {
                        failure!(error: NSError(domain: "mercadopago.sdk.merchantServer.getCustomer", code: MercadoPago.ERROR_API_CODE, userInfo: custDic as [NSObject : AnyObject]))
                    }
                } else {
                    cust = Customer.fromJSON(custDic)
                    success(customer: cust!)
                }
            } else {
                if failure != nil {
                    failure!(error: NSError(domain: "mercadopago.sdk.merchantServer.getCustomer", code: MercadoPago.ERROR_UNKNOWN_CODE, userInfo: ["message": "Response cannot be decoded"]))
                }
            }
        }, failure: failure)
    }
    
    public class func createPayment(payment : MerchantPayment, success: (payment: Payment) -> Void, failure: ((error: NSError) -> Void)?) {
        let service : MerchantService = MerchantService()
        service.createPayment(payment: payment, success: {(jsonResult: AnyObject?) -> Void in
            var payment : Payment? = nil
            
            if let paymentDic = jsonResult as? NSDictionary {
                if paymentDic["error"] != nil {
                    if failure != nil {
                        failure!(error: NSError(domain: "mercadopago.sdk.merchantServer.createPayment", code: MercadoPago.ERROR_API_CODE, userInfo: paymentDic as [NSObject : AnyObject]))
                    }
                } else {
					if paymentDic.allKeys.count > 0 {
						payment = Payment.fromJSON(paymentDic)
						success(payment: payment!)
					} else {
						failure!(error: NSError(domain: "mercadopago.sdk.merchantServer.createPayment", code: MercadoPago.ERROR_PAYMENT, userInfo: ["message": "PAYMENT_ERROR".localized]))
					}
					
                }
            } else {
                if failure != nil {
                    failure!(error: NSError(domain: "mercadopago.sdk.merchantServer.createPayment", code: MercadoPago.ERROR_UNKNOWN_CODE, userInfo: ["message": "Response cannot be decoded"]))
                }
            }
        }, failure: failure)
    }
    
    public class func createPreference(params : NSDictionary, success: (checkoutPreference: CheckoutPreference) -> Void, failure: ((error: NSError) -> Void)?) {
        
        let service : MerchantService = MerchantService()

        
       let paramsStr = JSON.stringify(params)
            
            service.createPreference(merchantParams: paramsStr, success: { (jsonResult) in
            var checkoutPreference : CheckoutPreference? = nil
            
            if let preferenceDic = jsonResult as? NSDictionary {
                if preferenceDic["error"] != nil && failure != nil {
                    failure!(error : NSError(domain: "mercadopago.merchantServer.createPreference", code: MercadoPago.ERROR_API_CODE, userInfo: ["message" : "PREFERENCE_ERROR".localized]))
                } else {
                    if preferenceDic.allKeys.count > 0 {
                        checkoutPreference = CheckoutPreference.fromJSON(preferenceDic)
                        success(checkoutPreference: checkoutPreference!)
                    }
                }
            } else {
                failure?(error: NSError(domain: "mercadopago.sdk.merchantServer.createPreference", code: MercadoPago.ERROR_UNKNOWN_CODE, userInfo: ["message": "Response cannot be decoded"]))
                
                }
            }, failure: failure)
        
    }
    
    
}