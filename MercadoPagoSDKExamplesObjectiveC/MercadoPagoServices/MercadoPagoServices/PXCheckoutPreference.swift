//
//  PXCheckoutPreference.swift
//  MercadoPagoSDK
//
//  Created by Eden Torres on 10/20/17.
//  Copyright © 2017 MercadoPago. All rights reserved.
//

import Foundation
open class PXCheckoutPreference: NSObject, Codable {
    open var id: String!
    open var items: [PXItem]!
    open var payer: PXPayer!
    open var paymentPreference: PXPaymentPreference!
    open var siteId: String!
    open var expirationDateTo: Date?
    open var expirationDateFrom: Date?
    open var site: PXSite?
    
    init(id: String, items: [PXItem], payer: PXPayer, paymentPreference: PXPaymentPreference, siteId: String, expirationDateTo: Date?, expirationDateFrom: Date?, site: PXSite?) {
        self.id = id
        self.items = items
        self.payer = payer
        self.paymentPreference = paymentPreference
        self.siteId = siteId
        self.expirationDateTo = expirationDateTo
        self.expirationDateFrom = expirationDateFrom
        self.site = site
    }

    public enum PXCheckoutPreferenceKeys: String, CodingKey {
        case id
        case items
        case payer = "payer"
        case paymentPreference = "payment_methods"
        case siteId = "site_id"
        case expirationDateTo = "expiration_date_to"
        case expirationDateFrom = "expiration_date_from"
        case site
    }

    required public convenience init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: PXCheckoutPreferenceKeys.self)
        let id: String = try container.decode(String.self, forKey: .id)
        let items: [PXItem] = try container.decode([PXItem].self, forKey: .items)
        let paymentPreference: PXPaymentPreference = try container.decode(PXPaymentPreference.self, forKey: .paymentPreference)
        let payer: PXPayer = try container.decode(PXPayer.self, forKey: .payer)
        let siteId: String = try container.decode(String.self, forKey: .siteId)
        let site: PXSite? = try container.decodeIfPresent(PXSite.self, forKey: .site)

        // TODO: Agregar dates

        self.init(id: id, items: items, payer: payer, paymentPreference: paymentPreference, siteId: siteId, expirationDateTo: nil, expirationDateFrom: nil, site: site)
    }

     public func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: PXCheckoutPreferenceKeys.self)
        try container.encodeIfPresent(self.id, forKey: .id)
        try container.encodeIfPresent(self.items, forKey: .items)
        try container.encodeIfPresent(self.paymentPreference, forKey: .paymentPreference)
        try container.encodeIfPresent(self.payer, forKey: .payer)
        try container.encodeIfPresent(self.siteId, forKey: .siteId)
        try container.encodeIfPresent(self.site, forKey: .site)
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

    open class func fromJSON(data: Data) throws -> PXCheckoutPreference {
        return try JSONDecoder().decode(PXCheckoutPreference.self, from: data)
    }
}
