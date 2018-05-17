//
//  PXImageService.swift
//  MercadoPagoSDK
//
//  Created by AUGUSTO COLLERONE ALFONSO on 5/3/18.
//  Copyright © 2018 MercadoPago. All rights reserved.
//

import Foundation

final class PXImageService: NSObject {

    class func getIconImageFor(paymentMethod: PaymentMethod) -> UIImage? {

        guard paymentMethod.paymentTypeId != PaymentTypeId.PAYMENT_METHOD_PLUGIN.rawValue else {
            return paymentMethod.getImageForExtenalPaymentMethod()
        }

        let path = MercadoPago.getBundle()!.path(forResource: "PaymentMethodSearch", ofType: "plist")
        let dictPM = NSDictionary(contentsOfFile: path!)

        if let pm = dictPM?.value(forKey: paymentMethod.paymentMethodId) as? NSDictionary {
            return MercadoPago.getImage(pm.object(forKey: "image_name") as? String ?? nil)
        } else if let pmPt = dictPM?.value(forKey: paymentMethod.paymentMethodId + "_" + paymentMethod.paymentTypeId) as? NSDictionary {
            return MercadoPago.getImage(pmPt.object(forKey: "image_name") as? String ?? nil)
        }

        return nil
    }
}
