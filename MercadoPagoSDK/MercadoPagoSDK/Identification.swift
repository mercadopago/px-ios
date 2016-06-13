//
//  Identification.swift
//  MercadoPagoSDK
//
//  Created by Matias Gualino on 28/12/14.
//  Copyright (c) 2014 com.mercadopago. All rights reserved.
//

import Foundation

public class Identification : NSObject {
    
    public var type : String?
    public var number : String?

    
    public init (type: String? = nil, number : String? = nil) {
        self.type = type
        self.number = number
    }
    
    public class func fromJSON(json : NSDictionary) -> Identification {
        let identification : Identification = Identification()
        identification.type = JSON(json["type"]!).asString
        identification.number = JSON(json["number"]!).asString
        return identification
    }
    
    public func toJSONString() -> String {
        let obj:[String:AnyObject] = [
            "type": String.isNullOrEmpty(self.type) ? JSON.null : self.type!,
            "number": String.isNullOrEmpty(self.number) ? JSON.null : self.number!
        ]
        return JSON(obj).toString()
    }
}

public func ==(obj1: Identification, obj2: Identification) -> Bool {
    
    let areEqual =
        obj1.type == obj2.type &&
        obj1.number == obj2.number
    
    return areEqual
}