//
//  Refund.swift
//  MercadoPagoSDK
//
//  Created by Matias Gualino on 6/3/15.
//  Copyright (c) 2015 com.mercadopago. All rights reserved.
//

import Foundation

@objcMembers open class Refund: NSObject {
    open var amount: Double = 0
    open var dateCreated: Date!
    open var refundId: Int = 0
    open var metadata: NSObject!
    open var paymentId: Int64 = 0
    open var source: String!
    open var uniqueSequenceNumber: String!

    open class func fromJSON(_ json: NSDictionary) -> Refund {
        let refund: Refund = Refund()
        if let id = JSONHandler.attemptParseToInt(json["id"]) {
            refund.refundId = id
        }
        if let amount = JSONHandler.attemptParseToDouble(json["amount"]) {
            refund.amount = amount
        }
        if let source = JSONHandler.attemptParseToString(json["source"]) {
            refund.source = source
        }
        if let uniqueSequenceNumber = JSONHandler.attemptParseToString(json["unique_sequence_number"]) {
            refund.uniqueSequenceNumber = uniqueSequenceNumber
        }
        if let paymentId = JSONHandler.attemptParseToInt(json["payment_id"]) {
            refund.paymentId = Int64(paymentId)
        }
        if let dateCreated = JSONHandler.attemptParseToString(json["date_created"]) {
            refund.dateCreated = Utils.getDateFromString(dateCreated)
        }
        return refund
    }
}
