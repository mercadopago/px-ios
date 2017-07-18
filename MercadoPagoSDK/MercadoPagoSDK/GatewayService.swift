//
//  GatewayService.swift
//  MercadoPagoSDK
//
//  Created by Matias Gualino on 29/12/14.
//  Copyright (c) 2014 com.mercadopago. All rights reserved.
//

import Foundation

open class GatewayService: MercadoPagoService {

    open func getToken(_ url: String = ServicePreference.MP_CREATE_TOKEN_URI, method: String = "POST", key: String, cardTokenJSON: String, success: @escaping (_ jsonResult: AnyObject?) -> Void, failure:  ((_ error: NSError) -> Void)?) {
        self.request(uri: url, params: MercadoPagoContext.keyType() + "=" + key, body: cardTokenJSON as AnyObject?, method: method, success: success, failure: { (error) -> Void in
            if let failure = failure {
                failure(NSError(domain: "mercadopago.sdk.GatewayService.getToken", code: error.code, userInfo: [NSLocalizedDescriptionKey: "Hubo un error".localized, NSLocalizedFailureReasonErrorKey: "Verifique su conexión a internet e intente nuevamente".localized]))
            }
        })
    }

    open func cloneToken(_ url: String = ServicePreference.MP_CREATE_TOKEN_URI, method: String = "POST", public_key: String, token: Token, securityCode: String, success: @escaping (_ jsonResult: AnyObject?) -> Void, failure:  ((_ error: NSError) -> Void)?) {
        self.request(uri: url + "/" + token._id + "/clone", params: "public_key=" + public_key, body: nil, method: method, success: { (jsonResult) in
            var token : Token? = nil
            if let tokenDic = jsonResult as? NSDictionary {
                if tokenDic["error"] == nil {
                    token = Token.fromJSON(tokenDic)
                }
            }
            let secCodeDic : [String:Any] = ["security_code": securityCode]

            self.request(uri: url + "/" + token!._id, params: "public_key=" + public_key, body: JSONHandler.jsonCoding(secCodeDic) as AnyObject?, method: "PUT", success: success, failure: failure)
        }, failure: { (error) -> Void in
            if let failure = failure {
                failure(NSError(domain: "mercadopago.sdk.GatewayService.cloneToken", code: error.code, userInfo: [NSLocalizedDescriptionKey: "Hubo un error".localized, NSLocalizedFailureReasonErrorKey: "Verifique su conexión a internet e intente nuevamente".localized]))
            }
        })
    }
}
