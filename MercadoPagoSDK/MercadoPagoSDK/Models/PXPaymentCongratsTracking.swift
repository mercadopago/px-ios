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
    let paymentStatusDetail: String
    let paymentId: Int64
    let totalAmount: NSDecimalNumber
    let trackListener: PXTrackerListener?
    let flowName: String?
    let flowDetails: [String: Any]?
    let sessionId: String?

    
    public init(campaingId: String?, currencyId: String?, paymentStatusDetail: String, totalAmount: NSDecimalNumber, paymentId: Int64, trackListener: PXTrackerListener, flowName: String?, flowDetails: [String: Any]?, sessionId: String?) {
        self.campaingId = campaingId
        self.currencyId = currencyId
        self.totalAmount = totalAmount
        self.trackListener = trackListener
        self.flowName = flowName
        self.flowDetails = flowDetails
        self.paymentStatusDetail = paymentStatusDetail
        self.paymentId = paymentId
        self.sessionId = sessionId
    }
}

