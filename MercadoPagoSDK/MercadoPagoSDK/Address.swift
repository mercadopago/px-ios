//
//  Address.swift
//  MercadoPagoSDK
//
//  Created by Matias Gualino on 31/12/14.
//  Copyright (c) 2014 com.mercadopago. All rights reserved.
//

import Foundation

@objcMembers open class Address: NSObject {
    open var streetName: String?
    open var streetNumber: NSNumber?
    open var zipCode: String?

    public init (streetName: String? = nil, streetNumber: NSNumber? = nil, zipCode: String? = nil) {
        self.streetName = streetName
        self.streetNumber = streetNumber
        self.zipCode = zipCode
    }

    open func toJSONString() -> String {
        return JSONHandler.jsonCoding(toJSON())
    }

    open class func fromJSON(_ json: NSDictionary) -> Address {
        let address: Address = Address()
        if let streetName = JSONHandler.attemptParseToString(json["street_name"]) {
            address.streetName = streetName
        }
        if let streetNumber = JSONHandler.attemptParseToString(json["street_number"]) {
            address.streetNumber = streetNumber.numberValue
        }
        if let zipCode = JSONHandler.attemptParseToString(json["zip_code"]) {
            address.zipCode = zipCode
        }
        return address
    }

    open func toJSON() -> [String: Any] {
        let streetName: Any = self.streetName == nil ? JSONHandler.null : self.streetName!
        let streetNumber: Any = self.streetNumber == nil ? JSONHandler.null : self.streetNumber!
        let zipCode: Any = self.zipCode == nil ? JSONHandler.null : self.zipCode!

        let obj: [String: Any] = [
            "street_name": streetName,
            "street_number": streetNumber,
            "zip_code": zipCode
        ]

        return obj
    }
}
