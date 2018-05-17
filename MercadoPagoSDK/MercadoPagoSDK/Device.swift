//
//  Device.swift
//  MercadoPagoSDK
//
//  Created by Matias Gualino on 28/12/14.
//  Copyright (c) 2014 com.mercadopago. All rights reserved.
//

import Foundation

@objcMembers open class Device: NSObject {
    open var fingerprint: Fingerprint!

    public override init() {
        super.init()
        self.fingerprint = Fingerprint()
    }

    open func toJSONString() -> String {
        return JSONHandler.jsonCoding(toJSON())
    }

    open func toJSON() -> [String: Any] {
        let finger: [String: Any] = self.fingerprint.toJSON()
        let obj: [String: Any] = [
            "fingerprint": finger
        ]
        return obj
    }
}
