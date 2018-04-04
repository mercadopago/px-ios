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
    open var refundId: Int = 0
    open var metadata: NSObject!
    open var paymentId: Int64 = 0
    open var source: String!
    open var uniqueSequenceNumber: String!
}
