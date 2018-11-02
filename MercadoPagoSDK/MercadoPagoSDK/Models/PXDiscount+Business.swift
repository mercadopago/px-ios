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
        get {
            if getDiscountDescription() != "" {
                return getDiscountDescription() + "discount_coupon_detail_description".localized_beta
            } else {
                return ""
            }
        }
    }

    internal func getDiscountDescription() -> String {
        let currency = SiteManager.shared.getCurrency()
        if self.percentOff != 0 {
            let percentageAttributedString = Utils.getAttributedPercentage(withAttributes: [:], amount: self.percentOff, addPercentageSymbol: true, negativeAmount: false)
            let string: String = ("total_row_title_percent_off".localized_beta as NSString).replacingOccurrences(of: "%1$s", with: percentageAttributedString.string)
            return string
        } else {
            let amountAttributedString = Utils.getAttributedAmount(withAttributes: [:], amount: self.amountOff, currency: currency, negativeAmount: true)
            let string: String = ("total_row_title_amount_off".localized_beta as NSString).replacingOccurrences(of: "%1$s", with: amountAttributedString.string)
            return string
        }
    }

    internal func getDiscountAmount() -> Double? {
        return self.couponAmount
    }

    internal func hasPercentOff() -> Bool {
        return percentOff != 0
    }

    internal func getDiscountReviewDescription() -> String {
        let text  = "discount_coupon_detail_default_concept".localized_beta
         if self.percentOff != 0 {
            return text + " " + String(describing: self.percentOff) + " %"
        }
        return text
    }
    var concept: String {
        get {
            return getDiscountReviewDescription()
        }
    }

    internal func toJSONDictionary() -> [String: Any] {

        var obj: [String: Any] = [
            "id": self.id,
            "percent_off": self.percentOff ?? 0,
            "amount_off": self.amountOff ??  0,
            "coupon_amount": self.couponAmount ?? 0
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
