//
//  MercadoPagoService.swift
//  MercadoPagoSDK
//
//  Created by Maria cristina rodriguez on 8/3/16.
//  Copyright © 2016 MercadoPago. All rights reserved.
//

import UIKit

open class MercadoPagoService: NSObject {
    
    var baseURL : String!
    init (baseURL : String) {
        super.init()
        self.baseURL = baseURL
    }
    
    public func request(uri: String, params: String?, body: AnyObject?, method: String, headers : NSDictionary? = nil, cache : Bool? = true, success: (_ jsonResult: AnyObject?) -> Void,
        failure: ((_ error: NSError) -> Void)?) {
        
        /*
        MercadoPagoTestContext.addExpectation(withDescription: BaseTest.WAIT_FOR_REQUEST_EXPECTATION_DESCRIPTION + uri)
        var finalUri = uri
        if params != nil {
            finalUri = finalUri + "?" + params!
        }
        
       if method == "POST" {
            let bodyData = (body as! String).data(using: String.Encoding.utf8)
            let bodyParams = JSON(data: bodyData!)
            
            if let public_key = (bodyParams["public_key"].asString) {
                finalUri = finalUri + "?public_key=" + public_key
            }
            
            if let paymentMethodId = bodyParams["payment_method_id"].asString {
                finalUri = finalUri + "&payment_method_id=" + paymentMethodId
            }
            
        }
        
        do {
            let jsonResponse = try MockManager.getMockResponseFor(finalUri, method: method)
            /* if (jsonResponse != nil && jsonResponse!["error"] != nil){
             failure!(error: NSError(domain: uri, code: 400, userInfo: nil))
             return
             }*/
            
            success(jsonResponse)
            MercadoPagoTestContext.fulfillExpectation(BaseTest.WAIT_FOR_REQUEST_EXPECTATION_DESCRIPTION + uri)
        } catch {
            failure!(NSError(domain: uri, code: 400, userInfo: nil))
        }*/
    }
}
