//
//  Order.swift
//  MercadoPagoSDK
//
//  Created by Matias Gualino on 6/3/15.
//  Copyright (c) 2015 com.mercadopago. All rights reserved.
//

import Foundation

open class Order : NSObject {
    open var _id : Int = 0
    open var type : String!
    
    open class func fromJSON(_ json : NSDictionary) -> Order {
        let order : Order = Order()
        if let _id = JSONHandler.attemptParseToInt(json["id"]){
            order._id = _id
        }
        if let type = JSONHandler.attemptParseToString(json["type"]){
            order.type = type
        }
        return order
    }
}

public func ==(obj1: Order, obj2: Order) -> Bool {
    
    let areEqual =
    obj1._id == obj2._id &&
    obj1.type == obj2.type
    
    return areEqual
}
