//
//  PXDevice.swift
//  MercadoPagoSDK
//
//  Created by Eden Torres on 10/20/17.
//  Copyright © 2017 MercadoPago. All rights reserved.
//

import Foundation
open class PXDevice: NSObject {

    open var fingerprint: PXFingerprint!

    open func toJSONString() -> String {
        return JSONHandler.jsonCoding(toJSON())
    }

    open func toJSON() -> [String: Any] {
        let finger: [String:Any] = self.fingerprint.toJSON()
        let obj: [String:Any] = [
            "fingerprint": finger
        ]
        return obj
    }
}
