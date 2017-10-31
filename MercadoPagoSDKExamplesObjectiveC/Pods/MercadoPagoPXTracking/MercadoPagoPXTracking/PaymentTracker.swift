//
//  PaymentTracker.swift
//  MercadoPagoSDK
//
//  Created by Demian Tejo on 6/13/16.
//  Copyright © 2016 MercadoPago. All rights reserved.
//

import UIKit

extension MPXTracker {

    public static func trackToken(token: String, siteId: String) {

        let obj: [String:Any] = ["public_key": MPXTracker.sharedInstance.getPublicKey(), "token": token, "sdk_flavor": "3", "sdk_platform": "iOS", "sdk_type": MPXTracker.sharedInstance.getPlatformType(), "sdk_version": MPXTracker.sharedInstance.getSdkVersion(), "sdk_framework": "", "site_id": siteId]

            TrackingServices.request(url: "https://api.mercadopago.com/v1/checkout/tracking", params: nil, body: JSONHandler.jsonCoding(obj), method: "POST", headers: nil, success: { (_) -> Void in

            }) { (_) -> Void in

            }

    }

    public static func trackPaymentOff(paymentId: String, siteId: String) {

        let obj: [String:Any] = ["public_key": MPXTracker.sharedInstance.getPublicKey(), "payment_id": paymentId, "sdk_flavor": "3", "sdk_platform": "iOS", "sdk_type": MPXTracker.sharedInstance.getPlatformType(), "sdk_version": MPXTracker.sharedInstance.getSdkVersion(), "sdk_framework": "", "site_id": siteId]

        TrackingServices.request(url: "https://api.mercadopago.com/v1/checkout/tracking/off", params: nil, body: JSONHandler.jsonCoding(obj), method: "POST", headers: nil, success: { (_) -> Void in

            }) { (_) -> Void in

        }
    }
}
