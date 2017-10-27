//
//  PaymentService.swift
//  MercadoPagoSDK
//
//  Created by Matias Gualino on 30/12/14.
//  Copyright (c) 2014 com.mercadopago. All rights reserved.
//

import Foundation
import MercadoPagoServices


open class PaymentService: MercadoPagoService {

    let merchantPublicKey: String!
    let payerAccessToken: String?
    let processingMode: String!

    init (baseURL: String, merchantPublicKey: String, payerAccessToken: String? = nil, processingMode: String) {
        self.merchantPublicKey = merchantPublicKey
        self.payerAccessToken = payerAccessToken
        self.processingMode = processingMode
        super.init(baseURL: baseURL)
    }

    open func getPaymentMethods(_ method: String = "GET", uri: String = ServicePreference.MP_PAYMENT_METHODS_URI, success: @escaping (_ data: Data) -> Void, failure: ((_ error: NSError) -> Void)?) {

        var params: String = MercadoPagoServices.getParamsPublicKeyAndAcessToken(merchantPublicKey, payerAccessToken)
        params.paramsAppend(key: ApiParams.PROCESSING_MODE, value: processingMode)

        self.request(uri: uri, params: params, body: nil, method: method, success: success, failure: { (error) in
            if let failure = failure {
                failure(NSError(domain: "mercadopago.sdk.paymentService.getPaymentMethods", code: error.code, userInfo: [NSLocalizedDescriptionKey: "Hubo un error".localized, NSLocalizedFailureReasonErrorKey: "Verifique su conexión a internet e intente nuevamente".localized]))
            }
        })
    }

    open func getInstallments(_ method: String = "GET", uri: String = ServicePreference.MP_INSTALLMENTS_URI, bin: String?, amount: Double, issuerId: String?, payment_method_id: String, success: @escaping ([PXInstallment]) -> Void, failure: @escaping ((_ error: NSError) -> Void)) {

        var params: String = MercadoPagoServices.getParamsPublicKeyAndAcessToken(merchantPublicKey, payerAccessToken)
        params.paramsAppend(key: ApiParams.BIN, value: bin)
        params.paramsAppend(key: ApiParams.AMOUNT, value: String(format:"%.2f", amount))
        params.paramsAppend(key: ApiParams.ISSUER_ID, value: String(describing: issuerId!))
        params.paramsAppend(key: ApiParams.PAYMENT_METHOD_ID, value: payment_method_id)
        params.paramsAppend(key: ApiParams.PROCESSING_MODE, value: processingMode)

        self.request( uri: uri, params:params, body: nil, method: method, success: {(data: Data) -> Void in
            let jsonResult = try! JSONSerialization.jsonObject(with: data, options:JSONSerialization.ReadingOptions.allowFragments)

            if let errorDic = jsonResult as? NSDictionary {
                if errorDic["error"] != nil {
                    failure(NSError(domain: "mercadopago.sdk.paymentService.getInstallments", code: MercadoPago.ERROR_API_CODE, userInfo: [NSLocalizedDescriptionKey: "Hubo un error".localized, NSLocalizedFailureReasonErrorKey: errorDic["error"] as? String ?? "Unknowed Error"]))

                }
            } else {
                var installments : [PXInstallment] = [PXInstallment]()
                installments =  try! PXInstallment.fromJSON(data: data)
                success(installments)
            }
        }, failure: { (error) in
            failure(NSError(domain: "mercadopago.sdk.paymentService.getInstallments", code: error.code, userInfo: [NSLocalizedDescriptionKey: "Hubo un error".localized, NSLocalizedFailureReasonErrorKey: "Verifique su conexión a internet e intente nuevamente".localized]))

        })
    }

    open func getIssuers(_ method: String = "GET", uri: String = ServicePreference.MP_ISSUERS_URI, payment_method_id: String, bin: String? = nil, success:  @escaping (_ data: Data) -> Void, failure: ((_ error: NSError) -> Void)?) {

        var params: String = MercadoPagoServices.getParamsPublicKeyAndAcessToken(merchantPublicKey, payerAccessToken)
        params.paramsAppend(key: ApiParams.PAYMENT_METHOD_ID, value: payment_method_id)
        params.paramsAppend(key: ApiParams.BIN, value: bin)
        params.paramsAppend(key: ApiParams.PROCESSING_MODE, value: processingMode)

        if bin != nil {
            self.request(uri: uri, params: params, body: nil, method: method, success: success, failure: { (error) in
                if let failure = failure {
                    failure(NSError(domain: "mercadopago.sdk.paymentService.getIssuers", code: error.code, userInfo: [NSLocalizedDescriptionKey: "Hubo un error".localized, NSLocalizedFailureReasonErrorKey: "Verifique su conexión a internet e intente nuevamente".localized]))
                }
            })
        } else {
            self.request(uri: uri, params: params, body: nil, method: method, success: success, failure: { (error) in
                if let failure = failure {
                    failure(NSError(domain: "mercadopago.sdk.paymentService.getIssuers", code: error.code, userInfo: [NSLocalizedDescriptionKey: "Hubo un error".localized, NSLocalizedFailureReasonErrorKey: "Verifique su conexión a internet e intente nuevamente".localized]))
                }
            })
        }
    }

}
