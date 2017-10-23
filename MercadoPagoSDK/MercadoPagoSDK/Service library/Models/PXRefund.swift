//
//  PXRefund.swift
//  MercadoPagoSDK
//
//  Created by Eden Torres on 10/20/17.
//  Copyright © 2017 MercadoPago. All rights reserved.
//

import Foundation
open class PXRefund: NSObject {
    open var dateCreated: Date!
    open var id: String!
    open var metadata: NSObject!
    open var paymentId: Int64!
    open var source: String!
    open var uniqueSecuenceNumber: String!

    open func toJSONString() -> String {
        return JSONHandler.jsonCoding(self.toJSON())
    }

    open func toJSON() -> [String:Any] {

    }

    open class func fromJSON(_ json: [String:Any]) -> PXRefund {

    }
}
