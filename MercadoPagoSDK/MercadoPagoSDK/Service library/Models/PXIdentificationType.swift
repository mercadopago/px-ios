//
//  PXIdentificationType.swift
//  MercadoPagoSDK
//
//  Created by Eden Torres on 10/20/17.
//  Copyright © 2017 MercadoPago. All rights reserved.
//

import Foundation
open class PXIdentificationType: NSObject {
    open var id: String!
    open var name: String!
    open var minLength: Int!
    open var maxLength: Int!

    open func toJSONString() -> String {
        return JSONHandler.jsonCoding(self.toJSON())
    }

    open func toJSON() -> [String:Any] {
        let map = ["":""]
        return map
    }

    open class func fromJSON(_ json: [String:Any]) -> PXIdentificationType {
        return PXIdentificationType()
    }
}
