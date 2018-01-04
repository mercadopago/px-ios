//
//  PXCampaign.swift
//  MercadoPagoSDK
//
//  Created by Eden Torres on 10/23/17.
//  Copyright © 2017 MercadoPago. All rights reserved.
//

import Foundation

open class PXCampaign: NSObject, Codable {

    open var id: Int64!
    open var code: String?
    open var name: String?
    open var discountType: String?
    open var minPaymentAmount: Double?
    open var maxPaymentAmount: Double?
    open var totalAmountLimit: Double?
    open var maxCoupons: Int64?
    open var maxCouponsByCode: Int?
    open var maxRedeemPerUser: Int?
    open var siteId: String?
    open var marketplace: String?
    open var codeType: String?
    open var maxUserAmountPerCampaign: Double?
    open var paymentMethodsIds: [String]?
    open var paymentTypesIds: [String]?
    open var cardIssuersIds: [String]?
    open var shippingModes: [String]?
    open var clientId: Int64?
    open var tags: [String]?
    open var multipleCodeLimit: Int?
    open var codeCount: Int?
    open var couponAmount: Double?
    open var collectors: [Int64]?

    public init(id: Int64, code: String?, name: String?, discountType: String?, minPaymentAmount: Double?, maxPaymentAmount: Double?, totalAmountLimit: Double?, maxCoupons: Int64?, maxCouponsByCode: Int?, maxRedeemPerUser: Int?, siteId: String?, marketplace: String?, codeType: String?, maxUserAmountPerCampaign: Double?, paymentMethodsIds: [String]?, paymentTypesIds: [String]?, cardIssuersIds: [String]?, shippingModes: [String]?, clientId: Int64?, tags: [String]?, multipleCodeLimit: Int?, codeCount: Int?, couponAmount: Double?, collectors: [Int64]?) {

            self.id = id
            self.code = code
            self.name = name
            self.discountType = discountType
            self.minPaymentAmount = minPaymentAmount
            self.maxPaymentAmount = maxPaymentAmount
            self.totalAmountLimit = totalAmountLimit
            self.maxCoupons = maxCoupons
            self.maxCouponsByCode = maxCouponsByCode
            self.maxRedeemPerUser = maxRedeemPerUser
            self.siteId = siteId
            self.marketplace = marketplace
            self.codeType = codeType
            self.maxUserAmountPerCampaign = maxUserAmountPerCampaign
            self.paymentMethodsIds = paymentMethodsIds
            self.paymentTypesIds = paymentTypesIds
            self.cardIssuersIds = cardIssuersIds
            self.shippingModes = shippingModes
            self.clientId = clientId
            self.tags = tags
            self.multipleCodeLimit = multipleCodeLimit
            self.codeCount = codeCount
            self.couponAmount = couponAmount
            self.collectors = collectors
    }

    public enum PXCampaignKeys: String, CodingKey {
        case id
        case code
        case name
        case discountType = "discount_type"
        case minPaymentAmount = "min_payment_amount"
        case maxPaymentAmount = "max_payment_amount"
        case totalAmountLimit = "total_amount_limit"
        case maxCoupons = "max_coupons"
        case maxCouponsByCode = "max_coupons_by_code"
        case maxRedeemPerUser = "max_redeem_per_user"
        case siteId = "site_id"
        case marketplace
        case codeType = "code_type"
        case maxUserAmountPerCampaign = "max_user_amount_per_campaign"
        case paymentMethodsIds = "payment_methods_ids"
        case paymentTypesIds = "payment_types_ids"
        case cardIssuersIds = "card_issuers_ids"
        case shippingModes = "shipping_modes"
        case clientId = "client_id"
        case tags
        case multipleCodeLimit = "multiple_code_limit"
        case codeCount = "code_count"
        case couponAmount = "coupon_amount"
        case collectors
    }

