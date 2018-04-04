//
//  Address.swift
//  MercadoPagoSDK
//
//  Created by Matias Gualino on 31/12/14.
//  Copyright (c) 2014 com.mercadopago. All rights reserved.
//

import Foundation

open class Address: NSObject {
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
