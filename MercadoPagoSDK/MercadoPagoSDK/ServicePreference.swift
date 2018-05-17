//
//  ServicePreference.swift
//  MercadoPagoSDK
//
//  Created by Eden Torres on 1/24/17.
//  Copyright © 2017 MercadoPago. All rights reserved.
//

import Foundation

@objcMembers open class ServicePreference: NSObject {

    var customerURL: String?
    var customerURI = ""
    var customerAdditionalInfo: [String: String]?
    var checkoutPreferenceURL: String?
    var checkoutPreferenceURI = ""
    var checkoutAdditionalInfo: NSDictionary?
    var paymentURL: String = URLConfigs.MP_API_BASE_URL
    var paymentURI: String = URLConfigs.MP_PAYMENTS_URI + "?api_version=" + URLConfigs.API_VERSION
    var paymentAdditionalInfo: NSDictionary?
    var discountURL: String = URLConfigs.MP_API_BASE_URL
    var discountURI: String = URLConfigs.MP_DISCOUNT_URI
    var discountAdditionalInfo: [String: String]?
    var processingMode: ProcessingMode = ProcessingMode.aggregator

    private static let kServiceSettings = "services_settings"
    private static let kURIInstallments = "uri_installments"
    private static let kURIIssuers = "uri_issuers"
    private static let kOPURI = "op_uri"
    private static let kWrapperURI = "wrapper_uri"
    private static let kShouldUseWrapper = "should_use_wrapper"

    private var useDefaultPaymentSettings = true
    private var defaultDiscountSettings = true

    var baseURL: String = URLConfigs.MP_API_BASE_URL
    var gatewayURL: String?

    public override init() {
        super.init()
    }

    public func setGetCustomer(baseURL: String, URI: String, additionalInfo: [String: String] = [:]) {
        customerURL = baseURL
        customerURI = URI
        customerAdditionalInfo = additionalInfo
    }

    public func setCreatePayment(baseURL: String, URI: String, additionalInfo: NSDictionary = [:]) {
        paymentURL = baseURL
        paymentURI = URI
        paymentAdditionalInfo = additionalInfo
        self.useDefaultPaymentSettings = false
    }

    public func setDiscount(baseURL: String, URI: String, additionalInfo: [String: String] = [:]) {
        discountURL = baseURL
        discountURI = URI
        discountAdditionalInfo = additionalInfo
        defaultDiscountSettings = false
    }

    public func setCreateCheckoutPreference(baseURL: String, URI: String, additionalInfo: NSDictionary = [:]) {
        checkoutPreferenceURL = baseURL
        checkoutPreferenceURI = URI
        checkoutAdditionalInfo = additionalInfo
    }

    public func setAdditionalPaymentInfo(_ additionalInfo: NSDictionary) {
        paymentAdditionalInfo = additionalInfo
    }

    public func setDefaultBaseURL(baseURL: String) {
        self.baseURL = baseURL
    }

    public func setGatewayURL(gatewayURL: String) {
        self.gatewayURL = gatewayURL
    }

    public func getDefaultBaseURL() -> String {
        return baseURL
    }

    public func getGatewayURL() -> String {
        return gatewayURL ?? baseURL
    }

    public func getCustomerURL() -> String? {
        return customerURL
    }

    public func getCustomerURI() -> String {
        return customerURI
    }

    public func isUsingDeafaultPaymentSettings() -> Bool {
        return useDefaultPaymentSettings
    }

    public func isUsingDefaultDiscountSettings() -> Bool {
        return defaultDiscountSettings
    }

    public func getCustomerAddionalInfo() -> String {
        if let customerAdditionalInfo = customerAdditionalInfo as NSDictionary?, !NSDictionary.isNullOrEmpty(customerAdditionalInfo) {
            return customerAdditionalInfo.parseToQuery()
        }
        return ""
    }

    public func getPaymentURL() -> String {
        if paymentURL == URLConfigs.MP_API_BASE_URL && baseURL != URLConfigs.MP_API_BASE_URL {
            return baseURL
        }
        return paymentURL
    }

    public func getPaymentURI() -> String {
        return paymentURI
    }

    public func getDiscountURL() -> String {
        if discountURL == URLConfigs.MP_API_BASE_URL && baseURL != URLConfigs.MP_API_BASE_URL {
            return baseURL
        }
        return discountURL
    }

    public func getDiscountURI() -> String {
        return discountURI
    }

    public func getPaymentAddionalInfo() -> NSDictionary? {
        if !NSDictionary.isNullOrEmpty(paymentAdditionalInfo) {
            return paymentAdditionalInfo!
        }
        return nil
    }

    public func getDiscountAddionalInfo() -> String {
        if let discountAdditionalInfo = discountAdditionalInfo as NSDictionary?, !NSDictionary.isNullOrEmpty(discountAdditionalInfo) {
            return discountAdditionalInfo.parseToQuery()
        }
        return ""
    }

    public func getCheckoutPreferenceURL() -> String? {
        return checkoutPreferenceURL
    }

    public func getCheckoutPreferenceURI() -> String {
        return checkoutPreferenceURI
    }

    public func getCheckoutAddionalInfo() -> String {
        if !NSDictionary.isNullOrEmpty(checkoutAdditionalInfo) {
            return checkoutAdditionalInfo!.toJsonString()
        }
        return ""
    }

    public func isGetCustomerSet() -> Bool {
        return !String.isNullOrEmpty(customerURL)
    }

    public func isCheckoutPreferenceSet() -> Bool {
        return !String.isNullOrEmpty(checkoutPreferenceURL)
    }

    public func isCreatePaymentSet() -> Bool {
        return !String.isNullOrEmpty(paymentURL)
    }

    public func isCustomerInfoAvailable() -> Bool {
        return !String.isNullOrEmpty(self.customerURL) && !String.isNullOrEmpty(self.customerURI)
    }

    public func getProcessingModeString() -> String {
        return self.processingMode.rawValue
    }

    public func setAggregatorAsProcessingMode() {
        self.processingMode = ProcessingMode.aggregator
    }

    public func setGatewayAsProcessingMode() {
        self.processingMode = ProcessingMode.gateway
    }

    public func setHybridAsProcessingMode() {
        self.processingMode = ProcessingMode.hybrid
    }

    internal func shouldShowBankDeals() -> Bool {
        return self.processingMode == ProcessingMode.aggregator
    }

    internal func shouldShowEmailConfirmationCell() -> Bool {
        return self.processingMode == ProcessingMode.aggregator
    }
}

public enum ProcessingMode: String {
    case gateway = "gateway"
    case aggregator = "aggregator"
    case hybrid = "gateway,aggregator"
}
