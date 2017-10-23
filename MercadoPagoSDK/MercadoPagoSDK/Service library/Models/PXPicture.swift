//
//  PXPicture.swift
//  MercadoPagoSDK
//
//  Created by Eden Torres on 10/20/17.
//  Copyright © 2017 MercadoPago. All rights reserved.
//

import Foundation
open class PXPicture: NSObject {
    open var id: String!
    open var size: String!
    open var url: String!
    open var secureUrl: String!

    open func toJSONString() -> String {
        return JSONHandler.jsonCoding(self.toJSON())
    }

    open func toJSON() -> [String:Any] {
        let map = ["": ""]
        return map
    }

    open class func fromJSON(_ json: [String:Any]) -> PXPicture {
        return PXPicture()
    }
}
