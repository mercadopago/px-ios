//
//  PXIssuer.swift
//  MercadoPagoSDK
//
//  Created by Eden Torres on 10/20/17.
//  Copyright © 2017 MercadoPago. All rights reserved.
//

import Foundation
open class PXIssuer: NSObject {
    open var id: String!
    open var name: String!

    open func toJSONString() -> String {
        return JSONHandler.jsonCoding(self.toJSON())
    }

    open func toJSON() -> [String:Any] {
        let map = ["": ""]
        return map
    }

    open class func fromJSON(_ json: [String:Any]) -> PXIssuer {
        let pxIssuer: PXIssuer = PXIssuer()
        
        if let _id = json["id"] as? String {
            pxIssuer.id = JSONHandler.attemptParseToString(json["id"])
        }
        if let name = JSONHandler.attemptParseToString(json["name"]) {
            pxIssuer.name = name
        }
        
        return pxIssuer
    }
}
