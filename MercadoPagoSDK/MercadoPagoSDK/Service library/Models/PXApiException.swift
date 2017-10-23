//
//  PXApiException.swift
//  MercadoPagoSDK
//
//  Created by Eden Torres on 10/20/17.
//  Copyright © 2017 MercadoPago. All rights reserved.
//

import Foundation
open class PXApiException: NSObject {

    open var cause: [PXCause]!
    open var error: String!
    open var message: String!
    open var status: Int!

    open func toJSONString() -> String {
        return JSONHandler.jsonCoding(self.toJSON())
    }

    open func toJSON() -> [String:Any] {
        let map = ["":""]
        return map
    }

    open class func fromJSON(_ json: [String:Any]) -> PXApiException {
        return PXApiException()
    }
}
