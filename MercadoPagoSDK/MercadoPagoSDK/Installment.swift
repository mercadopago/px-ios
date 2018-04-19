//
//  Installment.swift
//  MercadoPagoSDK
//
//  Created by Matias Gualino on 6/3/15.
//  Copyright (c) 2015 com.mercadopago. All rights reserved.
//

import Foundation
private func < <T: Comparable>(lhs: T?, rhs: T?) -> Bool {
    switch (lhs, rhs) {
    case let (l?, r?):
        return l < r
    case (nil, _?):
        return true
    default:
        return false
    }
}

private func > <T: Comparable>(lhs: T?, rhs: T?) -> Bool {
    switch (lhs, rhs) {
    case let (l?, r?):
        return l > r
    default:
        return rhs < lhs
    }
}

@objcMembers open class Installment: NSObject {
    open var issuer: Issuer!
    open var payerCosts: [PayerCost]!
    open var paymentMethodId: String!
    open var paymentTypeId: String!

    open class func fromJSON(_ json: NSDictionary) -> Installment {
                let installment: Installment = Installment()

            if let paymentMethodId = JSONHandler.attemptParseToString(json["payment_method_id"]) {
                        installment.paymentMethodId = paymentMethodId
                    }
                if let paymentTypeId = JSONHandler.attemptParseToString(json["payment_type_id"]) {
                        installment.paymentTypeId = paymentTypeId
                    }

                if let issuerDic = json["issuer"] as? NSDictionary {
                        installment.issuer = Issuer.fromJSON(issuerDic)
                    }

                var payerCosts: [PayerCost] = [PayerCost]()
                if let payerCostsArray = json["payer_costs"] as? NSArray {
                        for i in 0..<payerCostsArray.count {
                                if let payerCostDic = payerCostsArray[i] as? NSDictionary {
                                        payerCosts.append(PayerCost.fromJSON(payerCostDic))
                                    }
                            }
                    }
                installment.payerCosts = payerCosts
                return installment
            }

    open func toJSONString() -> String {

        let issuer: Any = self.issuer != nil ? JSONHandler.null : self.issuer.toJSONString()
        var obj: [String: Any] = [
            "issuer": issuer,
            "paymentMethodId": self.paymentMethodId,
            "paymentTypeId": self.paymentTypeId
        ]

        var payerCostsJson = ""
        for pc in payerCosts! {
            payerCostsJson += pc.toJSONString()
        }
        obj["payerCosts"] = payerCostsJson

        return JSONHandler.jsonCoding(obj)
    }

    open func numberOfPayerCostToShow(_ maxNumberOfInstallments: Int? = 0) -> Int {
        var count = 0
        if maxNumberOfInstallments == 0 || maxNumberOfInstallments == nil {
            return self.payerCosts!.count
        }
        for pc in payerCosts! {
            if pc.installments > maxNumberOfInstallments {
                return count
            }
            count += 1
        }

        return count
    }

    open func containsInstallment(_ installment: Int) -> PayerCost? {
        for pc in payerCosts! where pc.installments == installment {
                return pc
        }
        return nil
    }

}
