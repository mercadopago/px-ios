//
//  BinMask.swift
//  MercadoPagoSDK
//
//  Created by Matias Gualino on 6/3/15.
//  Copyright (c) 2015 com.mercadopago. All rights reserved.
//

import Foundation

open class BinMask: NSObject {
    open var exclusionPattern: String!
    open var installmentsPattern: String!
    open var pattern: String!

    public override init() {
        super.init()
    }

    open func toJSON() -> [String: Any] {
        let exclusionPattern: Any = String.isNullOrEmpty(self.exclusionPattern) ?  JSONHandler.null : self.exclusionPattern!
        let installmentsPattern: Any = self.installmentsPattern == nil ?  JSONHandler.null : self.installmentsPattern
        let pattern: Any = self.pattern == nil ? JSONHandler.null : self.pattern

        let obj: [String: Any] = [
            "pattern": pattern,
            "installments_pattern": installmentsPattern,
            "exclusion_pattern": exclusionPattern
            ]
        return obj
    }

    open func toJSONString() -> String {
        return JSONHandler.jsonCoding(self.toJSON())
    }
}
