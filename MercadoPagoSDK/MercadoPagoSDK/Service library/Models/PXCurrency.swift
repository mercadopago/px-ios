//
//  PXCurrency.swift
//  MercadoPagoSDK
//
//  Created by Eden Torres on 10/20/17.
//  Copyright © 2017 MercadoPago. All rights reserved.
//

import Foundation
open class PXCurrency: NSObject {

    open var id: String!
    open var desciption: String!
    open var symbol: String!
    open var decimalPlaces: Int!
    open var decimalSeparator: String!
    open var thousandsSeparator: String!

    open func toJSONString() -> String {
        return JSONHandler.jsonCoding(self.toJSON())
    }

    open func toJSON() -> [String:Any] {
        let map = ["": ""]
        return map
    }

    open class func fromJSON(_ json: [String:Any]) -> PXCurrency {
        return PXCurrency()
    }
}
