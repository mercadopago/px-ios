//
//  DiscountCoupon.swift
//  MercadoPagoSDK
//
//  Created by Demian Tejo on 12/26/16.
//  Copyright © 2016 MercadoPago. All rights reserved.
//

import UIKit

open class DiscountCoupon: NSObject {

    open static var activeCoupon: DiscountCoupon!

    /*  JSON EXAMPLE
     {
     "id": 12572,
     "name": "testChoOFF",
     "percent_off": 10,
     "amount_off": 0,
     "coupon_amount": 11,
     "currency_id": "ARS",
     "concept": "testConcept"
     }
     {
     "id": 15098,
     "name": "TestChoNativo2 (236387490)",
     "percent_off": 0,
     "amount_off": 15,
     "coupon_amount": 15,
     "currency_id": "ARS",
     "concept": "testConcept"
     }
     */

   open var discountId: UInt
   open var name: String?
   open var percent_off: String = "0"
   open var amount_off: String = "0"
   open var coupon_amount: String = "0"
   open var currency_id: String?
   open var concept: String?
   open var campaignId: String?

   open var amountWithoutDiscount: Double = 0

    open func toJSONString() -> String {
        return JSONHandler.jsonCoding(self.toJSON())
    }

    public init(discountId: UInt) {
        self.discountId = discountId
        super.init()
    }

    func toJSON() -> [String: Any] {

        var obj: [String: Any] = [
            "id": self.discountId,
            "percent_off": Int(self.percent_off) != nil ? Int(self.percent_off)! : 0,
            "amount_off": Int(self.amount_off) != nil ? Int(self.amount_off)! : 0,
            "coupon_amount": Int(self.coupon_amount) != nil ? Int(self.coupon_amount)! : 0
        ]

        if let name = self.name {
            obj["name"] = name
        }

        if let currencyId = self.currency_id {
            obj["currency_id"] = currencyId
        }

        if let concept = self.concept {
            obj["concept"] = concept
        }

        if let campaignId = self.campaignId {
            obj["campaign_id"] = campaignId
        }

        return obj
    }

    open func getDescription() -> String {
        if getDiscountDescription() != "" {
            return getDiscountDescription() + "discount_coupon_detail_description".localized_beta
        } else {
            return ""
        }
    }

    open func getDiscountDescription() -> String {
        let currency = MercadoPagoContext.getCurrency()
        if percent_off != "0" && percent_off != "0.0" {
            return percent_off + " %"
        } else if amount_off != "0" && amount_off != "0.0" {
            return currency.symbol + amount_off
        } else {
            return ""
        }
    }
    open func getDiscountAmount() -> Double? {
        if percent_off != "0" && percent_off != "0.0" {
            return Double(percent_off) // Deberia devolver el monto que se descuenta
        } else if amount_off != "0"  && amount_off != "0.0" {
            return  Double(amount_off)
        }
        return nil
    }

    open func getDiscountReviewDescription() -> String {
        var text = ""
        if let concept = self.concept {
            text = concept
        } else {
           text  = "discount_coupon_detail_default_concept".localized_beta
        }

        if percent_off != "0" && percent_off != "0.0" {
            return text + " " + percent_off + " %"
        }
        return text
    }

    open func newAmount() -> Double {
        return (amountWithoutDiscount - Double(coupon_amount)!)
    }
}
