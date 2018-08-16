//
//  MercadoPagoServicesAdapter.swift
//  MercadoPagoSDK
//
//  Created by AUGUSTO COLLERONE ALFONSO on 10/23/17.
//  Copyright © 2017 MercadoPago. All rights reserved.
//

import Foundation
import MercadoPagoServicesV4

/** :nodoc: */
@objcMembers open class MercadoPagoServicesAdapter: NSObject {

    let mercadoPagoServices: MercadoPagoServices!

    init(servicePreference: ServicePreference? = nil) {
        mercadoPagoServices = MercadoPagoServices(merchantPublicKey: MercadoPagoContext.publicKey(), payerAccessToken: MercadoPagoContext.payerAccessToken(), procesingMode: MercadoPagoCheckoutViewModel.servicePreference.getProcessingModeString())
        mercadoPagoServices.setLanguage(language: MercadoPagoContext.getLanguage())
        super.init()

        if let servicePreference = servicePreference {
            setServicePreference(servicePreference: servicePreference)
        }
    }

    func setServicePreference(servicePreference: ServicePreference) {
        mercadoPagoServices.setBaseURL(servicePreference.baseURL)
        mercadoPagoServices.setGatewayBaseURL(servicePreference.getGatewayURL())
    }

    func getTimeOut() -> TimeInterval {
        // TODO: Get it from services
        return 15.0
    }

    open func getCheckoutPreference(checkoutPreferenceId: String, callback : @escaping (CheckoutPreference) -> Void, failure: @escaping ((_ error: NSError) -> Void)) {

        mercadoPagoServices.getCheckoutPreference(checkoutPreferenceId: checkoutPreferenceId, callback: { [weak self] (pxCheckoutPreference) in
            guard let strongSelf = self else {
                return
            }
            MercadoPagoContext.setSiteID(pxCheckoutPreference.siteId ?? "MLA")
            let checkoutPreference = strongSelf.getCheckoutPreferenceFromPXCheckoutPreference(pxCheckoutPreference)
            callback(checkoutPreference)
            }, failure: failure)
    }

    open func getInstructions(paymentId: String, paymentTypeId: String, callback : @escaping (InstructionsInfo) -> Void, failure: @escaping ((_ error: NSError) -> Void)) {

        let int64PaymentId = Int64(paymentId) //TODO: FIX

        mercadoPagoServices.getInstructions(paymentId: int64PaymentId!, paymentTypeId: paymentTypeId, callback: { [weak self] (pxInstructions) in
            guard let strongSelf = self else {
                return
            }

            let instructionsInfo = strongSelf.getInstructionsInfoFromPXInstructions(pxInstructions)
            callback(instructionsInfo)
            }, failure: failure)
    }

    public typealias PaymentSearchExclusions = (excludedPaymentTypesIds: Set<String>?, excludedPaymentMethodsIds: Set<String>?)
    public typealias PaymentSearchOneTapInfo = (cardsWithEsc: [String]?, supportedPlugins: [String]?)
    public typealias ExtraParams = (defaultPaymentMethod: String?, differentialPricingId: String?)

    open func getPaymentMethodSearch(amount: Double, exclusions: PaymentSearchExclusions, oneTapInfo: PaymentSearchOneTapInfo, payer: Payer, site: String, extraParams: ExtraParams? ,callback : @escaping (PaymentMethodSearch) -> Void, failure: @escaping ((_ error: NSError) -> Void)) {

        let pxPayer = getPXPayerFromPayer(payer)
        let pxSite = getPXSiteFromId(site)

        let accountMoneyAvailable: Bool = false // TODO: This is temporary. (Warning: Until AM First Class Member)

        var excludedPaymentTypesIds = exclusions.excludedPaymentTypesIds
        if !accountMoneyAvailable {
            if excludedPaymentTypesIds != nil {
                excludedPaymentTypesIds?.insert("account_money")
            } else {
                excludedPaymentTypesIds = ["account_money"]
            }
        }

        mercadoPagoServices.getPaymentMethodSearch(amount: amount, excludedPaymentTypesIds: exclusions.excludedPaymentTypesIds, excludedPaymentMethodsIds: exclusions.excludedPaymentMethodsIds, cardsWithEsc: oneTapInfo.cardsWithEsc, supportedPlugins: oneTapInfo.supportedPlugins, defaultPaymentMethod: extraParams?.defaultPaymentMethod, payer: pxPayer, site: pxSite, differentialPricingId: extraParams?.differentialPricingId, callback: {  [weak self] (pxPaymentMethodSearch) in
                guard let strongSelf = self else {
                    return
                }
                let paymentMethodSearch = strongSelf.getPaymentMethodSearchFromPXPaymentMethodSearch(pxPaymentMethodSearch)
                callback(paymentMethodSearch)
            }, failure: failure)
    }

