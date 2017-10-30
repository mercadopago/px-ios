//
//  PXPaymentMethodSearch.swift
//  MercadoPagoSDK
//
//  Created by Eden Torres on 10/20/17.
//  Copyright © 2017 MercadoPago. All rights reserved.
//

import Foundation
open class PXPaymentMethodSearch: NSObject, Codable {
    open var paymentMethodSearchItem: [PXPaymentMethodSearchItem]!
    open var customOptionSearchItems: [PXCustomOptionSearchItem]!
    open var paymentMethods: [PXPaymentMethod]!
    open var cards: [PXCard]!
    open var defaultOption: PXPaymentMethodSearchItem?
    

    init(paymentMethodSearchItem: [PXPaymentMethodSearchItem], customOptionSearchItems: [PXCustomOptionSearchItem], paymentMethods: [PXPaymentMethod], cards: [PXCard], defaultOption: PXPaymentMethodSearchItem?) {
        self.paymentMethodSearchItem = paymentMethodSearchItem
        self.customOptionSearchItems = customOptionSearchItems
        self.paymentMethods = paymentMethods
        self.cards = cards
        self.defaultOption = defaultOption
    }

    public enum PXPaymentMethodSearchKeys: String, CodingKey {
        case paymentMethodSearchItem = "groups"
        case customOptionSearchItems = "custom_options"
        case paymentMethods = "payment_methods"
        case cards
        case defaultOption = "default_option"
    }

    required public convenience init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: PXPaymentMethodSearchKeys.self)
        let paymentMethodSearchItem: [PXPaymentMethodSearchItem] = try container.decode([PXPaymentMethodSearchItem].self, forKey: .paymentMethodSearchItem)
        let customOptionSearchItems: [PXCustomOptionSearchItem] = try container.decode([PXCustomOptionSearchItem].self, forKey: .customOptionSearchItems)
        let paymentMethods: [PXPaymentMethod] = try container.decode([PXPaymentMethod].self, forKey: .paymentMethods)
        let cards: [PXCard] = try container.decode([PXCard].self, forKey: .cards)
        let defaultOption: PXPaymentMethodSearchItem? = try container.decodeIfPresent(PXPaymentMethodSearchItem.self, forKey: .defaultOption)

        self.init(paymentMethodSearchItem: paymentMethodSearchItem, customOptionSearchItems: customOptionSearchItems, paymentMethods: paymentMethods, cards: cards, defaultOption: defaultOption)
    }

    public func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: PXPaymentMethodSearchKeys.self)
        try container.encodeIfPresent(self.paymentMethodSearchItem, forKey: .paymentMethodSearchItem)
        try container.encodeIfPresent(self.customOptionSearchItems, forKey: .customOptionSearchItems)
        try container.encodeIfPresent(self.paymentMethods, forKey: .paymentMethods)
        try container.encodeIfPresent(self.cards, forKey: .cards)
        try container.encodeIfPresent(self.defaultOption,forKey: .defaultOption)
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

    open class func fromJSON(data: Data) throws -> PXPaymentMethodSearch {
        return try JSONDecoder().decode(PXPaymentMethodSearch.self, from: data)
    }
}
