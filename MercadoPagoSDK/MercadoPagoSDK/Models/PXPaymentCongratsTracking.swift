//
//  PXPaymentCongratsTracking.swift
//  MercadoPagoSDK
//
//  Created by Daniel Alexander Silva on 8/18/20.
//

import Foundation

@objcMembers
public class PXPaymentCongratsTracking: NSObject {
    let campaingId: String?
    let currencyId: String?
    let paymentStatusDetail: String?
    let paymentId: Int64
    let totalAmount: NSDecimalNumber
    
    public init(campaingId: String?, currencyId: String?, paymentStatusDetail: String?, totalAmount: NSDecimalNumber, paymentId: Int64) {
        self.campaingId = campaingId
        self.currencyId = currencyId
        self.paymentStatusDetail = paymentStatusDetail
        self.paymentId = paymentId
        self.totalAmount = totalAmount
    }
}

