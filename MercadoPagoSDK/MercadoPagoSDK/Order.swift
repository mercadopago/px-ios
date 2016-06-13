//
//  Order.swift
//  MercadoPagoSDK
//
//  Created by Matias Gualino on 6/3/15.
//  Copyright (c) 2015 com.mercadopago. All rights reserved.
//

import Foundation

public class Order : NSObject {
    public var _id : Int = 0
    public var type : String!
    
    public class func fromJSON(json : NSDictionary) -> Order {
        let order : Order = Order()
		if json["id"] != nil && !(json["id"]! is NSNull) {
			order._id = (json["id"] as? Int)!
		}
        order.type = json["type"] as? String
        return order
    }
}

public func ==(obj1: Order, obj2: Order) -> Bool {
    
    let areEqual =
    obj1._id == obj2._id &&
    obj1.type == obj2.type
    
    return areEqual
}