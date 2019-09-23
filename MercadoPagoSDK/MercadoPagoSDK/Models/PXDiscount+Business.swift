//
//  PXDiscount+Business.swift
//  MercadoPagoSDK
//
//  Created by Demian Tejo on 29/5/18.
//  Copyright © 2018 MercadoPago. All rights reserved.
//

import Foundation

internal extension PXDiscount {
    /// :nodoc:
    override open var description: String {
        if getDiscountDescription() != "" {
            return getDiscountDescription() + "discount_coupon_detail_description".localized_beta
        } else {
            return ""
        }
    }

    func getDiscountDescription() -> String {
        return name ?? "discount_coupon_detail_default_concept".localized_beta
    }

    func getDiscountAmount() -> Double? {
        return self.couponAmount
    }

    func hasPercentOff() -> Bool {
        return percentOff != 0
    }

    var concept: String {
        return getDiscountDescription()
    }

    func toJSONDictionary() -> [String: Any] {

        var obj: [String: Any] = [
            "id": self.id,
            "percent_off": self.percentOff ,
            "amount_off": self.amountOff ,
            "coupon_amount": self.couponAmount
        ]

        if let name = self.name {
            obj["name"] = name
        }

        if let currencyId = self.currencyId {
            obj["currency_id"] = currencyId
        }

        obj["concept"] = self.concept

        if let campaignId = self.id {
            obj["campaign_id"] = campaignId
        }

        return obj
    }
}
