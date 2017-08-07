//
//  DiscountServices.swift
//  MercadoPagoSDK
//
//  Created by Demian Tejo on 12/26/16.
//  Copyright © 2016 MercadoPago. All rights reserved.
//

import UIKit

open class DiscountService: MercadoPagoService {

    var URI: String

    override init () {
        self.URI = MercadoPagoCheckoutViewModel.servicePreference.getDiscountURI()
        super.init()
        self.baseURL = MercadoPagoCheckoutViewModel.servicePreference.getDiscountURL()
    }

    init (baseURL: String, URI: String) {
        self.URI = MercadoPagoCheckoutViewModel.servicePreference.getDiscountURI()
        super.init()
        self.baseURL = MercadoPagoCheckoutViewModel.servicePreference.getDiscountURL()
    }

    open func getDiscount(amount: Double, code: String? = nil, payerEmail: String?, additionalInfo: String? = nil, success: @escaping (_ discount: DiscountCoupon?) -> Void, failure: @escaping ((_ error: NSError) -> Void)) {
        var params = "public_key=" + MercadoPagoContext.publicKey() + "&transaction_amount=" + String(amount)

        if !String.isNullOrEmpty(payerEmail) {
            params += "&payer_email=" + payerEmail!
        }

        if let couponCode = code {
            params = params + "&coupon_code=" + String(couponCode).trimSpaces()
        }

        if !String.isNullOrEmpty(additionalInfo) {
            params += "&" + additionalInfo!
        }

        self.request(uri: self.URI, params: params, body: nil, method: "GET", cache: false, success: { (jsonResult) -> Void in

            if let discount = jsonResult as? NSDictionary {
                if let error = discount["error"] {
                    failure(NSError(domain: "mercadopago.sdk.DiscountService.getDiscount", code: MercadoPago.ERROR_API_CODE, userInfo: [NSLocalizedDescriptionKey: error]))
                } else {
                    let discount = DiscountCoupon.fromJSON(jsonResult as! NSDictionary, amount: amount)
                    success(discount)
                }
            }

        }, failure: { (error) -> Void in
            failure(NSError(domain: "mercadopago.sdk.DiscountService.getDiscount", code: error.code, userInfo: [NSLocalizedDescriptionKey: "Hubo un error".localized, NSLocalizedFailureReasonErrorKey: "Verifique su conexión a internet e intente nuevamente".localized]))
        })
    }
}
