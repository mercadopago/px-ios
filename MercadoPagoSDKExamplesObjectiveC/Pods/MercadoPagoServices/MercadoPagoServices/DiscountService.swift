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

    init (baseURL: String, URI: String) {
        self.URI = URI
        super.init(baseURL: baseURL)
    }

    open func getDiscount(publicKey: String, amount: Double, code: String? = nil, payerEmail: String?, additionalInfo: String? = nil, success: @escaping (_ discount: PXDiscount?) -> Void, failure: @escaping ((_ error: PXError) -> Void)) {
        var params = "public_key=" + publicKey + "&transaction_amount=" + String(amount)

        if !String.isNullOrEmpty(payerEmail) {
            params += "&payer_email=" + payerEmail!
        }

        if let couponCode = code {
            params = params + "&coupon_code=" + String(couponCode).trimSpaces()
        }

        if !String.isNullOrEmpty(additionalInfo) {
            params += "&" + additionalInfo!
        }

        self.request(uri: self.URI, params: params, body: nil, method: "GET", cache: false, success: { (data) -> Void in
            let jsonResult = try! JSONSerialization.jsonObject(with: data, options:JSONSerialization.ReadingOptions.allowFragments)

            if let discount = jsonResult as? NSDictionary {
                if let error = discount["error"] {
                    let apiException = try! PXApiException.fromJSON(data: data)
                    failure(PXError(domain: "mercadopago.sdk.DiscountService.getDiscount", code: ErrorTypes.API_EXCEPTION_ERROR, userInfo: [NSLocalizedDescriptionKey: error], apiException: apiException))
                } else {
                    let discount = try! PXDiscount.fromJSON(data: data)
                    success(discount)
                }
            }

        }, failure: { (error) -> Void in
            failure(PXError(domain: "mercadopago.sdk.DiscountService.getDiscount", code: ErrorTypes.NO_INTERNET_ERROR, userInfo: [NSLocalizedDescriptionKey: "Hubo un error", NSLocalizedFailureReasonErrorKey: "Verifique su conexión a internet e intente nuevamente"]))
        })
    }

    open func getCampaigns(publicKey: String, success: @escaping (_ discount: [PXCampaign]) -> Void, failure: @escaping ((_ error: PXError) -> Void)) {
         var params = "public_key=" + publicKey

        self.request(uri: self.URI, params: params, body: nil, method: "GET", cache: false, success: { (data) -> Void in
            let jsonResult = try! JSONSerialization.jsonObject(with: data, options:JSONSerialization.ReadingOptions.allowFragments)

            if let discount = jsonResult as? NSDictionary {
                if let error = discount["error"] {
                    let apiException = try! PXApiException.fromJSON(data: data)
                    failure(PXError(domain: "mercadopago.sdk.DiscountService.getCampaigns", code: ErrorTypes.API_EXCEPTION_ERROR, userInfo: [NSLocalizedDescriptionKey: error], apiException: apiException))
                } else {
                    let campaign: [PXCampaign] = try! PXCampaign.fromJSON(data: data)
                    success(campaign)
                }
            }

        }, failure: { (error) -> Void in
            failure(PXError(domain: "mercadopago.sdk.DiscountService.getCampaigns", code: ErrorTypes.NO_INTERNET_ERROR, userInfo: [NSLocalizedDescriptionKey: "Hubo un error", NSLocalizedFailureReasonErrorKey: "Verifique su conexión a internet e intente nuevamente"]))
        })
    }
}
