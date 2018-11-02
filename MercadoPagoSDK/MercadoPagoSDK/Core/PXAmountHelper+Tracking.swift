//
//  PXAmountHelper+Tracking.swift
//  MercadoPagoSDK
//
//  Created by Eden Torres on 25/10/2018.
//
import Foundation

extension PXAmountHelper {
    func getDiscountForTracking() -> [String: Any] {
        var dic: [String: Any] = [:]

        guard let discount = discount, let campaign = campaign else {
            return dic
        }

        if discount.hasPercentOff() {
            dic["type"] = "percentage"
            dic["percentage"] = discount.percentOff
        } else {
            dic["type"] = "fixed_amount"
            dic["fixed_amount"] = discount.amountOff
        }
        dic["amount_to_discount"] = discount.couponAmount
        dic["max_amount_to_discount"] = campaign.maxCouponAmount
        dic["max_redeem_per_user"] = campaign.maxRedeemPerUser
        return dic
    }
}
