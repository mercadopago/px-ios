//
//  ServicePreference.swift
//  MercadoPagoSDK
//
//  Created by Eden Torres on 1/24/17.
//  Copyright © 2017 MercadoPago. All rights reserved.
//

import Foundation

open class ServicePreference: NSObject {

    var customerURL: String?
    var customerURI = ""
    var customerAdditionalInfo: NSDictionary?
    var checkoutPreferenceURL: String?
    var checkoutPreferenceURI = ""
    var checkoutAdditionalInfo: NSDictionary?
    var paymentURL: String = MP_API_BASE_URL
    var paymentURI: String = MP_PAYMENTS_URI + "?api_version=" + API_VERSION
    var paymentAdditionalInfo: NSDictionary?
    var discountURL: String = MP_API_BASE_URL
    var discountURI: String = MP_DISCOUNT_URI
    var discountAdditionalInfo: NSDictionary?
    var processingMode: ProcessingMode = ProcessingMode.aggregator

    static let MP_ALPHA_ENV = "/gamma"
    open static var MP_TEST_ENV = "/beta"
    open static var MP_PROD_ENV = "/v1"
    open static var MP_SELECTED_ENV = MP_PROD_ENV

    static var API_VERSION = "1.4.X"

    static var MP_ENVIROMENT = MP_SELECTED_ENV  + "/checkout"

    static let MP_OP_ENVIROMENT = "/v1"

    static let MP_ALPHA_API_BASE_URL: String =  "http://api.mp.internal.ml.com"
    static let MP_API_BASE_URL_PROD: String =  "https://api.mercadopago.com"

    static let MP_API_BASE_URL: String =  MP_API_BASE_URL_PROD

    static let PAYMENT_METHODS = "/payment_methods"
    static let INSTALLMENTS = "\(PAYMENT_METHODS)/installments"
    static let CARD_TOKEN = "/card_tokens"
    static let CARD_ISSSUERS = "\(PAYMENT_METHODS)/card_issuers"
    static let PAYMENTS = "/payments"

    static let MP_CREATE_TOKEN_URI = MP_OP_ENVIROMENT + CARD_TOKEN
    static let MP_PAYMENT_METHODS_URI = MP_OP_ENVIROMENT + PAYMENT_METHODS
    static var MP_INSTALLMENTS_URI = MP_OP_ENVIROMENT + INSTALLMENTS
    static var MP_ISSUERS_URI = MP_OP_ENVIROMENT + CARD_ISSSUERS
    static let MP_IDENTIFICATION_URI = "/identification_types"
    static let MP_PROMOS_URI = MP_OP_ENVIROMENT + PAYMENT_METHODS + "/deals"
    static let MP_SEARCH_PAYMENTS_URI = MP_ENVIROMENT + PAYMENT_METHODS + "/search/options"
    static let MP_INSTRUCTIONS_URI = MP_ENVIROMENT + PAYMENTS + "/${payment_id}/results"
    static let MP_PREFERENCE_URI = MP_ENVIROMENT + "/preferences/"
    static let MP_DISCOUNT_URI =  "/discount_campaigns/"
    static let MP_TRACKING_EVENTS_URI =  MP_ENVIROMENT + "/tracking/events"
    static let MP_CUSTOMER_URI = "/customers?preference_id="
    static let MP_PAYMENTS_URI = MP_ENVIROMENT + PAYMENTS

    private static let kIsProdApiEnvironemnt = "prod_api_environment"

    private static let kServiceSettings = "services_settings"
    private static let kURIInstallments = "uri_installments"
    private static let kURIIssuers = "uri_issuers"
    private static let kOPURI = "op_uri"
    private static let kWrapperURI = "wrapper_uri"
    private static let kShouldUseWrapper = "should_use_wrapper"

    private var useDefaultPaymentSettings = true
    private var defaultDiscountSettings = true

    var baseURL: String = MP_API_BASE_URL
    var gatewayURL: String?

    public override init() {
        super.init()
        ServicePreference.setupMPEnvironment()
    }

    public func setGetCustomer(baseURL: String, URI: String, additionalInfo: [String:String] = [:]) {
        customerURL = baseURL
        customerURI = URI
        customerAdditionalInfo = additionalInfo as NSDictionary
    }

    public func setCreatePayment(baseURL: String = MP_API_BASE_URL, URI: String = MP_PAYMENTS_URI + "?api_version=" + API_VERSION, additionalInfo: NSDictionary = [:]) {
        paymentURL = baseURL
        paymentURI = URI
        paymentAdditionalInfo = additionalInfo
        self.useDefaultPaymentSettings = false
    }

    public func setDiscount(baseURL: String = MP_API_BASE_URL, URI: String = MP_DISCOUNT_URI, additionalInfo: [String:String] = [:]) {
        discountURL = baseURL
        discountURI = URI
        discountAdditionalInfo = additionalInfo as NSDictionary?
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
        if !NSDictionary.isNullOrEmpty(customerAdditionalInfo) {
            return customerAdditionalInfo!.parseToQuery()
        }
        return ""
    }

    public func getPaymentURL() -> String {
        if paymentURL == ServicePreference.MP_API_BASE_URL && baseURL != ServicePreference.MP_API_BASE_URL {
            return baseURL
        }
        return paymentURL
    }

    public func getPaymentURI() -> String {
        return paymentURI
    }

    public func getDiscountURL() -> String {
        if discountURL == ServicePreference.MP_API_BASE_URL && baseURL != ServicePreference.MP_API_BASE_URL {
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
        if !NSDictionary.isNullOrEmpty(discountAdditionalInfo) {
            return discountAdditionalInfo!.parseToQuery()
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

    static public func setupMPEnvironment() {
        // En caso de correr los tests se toma environment como prod por default
        if Utils.isTesting() {
            ServicePreference.MP_ENVIROMENT = MP_PROD_ENV  + "/checkout"
        } else {

            guard let serviceSettings: [String:Any] = Utils.getSetting(identifier: ServicePreference.kServiceSettings) else {
                return
            }

            guard let isProdEnvironment = serviceSettings[ServicePreference.kIsProdApiEnvironemnt] as? Bool else {
                return
            }
            if isProdEnvironment {
                ServicePreference.MP_SELECTED_ENV = MP_PROD_ENV
                ServicePreference.MP_ENVIROMENT = MP_PROD_ENV  + "/checkout"
            } else {
                ServicePreference.MP_SELECTED_ENV = MP_TEST_ENV
                ServicePreference.MP_ENVIROMENT = MP_TEST_ENV  + "/checkout"
            }

            if let uriInstallmentSettings = serviceSettings[ServicePreference.kURIInstallments] as? [String:Any] {
                ServicePreference.MP_INSTALLMENTS_URI = getFinalURIFor(settings: uriInstallmentSettings)
            }

            if let uriIssuersSettings = serviceSettings[ServicePreference.kURIIssuers] as? [String:Any] {
                ServicePreference.MP_ISSUERS_URI = getFinalURIFor(settings: uriIssuersSettings)
            }

        }
    }

    static internal func getFinalURIFor(settings: [String:Any]) -> String {
        let shouldUseWrapper: Bool = settings[ServicePreference.kShouldUseWrapper] as? Bool ?? false
        if shouldUseWrapper {
            return ServicePreference.MP_SELECTED_ENV + (settings[ServicePreference.kWrapperURI] as! String)
        } else {
            return ServicePreference.MP_OP_ENVIROMENT + (settings[ServicePreference.kOPURI] as! String)
        }
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
