//
//  PXApiUtil.swift
//  MercadoPagoSDK
//
//  Created by Eden Torres on 10/20/17.
//  Copyright © 2017 MercadoPago. All rights reserved.
//

import Foundation
open class PXApitUtil: NSObject {
    open static let INTERNAL_SERVER_ERROR = 500
    open static let PROCESSING = 499
    open static let BAD_REQUEST = 400
    open static let NOT_FOUND = 404
    open static let OK = 200

    open func toJSONString() -> String {
        return JSONHandler.jsonCoding(self.toJSON())
    }

    open func toJSON() -> [String:Any] {
        let map = ["": ""]
        return map
    }

    open class func fromJSON(_ json: [String:Any]) -> PXApitUtil {
        return PXApitUtil()
    }
}
