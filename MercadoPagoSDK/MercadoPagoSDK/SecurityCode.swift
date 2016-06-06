//
//  SecurityCode.swift
//  MercadoPagoSDK
//
//  Created by Matias Gualino on 31/12/14.
//  Copyright (c) 2014 com.mercadopago. All rights reserved.
//

import Foundation

public class SecurityCode : NSObject {
    public var length : Int = 0
    public var cardLocation : String!
    public var mode : String!
    
    public override init(){
        super.init()
    }
    
    public class func fromJSON(json : NSDictionary) -> SecurityCode {
        let securityCode : SecurityCode = SecurityCode()
        if json["length"] != nil && !(json["length"]! is NSNull) {
            securityCode.length = (json["length"]! as? Int)!
        }
        if json["card_location"] != nil && !(json["card_location"]! is NSNull) {
            securityCode.cardLocation = JSON(json["card_location"]!).asString
        }
        if json["mode"] != nil && !(json["mode"]! is NSNull) {
            securityCode.mode = JSON(json["mode"]!).asString
        }
        return securityCode
    }
}

public func ==(obj1: SecurityCode, obj2: SecurityCode) -> Bool {
    
    let areEqual =
    obj1.length == obj2.length &&
    obj1.cardLocation == obj2.cardLocation &&
    obj1.mode == obj2.mode
    
    return areEqual
}