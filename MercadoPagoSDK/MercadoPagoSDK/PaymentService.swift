//
//  PaymentService.swift
//  MercadoPagoSDK
//
//  Created by Matias Gualino on 30/12/14.
//  Copyright (c) 2014 com.mercadopago. All rights reserved.
//

import Foundation

public class PaymentService : MercadoPagoService {
    
    public func getPaymentMethods(method: String = "GET", uri : String = "/v1/payment_methods", public_key : String, success: (jsonResult: AnyObject?) -> Void, failure: ((error: NSError) -> Void)?) {
        self.request(uri, params: "public_key=" + public_key, body: nil, method: method, success: success, failure: failure)
    }

    public func getInstallments(method: String = "GET", uri : String = "/v1/payment_methods/installments", public_key : String, bin : String, amount: Double, issuer_id: NSNumber?, payment_type_id: String, success: ([Installment]) -> Void, failure: ((error: NSError) -> Void)) {
        var params : String = "public_key=" + public_key
            params = params + "&bin=" + bin
            params = params + "&amount=" + String(format:"%.2f", amount)
        if issuer_id != nil {
            params = params + "&issuer.id=" + issuer_id!.stringValue
        }
        params = params + "&payment_type_id=" + payment_type_id
        self.request(uri, params:params, body: nil, method: method, success: {(jsonResult: AnyObject?) -> Void in
            
            if let errorDic = jsonResult as? NSDictionary {
                if errorDic["error"] != nil {
                    failure(error: NSError(domain: "mercadopago.sdk.paymentService.getInstallments", code: MercadoPago.ERROR_API_CODE, userInfo: [NSLocalizedDescriptionKey: "Hubo un error".localized, NSLocalizedFailureReasonErrorKey : errorDic["error"] as! String]))
                
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
                    failure(error: error)
                }
            }
            }, failure: { (error) in
                failure(error: NSError(domain: "mercadopago.sdk.paymentService.getInstallments", code: error.code, userInfo: [NSLocalizedDescriptionKey: "Hubo un error".localized, NSLocalizedFailureReasonErrorKey : "Verifique su conexión a ineternet e intente nuevamente".localized]))

        })
    }
    
    public func getIssuers(method: String = "GET", uri : String = "/v1/payment_methods/card_issuers", public_key : String, payment_method_id: String, bin: String? = nil, success: (jsonResult: AnyObject?) -> Void, failure: ((error: NSError) -> Void)?) {
        if(bin != nil){
            self.request(uri, params: "public_key=" + public_key + "&payment_method_id=" + payment_method_id + "&bin=" + bin!, body: nil, method: method, success: success, failure: failure)
        }else{
            self.request(uri, params: "public_key=" + public_key + "&payment_method_id=" + payment_method_id, body: nil, method: method, success: success, failure: failure)
        }
        
    }
    
}