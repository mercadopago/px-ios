//
//  PaymentMethodSearchService.swift
//  MercadoPagoSDK
//
//  Created by Maria cristina rodriguez on 15/1/16.
//  Copyright © 2016 MercadoPago. All rights reserved.
//

import UIKit

public class PaymentMethodSearchService: MercadoPagoService {
    
    public let MP_SEARCH_PAYMENTS_URI = MercadoPago.MP_ENVIROMENT + "/payment_methods/search/options"
    
    public init(){
        super.init(baseURL: MercadoPago.MP_API_BASE_URL)
    }
    
    public func getPaymentMethods(amount : Double, customerEmail : String? = nil, customerId : String? = nil, customerAccessToken : String? = nil, excludedPaymentTypeIds : Set<String>?, excludedPaymentMethodIds : Set<String>?, success: (paymentMethodSearch: PaymentMethodSearch) -> Void, failure: ((error: NSError) -> Void)) {
        var params = "public_key=" + MercadoPagoContext.publicKey() + "&amount=" + String(amount)
        
        if customerAccessToken != nil && customerAccessToken!.characters.count > 0 {
            params = params + "&access_token=" + customerAccessToken!
        }
        
        if excludedPaymentTypeIds != nil && excludedPaymentTypeIds?.count > 0 {
            let excludedPaymentTypesParams = excludedPaymentTypeIds!.map({$0}).joinWithSeparator(",")
            params = params + "&excluded_payment_types=" + String(excludedPaymentTypesParams).trimSpaces()
        }
        
        if excludedPaymentMethodIds != nil && excludedPaymentMethodIds!.count > 0 {
            let excludedPaymentMethodsParams = excludedPaymentMethodIds!.joinWithSeparator(",")
            params = params + "&excluded_payment_methods=" + excludedPaymentMethodsParams.trimSpaces()
        }
        
        if customerEmail != nil && customerEmail!.characters.count > 0 {
            params = params + "&email=" + customerEmail!
        }
        
        if customerId != nil && customerId!.characters.count > 0 {
            params = params + "&customer_id=" + customerId!
        }
        
        self.request(MP_SEARCH_PAYMENTS_URI, params: params, body: nil, method: "GET", success: { (jsonResult) -> Void in
            
            if let paymentSearchDic = jsonResult as? NSDictionary {
                if paymentSearchDic["error"] != nil {
                    failure(error: NSError(domain: "mercadopago.sdk.PaymentMethodSearchService.getPaymentMethods", code: MercadoPago.ERROR_API_CODE, userInfo: [NSLocalizedDescriptionKey : "Ha ocurrido un error".localized, NSLocalizedFailureReasonErrorKey : "No se han podido obtener los métodos de pago".localized]))
                } else {
                    if paymentSearchDic.allKeys.count > 0 {
                        let paymentSearch = PaymentMethodSearch.fromJSON(jsonResult as! NSDictionary)
                        success(paymentMethodSearch : paymentSearch)
                    } else {
                        failure(error: NSError(domain: "mercadopago.sdk.PaymentMethodSearchService.getPaymentMethods", code: MercadoPago.ERROR_API_CODE, userInfo: [NSLocalizedDescriptionKey : "Ha ocurrido un error".localized, NSLocalizedFailureReasonErrorKey : "No se han podido obtener los métodos de pago".localized]))
                    }
                }
            }
            
            },  failure: { (error) -> Void in
                failure(error: NSError(domain: "mercadopago.sdk.PaymentMethodSearchService.getPaymentMethods", code: error.code, userInfo: [NSLocalizedDescriptionKey: "Hubo un error".localized, NSLocalizedFailureReasonErrorKey : "Verifique su conexión a ineternet e intente nuevamente".localized]))
        })
    }
    
}
