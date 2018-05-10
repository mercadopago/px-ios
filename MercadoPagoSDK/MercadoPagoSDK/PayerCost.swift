//
//  PayerCost.swift
//  MercadoPagoSDK
//
//  Created by Matias Gualino on 28/12/14.
//  Copyright (c) 2014 com.mercadopago. All rights reserved.
//

import Foundation

@objcMembers open class PayerCost: NSObject, Cellable {

    public var objectType: ObjectTypes = ObjectTypes.payerCost
    open var installments: Int = 0
    open var installmentRate: Double = 0
    open var labels: [String]!
    open var minAllowedAmount: Double = 0
    open var maxAllowedAmount: Double = 0
    open var recommendedMessage: String!
    open var installmentAmount: Double = 0
    open var totalAmount: Double = 0

    public init (installments: Int = 0, installmentRate: Double = 0, labels: [String] = [],
                 minAllowedAmount: Double = 0, maxAllowedAmount: Double = 0, recommendedMessage: String! = nil, installmentAmount: Double = 0, totalAmount: Double = 0) {

        self.installments = installments
        self.installmentRate = installmentRate
        self.labels = labels
        self.minAllowedAmount = minAllowedAmount
        self.maxAllowedAmount = maxAllowedAmount
        self.recommendedMessage = recommendedMessage
        self.installmentAmount = installmentAmount
        self.totalAmount = totalAmount
    }

    open class func fromJSON(_ json: NSDictionary) -> PayerCost {
                let payerCost: PayerCost = PayerCost()
                if let installments = JSONHandler.attemptParseToInt(json["installments"]) {
                        payerCost.installments = installments
                }
                if let installmentRate = JSONHandler.attemptParseToDouble(json["installment_rate"]) {
                        payerCost.installmentRate = installmentRate
                    }
                if let minAllowedAmount = JSONHandler.attemptParseToDouble(json["min_allowed_amount"]) {
                        payerCost.minAllowedAmount = minAllowedAmount
                    }
                if let maxAllowedAmount = JSONHandler.attemptParseToDouble(json["max_allowed_amount"]) {
                        payerCost.maxAllowedAmount = maxAllowedAmount
                    }
                if let installmentAmount = JSONHandler.attemptParseToDouble(json["installment_amount"]) {
                        payerCost.installmentAmount = installmentAmount
                    }
                if let totalAmount = JSONHandler.attemptParseToDouble(json["total_amount"]) {
                        payerCost.totalAmount = totalAmount
                    }
                if let recommendedMessage = JSONHandler.attemptParseToString(json["recommended_message"]) {
                        payerCost.recommendedMessage = recommendedMessage
                    }
                if let labelsArray = json["labels"] as? NSArray {
                        for index in 0..<labelsArray.count {
                                if let label = labelsArray[index] as? String {
                                        payerCost.labels.append(label)
                                    }
                            }
                    }
                return payerCost
            }

    open func toJSONString() -> String {
        return JSONHandler.jsonCoding(toJSON())
    }

    open func toJSON() -> [String: Any] {
        let obj: [String: Any] = [
            "installments": self.installments,
            "installment_rate": self.installmentRate,
            "min_allowed_amount": self.minAllowedAmount,
            "max_allowed_amount": self.maxAllowedAmount,
            "recommended_message": self.recommendedMessage,
            "installment_amount": self.installmentAmount,
            "total_amount": self.totalAmount
        ]
        return obj
    }

    public func hasInstallmentsRate() -> Bool {
        return (self.installmentRate > 0 && self.installments > 1)
    }

    public func hasCFTValue() -> Bool {
        return !String.isNullOrEmpty(getCFTValue())
    }

    public func getCFTValue() -> String? {
        for label in labels {
            let values = label.components(separatedBy: "|")
            for value in values {
                if let range = value.range(of: "CFT_") {
                    return String(value[range.upperBound...])
                }
            }
        }
        return nil
    }

    public func getTEAValue() -> String? {

        for label in labels {
            let values = label.components(separatedBy: "|")
            for value in values {
                if let range = value.range(of: "TEA_") {
                    return String(value[range.upperBound...])
                }
            }
        }
        return nil
    }
}
