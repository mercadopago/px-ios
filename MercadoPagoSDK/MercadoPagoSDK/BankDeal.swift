//
//  BankDeal.swift
//  MercadoPagoSDK
//
//  Created by Matias Gualino on 22/5/15.
//  Copyright (c) 2015 MercadoPago. All rights reserved.
//

import Foundation

@objcMembers open class BankDeal: NSObject {

	open var promoId: String!
	open var issuer: Issuer!
	open var recommendedMessage: String!
	open var paymentMethods: [PaymentMethod]!
	open var legals: String!
	open var url: String?

    open class func fromJSON(_ json: NSDictionary) -> BankDeal {

                let promo: BankDeal = BankDeal()
                promo.promoId = json["id"] as? String

                if let issuerDic = json["issuer"] as? NSDictionary {
                       promo.issuer = Issuer.fromJSON(issuerDic)
                    }

                if let recommendedMessage = JSONHandler.attemptParseToString(json["recommended_message"]) {
                        promo.recommendedMessage = recommendedMessage
                    }
                if let recommendedMessage = JSONHandler.attemptParseToString(json["recommended_message"]) {
                        promo.recommendedMessage = recommendedMessage
                    }

                if let picDic = json["picture"] as? NSDictionary {
                        if let url = JSONHandler.attemptParseToString(picDic["url"]) {
                                promo.url = url
                            }
                    }

                var paymentMethods: [PaymentMethod] = [PaymentMethod]()
                if let pmArray = json["payment_methods"] as? NSArray {
                        for i in 0..<pmArray.count {
                                if let pmDic = pmArray[i] as? NSDictionary {
                                        paymentMethods.append(PaymentMethod.fromJSON(pmDic))
                                   }
                            }
                   }

                promo.paymentMethods = paymentMethods

                promo.legals = json["legals"] as? String

                return promo
            }

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
