//
//  PXPaymentPreference.swift
//  MercadoPagoSDK
//
//  Created by Eden Torres on 10/23/17.
//  Copyright © 2017 MercadoPago. All rights reserved.
//

import Foundation
open class PXPaymentPreference: NSObject {

    open var maxAcceptedInstallments: Int!
    open var defaultInstallments: Int!
    open var excludedPaymentMethodIds: [String]!
    open var excludedPaymentTypeIds: [String]!
    open var defaultPaymentMethodId: String!
    open var defaultPaymentTypeId: String!

    open func toJSONString() -> String {
        return JSONHandler.jsonCoding(self.toJSON())
    }

    open func toJSON() -> [String:Any] {
        let map = ["": ""]
        return map
    }

    open class func fromJSON(_ json: [String:Any]) -> PXPaymentPreference {
        return PXPaymentPreference()
    }
}
