//
//  Refund.swift
//  MercadoPagoSDK
//
//  Created by Matias Gualino on 6/3/15.
//  Copyright (c) 2015 com.mercadopago. All rights reserved.
//

import Foundation

open class Refund: NSObject {
    open var amount: Double = 0
    open var dateCreated: Date!
    open var _id: Int = 0
    open var metadata: NSObject!
    open var paymentId: Int = 0
    open var source: String!
    open var uniqueSequenceNumber: String!

    open class func fromJSON(_ json: NSDictionary) -> Refund {
        let refund: Refund = Refund()
        if let _id = JSONHandler.attemptParseToInt(json["id"]) {
            refund._id = _id
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
            refund.paymentId = paymentId
        }
        if let dateCreated = JSONHandler.attemptParseToString(json["date_created"]) {
            refund.dateCreated = Utils.getDateFromString(dateCreated)
        }
        return refund
    }

}

public func ==(obj1: Refund, obj2: Refund) -> Bool {

    let areEqual =
    obj1.amount == obj2.amount &&
 //   obj1.dateCreated == obj2.dateCreated &&
    obj1._id == obj2._id &&
    obj1.paymentId == obj2.paymentId &&
    obj1.source == obj2.source &&
    obj1.uniqueSequenceNumber == obj2.uniqueSequenceNumber

    return areEqual
}
