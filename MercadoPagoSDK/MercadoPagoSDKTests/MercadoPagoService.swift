//
//  MercadoPagoService.swift
//  MercadoPagoSDK
//
//  Created by Maria cristina rodriguez on 8/3/16.
//  Copyright © 2016 MercadoPago. All rights reserved.
//

import UIKit

open class MercadoPagoService: NSObject {

    var baseURL: String!

    init (baseURL: String) {
        super.init()
        self.baseURL = baseURL
    }

    override init () {
        super.init()
    }

    public func request(uri: String, params: String?, body: String?, method: String, headers: [String:String]? = nil, cache: Bool? = true, success: (_ jsonResult: AnyObject?) -> Void,
        failure: ((_ error: NSError) -> Void)?) {

        /*
        MercadoPagoTestContext.addExpectation(withDescription: BaseTest.WAIT_FOR_REQUEST_EXPECTATION_DESCRIPTION + uri)*/
        var finalUri = uri
        if params != nil {
            finalUri = finalUri + "?" + params!
        }

       if method == "POST" {
            /*if body != nil {
                let bodyData = (body as! String).data(using: String.Encoding.utf8)
            }
        
               let bodyParams = JSON(data: bodyData!)
            
            if let public_key = (bodyParams["public_key"].asString) {
                finalUri = finalUri + "?public_key=" + public_key
            }
            
            if let paymentMethodId = bodyParams["payment_method_id"].asString {
                finalUri = finalUri + "&payment_method_id=" + paymentMethodId
            }
           */
        }

        do {
            let jsonResponse = try MockManager.getMockResponseFor(finalUri, method: method)

            if jsonResponse != nil {
                // JSON responses should call success. Could be an API error, so each caller class checks:
                // if dic["error"] == nil {...}. See MerchantServer or MPServicesBuilder methods as an example.
                success(jsonResponse)
                //MercadoPagoTestContext.fulfillExpectation(BaseTest.WAIT_FOR_REQUEST_EXPECTATION_DESCRIPTION + uri)
            } else {
                failure!(NSError(domain: uri, code: 400, userInfo: nil))
            }
        } catch {
            failure!(NSError(domain: uri, code: 400, userInfo: nil))
        }
    }
}
