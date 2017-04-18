//
//  PayerCost.swift
//  MercadoPagoSDK
//
//  Created by Matias Gualino on 28/12/14.
//  Copyright (c) 2014 com.mercadopago. All rights reserved.
//

import Foundation

open class PayerCost : NSObject, Cellable {
    open var installments : Int = 0
    open var installmentRate : Double = 0
    open var labels : [String]!
    open var minAllowedAmount : Double = 0
    open var maxAllowedAmount : Double = 0
    open var recommendedMessage : String!
    open var installmentAmount : Double = 0
    open var totalAmount : Double = 0
    
    
    open func getCell(width: Double, height: Double) -> UITableViewCell {
        let bundle = MercadoPago.getBundle()
        let cell: PayerCostRowTableViewCell = bundle!.loadNibNamed("PayerCostRowTableViewCell", owner: nil, options: nil)?[0] as! PayerCostRowTableViewCell
        cell.fillCell(payerCost: self)
        cell.addSeparatorLineToBottom(width: width, height: height)
        cell.selectionStyle = .none
        
        return cell
    }
    
    
    public init (installments : Int = 0, installmentRate : Double = 0, labels : [String] = [],
        minAllowedAmount : Double = 0, maxAllowedAmount : Double = 0, recommendedMessage: String! = nil, installmentAmount: Double = 0, totalAmount: Double = 0) {

        self.installments = installments
        self.installmentRate = installmentRate
        self.labels = labels
        self.minAllowedAmount = minAllowedAmount
        self.maxAllowedAmount = maxAllowedAmount
        self.recommendedMessage = recommendedMessage
        self.installmentAmount = installmentAmount
        self.totalAmount = totalAmount
    }
    
  
    open class func fromJSON(_ json : NSDictionary) -> PayerCost {
        let payerCost : PayerCost = PayerCost()
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
            for i in 0..<labelsArray.count {
                if let label = labelsArray[i] as? String {
                    payerCost.labels.append(label)
                }
            }
        }
        return payerCost
    }
    
    open func toJSONString() -> String {
        return JSONHandler.jsonCoding(toJSON())
    }
    
    open func toJSON() -> [String:Any] {
        let obj:[String:Any] = [
            "installments": self.installments,
            "installmentRate" : self.installmentRate,
            "minAllowedAmount" : self.installmentRate,
            "maxAllowedAmount" : self.installmentRate,
            "recommendedMessage" : self.recommendedMessage,
            "installmentAmount" : self.installmentAmount,
            "totalAmount" : self.totalAmount,
            ]
        return obj
    }

    public func hasInstallmentsRate() -> Bool {
        return (self.installmentRate > 0 && self.installments > 1)
    }
    
    public func getCFTValue() -> String? {
        for label in labels {
            let values = label.components(separatedBy: "|")
            for value in values {
                if let range = value.range(of: "CFT_"){
                    return value.substring(from: range.upperBound)
                }
            }
        }
        return nil
    }
    
    public func getTEAValeu() -> String? {
        
        for label in labels {
            let values = label.components(separatedBy: "|")
            for value in values {
                if let range = value.range(of: "TEA_"){
                    return value.substring(from: range.upperBound)
                }
            }
        }
        return nil
    }
}


public func ==(obj1: PayerCost, obj2: PayerCost) -> Bool {
    
    let areEqual =
    obj1.installments == obj2.installments &&
        obj1.installmentRate == obj2.installmentRate &&
        obj1.labels == obj2.labels &&
        obj1.minAllowedAmount == obj2.minAllowedAmount &&
        obj1.maxAllowedAmount == obj2.maxAllowedAmount &&
        obj1.recommendedMessage == obj2.recommendedMessage &&
        obj1.installmentAmount == obj2.installmentAmount &&
        obj1.totalAmount == obj2.totalAmount
    
    return areEqual
}

