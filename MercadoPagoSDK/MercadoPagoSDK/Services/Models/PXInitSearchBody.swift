//
//  PXInitSearchBody.swift
//  MercadoPagoSDK
//
//  Created by Esteban Adrian Boffa on 11/08/2019.
//

import Foundation
import UIKit

class PXInitSearchBody: Codable {

    let preferenceId: String
    let preference: PXCheckoutPreference?
    let merchantOrderId: String?
    let checkoutParams: PXInitCheckoutParams

    public enum PXInitSearchBodyCodingKeys: String, CodingKey {
        case preferenceId = "preference_id"
        case preference
        case merchantOrderId = "merchant_order_id"
        case checkoutParams = "checkout_params"
    }

    init(preferenceId: String, preference: PXCheckoutPreference?, merchantOrderId: String?, checkoutParams: PXInitCheckoutParams) {
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

    open class func fromJSON(data: Data) throws -> PXInitSearchBody {
        return try JSONDecoder().decode(PXInitSearchBody.self, from: data)
    }
}
