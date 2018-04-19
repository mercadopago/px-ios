//
//  Order.swift
//  MercadoPagoSDK
//
//  Created by Matias Gualino on 6/3/15.
//  Copyright (c) 2015 com.mercadopago. All rights reserved.
//

import Foundation

@objcMembers open class Order: NSObject {
    open var orderId: Int = 0
    open var type: String!

    open class func fromJSON(_ json: NSDictionary) -> Order {
                let order: Order = Order()
                if let orderId = JSONHandler.attemptParseToInt(json["id"]) {
                        order.orderId = orderId
                    }
                if let type = JSONHandler.attemptParseToString(json["type"]) {
                        order.type = type
                }
                return order
            }
}
