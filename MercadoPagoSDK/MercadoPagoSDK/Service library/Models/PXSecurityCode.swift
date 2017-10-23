//
//  PXSecurityCode.swift
//  MercadoPagoSDK
//
//  Created by Eden Torres on 10/20/17.
//  Copyright © 2017 MercadoPago. All rights reserved.
//

import Foundation
open class PXSecurityCode: NSObject {

    open var cardLocation: String!
    open var mode: String!
    open var length: Int!

    open func toJSONString() -> String {
        return JSONHandler.jsonCoding(self.toJSON())
    }

    open func toJSON() -> [String:Any] {
        let map = ["": ""]
        return map
    }

    open class func fromJSON(_ json: [String:Any]) -> PXSecurityCode {
        return PXSecurityCode()
    }
}
