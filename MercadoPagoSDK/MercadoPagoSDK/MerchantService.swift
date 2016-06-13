//
//  MerchantService.swift
//  MercadoPagoSDK
//
//  Created by Matias Gualino on 31/12/14.
//  Copyright (c) 2014 com.mercadopago. All rights reserved.
//

import Foundation
import UIKit

public class MerchantService : MercadoPagoService {
    
    public var data: NSMutableData = NSMutableData()
    
    init() {
        super.init(baseURL: MercadoPagoContext.baseURL())
    }

    public func getCustomer(method : String = "GET", success: (jsonResult: AnyObject?) -> Void, failure: ((error: NSError) -> Void)?) {
        self.request(MercadoPagoContext.customerURI(), params: "merchant_access_token=" + MercadoPagoContext.merchantAccessToken(), body: nil, method: method, success: success, failure: failure)
    }
    
    public func createPayment(method : String = "POST", payment : MerchantPayment, success: (jsonResult: AnyObject?) -> Void, failure: ((error: NSError) -> Void)?) {
        self.request(MercadoPagoContext.paymentURI(), params: nil, body: payment.toJSONString(), method: method, success: success, failure: failure)
    }
    
    public func createMPPayment(method : String = "POST", payment : MPPayment, success: (jsonResult: AnyObject?) -> Void, failure: ((error: NSError) -> Void)?) {
        self.baseURL = MercadoPago.MP_API_BASE_URL
        
        let headers = NSDictionary(dictionary: ["X-Idempotency-Key" : MercadoPagoContext.paymentKey()])
        self.request(MercadoPago.MP_PAYMENTS_URI, params: nil, body: payment.toJSONString(), method: method, headers : headers, cache: false, success: success, failure: failure)
    }
    
    public func createPreference(method : String = "POST", merchantParams : String, success: (jsonResult: AnyObject?) -> Void, failure: ((error: NSError) -> Void)?) {
        self.request(MercadoPagoContext.preferenceURI(), params: nil, body: merchantParams, method: method, success: success, failure: failure)
    }
}