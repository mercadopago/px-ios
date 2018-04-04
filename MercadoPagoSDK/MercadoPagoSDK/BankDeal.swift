//
//  BankDeal.swift
//  MercadoPagoSDK
//
//  Created by Matias Gualino on 22/5/15.
//  Copyright (c) 2015 MercadoPago. All rights reserved.
//

import Foundation

open class BankDeal: NSObject {

	open var promoId: String!
	open var issuer: Issuer!
	open var recommendedMessage: String!
	open var paymentMethods: [PaymentMethod]!
	open var legals: String!
	open var url: String?

    open func toJSONString() -> String {
        return JSONHandler.jsonCoding(toJSON())
    }

    open func toJSON() -> [String: Any] {
        let issuer: Any = (self.issuer == nil) ? JSONHandler.null : self.issuer.toJSON()
        let url: Any = (self.url != nil) ? self.url! : ""

        var obj: [String: Any] = [
            "promoId": self.promoId ,
            "issuer": issuer,
            "recommendedMessage": self.recommendedMessage ?? "",
            "legals": self.legals ?? "",
            "url": url
        ]

        var arrayPMs = ""
        if !Array.isNullOrEmpty(self.paymentMethods) {
            for pm in self.paymentMethods {
                arrayPMs.append(pm.toJSONString() + ",")
            }
            obj["payment_methods"] = String(arrayPMs.dropLast())
        }

        return obj
    }
	open class func getDateFromString(_ string: String!) -> Date! {
		if string == nil {
			return nil
		}
		let dateFormatter = DateFormatter()
		dateFormatter.dateFormat = "yyyy-MM-dd"
		var dateArr = string.split {$0 == "T"}.map(String.init)
		return dateFormatter.date(from: dateArr[0])
	}
}
