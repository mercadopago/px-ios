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
    
    var URI: String
    
    init (baseURL: String, URI: String) {
        self.URI = URI
        super.init()
        self.baseURL = baseURL
    }
    

    open func getCustomer(_ method : String = "GET", params: String, success: @escaping (_ jsonResult: AnyObject?) -> Void, failure: ((_ error: NSError) -> Void)?) {
        
            
        self.request(uri: self.URI, params: params, body: nil, method: method, cache: false, success: success, failure: failure)
    }
    
    
    open func createPayment(_ method : String = "POST", body : String, success: @escaping (_ jsonResult: AnyObject?) -> Void, failure: ((_ error: NSError) -> Void)?) {
        
        
        let headers = NSMutableDictionary()
        headers.setValue(MercadoPagoContext.paymentKey() , forKey: "X-Idempotency-Key")
        
        self.request(uri: self.URI, params: nil, body: body as AnyObject?, method: method, headers : headers, cache: false, success: success, failure: failure)
    }
    
    open func createPreference(_ method : String = "POST", body: String, success: @escaping (_ jsonResult: AnyObject?) -> Void, failure: ((_ error: NSError) -> Void)?) {
        
        
        self.request(uri: self.URI, params: nil, body: body as AnyObject?, method: method, cache: false, success: success, failure: failure)
    }
}
