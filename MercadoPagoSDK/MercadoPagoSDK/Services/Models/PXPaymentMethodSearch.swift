//
//  PXPaymentMethodSearch.swift
//  MercadoPagoSDK
//
//  Created by Eden Torres on 10/20/17.
//  Copyright © 2017 MercadoPago. All rights reserved.
//

import Foundation
/// :nodoc:
open class PXPaymentMethodSearch: NSObject, Codable {
    open var preference: PXCheckoutPreference
    open var site: PXSite
    open var currency: PXCurrency
    open var expressCho: [PXOneTapDto]?
    open var defaultAmountConfiguration: String
    open var discountConfigurations: [String: PXDiscountConfiguration]
    open var selectedDiscountConfiguration: PXDiscountConfiguration?
    open var paymentMethodSearchItem: [PXPaymentMethodSearchItem] = []
    open var customOptionSearchItems: [PXCustomOptionSearchItem] = []
    open var paymentMethods: [PXPaymentMethod] = []
    open var cards: [PXCard]?
    open var defaultOption: PXPaymentMethodSearchItem?

    public init(preference: PXCheckoutPreference, site: PXSite, currency: PXCurrency, expressCho: [PXOneTapDto]?, defaultAmountConfiguration: String, discountConfigurations: [String: PXDiscountConfiguration], paymentMethodSearchItem: [PXPaymentMethodSearchItem], customOptionSearchItems: [PXCustomOptionSearchItem], paymentMethods: [PXPaymentMethod], cards: [PXCard]?, defaultOption: PXPaymentMethodSearchItem?, oneTap: PXOneTapItem?) {

        self.preference = preference
        self.site = site
        self.currency = currency
        self.defaultAmountConfiguration = defaultAmountConfiguration
        self.discountConfigurations = discountConfigurations
        self.paymentMethodSearchItem = paymentMethodSearchItem
        self.customOptionSearchItems = customOptionSearchItems
        self.paymentMethods = paymentMethods
        self.cards = cards
        self.defaultOption = defaultOption
        self.expressCho = expressCho
        if let selectedDiscountConfiguration = discountConfigurations[defaultAmountConfiguration] {
            self.selectedDiscountConfiguration = selectedDiscountConfiguration
        }
        super.init()
        self.populateAMDescription()
    }

    public enum PXPaymentMethodSearchKeys: String, CodingKey {
        case preference
        case site
        case currency
        case paymentMethodSearchItem = "groups"
        case customOptionSearchItems = "custom_options"
        case paymentMethods = "payment_methods"
        case cards
        case defaultOption = "default_option"
        case expressCho = "express"
        case discountConfigurations = "discounts_configurations"
        case defaultAmountConfiguration = "default_amount_configuration"
    }

    required public convenience init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: PXPaymentMethodSearchKeys.self)
        let preference: PXCheckoutPreference = try container.decode(PXCheckoutPreference.self, forKey: .preference)
        let site: PXSite = try container.decode(PXSite.self, forKey: .site)
        let currency: PXCurrency = try container.decode(PXCurrency.self, forKey: .currency)
        let paymentMethodSearchItem: [PXPaymentMethodSearchItem] = try container.decodeIfPresent([PXPaymentMethodSearchItem].self, forKey: .paymentMethodSearchItem) ?? []
        let customOptionSearchItems: [PXCustomOptionSearchItem] = try container.decodeIfPresent([PXCustomOptionSearchItem].self, forKey: .customOptionSearchItems) ?? []
        let paymentMethods: [PXPaymentMethod] = try container.decodeIfPresent([PXPaymentMethod].self, forKey: .paymentMethods) ?? []
        let defaultOption: PXPaymentMethodSearchItem? = try container.decodeIfPresent(PXPaymentMethodSearchItem.self, forKey: .defaultOption)
        let expressCho: [PXOneTapDto]? = try container.decodeIfPresent([PXOneTapDto].self, forKey: .expressCho)
        let defaultAmountConfiguration: String = try container.decode(String.self, forKey: .defaultAmountConfiguration)
        let discountConfigurations: [String: PXDiscountConfiguration] = try container.decode([String: PXDiscountConfiguration].self, forKey: .discountConfigurations)

        self.init(preference: preference, site: site, currency: currency, expressCho: expressCho, defaultAmountConfiguration: defaultAmountConfiguration, discountConfigurations: discountConfigurations, paymentMethodSearchItem: paymentMethodSearchItem, customOptionSearchItems: customOptionSearchItems, paymentMethods: paymentMethods, cards: [], defaultOption: defaultOption, oneTap: nil)
    }

    public func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: PXPaymentMethodSearchKeys.self)
        try container.encodeIfPresent(self.preference, forKey: .preference)
        try container.encodeIfPresent(self.site, forKey: .site)
        try container.encodeIfPresent(self.currency, forKey: .currency)
        try container.encodeIfPresent(self.paymentMethodSearchItem, forKey: .paymentMethodSearchItem)
        try container.encodeIfPresent(self.customOptionSearchItems, forKey: .customOptionSearchItems)
        try container.encodeIfPresent(self.paymentMethods, forKey: .paymentMethods)
        try container.encodeIfPresent(self.cards, forKey: .cards)
        try container.encodeIfPresent(self.defaultOption, forKey: .defaultOption)
        try container.encodeIfPresent(self.expressCho, forKey: .expressCho)
        try container.encodeIfPresent(self.defaultAmountConfiguration, forKey: .defaultAmountConfiguration)
        try container.encodeIfPresent(self.discountConfigurations, forKey: .discountConfigurations)
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

extension PXPaymentMethodSearch {
    private func populateAMDescription() {
        var descriptionToPopulate: String?
        let targetId: String = PXPaymentTypes.ACCOUNT_MONEY.rawValue
        for customItem in customOptionSearchItems {
            if customItem.id == targetId {
                descriptionToPopulate = customItem.comment
                break
            }
        }
        if let amDescription = descriptionToPopulate {
            for pMethod in paymentMethods {
                if pMethod.id == targetId {
                    pMethod.paymentMethodDescription = amDescription
                    break
                }
            }
        }
    }
}
