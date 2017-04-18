//
//  PaymentService.swift
//  MercadoPagoSDK
//
//  Created by Matias Gualino on 30/12/14.
//  Copyright (c) 2014 com.mercadopago. All rights reserved.
//

import Foundation
fileprivate func < <T : Comparable>(lhs: T?, rhs: T?) -> Bool {
  switch (lhs, rhs) {
  case let (l?, r?):
    return l < r
  case (nil, _?):
    return true
  default:
    return false
  }
}

fileprivate func > <T : Comparable>(lhs: T?, rhs: T?) -> Bool {
  switch (lhs, rhs) {
  case let (l?, r?):
    return l > r
  default:
    return rhs < lhs
  }
}


open class PaymentService : MercadoPagoService {
    
    open func getPaymentMethods(_ method: String = "GET", uri : String = MercadoPago.MP_OP_ENVIROMENT + "/payment_methods", public_key : String, success: @escaping (_ jsonResult: AnyObject?) -> Void, failure: ((_ error: NSError) -> Void)?) {
        self.request(uri: uri, params: "public_key=" + public_key, body: nil, method: method, success: success, failure: failure)
    }

    open func getInstallments(_ method: String = "GET", uri : String = MercadoPago.MP_OP_ENVIROMENT + "/payment_methods/installments", public_key : String, bin : String?, amount: Double, issuer_id: NSNumber?, payment_method_id: String, success: @escaping ([Installment]) -> Void, failure: @escaping ((_ error: NSError) -> Void)) {
        var params : String = "public_key=" + public_key
        if(bin != nil){
                    params = params + "&bin=" + bin!
        }

            params = params + "&amount=" + String(format:"%.2f", amount)
        if issuer_id != nil {
            params = params + "&issuer.id=" + String(describing: issuer_id!)
        }
        params = params + "&payment_method_id=" + payment_method_id
        self.request( uri: uri, params:params, body: nil, method: method, success: {(jsonResult: AnyObject?) -> Void in
            
            if let errorDic = jsonResult as? NSDictionary {
                if errorDic["error"] != nil {
                    failure(NSError(domain: "mercadopago.sdk.paymentService.getInstallments", code: MercadoPago.ERROR_API_CODE, userInfo: [NSLocalizedDescriptionKey: "Hubo un error".localized, NSLocalizedFailureReasonErrorKey : errorDic["error"] as! String]))
                
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
                failure(NSError(domain: "mercadopago.sdk.paymentService.getInstallments", code: error.code, userInfo: [NSLocalizedDescriptionKey: "Hubo un error".localized, NSLocalizedFailureReasonErrorKey : "Verifique su conexión a internet e intente nuevamente".localized]))

        })
    }
    
    open func getIssuers(_ method: String = "GET", uri : String = MercadoPago.MP_OP_ENVIROMENT + "/payment_methods/card_issuers", public_key : String, payment_method_id: String, bin: String? = nil, success:  @escaping (_ jsonResult: AnyObject?) -> Void, failure: ((_ error: NSError) -> Void)?) {
        if(bin != nil){
            self.request(uri: uri, params: "public_key=" + public_key + "&payment_method_id=" + payment_method_id + "&bin=" + bin!, body: nil, method: method, success: success, failure: failure)
        }else{
            self.request(uri: uri, params: "public_key=" + public_key + "&payment_method_id=" + payment_method_id, body: nil, method: method, success: success, failure: failure)
        }
        
    }
    
}
