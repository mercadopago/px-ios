//
//  PXPayer.swift
//  MercadoPagoSDK
//
//  Created by Eden Torres on 10/20/17.
//  Copyright © 2017 MercadoPago. All rights reserved.
//

import Foundation
open class PXPayer: NSObject {

    open var id: String!
    open var accessToken: String!
    open var identification: PXIdentification!
    open var type: String!
    open var entityType: String!
    open var email: String!
    open var firstName: String!
    open var lastName: String!

    open func toJSONString() -> String {
        return JSONHandler.jsonCoding(self.toJSON())
    }

    open func toJSON() -> [String:Any] {
        let map = ["": ""]
        return map
    }

    open class func fromJSON(_ json: [String:Any]) -> PXPayer {
        return PXPayer()
    }
}
