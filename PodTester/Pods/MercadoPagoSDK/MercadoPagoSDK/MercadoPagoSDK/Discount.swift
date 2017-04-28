//
//  Discount.swift
//  MercadoPagoSDK
//
//  Created by Matias Gualino on 6/3/15.
//  Copyright (c) 2015 com.mercadopago. All rights reserved.
//

import Foundation

open class Discount : Equatable {
    open var amountOff : NSNumber = 0
    open var couponAmount : NSNumber = 0
    open var currencyId : String!
    open var _id : Int = 0
    open var name : String!
    open var percentOff : NSNumber = 0
    
    
    
    public init (amountOff: NSNumber? = 0, couponAmount : NSNumber? = 0, currencyId: String? = nil, _id: Int? = 0, name : String? = nil, percentOff : NSNumber? = 0 ) {
        self.amountOff = amountOff!
        self.couponAmount = couponAmount!
        self.currencyId = currencyId
        self._id = _id!
        self.name = name
        self.percentOff = percentOff!
    }
    
    open class func fromJSON(_ json : NSDictionary) -> Discount {
        let discount : Discount = Discount()
        if let amountOff = JSONHandler.attemptParseToString(json["amount_off"])?.numberValue {
            discount.amountOff = amountOff
        }
        if let couponAmount = JSONHandler.attemptParseToString(json["coupon_amount"])?.numberValue {
            discount.couponAmount = couponAmount
        }
        if let currencyId = JSONHandler.attemptParseToString(json["currency_id"]) {
            discount.currencyId = currencyId
        }
        if let _id = JSONHandler.attemptParseToInt(json["id"]) {
            discount._id = _id
        }
        if let name = JSONHandler.attemptParseToString(json["name"]) {
            discount.name = name
        }
        if let percentOff = JSONHandler.attemptParseToString(json["percent_off"])?.numberValue {
            discount.percentOff = percentOff
        }
        return discount
    }
    
    
}

public func ==(obj1: Discount, obj2: Discount) -> Bool {
    
    let areEqual =
    obj1.amountOff == obj2.amountOff &&
        obj1.couponAmount == obj2.couponAmount &&
        obj1.currencyId == obj2.currencyId &&
        obj1._id == obj2._id &&
        obj1.name == obj2.name &&
        obj1.percentOff == obj2.percentOff
    
    return areEqual
}