    required public convenience init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: PXCampaignKeys.self)
        let id: Int64 = try container.decode(Int64.self, forKey: .id)
        let code: String? = try container.decodeIfPresent(String.self, forKey: .code)
        let name: String? = try container.decodeIfPresent(String.self, forKey: .name)
        let discountType: String? = try container.decodeIfPresent(String.self, forKey: .discountType)
        let minPaymentAmount: Double? = try container.decodeIfPresent(Double.self, forKey: .minPaymentAmount)
        let maxPaymentAmount: Double? = try container.decodeIfPresent(Double.self, forKey: .maxPaymentAmount)
        let totalAmountLimit: Double? = try container.decodeIfPresent(Double.self, forKey: .totalAmountLimit)
        let maxCoupons: Int64? = try container.decodeIfPresent(Int64.self, forKey: .maxCoupons)
        let maxCouponsByCode: Int? = try container.decodeIfPresent(Int.self, forKey: .maxCouponsByCode)
        let maxRedeemPerUser: Int? = try container.decodeIfPresent(Int.self, forKey: .maxRedeemPerUser)
        let siteId: String? = try container.decodeIfPresent(String.self, forKey: .siteId)
        let marketplace: String? = try container.decodeIfPresent(String.self, forKey: .marketplace)
        let codeType: String? = try container.decodeIfPresent(String.self, forKey: .codeType)
        let maxUserAmountPerCampaign: Double? = try container.decodeIfPresent(Double.self, forKey: .maxUserAmountPerCampaign)
        let paymentMethodsIds: [String]? = try container.decodeIfPresent([String].self, forKey: .paymentMethodsIds)
        let paymentTypesIds: [String]? = try container.decodeIfPresent([String].self, forKey: .paymentTypesIds)
        let cardIssuersIds: [String]? = try container.decodeIfPresent([String].self, forKey: .cardIssuersIds)
        let shippingModes: [String]? = try container.decodeIfPresent([String].self, forKey: .shippingModes)
        let clientId: Int64? = try container.decodeIfPresent(Int64.self, forKey: .clientId)
        let tags: [String]? = try container.decodeIfPresent([String].self, forKey: .tags)
        let multipleCodeLimit: Int? = try container.decodeIfPresent(Int.self, forKey: .multipleCodeLimit)
        let codeCount: Int? = try container.decodeIfPresent(Int.self, forKey: .codeCount)
        let couponAmount: Double? = try container.decodeIfPresent(Double.self, forKey: .couponAmount)
        let collectors: [Int64]? = try container.decodeIfPresent([Int64].self, forKey: .collectors)

       self.init(id: id, code: code, name: name, discountType: discountType, minPaymentAmount: minPaymentAmount, maxPaymentAmount: maxPaymentAmount, totalAmountLimit: totalAmountLimit, maxCoupons: maxCoupons, maxCouponsByCode: maxCouponsByCode, maxRedeemPerUser: maxRedeemPerUser, siteId: siteId, marketplace: marketplace, codeType: codeType, maxUserAmountPerCampaign: maxUserAmountPerCampaign, paymentMethodsIds: paymentMethodsIds, paymentTypesIds: paymentTypesIds, cardIssuersIds: cardIssuersIds, shippingModes: shippingModes, clientId: clientId, tags: tags, multipleCodeLimit: multipleCodeLimit, codeCount: codeCount, couponAmount: couponAmount, collectors: collectors)
    }

    public func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: PXCampaignKeys.self)
        try container.encodeIfPresent(self.id, forKey: .id)
        try container.encodeIfPresent(self, forKey: .code)
        try container.encodeIfPresent(self, forKey: .name)
        try container.encodeIfPresent(self, forKey: .discountType)
        try container.encodeIfPresent(self, forKey: .minPaymentAmount)
        try container.encodeIfPresent(self, forKey: .maxPaymentAmount)
        try container.encodeIfPresent(self, forKey: .totalAmountLimit)
        try container.encodeIfPresent(self, forKey: .maxCoupons)
        try container.encodeIfPresent(self, forKey: .maxCouponsByCode)
        try container.encodeIfPresent(self, forKey: .maxRedeemPerUser)
        try container.encodeIfPresent(self, forKey: .siteId)
        try container.encodeIfPresent(self, forKey: .marketplace)
        try container.encodeIfPresent(self, forKey: .codeType)
        try container.encodeIfPresent(self, forKey: .maxUserAmountPerCampaign)
        try container.encodeIfPresent(self, forKey: .paymentMethodsIds)
        try container.encodeIfPresent(self, forKey: .paymentTypesIds)
        try container.encodeIfPresent(self, forKey: .cardIssuersIds)
        try container.encodeIfPresent(self, forKey: .shippingModes)
        try container.encodeIfPresent(self, forKey: .clientId)
        try container.encodeIfPresent(self, forKey: .tags)
        try container.encodeIfPresent(self, forKey: .multipleCodeLimit)
        try container.encodeIfPresent(self, forKey: .codeCount)
        try container.encodeIfPresent(self, forKey: .couponAmount)
        try container.encodeIfPresent(self, forKey: .collectors)
    }

    open func toJSONString() throws -> String? {
        let encoder = JSONEncoder()
        let data = try encoder.encode(self)
        return String(data: data, encoding: .utf8)
    }

    open func toJSON() throws -> Data {
        let encoder = JSONEncoder()
        return try encoder.encode(self)
    }

    open class func fromJSONToPXCampaing(data: Data) throws -> PXCampaign {
        return try JSONDecoder().decode(PXCampaign.self, from: data)
    }

    open class func fromJSON(data: Data) throws -> [PXCampaign] {
        return try JSONDecoder().decode([PXCampaign].self, from: data)
    }

}
