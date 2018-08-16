//
//  PXPaymentPluginResult.swift
//  MercadoPagoSDK
//
//  Created by Eden Torres on 26/06/2018.
//  Copyright © 2018 MercadoPago. All rights reserved.
//

import Foundation

/** :nodoc: */
@objcMembers
open class PXPaymentPluginResult: NSObject {
    let status: String
    let statusDetail: String
    let receiptId: String?

    @objc public init(status: String, statusDetail: String, receiptId: String? = nil) {
        self.status = status
        self.statusDetail = statusDetail
        self.receiptId = receiptId
    }

    public init(paymentStatus: PXPaymentMethodPlugin.RemotePaymentStatus, statusDetail: String, receiptId: String? = nil) {
        var paymentStatusStrDefault = PaymentStatus.REJECTED

        if paymentStatus == .APPROVED {
            paymentStatusStrDefault = PaymentStatus.APPROVED
        }
        self.status = paymentStatusStrDefault
        self.statusDetail = statusDetail
        self.receiptId = receiptId
    }
}
