//
//  PXSite.swift
//  MercadoPagoSDK
//
//  Created by Eden Torres on 10/20/17.
//  Copyright © 2017 MercadoPago. All rights reserved.
//

import Foundation
open class PXSite: NSObject {

    open var id: String!
    open var currencyId: String!

    override init() {
        super.init()
    }

    public init(id: String, currencyId: String) {
        self.id = id
        self.currencyId = currencyId
    }

    open func toJSONString() -> String {
        return JSONHandler.jsonCoding(self.toJSON())
    }

    open func toJSON() -> [String:Any] {
        let map = ["": ""]
        return map
    }

    open class func fromJSON(_ json: [String:Any]) -> PXSite {
        return PXSite()
    }
}
