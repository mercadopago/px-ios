//
//  PXPaymentTypeChargeRule.swift
//  MercadoPagoSDK
//
//  Created by Demian Tejo on 13/6/18.
//  Copyright © 2018 MercadoPago. All rights reserved.
//

import UIKit

@objc
public final class PXPaymentTypeChargeRule: NSObject {
    let paymentMethdodId: String
    let amountCharge: Double

   @objc public init(paymentMethdodId: String, amountCharge: Double) {
        self.paymentMethdodId = paymentMethdodId
        self.amountCharge = amountCharge
        super.init()
    }
}
