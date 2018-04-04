//
//  PaymentTracker.swift
//  MercadoPagoSDK
//
//  Created by Demian Tejo on 6/13/16.
//  Copyright © 2016 MercadoPago. All rights reserved.
//

import UIKit

extension MPXTracker {
    public static func trackToken(token: String) {

        let obj: [String: Any] = ["public_key": MercadoPagoContext.sharedInstance.publicKey(), "token": token, "sdk_flavor": "3", "sdk_platform": "iOS", "sdk_type": MercadoPagoContext.platformType, "sdk_version": MercadoPagoContext.sharedInstance.sdkVersion(), "sdk_framework": "", "site_id": MercadoPagoContext.sharedInstance.siteId() ]

            TrackingServices.request(url: "https://api.mercadopago.com/v1/checkout/tracking", params: nil, body: JSONHandler.jsonCoding(obj), method: "POST", headers: nil, success: { (_) -> Void in

            }, failure: nil)

    }

    public static func trackPaymentOff(paymentId: String) {

        let obj: [String: Any] = ["public_key": MercadoPagoContext.sharedInstance.publicKey(), "payment_id": paymentId, "sdk_flavor": "3", "sdk_platform": "iOS", "sdk_type": MercadoPagoContext.platformType, "sdk_version": MercadoPagoContext.sharedInstance.sdkVersion(), "sdk_framework": "", "site_id": MercadoPagoContext.sharedInstance.siteId() ]

        TrackingServices.request(url: "https://api.mercadopago.com/v1/checkout/tracking/off", params: nil, body: JSONHandler.jsonCoding(obj), method: "POST", headers: nil, success: { (_) -> Void in

        }, failure: nil)
    }
}
