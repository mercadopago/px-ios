//
//  FeesDetail.swift
//  MercadoPagoSDK
//
//  Created by Matias Gualino on 6/3/15.
//  Copyright (c) 2015 com.mercadopago. All rights reserved.
//

import Foundation

@objcMembers open class FeesDetail: NSObject {
    open var amount: Double = 0
    open var amountRefunded: Double = 0
    open var feePayer: String!
    open var type: String!

    open class func fromJSON(_ json: NSDictionary) -> FeesDetail {
                let fd: FeesDetail = FeesDetail()
                if let type = JSONHandler.attemptParseToString(json["type"]) {
                        fd.type = type
                    }
                if let feePayer = JSONHandler.attemptParseToString(json["fee_payer"]) {
                        fd.feePayer = feePayer
                    }
                if let amount = JSONHandler.attemptParseToDouble(json["amount"]) {
                        fd.amount = amount
                    }
                if let amountRefunded = JSONHandler.attemptParseToDouble(json["amount_refunded"]) {
                        fd.amountRefunded = amountRefunded
                    }
                return fd
            }

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
