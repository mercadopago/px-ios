//
//  MerchantService.swift
//  MercadoPagoSDK
//
//  Created by Matias Gualino on 31/12/14.
//  Copyright (c) 2014 com.mercadopago. All rights reserved.
//

import Foundation
import UIKit

open class MerchantService : MercadoPagoService {
    
    open var data: NSMutableData = NSMutableData()
    
    init() {
        super.init(baseURL: MercadoPagoContext.baseURL())
    }

    open func getCustomer(_ method : String = "GET", success: @escaping (_ jsonResult: AnyObject?) -> Void, failure: ((_ error: NSError) -> Void)?) {
        self.request(uri: MercadoPagoContext.customerURI(), params: "merchant_access_token=" + MercadoPagoContext.merchantAccessToken(), body: nil, method: method, cache: false, success: success, failure: failure)
    }
    
    open func createPayment(_ method : String = "POST", payment : MerchantPayment, success: @escaping (_ jsonResult: AnyObject?) -> Void, failure: ((_ error: NSError) -> Void)?) {
        self.request(uri: MercadoPagoContext.paymentURI(), params: nil, body: payment.toJSONString() as AnyObject?, method: method, cache: false,success: success, failure: failure)
    }
    
    open func createMPPayment(_ method : String = "POST", payment : MPPayment, success: @escaping (_ jsonResult: AnyObject?) -> Void, failure: ((_ error: NSError) -> Void)?) {
        self.baseURL = MercadoPago.MP_API_BASE_URL
        
        let headers = NSMutableDictionary()
        headers.setValue(MercadoPagoContext.paymentKey() , forKey: "X-Idempotency-Key")
        
        let params = "api_version=" + MercadoPago.API_VERSION
        self.request(uri: MercadoPago.MP_PAYMENTS_URI, params: params, body: payment.toJSONString() as AnyObject?, method: method, headers : headers, cache: false, success: success, failure: failure)
    }
    
    open func createPreference(_ method : String = "POST", merchantParams : String, success: @escaping (_ jsonResult: AnyObject?) -> Void, failure: ((_ error: NSError) -> Void)?) {
        self.request(uri: MercadoPagoContext.preferenceURI(), params: nil, body: merchantParams as AnyObject?, method: method, cache: false, success: success, failure: failure)
    }
}
