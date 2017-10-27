//
//  MercadoPagoServicesAdapter.swift
//  MercadoPagoSDK
//
//  Created by AUGUSTO COLLERONE ALFONSO on 10/23/17.
//  Copyright © 2017 MercadoPago. All rights reserved.
//

import Foundation
import MercadoPagoServices

open class MercadoPagoServicesAdapter: NSObject {

    let mercadoPagoServices: MercadoPagoServices!

    init(servicePreference: ServicePreference? = nil) {
        mercadoPagoServices = MercadoPagoServices(merchantPublicKey: MercadoPagoContext.publicKey(), payerAccessToken: MercadoPagoContext.payerAccessToken(), procesingMode: MercadoPagoCheckoutViewModel.servicePreference.getProcessingModeString())
        super.init()

        if let servicePreference = servicePreference {
            setServicePreference(servicePreference: servicePreference)
        }
    }

    func setServicePreference(servicePreference: ServicePreference) {
        
        mercadoPagoServices.setBaseURL(servicePreference.baseURL)
        mercadoPagoServices.setGatewayBaseURL(servicePreference.getGatewayURL())
        if let customerURL = servicePreference.getCustomerURL() {
            mercadoPagoServices.setGetCustomer(baseURL: customerURL, URI: servicePreference.customerURI, additionalInfo: servicePreference.customerAdditionalInfo as? [String : String])
        }
        if let checkoutPreferenceURL = servicePreference.getCheckoutPreferenceURL() {
            mercadoPagoServices.setCreateCheckoutPreference(baseURL: checkoutPreferenceURL, URI: servicePreference.checkoutPreferenceURI, additionalInfo: servicePreference.checkoutAdditionalInfo)
        }

        mercadoPagoServices.setDiscount(baseURL: servicePreference.getDiscountURL(), URI: servicePreference.getDiscountURI(), additionalInfo: servicePreference.discountAdditionalInfo as? [String : String])
    }
    
    open func getCheckoutPreference(checkoutPreferenceId: String, callback : @escaping (CheckoutPreference) -> Void, failure: @escaping ((_ error: NSError) -> Void)) {
        
        mercadoPagoServices.getCheckoutPreference(checkoutPreferenceId: checkoutPreferenceId, callback: { [weak self] (pxCheckoutPreference) in
            guard let strongSelf = self else {
                return
            }
            MercadoPagoContext.setSiteID(pxCheckoutPreference.siteId)
            let checkoutPreference = strongSelf.getCheckoutPreferenceFromPXCheckoutPreference(pxCheckoutPreference)
            callback(checkoutPreference)
        }, failure: failure)
    }
    
    open func getInstructions(paymentId: Int64, paymentTypeId: String, callback : @escaping (InstructionsInfo) -> Void, failure: @escaping ((_ error: NSError) -> Void)) {
        
        mercadoPagoServices.getInstructions(paymentId: paymentId, paymentTypeId: paymentTypeId, callback: { [weak self] (pxInstructions) in
            guard let strongSelf = self else {
                return
            }

            let instructionsInfo = strongSelf.getInstructionsInfoFromPXInstructions(pxInstructions)
            callback(instructionsInfo)
        }, failure: failure)
    }
    
    open func getPaymentMethodSearch(amount: Double, excludedPaymentTypesIds: Set<String>?, excludedPaymentMethodsIds: Set<String>?, defaultPaymentMethod: String?, payer: Payer, site: String, callback : @escaping (PaymentMethodSearch) -> Void, failure: @escaping ((_ error: NSError) -> Void)) {
        
        let pxPayer = getPXPayerFromPayer(payer)
        let pxSite = getPXSiteFromId(site)
        
        mercadoPagoServices.getPaymentMethodSearch(amount: amount, excludedPaymentTypesIds: excludedPaymentTypesIds, excludedPaymentMethodsIds: excludedPaymentMethodsIds, defaultPaymentMethod: defaultPaymentMethod, payer: pxPayer, site: pxSite, callback: {  [weak self] (pxPaymentMethodSearch) in
            guard let strongSelf = self else {
                return
            }
            let paymentMethodSearch = strongSelf.getPaymentMethodSearchFromPXPaymentMethodSearch(pxPaymentMethodSearch)
            callback(paymentMethodSearch)
        }, failure: failure)
    }
    
