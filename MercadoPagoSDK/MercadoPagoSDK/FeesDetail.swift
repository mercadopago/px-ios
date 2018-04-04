//
//  FeesDetail.swift
//  MercadoPagoSDK
//
//  Created by Matias Gualino on 6/3/15.
//  Copyright (c) 2015 com.mercadopago. All rights reserved.
//

import Foundation

open class FeesDetail: NSObject {
    open var amount: Double = 0
    open var amountRefunded: Double = 0
    open var feePayer: String!
    open var type: String!

    func isFinancingFeeType() -> Bool {
        return self.type == "financing_fee"
    }

    open func toJSONString() -> String {
        let type: Any = self.type != nil ? JSONHandler.null : self.type!
        let obj: [String: Any] = [
            "type": type,
            "amountRefunded": self.amountRefunded,
            "amount": self.amount,
            "type": self.type
            ]
        return JSONHandler.jsonCoding(obj)
    }

}
