//
//  PXInitSearchBody.swift
//  MercadoPagoSDK
//
//  Created by Esteban Adrian Boffa on 11/08/2019.
//

import Foundation
import UIKit

class PXInitSearchBody: Codable {

    let preferenceId: String?
    let preference: PXCheckoutPreference?
    let merchantOrderId: String?
    let checkoutParams: PXInitCheckoutParams

    public enum PXInitSearchBodyCodingKeys: String, CodingKey {
        case preferenceId = "preference_id"
        case preference
        case merchantOrderId = "merchant_order_id"
        case checkoutParams = "checkout_params"
    }

    init(preferenceId: String?, preference: PXCheckoutPreference?, merchantOrderId: String?, checkoutParams: PXInitCheckoutParams) {
        self.preferenceId = preferenceId
        self.preference = preference
        self.merchantOrderId = merchantOrderId
        self.checkoutParams = checkoutParams
    }

    public func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: PXInitSearchBodyCodingKeys.self)
        try container.encodeIfPresent(self.preferenceId, forKey: .preferenceId)
        try container.encodeIfPresent(self.preference, forKey: .preference)
        try container.encodeIfPresent(self.merchantOrderId, forKey: .merchantOrderId)
        try container.encodeIfPresent(self.checkoutParams, forKey: .checkoutParams)
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
}

struct PXInitBody: Codable {
    let preference: PXCheckoutPreference?
    let publicKey: String
    let accessToken: String?
    let flowId: String
    let cardsWithESC: [String]
    let charges: [PXPaymentTypeChargeRule]?
    let discountConfiguration: PXDiscountParamsConfiguration
    let features: PXInitFeatures

    enum CodingKeys: String, CodingKey {
        case preference
        case publicKey = "public_key"
        case accessToken = "access_token"
        case flowId = "flow_id"
        case cardsWithESC = "cards_with_esc"
        case charges
        case discountConfiguration = "discount_configuration"
        case features
    }
}

struct PXInitFeatures: Codable {
    let oneTap: Bool
    let split: Bool

    enum CodingKeys: String, CodingKey {
        case oneTap = "one_tap"
        case split = "split"
    }
}