    open func createPayment(url: String, uri: String, transactionId: String? = nil, paymentData: NSDictionary, callback : @escaping (Payment) -> Void, failure: @escaping ((_ error: NSError) -> Void)) {
        
        mercadoPagoServices.createPayment(url: url, uri: uri, transactionId: transactionId, paymentData: paymentData, callback: { [weak self] (pxPayment) in
            guard let strongSelf = self else {
                return
            }
            let payment = strongSelf.getPaymentFromPXPayment(pxPayment)
            callback(payment)
        }, failure: failure)
    }
    
    open func createToken(cardToken: CardToken, callback : @escaping (Token) -> Void, failure: @escaping ((_ error: NSError) -> Void)) {
        
        mercadoPagoServices.createToken(cardToken: cardToken, callback: { [weak self] (pxToken) in
            guard let strongSelf = self else {
                return
            }

            let token = strongSelf.getTokenFromPXToken(pxToken)
            callback(token)
        }, failure: failure)
    }
    
    open func createToken(savedESCCardToken: SavedESCCardToken, callback : @escaping (Token) -> Void, failure: @escaping ((_ error: NSError) -> Void)) {
        
        mercadoPagoServices.createToken(savedESCCardToken: savedESCCardToken, callback: { [weak self] (pxToken) in
            guard let strongSelf = self else {
                return
            }

            let token = strongSelf.getTokenFromPXToken(pxToken)
            callback(token)
        }, failure: failure)
    }
    
    open func createToken(savedCardToken: SavedCardToken, callback : @escaping (Token) -> Void, failure: @escaping ((_ error: NSError) -> Void)) {
    
        mercadoPagoServices.createToken(savedCardToken: savedCardToken, callback: { [weak self] (pxToken) in
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
    
    open func getBankDeals(callback : @escaping ([BankDeal]) -> Void, failure: @escaping ((_ error: NSError) -> Void)) {
        
        mercadoPagoServices.getBankDeals(callback: { [weak self] (pxBankDeals) in
            guard let strongSelf = self else {
                return
            }
            var bankDeals: [BankDeal] = []
            for pxBankDeal in pxBankDeals {
                let bankDeal = strongSelf.getBankDealFromPXBankDeal(pxBankDeal)
                bankDeals.append(bankDeal)
            }
            callback(bankDeals)
        }, failure: failure)
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
    
    open func getCodeDiscount(amount: Double, payerEmail: String, couponCode: String?, discountAdditionalInfo: NSDictionary?, callback: @escaping (DiscountCoupon?) -> Void, failure: @escaping ((_ error: NSError) -> Void)) {
        
        mercadoPagoServices.getCodeDiscount(amount: amount, payerEmail: payerEmail, couponCode: couponCode, discountAdditionalInfo: discountAdditionalInfo, callback: { [weak self] (pxDiscount) in
            guard let strongSelf = self else {
                return
            }

            if let pxDiscount = pxDiscount {
                let discountCoupon = strongSelf.getDiscountCouponFromPXDiscount(pxDiscount)
                callback(discountCoupon)
            } else {
                callback(nil)
            }
        }, failure: failure)
    }
    
    open func getDirectDiscount(amount: Double, payerEmail: String, discountAdditionalInfo: NSDictionary?, callback: @escaping (DiscountCoupon?) -> Void, failure: @escaping ((_ error: NSError) -> Void)) {
        getCodeDiscount(amount: amount, payerEmail: payerEmail, couponCode: nil, discountAdditionalInfo: discountAdditionalInfo, callback: callback, failure: failure)
    }

    open func getInstallments(bin: String?, amount: Double, issuer: Issuer?, paymentMethodId: String, callback: @escaping ([Installment]) -> Void, failure: @escaping ((_ error: NSError) -> Void)) {

        mercadoPagoServices.getInstallments(bin: bin, amount: amount, issuerId: issuer?._id, paymentMethodId: paymentMethodId, callback: { [weak self] (pxInstallments) in
            guard let strongSelf = self else {
                return
            }

            var installments: [Installment] = []
            for pxInstallment in pxInstallments {
                let installment = strongSelf.getInstallmentFromPXInstallment(pxInstallment)
                installments.append(installment)
            }
            callback(installments)
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
        
        mercadoPagoServices.getCustomer(callback: { [weak self] (pxCustomer) in
            guard let strongSelf = self else {
                return
            }

            let customer = strongSelf.getCustomerFromPXCustomer(pxCustomer)
            callback(customer)
        }, failure: failure)
        
    }
}
