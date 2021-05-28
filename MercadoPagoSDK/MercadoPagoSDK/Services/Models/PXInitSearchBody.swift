//
//  PXInitSearchBody.swift
//  MercadoPagoSDK
//
//  Created by Esteban Adrian Boffa on 11/08/2019.
//

import Foundation
import UIKit

struct PXInitBody: Codable {
    let preference: PXCheckoutPreference?
    let publicKey: String
    let flow: String?
    let cardsWithESC: [String]
    let charges: [PXPaymentTypeChargeRule]
    let discountConfiguration: PXDiscountParamsConfiguration?
    let features: PXInitFeatures

    init(preference: PXCheckoutPreference?, publicKey: String, flow: String?, cardsWithESC: [String], charges: [PXPaymentTypeChargeRule], discountConfiguration: PXDiscountParamsConfiguration?, features: PXInitFeatures) {
        self.preference = preference
        self.publicKey = publicKey
        self.flow = flow
        self.cardsWithESC = cardsWithESC
        self.charges = charges
        self.discountConfiguration = discountConfiguration
        self.features = features
    }

    enum CodingKeys: String, CodingKey {
        case preference
        case publicKey = "public_key"
        case flow = "flow"
        case cardsWithESC = "cards_with_esc"
        case charges
        case discountConfiguration = "discount_configuration"
        case features
    }

    public func toJSON() throws -> Data {
        let encoder = JSONEncoder()
        return try encoder.encode(self)
    }
}

struct PXInitFeatures: Codable {
    let oneTap: Bool
    let split: Bool
    let odr: Bool
    let pix: Bool

    init(oneTap: Bool = true, split: Bool, odr: Bool = true, pix: Bool = true) {
        self.oneTap = oneTap
        self.split = split
        self.odr = odr
        self.pix = pix
    }

    enum CodingKeys: String, CodingKey {
        case oneTap = "one_tap"
        case split = "split"
        case odr
        case pix
    }
}
