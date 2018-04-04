//
//  SecurityCode.swift
//  MercadoPagoSDK
//
//  Created by Matias Gualino on 31/12/14.
//  Copyright (c) 2014 com.mercadopago. All rights reserved.
//

import Foundation

open class SecurityCode: NSObject {
    open var length: Int = 0
    open var cardLocation: String!
    open var mode: String!

    public override init() {
        super.init()
    }

    open func toJSONString() -> String {
        return JSONHandler.jsonCoding(toJSON())
    }

    open func toJSON() -> [String: Any] {
        let obj: [String: Any] = [
            "length": self.length,
            "card_location": self.cardLocation == nil ? "" : self.cardLocation!,
            "mode": self.mode == nil ? "" : self.mode!
        ]

        return obj
    }
}
