//
//  PaymentService.swift
//  MercadoPagoSDK
//
//  Created by Matias Gualino on 30/12/14.
//  Copyright (c) 2014 com.mercadopago. All rights reserved.
//

import Foundation
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

open class PaymentService: MercadoPagoService {

    open func getPaymentMethods(_ method: String = "GET", uri: String = ServicePreference.MP_PAYMENT_METHODS_URI, success: @escaping (_ jsonResult: AnyObject?) -> Void, failure: ((_ error: NSError) -> Void)?) {

        var params = "\(MercadoPagoContext.PRIVATE_KEY)=\(MercadoPagoContext.payerAccessToken())"
        params += "&\(MercadoPagoContext.PUBLIC_KEY)=\(MercadoPagoContext.publicKey())"

        self.request(uri: uri, params: params, body: nil, method: method, success: success, failure: { (error) in
            if let failure = failure {
            failure(NSError(domain: "mercadopago.sdk.paymentService.getPaymentMethods", code: error.code, userInfo: [NSLocalizedDescriptionKey: "Hubo un error".localized, NSLocalizedFailureReasonErrorKey: "Verifique su conexión a internet e intente nuevamente".localized]))
            }
            })
    }

    open func getInstallments(_ method: String = "GET", uri: String = ServicePreference.MP_INSTALLMENTS_URI, bin: String?, amount: Double, issuer_id: String?, payment_method_id: String, success: @escaping ([Installment]) -> Void, failure: @escaping ((_ error: NSError) -> Void)) {
        var params = "\(MercadoPagoContext.PRIVATE_KEY)=\(MercadoPagoContext.payerAccessToken())"
        params += "&\(MercadoPagoContext.PUBLIC_KEY)=\(MercadoPagoContext.publicKey())"
        if bin != nil {
                    params = params + "&bin=" + bin!
        }

            params = params + "&amount=" + String(format:"%.2f", amount)
        if issuer_id != nil {
            params = params + "&issuer.id=" + String(describing: issuer_id!)
        }
        params = params + "&payment_method_id=" + payment_method_id

        params = params + "&processing_mode=" + MercadoPagoCheckoutViewModel.servicePreference.getProcessingModeString()
        
        self.request( uri: uri, params:params, body: nil, method: method, success: {(jsonResult: AnyObject?) -> Void in
            if let errorDic = jsonResult as? NSDictionary {
                if errorDic["error"] != nil {
                    failure(NSError(domain: "mercadopago.sdk.paymentService.getInstallments", code: MercadoPago.ERROR_API_CODE, userInfo: [NSLocalizedDescriptionKey: "Hubo un error".localized, NSLocalizedFailureReasonErrorKey: errorDic["error"] as? String ?? "Unknowed Error"]))

                }
            } else {
                let paymentMethods = jsonResult as? NSArray
                var installments : [Installment] = [Installment]()
                if paymentMethods != nil && paymentMethods?.count > 0 {
                    if let dic = paymentMethods![0] as? NSDictionary {
                        installments.append(Installment.fromJSON(dic))
                    }
                    success(installments)
                } else {
                    let error : NSError = NSError(domain: "mercadopago.sdk.paymentService.getInstallments", code: MercadoPago.ERROR_NOT_INSTALLMENTS_FOUND, userInfo: [NSLocalizedDescriptionKey: "Hubo un error", NSLocalizedFailureReasonErrorKey: "NOT_INSTALLMENTS_FOUND".localized + "\(amount)"])
                    failure(error)
                }
            }
            }, failure: { (error) in
                failure(NSError(domain: "mercadopago.sdk.paymentService.getInstallments", code: error.code, userInfo: [NSLocalizedDescriptionKey: "Hubo un error".localized, NSLocalizedFailureReasonErrorKey: "Verifique su conexión a internet e intente nuevamente".localized]))

        })
    }

    open func getIssuers(_ method: String = "GET", uri: String = ServicePreference.MP_ISSUERS_URI, payment_method_id: String, bin: String? = nil, success:  @escaping (_ jsonResult: AnyObject?) -> Void, failure: ((_ error: NSError) -> Void)?) {
        var params = "\(MercadoPagoContext.PRIVATE_KEY)=\(MercadoPagoContext.payerAccessToken())"
            params += "&\(MercadoPagoContext.PUBLIC_KEY)=\(MercadoPagoContext.publicKey())"
            params += "&payment_method_id=" + payment_method_id
        
        params = params + "&processing_mode=" + MercadoPagoCheckoutViewModel.servicePreference.getProcessingModeString()

        if bin != nil {
            self.request(uri: uri, params: params + "&bin=" + bin!, body: nil, method: method, success: success, failure: { (error) in
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
