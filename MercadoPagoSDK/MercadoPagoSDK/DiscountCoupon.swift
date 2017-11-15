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

   open var _id: String!
   open var name: String?
   open var percent_off: String = "0"
   open var amount_off: String = "0"
   open var coupon_amount: String = "0"
   open var currency_id: String?
   open var concept: String?

   open var amount: Double = 0

    open func toJSONString() -> String {
        return JSONHandler.jsonCoding(self.toJSON())
    }

    func toJSON() -> [String:Any] {
        var obj: [String:Any] = [
            "id": Int(self._id),
            "percent_off": Int(self.percent_off),
            "amount_off": Int(self.amount_off),
            "coupon_amount": Int(self.coupon_amount)
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

        return obj
    }

    open class func fromJSON(_ json: NSDictionary, amount: Double) -> DiscountCoupon? {
        let discount = DiscountCoupon()
        if json["id"] != nil && !(json["id"]! is NSNull) {
            discount._id = String( describing: json["id"] as! NSNumber)
        } else {
            return nil
        }
        if json["name"] != nil && !(json["name"]! is NSNull) {
            discount.name = json["name"] as? String
        }
        if json["percent_off"] != nil && !(json["percent_off"]! is NSNull) {
            discount.percent_off = String( describing: json["percent_off"]  as! NSNumber)
        }
        if json["amount_off"] != nil && !(json["amount_off"]! is NSNull) {
            discount.amount_off = String( describing: json["amount_off"]  as! NSNumber)
        }
        if json["coupon_amount"] != nil && !(json["coupon_amount"]! is NSNull) {
            discount.coupon_amount = String( describing: json["coupon_amount"]  as! NSNumber)
        }
        if json["currency_id"] != nil && !(json["currency_id"]! is NSNull) {
            discount.currency_id = json["currency_id"] as? String
        }
        if json["concept"] != nil && !(json["concept"]! is NSNull) {
            discount.concept = json["concept"] as? String
        }
        discount.amount = amount
        return discount
    }

    open func getDescription() -> String {
        if getDiscountDescription() != "" {
            return getDiscountDescription() + " de descuento".localized
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
        } else if amount_off != "0"  && amount_off != "0.0"  {
            return  Double(amount_off)
        }
        return nil
    }

    open func getDiscountReviewDescription() -> String {
        var text = ""
        if let concept = self.concept {
            text = concept
        } else {
           text  = "Descuento"
        }

        if percent_off != "0" && percent_off != "0.0" {
            return text + " " + percent_off + " %"
        }
        return text
    }

    open func newAmount() -> Double {
        return (amount - Double(coupon_amount)!)
    }
}
