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
        dateCreated
    */
    open var dateCreated: String?
    /**
        operationType
    */
    open var operationType: String?
    /**
        autoReturn
     */
    open var autoReturn: String?
    /**
        externalReference
    */
    open var externalReference: String?
    /**
        collectorId
    */
    open var collectorId: Int?
    /**
        clientId
    */
    open var clientId: Int?
    /**
        expires
    */
    open var expires: Bool?
    /**
        marketplaceFee
     */
    open var marketplaceFee: Int?
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

    open var backUrls: PXBackUrls?
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

        guard let site = SiteManager.shared.siteIdsSettings[siteId] else {
            fatalError("Invalid site id")
        }
        self.siteId = siteId
        self.payer = PXPayer(email: payerEmail)
    }

    internal init(id: String, items: [PXItem], payer: PXPayer, paymentPreference: PXPaymentPreference?, siteId: String, dateCreated: String?, operationType: String?, autoReturn: String?, externalReference: String?, collectorId: Int?, clientId: Int?, expires: Bool?, expirationDateTo: Date?, expirationDateFrom: Date?, site: PXSite?, differentialPricing: PXDifferentialPricing?, marketplace: String?, marketplaceFee: Int?, branchId: String?, processingModes: [String] = PXServicesURLConfigs.MP_DEFAULT_PROCESSING_MODES) {

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
        self.dateCreated = dateCreated
        self.operationType = operationType
        self.autoReturn = autoReturn
        self.externalReference = externalReference
        self.collectorId = collectorId
        self.clientId = clientId
        self.expires = expires
        self.marketplace = marketplace
        self.marketplaceFee = marketplaceFee
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
        case dateCreated = "date_created"
        case operationType = "operation_type"
        case additionalInfo = "additional_info"
        case autoReturn = "auto_return"
        case externalReference = "external_reference"
        case collectorId = "collector_id"
        case clientId = "client_id"
        case expires
        case marketplaceFee = "marketplace_fee"
        case backUrls = "back_urls"
        case branchId = "branch_id"
        case processingModes = "processing_modes"
    }

    required public convenience init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: PXCheckoutPreferenceKeys.self)
        let id: String? = try container.decodeIfPresent(String.self, forKey: .id)
        let prefId: String = id ?? ""
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
        let dateCreated: String? = try container.decodeIfPresent(String.self, forKey: .dateCreated)
        let operationType: String? = try container.decodeIfPresent(String.self, forKey: .operationType)
        let autoReturn: String? = try container.decodeIfPresent(String.self, forKey: .autoReturn)
        let externalReference: String? = try container.decodeIfPresent(String.self, forKey: .externalReference)
        let collectorId: Int? = try container.decodeIfPresent(Int.self, forKey: .collectorId)
        let clientId: Int? = try container.decodeIfPresent(Int.self, forKey: .collectorId)
        let expires: Bool? = try container.decodeIfPresent(Bool.self, forKey: .expires)
        let marketplace: String? = try container.decodeIfPresent(String.self, forKey: .marketplace)
        let marketplaceFee: Int? = try container.decodeIfPresent(Int.self, forKey: .marketplaceFee)

        self.init(id: prefId, items: items, payer: payer, paymentPreference: paymentPreference, siteId: siteId, dateCreated: dateCreated, operationType: operationType, autoReturn: autoReturn, externalReference: externalReference, collectorId: collectorId, clientId: clientId, expires: expires, expirationDateTo: expirationDateTo, expirationDateFrom: expirationDateFrom, site: site, differentialPricing: differentialPricing, marketplace: marketplace, marketplaceFee: marketplaceFee, branchId: branchId, processingModes: processingModes)

        self.additionalInfo = try container.decodeIfPresent(String.self, forKey: .additionalInfo)
        populateAdditionalInfoModel()
        self.backUrls = try container.decodeIfPresent(PXBackUrls.self, forKey: .backUrls)
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
        try container.encodeIfPresent(self.dateCreated, forKey: .dateCreated)
        try container.encodeIfPresent(self.operationType, forKey: .operationType)
        try container.encodeIfPresent(self.autoReturn, forKey: .autoReturn)
        try container.encodeIfPresent(self.externalReference, forKey: .externalReference)
        try container.encodeIfPresent(self.collectorId, forKey: .collectorId)
        try container.encodeIfPresent(self.clientId, forKey: .clientId)
        try container.encodeIfPresent(self.expires, forKey: .expires)
        try container.encodeIfPresent(self.additionalInfo, forKey: .additionalInfo)
        try container.encodeIfPresent(self.marketplaceFee, forKey: .marketplaceFee)
        try container.encodeIfPresent(self.marketplace, forKey: .marketplace)
        try container.encodeIfPresent(self.additionalInfo, forKey: .additionalInfo)
        try container.encodeIfPresent(self.backUrls, forKey: .backUrls)
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
