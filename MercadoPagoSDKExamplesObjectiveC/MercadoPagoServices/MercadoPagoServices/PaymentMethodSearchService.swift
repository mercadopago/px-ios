//
//  PaymentMethodSearchService.swift
//  MercadoPagoSDK
//
//  Created by Maria cristina rodriguez on 15/1/16.
//  Copyright © 2016 MercadoPago. All rights reserved.
//

import UIKit

private func < <T: Comparable>(lhs: T?, rhs: T?) -> Bool {
  switch (lhs, rhs) {
  case let (l?, r?):
    return l < r
  case (nil, _?):
    return true
  default:
    return false
  }
}

private func > <T: Comparable>(lhs: T?, rhs: T?) -> Bool {
  switch (lhs, rhs) {
  case let (l?, r?):
    return l > r
  default:
    return rhs < lhs
  }
}

open class PaymentMethodSearchService: MercadoPagoService {

    let merchantPublicKey: String!
    let payerAccessToken: String?
    let processingMode: String!

    init (baseURL: String, merchantPublicKey: String, payerAccessToken: String? = nil, processingMode: String) {
        self.merchantPublicKey = merchantPublicKey
        self.payerAccessToken = payerAccessToken
        self.processingMode = processingMode
        super.init(baseURL: baseURL)
    }

    open func getPaymentMethods(_ amount: Double, customerEmail: String? = nil, customerId: String? = nil, defaultPaymenMethodId: String?, excludedPaymentTypeIds: Set<String>?, excludedPaymentMethodIds: Set<String>?, site: PXSite, payer: PXPayer, language: String, success: @escaping (_ paymentMethodSearch: PXPaymentMethodSearch) -> Void, failure: @escaping ((_ error: NSError) -> Void)) {

        var params =  MercadoPagoServices.getParamsPublicKey(merchantPublicKey)

        params.paramsAppend(key: ApiParams.AMOUNT, value: String(amount))

        let newExcludedPaymentTypesIds = excludedPaymentTypeIds

        if newExcludedPaymentTypesIds != nil && newExcludedPaymentTypesIds!.count > 0 {
            let excludedPaymentTypesParams = newExcludedPaymentTypesIds!.map({$0}).joined(separator: ",")
            params.paramsAppend(key: ApiParams.EXCLUDED_PAYMET_TYPES, value : String(excludedPaymentTypesParams).trimSpaces())
        }

        if excludedPaymentMethodIds != nil && excludedPaymentMethodIds!.count > 0 {
            let excludedPaymentMethodsParams = excludedPaymentMethodIds!.joined(separator: ",")
            params.paramsAppend(key: ApiParams.EXCLUDED_PAYMENT_METHOD, value : excludedPaymentMethodsParams.trimSpaces())
        }

        if let defaultPaymenMethodId = defaultPaymenMethodId {
            params.paramsAppend(key: ApiParams.DEFAULT_PAYMENT_METHOD, value : defaultPaymenMethodId.trimSpaces())
        }

        params.paramsAppend(key: ApiParams.EMAIL, value : customerEmail)
        params.paramsAppend(key: ApiParams.CUSTOMER_ID, value : customerId)
        params.paramsAppend(key: ApiParams.SITE_ID, value : site.id)
        params.paramsAppend(key: ApiParams.API_VERSION, value : MercadoPagoService.API_VERSION)
        params.paramsAppend(key: ApiParams.PROCESSING_MODE, value: processingMode)

        let groupsPayerBody = try! payer.toJSONString()

        let headers = ["Accept-Language": language]

        self.request(uri: MercadoPagoService.MP_SEARCH_PAYMENTS_URI, params: params, body: groupsPayerBody, method: "POST", headers: headers, cache: false, success: { (data) -> Void in
             let jsonResult = try! JSONSerialization.jsonObject(with: data, options:JSONSerialization.ReadingOptions.allowFragments)
            if let paymentSearchDic = jsonResult as? NSDictionary {
                if paymentSearchDic["error"] != nil {
                    failure(NSError(domain: "mercadopago.sdk.PaymentMethodSearchService.getPaymentMethods", code: PXApitUtil.ERROR_API_CODE, userInfo: [NSLocalizedDescriptionKey: "Hubo un error", NSLocalizedFailureReasonErrorKey: "No se ha podido obtener los métodos de pago"]))
                } else {

                    if paymentSearchDic.allKeys.count > 0 {
                            let paymentSearch = try! PXPaymentMethodSearch.fromJSON(data: data)
                            success(paymentSearch)
                    } else {
                        failure(NSError(domain: "mercadopago.sdk.PaymentMethodSearchService.getPaymentMethods", code: PXApitUtil.ERROR_API_CODE, userInfo: [NSLocalizedDescriptionKey: "Hubo un error", NSLocalizedFailureReasonErrorKey: "No se ha podido obtener los métodos de pago"]))
                    }
                }
            }

            }, failure: { (error) -> Void in
                failure(NSError(domain: "mercadopago.sdk.PaymentMethodSearchService.getPaymentMethods", code: error.code, userInfo: [NSLocalizedDescriptionKey: "Hubo un error", NSLocalizedFailureReasonErrorKey: "Verifique su conexión a internet e intente nuevamente"]))
        })
    }

}
