//
//  Cardholder.swift
//  MercadoPagoSDK
//
//  Created by Matias Gualino on 28/12/14.
//  Copyright (c) 2014 com.mercadopago. All rights reserved.
//

import Foundation

open class Cardholder: NSObject {
    open var name: String?
    open var identification: Identification!

    open class func fromJSON(_ json: NSDictionary) -> Cardholder {
        let cardholder: Cardholder = Cardholder()

        if let name = json["name"] as? String {
            cardholder.name = name
        }

        let identificationDic: NSDictionary = JSONHandler.getValue(of: NSDictionary.self, key: "identification", from: json)
        cardholder.identification = Identification.fromJSON(identificationDic)

        return cardholder
    }

    open func toJSONString() -> String {
        return JSONHandler.jsonCoding(self.toJSON())
    }

    open func toJSON() -> [String: Any] {
        let name: Any = String.isNullOrEmpty(self.name) ? JSONHandler.null : self.name!
        let identification: Any = self.identification == nil ? JSONHandler.null : self.identification!.toJSON()
        let obj: [String: Any] = [
            "name": name,
            "identification": identification
        ]
        return obj
    }
}

public func ==(obj1: Cardholder, obj2: Cardholder) -> Bool {

    let areEqual =
    obj1.name == obj2.name &&
    obj1.identification == obj2.identification

    return areEqual
}
