//
//  PXPaymentCongratsTracking.swift
//  MercadoPagoSDK
//
//  Created by Daniel Alexander Silva on 8/18/20.
//

import Foundation

@objcMembers
public class PXPaymentCongratsTracking: NSObject {
    let currencyId: String
    let paymentStatus: String
    let paymentStatusDetail: String
    let paymentId: String
    let totalAmount: Double
    
    public init(paymentStatus: String, paymentStatusDetail: String, totalAmount: Double, paymentId: String, currencyId: String) {
        self.currencyId = currencyId
        self.paymentStatus = paymentStatus
        self.paymentStatusDetail = paymentStatusDetail
        self.paymentId = paymentId
        self.totalAmount = totalAmount
    }
}

