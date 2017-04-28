//
//  Phone.swift
//  MercadoPagoSDK
//
//  Created by Matias Gualino on 31/12/14.
//  Copyright (c) 2014 com.mercadopago. All rights reserved.
//

import Foundation

open class Phone : Equatable {
    open var areaCode : String?
    open var number : String?
    
    open class func fromJSON(_ json : NSDictionary) -> Phone {
        let phone : Phone = Phone()
        if let areaCode = JSONHandler.attemptParseToString(json["area_code"]){
             phone.areaCode = areaCode
        }
        if let number = JSONHandler.attemptParseToString(json["number"]){
            phone.number = number
        }
        return phone
    }
}

public func ==(obj1: Phone, obj2: Phone) -> Bool {
    
    let areEqual =
    obj1.areaCode == obj2.areaCode &&
    obj1.number == obj2.number
    
    return areEqual
}
