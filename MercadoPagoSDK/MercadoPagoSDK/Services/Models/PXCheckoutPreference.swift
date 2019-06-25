//
//  PXCheckoutPreference.swift
//  MercadoPagoSDK
//
//  Created by Eden Torres on 10/20/17.
//  Copyright © 2017 MercadoPago. All rights reserved.
//

import Foundation

/**
 Model that represents `curl -X OPTIONS` (https://api.mercadopago.com/checkout/preferences) `| json_pp`
 It can be not exactly the same because exists custom configurations for open Preference.
 Some values like: binary mode are not present on API call.
 */
@objcMembers open class PXCheckoutPreference: NSObject, Codable {

    // MARK: Public accessors.
    /**
     id
     */
    open var id: String!
    /**
     items
     */
    open var items: [PXItem] = []
    /**
    payer
     */
    open var payer: PXPayer!
    /**
     paymentPreference
     */
    open var paymentPreference: PXPaymentPreference = PXPaymentPreference()
    /**
        siteId
     */
    open var siteId: String!
    /**
     expirationDateTo
     */
    open var expirationDateTo: Date?
    /**
     expirationDateFrom
     */
    open var expirationDateFrom: Date?
    /**
     site
     */
    open var site: PXSite?
    /**
     differentialPricing
     */
    open var differentialPricing: PXDifferentialPricing?
    /**
     marketplace
     */
    open var marketplace: String? = "NONE"

    /**
     branch id
     */
    open var branchId: String?

    /**
     processing mode
     */
    open var processingModes: [String] = PXServicesURLConfigs.MP_DEFAULT_PROCESSING_MODES

    /**
     Additional info - json string.
     */
    open var additionalInfo: String? {
        didSet {
            self.populateAdditionalInfoModel()
        }
    }

    internal var binaryModeEnabled: Bool = false
    internal var pxAdditionalInfo: PXAdditionalInfo?

    // MARK: Initialization
    /**
     Mandatory init.
     - parameter preferenceId: The preference id that represents the payment information.
     */
    public init(preferenceId: String) {
        self.id = preferenceId
    }

    /**
     Mandatory init.
     Builder for custom CheckoutPreference construction.
     It should be only used if you are processing the payment
     with a Payment processor. Otherwise you should use the ID constructor.
     - parameter siteId: Preference site.
     - parameter payerEmail: Payer email.
     - parameter items: Items to pay.
     */
    public init(siteId: String, payerEmail: String, items: [PXItem]) {
        self.items = items

        guard let siteId = PXSites(rawValue: siteId)?.rawValue else {
            fatalError("Invalid site id")
        }
        self.siteId = siteId
        self.payer = PXPayer(email: payerEmail)
    }

    internal init(id: String, items: [PXItem], payer: PXPayer, paymentPreference: PXPaymentPreference?, siteId: String, expirationDateTo: Date?, expirationDateFrom: Date?, site: PXSite?, differentialPricing: PXDifferentialPricing?, marketplace: String?, branchId: String?, processingModes: [String] = PXServicesURLConfigs.MP_DEFAULT_PROCESSING_MODES) {
        self.id = id
        self.items = items
        self.payer = payer
        if let payPref = paymentPreference {
            self.paymentPreference = payPref
        }
        self.siteId = siteId
        self.expirationDateTo = expirationDateTo
        self.expirationDateFrom = expirationDateFrom
        self.site = site
        self.differentialPricing = differentialPricing
        let sanitizedProcessingModes = processingModes.isEmpty ? PXServicesURLConfigs.MP_DEFAULT_PROCESSING_MODES : processingModes
        self.processingModes = sanitizedProcessingModes
        self.branchId = branchId
        self.marketplace = marketplace
    }

    /// :nodoc:
    public enum PXCheckoutPreferenceKeys: String, CodingKey {
        case id
        case items
        case payer = "payer"
        case paymentPreference = "payment_methods"
        case siteId = "site_id"
        case expirationDateTo = "expiration_date_to"
        case expirationDateFrom = "expiration_date_from"
        case differentialPricing = "differential_pricing"
        case site
        case marketplace
        case additionalInfo = "additional_info"
        case branchId = "branch_id"
        case processingModes = "processing_modes"
    }

    required public convenience init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: PXCheckoutPreferenceKeys.self)
        let id: String = try container.decode(String.self, forKey: .id)
        let branchId: String? = try container.decodeIfPresent(String.self, forKey: .branchId)
        let processingModes: [String] = try container.decodeIfPresent([String].self, forKey: .processingModes) ?? PXServicesURLConfigs.MP_DEFAULT_PROCESSING_MODES
        let items: [PXItem] = try container.decodeIfPresent([PXItem].self, forKey: .items) ?? []
        let paymentPreference: PXPaymentPreference? = try container.decodeIfPresent(PXPaymentPreference.self, forKey: .paymentPreference)
        let payer: PXPayer = try container.decode(PXPayer.self, forKey: .payer)
        let expirationDateTo: Date? = try container.decodeDateFromStringIfPresent(forKey: .expirationDateTo)
        let expirationDateFrom: Date? = try container.decodeDateFromStringIfPresent(forKey: .expirationDateFrom)
        let siteId: String = try container.decode(String.self, forKey: .siteId)
        let site: PXSite? = try container.decodeIfPresent(PXSite.self, forKey: .site)
        let differentialPricing: PXDifferentialPricing? = try container.decodeIfPresent(PXDifferentialPricing.self, forKey: .differentialPricing)
        let marketplace: String? = try container.decodeIfPresent(String.self, forKey: .marketplace)
        self.init(id: id, items: items, payer: payer, paymentPreference: paymentPreference, siteId: siteId, expirationDateTo: expirationDateTo, expirationDateFrom: expirationDateFrom, site: site, differentialPricing: differentialPricing, marketplace: marketplace, branchId: branchId, processingModes: processingModes)
        self.additionalInfo = try container.decodeIfPresent(String.self, forKey: .additionalInfo)
        populateAdditionalInfoModel()
    }

    /// :nodoc:
    public func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: PXCheckoutPreferenceKeys.self)
        try container.encodeIfPresent(self.id, forKey: .id)
        try container.encodeIfPresent(self.items, forKey: .items)
        try container.encodeIfPresent(self.paymentPreference, forKey: .paymentPreference)
        try container.encodeIfPresent(self.payer, forKey: .payer)
        try container.encodeIfPresent(self.siteId, forKey: .siteId)
        try container.encodeIfPresent(self.site, forKey: .site)
        try container.encodeIfPresent(self.differentialPricing, forKey: .differentialPricing)
        try container.encodeIfPresent(self.marketplace, forKey: .marketplace)
        try container.encodeIfPresent(self.additionalInfo, forKey: .additionalInfo)
        try container.encodeIfPresent(self.branchId, forKey: .branchId)
        try container.encodeIfPresent(self.processingModes, forKey: .processingModes)
    }

    /// :nodoc:
    open func toJSONString() throws -> String? {
        let encoder = JSONEncoder()
        let data = try encoder.encode(self)
        return String(data: data, encoding: .utf8)
    }

    /// :nodoc:
    open func toJSON() throws -> Data {
        let encoder = JSONEncoder()
        return try encoder.encode(self)
    }

    /// :nodoc:
    open class func fromJSON(data: Data) throws -> PXCheckoutPreference {
        return try JSONDecoder().decode(PXCheckoutPreference.self, from: data)
    }
}
