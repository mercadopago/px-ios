//
//  PXDiscount.swift
//  MercadoPagoSDK
//
//  Created by Eden Torres on 10/20/17.
//  Copyright © 2017 MercadoPago. All rights reserved.
//

import Foundation
open class PXDiscount: NSObject, Codable {
    open var id: String!
    open var name: String!
    open var percentOff: Double!
    open var amountOff: Double!
    open var couponAmount: Double!
    open var currencyId: String!
    open var couponCode: String!
    open var concept: String!

    init(id: String, name: String, percentOff: Double, amountOff: Double, couponAmount: Double, currencyId: String, couponCode: String, concept: String) {
        self.id = id
        self.name = name
        self.percentOff = percentOff
        self.amountOff = amountOff
        self.couponAmount = couponAmount
        self.currencyId = currencyId
        self.couponCode = couponCode
        self.concept = concept
    }

    public enum PXDiscountKeys: String, CodingKey {
        case id
        case name
        case percentOff = "percent_off"
        case amountOff = "amount_off"
        case couponAmount = "coupon_amount"
        case currencyId = "currency_id"
        case couponCode = "coupon_code"
        case concept
    }

    required public convenience init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: PXDiscountKeys.self)
        let percentOff: Double = try container.decode(Double.self, forKey: .percentOff)
        let amountOff: Double = try container.decode(Double.self, forKey: .amountOff)
        let couponAmount: Double = try container.decode(Double.self, forKey: .couponAmount)
        let id: String = try container.decode(String.self, forKey: .id)
        let name: String = try container.decode(String.self, forKey: .name)
        let currencyId: String = try container.decode(String.self, forKey: .currencyId)
        let couponCode: String = try container.decode(String.self, forKey: .couponCode)
        let concept: String = try container.decode(String.self, forKey: .concept)

        self.init(id: id, name: name, percentOff: percentOff, amountOff: amountOff, couponAmount: couponAmount, currencyId: currencyId, couponCode: couponCode, concept: concept)
    }

    public func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: PXDiscountKeys.self)
        try container.encodeIfPresent(self.percentOff, forKey: .percentOff)
        try container.encodeIfPresent(self.amountOff, forKey: .amountOff)
        try container.encodeIfPresent(self.couponAmount, forKey: .couponAmount)
        try container.encodeIfPresent(self.id, forKey: .id)
        try container.encodeIfPresent(self.name, forKey: .name)
        try container.encodeIfPresent(self.currencyId, forKey: .currencyId)
        try container.encodeIfPresent(self.couponCode, forKey: .couponCode)
        try container.encodeIfPresent(self.concept, forKey: .concept)
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

    open class func fromJSON(data: Data) throws -> PXDiscount {
        return try JSONDecoder().decode(PXDiscount.self, from: data)
    }

}
