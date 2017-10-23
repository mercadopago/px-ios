//
//  PXCampaings.swift
//  MercadoPagoSDK
//
//  Created by Eden Torres on 10/23/17.
//  Copyright © 2017 MercadoPago. All rights reserved.
//

import Foundation

open class PXCampaings: NSObject {

    open var id: Int64!
    open var code: String!
    open var name: String!
    open var discountType: String!
    open var minPaymentAmount: Double!
    open var maxPaymentAmount: Double!
    open var totalAmountLimit: Double!
    open var maxCoupons: Int64!
    open var maxCouponsByCode: Int!
    open var maxRedeemPerUser: Int!
    open var siteId: String!
    open var marketplace: String!
    open var codeType: String!
    open var maxUserAmountPerCampaign: Double!
    open var paymentMethodsIds: [String]!
    open var paymentTypesIds: [String]!
    open var cardIssuersIds: [String]!
    open var shippingModes: [String]!
    open var clientId: Int64!
    open var tags: [String]!
    open var multipleCodeLimit: Int!
    open var codeCount: Int!
    open var couponAmount: Double!
    open var collectors: [Int64]!

    open func toJSONString() -> String {
        return JSONHandler.jsonCoding(self.toJSON())
    }

    open func toJSON() -> [String:Any] {
        let map = ["": ""]
        return map
    }

    open class func fromJSON(_ json: [String:Any]) -> PXCampaings {
        return PXCampaings()
    }
}
