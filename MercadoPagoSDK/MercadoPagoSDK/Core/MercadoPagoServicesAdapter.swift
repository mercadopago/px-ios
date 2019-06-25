//
//  MercadoPagoServicesAdapter.swift
//  MercadoPagoSDK
//
//  Created by AUGUSTO COLLERONE ALFONSO on 10/23/17.
//  Copyright © 2017 MercadoPago. All rights reserved.
//

import Foundation

// swiftlint:disable function_parameter_count
internal class MercadoPagoServicesAdapter {

    let mercadoPagoServices: MercadoPagoServices!

    init(publicKey: String, privateKey: String?) {
        mercadoPagoServices = MercadoPagoServices(merchantPublicKey: publicKey, payerAccessToken: privateKey ?? "")
        mercadoPagoServices.setLanguage(language: Localizator.sharedInstance.getLanguage())
    }

    func update(processingModes: [String]?, branchId: String? = nil) {
        mercadoPagoServices.update(processingModes: processingModes ?? PXServicesURLConfigs.MP_DEFAULT_PROCESSING_MODES)
        if let branchId = branchId {
            mercadoPagoServices.update(branchId: branchId)
        }
    }

    func getTimeOut() -> TimeInterval {
        return 15.0
    }

    func getCheckoutPreference(checkoutPreferenceId: String, callback : @escaping (PXCheckoutPreference) -> Void, failure: @escaping ((_ error: NSError) -> Void)) {

        mercadoPagoServices.getCheckoutPreference(checkoutPreferenceId: checkoutPreferenceId, callback: { (pxCheckoutPreference) in
            guard let siteId = pxCheckoutPreference.siteId else {
                // TODO: faltal error?
                return
            }
            SiteManager.shared.setSite(siteId: siteId)
            callback(pxCheckoutPreference)
            }, failure: failure)
    }

    func getInstructions(paymentId: String, paymentTypeId: String, callback : @escaping (PXInstructions) -> Void, failure: @escaping ((_ error: NSError) -> Void)) {

        let int64PaymentId = Int64(paymentId) //TODO: FIX

        mercadoPagoServices.getInstructions(paymentId: int64PaymentId!, paymentTypeId: paymentTypeId, callback: { (pxInstructions) in
            callback(pxInstructions)
            }, failure: failure)
    }

    typealias PaymentSearchExclusions = (excludedPaymentTypesIds: [String], excludedPaymentMethodsIds: [String])
    typealias PaymentSearchOneTapInfo = (cardsWithEsc: [String]?, supportedPlugins: [String]?)
    typealias ExtraParams = (defaultPaymentMethod: String?, differentialPricingId: String?, defaultInstallments: String?, expressEnabled: Bool, hasPaymentProcessor: Bool, splitEnabled: Bool, maxInstallments: String?)

    func getPaymentMethodSearch(amount: Double, exclusions: PaymentSearchExclusions, oneTapInfo: PaymentSearchOneTapInfo, payer: PXPayer, site: String, extraParams: ExtraParams?, discountParamsConfiguration: PXDiscountParamsConfiguration?, marketplace: String?, charges: [PXPaymentTypeChargeRule]?, callback : @escaping (PXPaymentMethodSearch) -> Void, failure: @escaping ((_ error: NSError) -> Void)) {

        payer.setAccessToken(accessToken: mercadoPagoServices.payerAccessToken)

        let pxSite = getPXSiteFromId(site)

        var expressValue: String = "false"
        if let eParams = extraParams, eParams.expressEnabled {
            expressValue = "true"
        }

        var splitValue: String = "false"
        if let eParams = extraParams, eParams.splitEnabled {
            splitValue = "true"
        }

        var excludedPaymentTypesIds = exclusions.excludedPaymentTypesIds
        if let eParams = extraParams, !eParams.hasPaymentProcessor {
        // Only until our backend can pay with account money.
        // Add exclusion for account money.
        excludedPaymentTypesIds.append(PXPaymentTypes.ACCOUNT_MONEY.rawValue)
        }

        mercadoPagoServices.getPaymentMethodSearch(amount: amount, excludedPaymentTypesIds: exclusions.excludedPaymentTypesIds, excludedPaymentMethodsIds: exclusions.excludedPaymentMethodsIds, cardsWithEsc: oneTapInfo.cardsWithEsc, supportedPlugins: oneTapInfo.supportedPlugins, defaultPaymentMethod: extraParams?.defaultPaymentMethod, payer: payer, site: pxSite, differentialPricingId: extraParams?.differentialPricingId, defaultInstallments: extraParams?.defaultInstallments, expressEnabled: expressValue, splitEnabled: splitValue, discountParamsConfiguration: discountParamsConfiguration, marketplace: marketplace, charges: charges, maxInstallments: extraParams?.maxInstallments, callback: { (pxPaymentMethodSearch) in
            callback(pxPaymentMethodSearch)
        }, failure: failure)
    }

