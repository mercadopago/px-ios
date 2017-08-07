//
//  CardNumber.swift
//  MercadoPagoSDK
//
//  Created by Matias Gualino on 6/3/15.
//  Copyright (c) 2015 com.mercadopago. All rights reserved.
//

import Foundation

open class CardNumber: NSObject {
    open var length: Int = 0
    open var validation: String!

    public override init() {
        super.init()
    }

    open class func fromJSON(_ json: NSDictionary) -> CardNumber {
        let cardNumber: CardNumber = CardNumber()
        if let validation = JSONHandler.attemptParseToString(json["validation"]) {
            cardNumber.validation = validation
        }
        if let length = JSONHandler.attemptParseToInt(json["length"]) {
            cardNumber.length = length
        }
        return cardNumber
    }

    open func toJSONString() -> String {
        return JSONHandler.jsonCoding(toJSON())
    }

    open func toJSON() -> [String:Any] {
        let validation : Any = String.isNullOrEmpty(self.validation) ? JSONHandler.null : self.validation!
        let obj: [String:Any] = [
            "length": self.length,
            "validation": validation
            ]
        return obj
    }
}

public func ==(obj1: CardNumber, obj2: CardNumber) -> Bool {

    let areEqual =
    obj1.length == obj2.length &&
    obj1.validation == obj2.validation

    return areEqual
}
