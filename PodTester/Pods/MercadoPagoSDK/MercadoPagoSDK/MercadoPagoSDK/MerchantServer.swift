//
//  MerchantServer.swift
//  MercadoPagoSDK
//
//  Created by Matias Gualino on 31/12/14.
//  Copyright (c) 2014 com.mercadopago. All rights reserved.
//

import Foundation
import UIKit

open class MerchantServer : NSObject {
    
    
    open class func getCustomer(_ success: @escaping (_ customer: Customer) -> Void, failure: ((_ error: NSError) -> Void)?) {
        if let baseURL = MercadoPagoCheckoutViewModel.servicePreference.getCustomerURL() {
            
            let service : MerchantService = MerchantService(baseURL: baseURL, URI: MercadoPagoCheckoutViewModel.servicePreference.getCustomerURI())
            let params = MercadoPagoCheckoutViewModel.servicePreference.getCustomerAddionalInfo()
            
            service.getCustomer(params: params, success: {(jsonResult: AnyObject?) -> Void in
                var cust : Customer? = nil
                if let custDic = jsonResult as? NSDictionary {
                    if custDic["error"] != nil {
                        if failure != nil {
                            failure!(NSError(domain: "mercadopago.sdk.merchantServer.getCustomer", code: MercadoPago.ERROR_API_CODE, userInfo: custDic as! [AnyHashable: AnyObject]))
                        }
                    } else {
                        cust = Customer.fromJSON(custDic)
                        success(cust!)
                    }
                } else {
                    if failure != nil {
                        failure!(NSError(domain: "mercadopago.sdk.merchantServer.getCustomer", code: MercadoPago.ERROR_UNKNOWN_CODE, userInfo: ["message": "Response cannot be decoded"]))
                    }
                }
            }, failure: failure)
        }
    }

    open class func createPayment(paymentUrl : String, paymentUri: String, paymentBody : NSDictionary, success: @escaping (_ payment: Payment) -> Void, failure: ((_ error: NSError) -> Void)?) {
        let service : MerchantService = MerchantService(baseURL: paymentUrl, URI: paymentUri)
        
        var body = ""
        if !NSDictionary.isNullOrEmpty(paymentBody){
            body = Utils.append(firstJSON: paymentBody.toJsonString(), secondJSON: MercadoPagoCheckoutViewModel.servicePreference.getPaymentAddionalInfo())
        }
        
        service.createPayment(body: body, success: {(jsonResult: AnyObject?) -> Void in
            var payment : Payment? = nil
            
            
            if let paymentDic = jsonResult as? NSDictionary {
                if paymentDic["error"] != nil {
                    if failure != nil {
                        failure!(NSError(domain: "mercadopago.sdk.merchantServer.createPayment", code: MercadoPago.ERROR_API_CODE, userInfo: paymentDic as! [AnyHashable: AnyObject]))
                    }
                } else {
                    if paymentDic.allKeys.count > 0 {
                        payment = Payment.fromJSON(paymentDic)
                        success(payment!)
                    } else {
                        failure!(NSError(domain: "mercadopago.sdk.merchantServer.createPayment", code: MercadoPago.ERROR_PAYMENT, userInfo: ["message": "PAYMENT_ERROR".localized]))
                    }
                    
                }
            } else {
                if failure != nil {
                    failure!(NSError(domain: "mercadopago.sdk.merchantServer.createPayment", code: MercadoPago.ERROR_UNKNOWN_CODE, userInfo: ["message": "Response cannot be decoded"]))
                }
            }
        }, failure: failure)
    }
    
    
    open class func createPreference(success: @escaping (_ checkoutPreference: CheckoutPreference) -> Void, failure: ((_ error: NSError) -> Void)?) {
        
        if let baseURL = MercadoPagoCheckoutViewModel.servicePreference.getCheckoutPreferenceURL() {
            let service : MerchantService = MerchantService(baseURL: baseURL, URI: MercadoPagoCheckoutViewModel.servicePreference.getCheckoutPreferenceURI())
            
            
            service.createPreference(body: MercadoPagoCheckoutViewModel.servicePreference.getCheckoutAddionalInfo(), success: { (jsonResult) in
                var checkoutPreference : CheckoutPreference? = nil
                
                if let preferenceDic = jsonResult as? NSDictionary {
                    if preferenceDic["error"] != nil && failure != nil {
                        failure!(NSError(domain: "mercadopago.merchantServer.createPreference", code: MercadoPago.ERROR_API_CODE, userInfo: ["message" : "PREFERENCE_ERROR".localized]))
                    } else {
                        if preferenceDic.allKeys.count > 0 {
                            checkoutPreference = CheckoutPreference.fromJSON(preferenceDic)
                            success(checkoutPreference!)
                        }
                    }
                } else {
                    failure?(NSError(domain: "mercadopago.sdk.merchantServer.createPreference", code: MercadoPago.ERROR_UNKNOWN_CODE, userInfo: ["message": "Response cannot be decoded"]))
                    
                }
            }, failure: failure)
        }
    }
    
    
}
