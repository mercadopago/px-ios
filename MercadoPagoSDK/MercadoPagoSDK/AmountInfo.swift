//
//  PaymentInfo.swift
//  MercadoPagoSDK
//
//  Created by Maria cristina rodriguez on 29/7/16.
//  Copyright © 2016 MercadoPago. All rights reserved.
//

import UIKit

@objcMembers open class AmountInfo: NSObject {

    var amount: Double!
    var currency: Currency!

    override init() {
        super.init()
    }

    open class func fromJSON(_ json: NSDictionary) -> AmountInfo {

        let amountInfo: AmountInfo = AmountInfo()

        if let amount = JSONHandler.attemptParseToDouble(json["amount"]) {
            amountInfo.amount = amount
        }

        let currency = Currency()
        if let thousandsSeparator = JSONHandler.attemptParseToString(json["thousands_separator"]) {
            currency.thousandsSeparator = thousandsSeparator
        }

        if let decimalSeparator = JSONHandler.attemptParseToString(json["decimal_separator"]) {
            currency.decimalSeparator = decimalSeparator
        }

        if let symbol = JSONHandler.attemptParseToString(json["symbol"]) {
            currency.symbol = symbol
        }

        if let decimalPlaces = JSONHandler.attemptParseToInt(json["decimal_places"]) {
            currency.decimalPlaces = decimalPlaces
        }

        amountInfo.currency = currency
        return amountInfo
    }

    open func toJSONString() -> String {
       return JSONHandler.jsonCoding(self.toJSON())
    }

    open func toJSON() -> [String: Any] {
        let thousands_separator: Any = self.currency == nil ? JSONHandler.null : String(self.currency!.thousandsSeparator)
        let decimal_separator: Any = self.currency == nil ? JSONHandler.null : String(self.currency!.decimalSeparator)
        let symbol: Any = self.currency == nil ? JSONHandler.null : self.currency!.symbol
        let decimal_places: Any = self.currency == nil ? JSONHandler.null : self.currency!.decimalPlaces

        let obj: [String: Any] = ["amount": self.amount!,
            "thousands_separator": thousands_separator,
            "decimal_separator": decimal_separator,
            "symbol": symbol,
            "decimal_places": decimal_places]
        return obj
    }
}
