//
//  Issuer.swift
//  MercadoPagoSDK
//
//  Created by Matias Gualino on 31/12/14.
//  Copyright (c) 2014 com.mercadopago. All rights reserved.
//

import Foundation

open class Issuer : NSObject {
    open var _id : NSNumber?
    open var name : String?
    
    open class func fromJSON(_ json : NSDictionary) -> Issuer {
        let issuer : Issuer = Issuer()
        
        if let _id = JSONHandler.attemptParseToString(json["id"])?.numberValue{
            issuer._id = _id
        }
        if let name = JSONHandler.attemptParseToString(json["name"]){
            issuer.name = name
        }
        
        return issuer
    }
    
    open func toJSONString() -> String {
       return JSONHandler.jsonCoding(toJSON())
    }
    
    open func toJSON() -> [String:Any] {
        let id : Any = self._id == nil ? JSONHandler.null : self._id!
        let name : Any = self.name == nil ? JSONHandler.null : self.name!
        let obj:[String:Any] = [
            "id": id,
            "name" : name,
            ]
        return obj
    }
}

public func ==(obj1: Issuer, obj2: Issuer) -> Bool {
    
    let areEqual =
        obj1._id == obj2._id &&
        obj1.name == obj2.name
    
    return areEqual
}
