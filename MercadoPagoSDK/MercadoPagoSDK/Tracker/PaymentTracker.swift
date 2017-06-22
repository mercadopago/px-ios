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

        let obj: [String:Any] = ["public_key": mpxPublicKey, "token": token, "sdk_flavor": "3", "sdk_platform": "iOS", "sdk_type": mpxPlatformType, "sdk_version": mpxCheckoutVersion, "sdk_framework": "", "site_id": mpxSiteId ]

            self.request(url: "https://api.mercadopago.com/v1/checkout/tracking", params: nil, body: JSONHandler.jsonCoding(obj), method: "POST", headers: nil, success: { (_) -> Void in

            }) { (_) -> Void in

            }

    }

    public static func trackPaymentOff(paymentId: String) {

        let obj: [String:Any] = ["public_key": mpxPublicKey, "payment_id": paymentId, "sdk_flavor": "3", "sdk_platform": "iOS", "sdk_type": mpxPlatformType, "sdk_version": mpxCheckoutVersion, "sdk_framework": "", "site_id": mpxSiteId ]

        self.request(url: "https://api.mercadopago.com/v1/checkout/tracking/off", params: nil, body: JSONHandler.jsonCoding(obj), method: "POST", headers: nil, success: { (_) -> Void in

            }) { (_) -> Void in

        }
    }
}
