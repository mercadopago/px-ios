//
//  PXCause.swift
//  MercadoPagoSDK
//
//  Created by Eden Torres on 10/20/17.
//  Copyright © 2017 MercadoPago. All rights reserved.
//

import Foundation
open class PXCause: NSObject {
    open var code: String!
    open var _description: String!

    open func toJSONString() -> String {
        return JSONHandler.jsonCoding(self.toJSON())
    }

    open func toJSON() -> [String:Any] {
        let map = ["":""]
        return map
    }

    open class func fromJSON(_ json: [String:Any]) -> PXCause {
        return PXCause()
    }
}
