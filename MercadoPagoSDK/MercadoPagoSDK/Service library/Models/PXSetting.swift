//
//  PXSetting.swift
//  MercadoPagoSDK
//
//  Created by Eden Torres on 10/20/17.
//  Copyright © 2017 MercadoPago. All rights reserved.
//

import Foundation
open class PXSetting: NSObject {

    open var bin: PXBin!
    open var cardNumber: PXCardNumber!
    open var securityCode: PXSecurityCode!

    open func toJSONString() -> String {
        return JSONHandler.jsonCoding(self.toJSON())
    }

    open func toJSON() -> [String:Any] {
        let map = ["": ""]
        return map
    }

    open class func fromJSON(_ json: [String:Any]) -> PXSetting {
        return PXSetting()
    }
}
