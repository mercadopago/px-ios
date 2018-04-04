//
//  PaymentInfo.swift
//  MercadoPagoSDK
//
//  Created by Maria cristina rodriguez on 29/7/16.
//  Copyright © 2016 MercadoPago. All rights reserved.
//

import UIKit

open class AmountInfo: NSObject {

    var amount: Double!
    var currency: Currency!

    override init() {
        super.init()
    }

    open func toJSONString() -> String {
       return JSONHandler.jsonCoding(self.toJSON())
    }

    open func toJSON() -> [String: Any] {
        let thousands_separator: Any = self.currency == nil ? JSONHandler.null : String(self.currency!.thousandsSeparator) ?? ""
        let decimal_separator: Any = self.currency == nil ? JSONHandler.null : String(self.currency!.decimalSeparator) ?? ""
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
