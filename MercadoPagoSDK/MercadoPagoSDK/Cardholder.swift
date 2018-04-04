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