    func createPayment(url: String, uri: String, transactionId: String? = nil, paymentDataJSON: Data, query: [String: String]? = nil, callback : @escaping (PXPayment) -> Void, failure: @escaping ((_ error: NSError) -> Void)) {

        mercadoPagoServices.createPayment(url: url, uri: uri, transactionId: transactionId, paymentDataJSON: paymentDataJSON, query: query, callback: { (pxPayment) in
            callback(pxPayment)
        }, failure: failure)
    }

    func createToken(cardToken: PXCardToken, callback : @escaping (PXToken) -> Void, failure: @escaping ((_ error: NSError) -> Void)) {

        mercadoPagoServices.createToken(cardToken: cardToken, callback: { (pxToken) in
            callback(pxToken)
            }, failure: failure)
    }

    func createToken(savedESCCardToken: PXSavedESCCardToken, callback : @escaping (PXToken) -> Void, failure: @escaping ((_ error: NSError) -> Void)) {

        mercadoPagoServices.createToken(savedESCCardToken: savedESCCardToken, callback: { (pxToken) in
            callback(pxToken)
        }, failure: failure)
    }

    func createToken(savedCardToken: PXSavedCardToken, callback : @escaping (PXToken) -> Void, failure: @escaping ((_ error: NSError) -> Void)) {
        mercadoPagoServices.createToken(savedCardToken: savedCardToken, callback: { (pxToken) in
            callback(pxToken)
        }, failure: failure)
    }

    func createToken(cardToken: Data, callback : @escaping (PXToken) -> Void, failure: @escaping ((_ error: NSError) -> Void)) {
        mercadoPagoServices.createToken(cardToken: cardToken, callback: { (pxToken) in
            callback(pxToken)
        }, failure: failure)
    }

    func cloneToken(tokenId: String, securityCode: String, callback : @escaping (PXToken) -> Void, failure: @escaping ((_ error: NSError) -> Void)) {
        mercadoPagoServices.cloneToken(tokenId: tokenId, securityCode: securityCode, callback: { (pxToken) in
            callback(pxToken)
        }, failure: failure)
    }

    func getBankDeals(callback : @escaping ([PXBankDeal]) -> Void, failure: @escaping ((_ error: NSError) -> Void)) {
        mercadoPagoServices.getBankDeals(callback: callback, failure: failure)
    }

    func getIdentificationTypes(callback: @escaping ([PXIdentificationType]) -> Void, failure: @escaping ((_ error: NSError) -> Void)) {
        mercadoPagoServices.getIdentificationTypes(callback: { (pxIdentificationTypes) in
            callback(pxIdentificationTypes)
        }, failure: failure)
    }

    func getIssuers(paymentMethodId: String, bin: String? = nil, callback: @escaping ([PXIssuer]) -> Void, failure: @escaping ((_ error: NSError) -> Void)) {

        mercadoPagoServices.getIssuers(paymentMethodId: paymentMethodId, bin: bin, callback: { (pxIssuers) in
            callback(pxIssuers)
        }, failure: failure)
    }

    func createSerializationError(requestOrigin: ApiUtil.RequestOrigin) -> NSError {
        #if DEBUG
        print("--REQUEST_ERROR: Cannot serlialize data in \(requestOrigin.rawValue)\n")
        #endif

        return NSError(domain: "com.mercadopago.sdk", code: NSURLErrorCannotDecodeContentData, userInfo: [NSLocalizedDescriptionKey: "Hubo un error"])
    }

    open func getSummaryAmount(bin: String?, amount: Double, issuer: PXIssuer?, paymentMethodId: String, payment_type_id: String, differentialPricingId: String?, siteId: String?, marketplace: String?, discountParamsConfiguration: PXDiscountParamsConfiguration?, payer: PXPayer, defaultInstallments: Int?, charges: [PXPaymentTypeChargeRule]?, maxInstallments: Int?, callback: @escaping (PXSummaryAmount) -> Void, failure: @escaping ((_ error: NSError) -> Void)) {

        mercadoPagoServices.getSummaryAmount(bin: bin, amount: amount, issuerId: issuer?.id, paymentMethodId: paymentMethodId, payment_type_id: payment_type_id, differentialPricingId: differentialPricingId, siteId: siteId, marketplace: marketplace, discountParamsConfiguration: discountParamsConfiguration, payer: payer, defaultInstallments: defaultInstallments, charges: charges, maxInstallments: maxInstallments, callback: { [weak self] (summaryAmount) in
                guard let strongSelf = self else {
                    return
                }
                callback(summaryAmount)
            }, failure: failure)
    }
}