    open func createPayment(url: String, uri: String, transactionId: String? = nil, paymentData: NSDictionary, query: [String: String]? = nil, callback : @escaping (Payment) -> Void, failure: @escaping ((_ error: NSError) -> Void)) {

        mercadoPagoServices.createPayment(url: url, uri: uri, transactionId: transactionId, paymentData: paymentData, query: query, callback: { [weak self] (pxPayment) in
            guard let strongSelf = self else {
                return
            }
            let payment = strongSelf.getPaymentFromPXPayment(pxPayment)
            callback(payment)
            }, failure: failure)
    }

    open func createToken(cardToken: CardToken, callback : @escaping (Token) -> Void, failure: @escaping ((_ error: NSError) -> Void)) {

        let pxCardToken = getPXCardTokenFromCardToken(cardToken)

        mercadoPagoServices.createToken(cardToken: pxCardToken, callback: { [weak self] (pxToken) in
            guard let strongSelf = self else {
                return
            }

            let token = strongSelf.getTokenFromPXToken(pxToken)
            callback(token)
            }, failure: failure)
    }

    open func createToken(savedESCCardToken: SavedESCCardToken, callback : @escaping (Token) -> Void, failure: @escaping ((_ error: NSError) -> Void)) {

        let pxSavedESCCardToken = getPXSavedESCCardTokenFromSavedESCCardToken(savedESCCardToken)

        mercadoPagoServices.createToken(savedESCCardToken: pxSavedESCCardToken, callback: { [weak self] (pxToken) in
            guard let strongSelf = self else {
                return
            }

            let token = strongSelf.getTokenFromPXToken(pxToken)
            callback(token)
            }, failure: failure)
    }

    open func createToken(savedCardToken: SavedCardToken, callback : @escaping (Token) -> Void, failure: @escaping ((_ error: NSError) -> Void)) {

        let pxSavedCardToken = getPXSavedCardTokenFromSavedCardToken(savedCardToken)

        mercadoPagoServices.createToken(savedCardToken: pxSavedCardToken, callback: { [weak self] (pxToken) in
            guard let strongSelf = self else {
                return
            }

            let token = strongSelf.getTokenFromPXToken(pxToken)
            callback(token)
            }, failure: failure)
    }

    internal func createToken(cardTokenJSON: String, callback : @escaping (Token) -> Void, failure: @escaping ((_ error: NSError) -> Void)) {
        mercadoPagoServices.createToken(cardTokenJSON: cardTokenJSON, callback: { [weak self] (pxToken) in
            guard let strongSelf = self else {
                return
            }
            let token = strongSelf.getTokenFromPXToken(pxToken)
            callback(token)
            }, failure: failure)
    }

    open func cloneToken(tokenId: String, securityCode: String, callback : @escaping (Token) -> Void, failure: @escaping ((_ error: NSError) -> Void)) {
        mercadoPagoServices.cloneToken(tokenId: tokenId, securityCode: securityCode, callback: { [weak self] (pxToken) in
            guard let strongSelf = self else {
                return
            }
            let token = strongSelf.getTokenFromPXToken(pxToken)
            callback(token)
            }, failure: failure)
    }

    open func getBankDeals(callback : @escaping ([PXBankDeal]) -> Void, failure: @escaping ((_ error: NSError) -> Void)) {
        mercadoPagoServices.getBankDeals(callback: callback, failure: failure)
    }

    open func getIdentificationTypes(callback: @escaping ([IdentificationType]) -> Void, failure: @escaping ((_ error: NSError) -> Void)) {

        mercadoPagoServices.getIdentificationTypes(callback: { [weak self] (pxIdentificationTypes) in
            guard let strongSelf = self else {
                return
            }

            var identificationTypes: [IdentificationType] = []
            for pxIdentificationTypes in pxIdentificationTypes {
                let identificationType = strongSelf.getIdentificationTypeFromPXIdentificationType(pxIdentificationTypes)
                identificationTypes.append(identificationType)
            }
            callback(identificationTypes)
            }, failure: failure)
    }

