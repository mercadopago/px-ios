//
//  MercadoPagoService.swift
//  MercadoPagoSDK
//
//  Created by Maria cristina rodriguez on 8/3/16.
//  Copyright © 2016 MercadoPago. All rights reserved.
//

import UIKit

public class MercadoPagoService: NSObject {
    
    static let MP_BASE_URL = "https://api.mercadopago.com"
    
    var baseURL : String!
    init (baseURL : String) {
        super.init()
        self.baseURL = baseURL
    }
    
    public func request(uri: String, params: String?, body: AnyObject?, method: String, headers : NSDictionary? = nil, cache : Bool? = true, success: (jsonResult: AnyObject?) -> Void,
        failure: ((error: NSError) -> Void)?) {
        
        MercadoPagoTestContext.addExpectation(withDescription: BaseTest.WAIT_FOR_REQUEST_EXPECTATION_DESCRIPTION + uri)
        var finalUri = uri
        if params != nil {
            finalUri = finalUri + "?" + params!
        }
        
        
        if method == "POST" {
            let bodyData = (body as! String).dataUsingEncoding(NSUTF8StringEncoding)
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
            
            success(jsonResult: jsonResponse)
            MercadoPagoTestContext.fulfillExpectation(BaseTest.WAIT_FOR_REQUEST_EXPECTATION_DESCRIPTION + uri)
        } catch {
            failure!(error: NSError(domain: uri, code: 400, userInfo: nil))
        }
    }
}
