//
//  PaymentMethodSearchService.swift
//  MercadoPagoSDK
//
//  Created by Maria cristina rodriguez on 15/1/16.
//  Copyright © 2016 MercadoPago. All rights reserved.
//

import UIKit
fileprivate func < <T: Comparable>(lhs: T?, rhs: T?) -> Bool {
  switch (lhs, rhs) {
  case let (l?, r?):
    return l < r
  case (nil, _?):
    return true
  default:
    return false
  }
}

fileprivate func > <T: Comparable>(lhs: T?, rhs: T?) -> Bool {
  switch (lhs, rhs) {
  case let (l?, r?):
    return l > r
  default:
    return rhs < lhs
  }
}

open class PaymentMethodSearchService: MercadoPagoService {

//    public override init(){
//        super.init(baseURL: MercadoPagoCheckoutViewModel.servicePreference.getDefaultBaseURL())
//    }

    open func getPaymentMethods(_ amount: Double, customerEmail: String? = nil, customerId: String? = nil, defaultPaymenMethodId: String?, excludedPaymentTypeIds: Set<String>?, excludedPaymentMethodIds: Set<String>?, success: @escaping (_ paymentMethodSearch: PaymentMethodSearch) -> Void, failure: @escaping ((_ error: NSError) -> Void)) {
        var params = "public_key=" + MercadoPagoContext.publicKey() + "&amount=" + String(amount)

        var newExcludedPaymentTypesIds = excludedPaymentTypeIds

        if !MercadoPagoContext.accountMoneyAvailable() {
            newExcludedPaymentTypesIds?.insert("account_money")
        }

        if newExcludedPaymentTypesIds != nil && newExcludedPaymentTypesIds!.count > 0 {
            let excludedPaymentTypesParams = newExcludedPaymentTypesIds!.map({$0}).joined(separator: ",")
            params = params + "&excluded_payment_types=" + String(excludedPaymentTypesParams).trimSpaces()
        }

        if excludedPaymentMethodIds != nil && excludedPaymentMethodIds!.count > 0 {
            let excludedPaymentMethodsParams = excludedPaymentMethodIds!.joined(separator: ",")
            params = params + "&excluded_payment_methods=" + excludedPaymentMethodsParams.trimSpaces()
        }

        if let defaultPaymenMethodId = defaultPaymenMethodId {
            params = params + "&default_payment_method=" + defaultPaymenMethodId.trimSpaces()
        }

        if customerEmail != nil && customerEmail!.characters.count > 0 {
            params = params + "&email=" + customerEmail!
        }

        if customerId != nil && customerId!.characters.count > 0 {
            params = params + "&customer_id=" + customerId!
        }

        params = params + "&site_id=" + MercadoPagoContext.getSite()

        params = params + "&api_version=" + ServicePreference.API_VERSION

        var groupsPayerBody: AnyObject? = nil
        if !String.isNullOrEmpty(MercadoPagoContext.payerAccessToken()) {
            let groupsPayerBodyJson: [String:Any] = [
                "payer": GroupsPayer().toJSON()
            ]
            groupsPayerBody = JSONHandler.jsonCoding(groupsPayerBodyJson) as AnyObject?
        }

        let headers = NSMutableDictionary()
        headers.setValue(MercadoPagoContext.getLanguage(), forKey: "Accept-Language")

        self.request(uri: ServicePreference.MP_SEARCH_PAYMENTS_URI, params: params, body: groupsPayerBody, method: "POST", headers: headers, cache: false, success: { (jsonResult) -> Void in

            if let paymentSearchDic = jsonResult as? NSDictionary {
                if paymentSearchDic["error"] != nil {
                    failure(NSError(domain: "mercadopago.sdk.PaymentMethodSearchService.getPaymentMethods", code: MercadoPago.ERROR_API_CODE, userInfo: [NSLocalizedDescriptionKey: "Ha ocurrido un error".localized, NSLocalizedFailureReasonErrorKey: "No se ha podido obtener los métodos de pago".localized]))
                } else {

                    if paymentSearchDic.allKeys.count > 0 {
                        let paymentSearch = PaymentMethodSearch.fromJSON(jsonResult as! NSDictionary)
                            success(paymentSearch)
                    } else {
                        failure(NSError(domain: "mercadopago.sdk.PaymentMethodSearchService.getPaymentMethods", code: MercadoPago.ERROR_API_CODE, userInfo: [NSLocalizedDescriptionKey: "Ha ocurrido un error".localized, NSLocalizedFailureReasonErrorKey: "No se ha podido obtener los métodos de pago".localized]))
                    }
                }
            }

            }, failure: { (error) -> Void in
                failure(NSError(domain: "mercadopago.sdk.PaymentMethodSearchService.getPaymentMethods", code: error.code, userInfo: [NSLocalizedDescriptionKey: "Hubo un error".localized, NSLocalizedFailureReasonErrorKey: "Verifique su conexión a internet e intente nuevamente".localized]))
        })
    }

}
