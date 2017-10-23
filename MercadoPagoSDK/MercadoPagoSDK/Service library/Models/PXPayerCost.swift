//
//  PXPayerCost.swift
//  MercadoPagoSDK
//
//  Created by Eden Torres on 10/20/17.
//  Copyright © 2017 MercadoPago. All rights reserved.
//

import Foundation
open class PXPayerCost: NSObject {

    open var installmentRate: Double!
    open var labels: [String]!
    open var minAllowedAmount: Double!
    open var maxAllowedAmount: Double!
    open var recommendMessage: String!
    open var installmentAmount: Double!
    open var totalAmount: Double!

    open func toJSONString() -> String {
        return JSONHandler.jsonCoding(self.toJSON())
    }

    open func toJSON() -> [String:Any] {
        let map = ["":""]
        return map
    }

    open class func fromJSON(_ json: [String:Any]) -> PXPayerCost {
        return PXPayerCost()
    }
}
