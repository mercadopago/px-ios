//
//  GatewayService.swift
//  MercadoPagoSDK
//
//  Created by Matias Gualino on 29/12/14.
//  Copyright (c) 2014 com.mercadopago. All rights reserved.
//

import Foundation
import MercadoPagoServices

open class GatewayService: MercadoPagoService {

    open func getToken(_ url: String = ServicePreference.MP_CREATE_TOKEN_URI, method: String = "POST", cardTokenJSON: String, success: @escaping (_ data: Data?) -> Void, failure:  ((_ error: NSError) -> Void)?) {

        let params: String = MercadoPagoServices.getParamsPublicKeyAndAcessToken()

        self.request(uri: url, params: params, body: cardTokenJSON, method: method, success: success, failure: { (error) -> Void in
            if let failure = failure {
                failure(NSError(domain: "mercadopago.sdk.GatewayService.getToken", code: error.code, userInfo: [NSLocalizedDescriptionKey: "Hubo un error".localized, NSLocalizedFailureReasonErrorKey: "Verifique su conexión a internet e intente nuevamente".localized]))
            }
        })
    }

    open func cloneToken(_ url: String = ServicePreference.MP_CREATE_TOKEN_URI, method: String = "POST", public_key: String, tokenId: String, securityCode: String, success: @escaping (_ data: Data?) -> Void, failure:  ((_ error: NSError) -> Void)?) {
        self.request(uri: url + "/" + tokenId + "/clone", params: "public_key=" + public_key, body: nil, method: method, success: { (jsonResult) in
            var token : PXToken? = nil
            if let tokenDic = jsonResult as? NSDictionary {
                if tokenDic["error"] == nil {
                    token = PXToken.fromJSON(tokenDic)
                }
            }
            let secCodeDic : [String:Any] = ["security_code": securityCode]

            self.request(uri: url + "/" + token!.id, params: "public_key=" + public_key, body: JSONHandler.jsonCoding(secCodeDic), method: "PUT", success: success, failure: failure)
        }, failure: { (error) -> Void in
            if let failure = failure {
                failure(NSError(domain: "mercadopago.sdk.GatewayService.cloneToken", code: error.code, userInfo: [NSLocalizedDescriptionKey: "Hubo un error".localized, NSLocalizedFailureReasonErrorKey: "Verifique su conexión a internet e intente nuevamente".localized]))
            }
        })
    }
}
