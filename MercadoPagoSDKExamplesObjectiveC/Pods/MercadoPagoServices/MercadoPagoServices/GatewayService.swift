//
//  GatewayService.swift
//  MercadoPagoSDK
//
//  Created by Matias Gualino on 29/12/14.
//  Copyright (c) 2014 com.mercadopago. All rights reserved.
//

import Foundation

open class GatewayService: MercadoPagoService {
    let merchantPublicKey: String!
    let payerAccessToken: String?

    init (baseURL: String, merchantPublicKey: String, payerAccessToken: String? = nil) {
        self.merchantPublicKey = merchantPublicKey
        self.payerAccessToken = payerAccessToken
        super.init(baseURL: baseURL)
    }

    open func getToken(_ url: String = PXServicesURLConfigs.MP_CREATE_TOKEN_URI, method: String = "POST", cardTokenJSON: String, success: @escaping (_ data: Data) -> Void, failure:  ((_ error: PXError) -> Void)?) {

        let params: String = MercadoPagoServices.getParamsPublicKeyAndAcessToken(merchantPublicKey, payerAccessToken)

        self.request(uri: url, params: params, body: cardTokenJSON, method: method, success: success, failure: { (error) -> Void in
            if let failure = failure {
                failure(PXError(domain: "mercadopago.sdk.GatewayService.getToken", code: error.code, userInfo: [NSLocalizedDescriptionKey: "Hubo un error", NSLocalizedFailureReasonErrorKey: "Verifique su conexión a internet e intente nuevamente"]))
            }
        })
    }

    open func cloneToken(_ url: String = PXServicesURLConfigs.MP_CREATE_TOKEN_URI, method: String = "POST", public_key: String, tokenId: String, securityCode: String, success: @escaping (_ data: Data) -> Void, failure:  ((_ error: PXError) -> Void)?) {
        self.request(uri: url + "/" + tokenId + "/clone", params: "public_key=" + public_key, body: nil, method: method, success: { (data) in
             let jsonResult = try! JSONSerialization.jsonObject(with: data, options:JSONSerialization.ReadingOptions.allowFragments)

            var token : PXToken? = nil
            if let tokenDic = jsonResult as? NSDictionary {
                if tokenDic["error"] == nil {
                    token = try! PXToken.fromJSON(data: data)
                } else {
                    let apiException = try! PXApiException.fromJSON(data: data)
                    failure?(PXError(domain: "mercadopago.sdk.cloneToken", code: ErrorTypes.API_EXCEPTION_ERROR, userInfo: tokenDic as? [String: Any], apiException: apiException))
                    return
                }
            }
            let secCodeDic : [String: Any] = ["security_code": securityCode]

            self.request(uri: url + "/" + token!.id, params: "public_key=" + public_key, body: JSONHandler.jsonCoding(secCodeDic), method: "PUT", success: success, failure: { (error) in
                failure?(PXError(domain: "mercadopago.sdk.GatewayService.cloneToken", code: ErrorTypes.NO_INTERNET_ERROR, userInfo: [NSLocalizedDescriptionKey: "Hubo un error", NSLocalizedFailureReasonErrorKey: "Verifique su conexión a internet e intente nuevamente"]))
                })

        }, failure: { (error) -> Void in
            if let failure = failure {
                failure(PXError(domain: "mercadopago.sdk.GatewayService.cloneToken", code: error.code, userInfo: [NSLocalizedDescriptionKey: "Hubo un error", NSLocalizedFailureReasonErrorKey: "Verifique su conexión a internet e intente nuevamente"]))
            }
        })
    }
}
