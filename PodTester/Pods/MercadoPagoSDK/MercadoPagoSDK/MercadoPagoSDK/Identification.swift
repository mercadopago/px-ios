//
//  Identification.swift
//  MercadoPagoSDK
//
//  Created by Matias Gualino on 28/12/14.
//  Copyright (c) 2014 com.mercadopago. All rights reserved.
//

import Foundation

open class Identification : NSObject {
    
    open var type : String?
    open var number : String?

    
    public init (type: String? = nil, number : String? = nil) {
        self.type = type
        self.number = number
    }
    
    open class func fromJSON(_ json : NSDictionary) -> Identification {
        let identification : Identification = Identification()
        identification.type = json["type"] as? String
        identification.number = json["number"] as? String
        return identification
    }
    
    open func toJSONString() -> String {
        return JSONHandler.jsonCoding(self.toJSON())
    }
    
    open func toJSON() -> [String:Any] {
        let type : Any = String.isNullOrEmpty(self.type) ?  JSONHandler.null : self.type!
        let number : Any = String.isNullOrEmpty(self.number) ?  JSONHandler.null : self.number!
        let obj:[String:Any] = [
            "type":type ,
            "number": number
        ]
        return obj
    }
}

public func ==(obj1: Identification, obj2: Identification) -> Bool {
    
    let areEqual =
        obj1.type == obj2.type &&
        obj1.number == obj2.number
    
    return areEqual
}
