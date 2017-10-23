//
//  PXInstructionReference.swift
//  MercadoPagoSDK
//
//  Created by Eden Torres on 10/20/17.
//  Copyright © 2017 MercadoPago. All rights reserved.
//

import Foundation
open class PXInstructionReference: NSObject {

    open var label: String!
    open var fieldValue: [String]!
    open var separator: String!
    open var comment: String!

    open func toJSONString() -> String {
        return JSONHandler.jsonCoding(self.toJSON())
    }

    open func toJSON() -> [String:Any] {
        let map = ["": ""]
        return map
    }

    open class func fromJSON(_ json: [String:Any]) -> PXInstructionReference {
        return PXInstructionReference()
    }
}