    open func getCampaigns(payerEmail: String?, callback: @escaping ([PXCampaign]) -> Void, failure: @escaping ((_ error: NSError) -> Void)) {
        mercadoPagoServices.getCampaigns(payerEmail: payerEmail, callback: callback, failure: failure)
    }

    open func getCodeDiscount(amount: Double, payerEmail: String, couponCode: String?, callback: @escaping (PXDiscount?) -> Void, failure: @escaping ((_ error: NSError) -> Void)) {

        let url = MercadoPagoCheckoutViewModel.servicePreference.getDiscountURL()
        let uri = MercadoPagoCheckoutViewModel.servicePreference.getDiscountURI()
        let additionalInfo = MercadoPagoCheckoutViewModel.servicePreference.discountAdditionalInfo

        mercadoPagoServices.getCodeDiscount(url: url, uri: uri, amount: amount, payerEmail: payerEmail, couponCode: couponCode, discountAdditionalInfo: additionalInfo, callback: { (pxDiscount) in
                callback(pxDiscount)
            }, failure: failure)
    }

    open func getDirectDiscount(amount: Double, payerEmail: String, callback: @escaping (PXDiscount?) -> Void, failure: @escaping ((_ error: NSError) -> Void)) {
        getCodeDiscount(amount: amount, payerEmail: payerEmail, couponCode: nil, callback: callback, failure: failure)
    }

    open func getInstallments(bin: String?, amount: Double, issuer: Issuer?, paymentMethodId: String,  differentialPricingId: String?, callback: @escaping ([Installment]) -> Void, failure: @escaping ((_ error: NSError) -> Void)) {

        mercadoPagoServices.getInstallments(bin: bin, amount: amount, issuerId: issuer?.issuerId, paymentMethodId: paymentMethodId,  differentialPricingId: differentialPricingId, callback: { [weak self] (pxInstallments) in
            guard let strongSelf = self else {
                return
            }

            var installments: [Installment] = []
            for pxInstallment in pxInstallments {
                let installment = strongSelf.getInstallmentFromPXInstallment(pxInstallment)
                installments.append(installment)
            }
            if let installment = installments.first, !installment.payerCosts.isEmpty {
                callback(installments)
            } else {
                failure(strongSelf.createSerializationError(requestOrigin: ApiUtil.RequestOrigin.GET_INSTALLMENTS))
            }
            }, failure: failure)
    }

    open func getIssuers(paymentMethodId: String, bin: String? = nil, callback: @escaping ([Issuer]) -> Void, failure: @escaping ((_ error: NSError) -> Void)) {

        mercadoPagoServices.getIssuers(paymentMethodId: paymentMethodId, bin: bin, callback: { [weak self] (pxIssuers) in
            guard let strongSelf = self else {
                return
            }

            var issuers: [Issuer] = []
            for pxIssuer in pxIssuers {
                let issuer = strongSelf.getIssuerFromPXIssuer(pxIssuer)
                issuers.append(issuer)
            }
            callback(issuers)
            }, failure: failure)
    }

    open func getCustomer(callback: @escaping (Customer) -> Void, failure: @escaping ((_ error: NSError) -> Void)) {

        let url = MercadoPagoCheckoutViewModel.servicePreference.getCustomerURL()
        let uri = MercadoPagoCheckoutViewModel.servicePreference.getCustomerURI()
        let additionalInfo = MercadoPagoCheckoutViewModel.servicePreference.customerAdditionalInfo

        mercadoPagoServices.getCustomer(url: url!, uri: uri, additionalInfo: additionalInfo!, callback: { [weak self] (pxCustomer) in
            guard let strongSelf = self else {
                return
            }

            let customer = strongSelf.getCustomerFromPXCustomer(pxCustomer)
            callback(customer)
            }, failure: failure)

    }

    func createSerializationError(requestOrigin: ApiUtil.RequestOrigin) -> NSError {
        #if DEBUG
            print("--REQUEST_ERROR: Cannot serlialize data in \(requestOrigin.rawValue)\n")
        #endif

        return NSError(domain: "com.mercadopago.sdk", code: NSURLErrorCannotDecodeContentData, userInfo: [NSLocalizedDescriptionKey: "Hubo un error"])
    }
}
