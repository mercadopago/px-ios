//
//  PXItem.swift
//  MercadoPagoSDK
//
//  Created by Eden Torres on 10/20/17.
//  Copyright © 2017 MercadoPago. All rights reserved.
//

import Foundation
open class PXItem: NSObject {

    open var categoryId: String!
    open var currencyId: String!
    open var _description: String!
    open var id: String!
    open var pictureUrl: String!
    open var quantity: Int!
    open var title: String!
    open var unitPrice: Double!

    open func toJSONString() -> String {
        return JSONHandler.jsonCoding(self.toJSON())
    }

    open func toJSON() -> [String:Any] {
        let map = ["": ""]
        return map
    }

    open class func fromJSON(_ json: [String:Any]) -> PXItem {
        return  PXItem()
    }
}
