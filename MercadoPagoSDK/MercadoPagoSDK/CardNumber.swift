//
//  CardNumber.swift
//  MercadoPagoSDK
//
//  Created by Matias Gualino on 6/3/15.
//  Copyright (c) 2015 com.mercadopago. All rights reserved.
//

import Foundation

public class CardNumber : NSObject {
    public var length : Int = 0
    public var validation : String!
    
    public override init(){
        super.init()
    }
    
    public class func fromJSON(json : NSDictionary) -> CardNumber {
        let cardNumber : CardNumber = CardNumber()
        cardNumber.validation = JSON(json["validation"]!).asString
		if json["length"] != nil && !(json["length"]! is NSNull) {
			cardNumber.length = JSON(json["length"]!).asInt!
		}
        return cardNumber
    }
    
}


public func ==(obj1: CardNumber, obj2: CardNumber) -> Bool {
    
    let areEqual =
    obj1.length == obj2.length &&
    obj1.validation == obj2.validation
    
    return areEqual
}
