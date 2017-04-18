//
//  Device.swift
//  MercadoPagoSDK
//
//  Created by Matias Gualino on 28/12/14.
//  Copyright (c) 2014 com.mercadopago. All rights reserved.
//

import Foundation

open class Device : NSObject {
    open var fingerprint : Fingerprint!
    
    public override init() {
        super.init()
        self.fingerprint = Fingerprint()
    }
    
    open func toJSONString() -> String {
        let obj:[String:Any] = [
            "fingerprint": self.fingerprint.toJSONString()
        ]
        return JSONHandler.jsonCoding(obj)
    }
}
