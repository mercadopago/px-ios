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
    
    open class func getCheckoutPreference(checkoutPreferenceId: String, callback : @escaping (CheckoutPreference) -> Void, failure: @escaping ((_ error: NSError) -> Void)) {
        
        MercadoPagoServices.getCheckoutPreference(checkoutPreferenceId: checkoutPreferenceId, callback: { (pxCheckoutPreference) in
            MercadoPagoContext.setSiteID(pxCheckoutPreference.siteId)
            let checkoutPreference = getCheckoutPreferenceFromPXCheckoutPreference(pxCheckoutPreference)
            callback(checkoutPreference)
        }, failure: failure)
    }
    
    open class func getInstructions(paymentId: Int64, paymentTypeId: String, callback : @escaping (InstructionsInfo) -> Void, failure: @escaping ((_ error: NSError) -> Void)) {
        
        MercadoPagoServices.getInstructions(paymentId: paymentId, paymentTypeId: paymentTypeId, callback: { (pxInstructions) in
            let instructionsInfo = getInstructionsInfoFromPXInstructions(pxInstructions)
            callback(instructionsInfo)
        }, failure: failure)
    }
    
    open class func getPaymentMethodSearch(amount: Double, excludedPaymentTypesIds: Set<String>?, excludedPaymentMethodsIds: Set<String>?, defaultPaymentMethod: String?, payer: Payer, site: String, callback : @escaping (PaymentMethodSearch) -> Void, failure: @escaping ((_ error: NSError) -> Void)) {
        
        let pxPayer = getPXPayerFromPayer(payer)
        let pxSite = getPXSiteFromId(site)
        
        MercadoPagoServices.getPaymentMethodSearch(amount: amount, excludedPaymentTypesIds: excludedPaymentTypesIds, excludedPaymentMethodsIds: excludedPaymentMethodsIds, defaultPaymentMethod: defaultPaymentMethod, payer: pxPayer, site: pxSite, callback: { (pxPaymentMethodSearch) in
            let paymentMethodSearch = getPaymentMethodSearchFromPXPaymentMethodSearch(pxPaymentMethodSearch)
            callback(paymentMethodSearch)
        }, failure: failure)
    }
    
    open class func createPayment(url: String, uri: String, transactionId: String? = nil, paymentData: NSDictionary, callback : @escaping (Payment) -> Void, failure: @escaping ((_ error: NSError) -> Void)) {
        
        MercadoPagoServices.createPayment(url: url, uri: uri, transactionId: transactionId, paymentData: paymentData, callback: { (pxPayment) in
            let payment = getPaymentFromPXPayment(pxPayment)
            callback(payment)
        }, failure: failure)
    }
    
    open class func createToken(cardToken: CardToken, callback : @escaping (Token) -> Void, failure: @escaping ((_ error: NSError) -> Void)) {
        
        MercadoPagoServices.createToken(cardToken: cardToken, callback: { (pxToken) in
            let token = getTokenFromPXToken(pxToken)
            callback(token)
        }, failure: failure)
    }
    
    open class func createToken(savedESCCardToken: SavedESCCardToken, callback : @escaping (Token) -> Void, failure: @escaping ((_ error: NSError) -> Void)) {
        
        MercadoPagoServices.createToken(savedESCCardToken: savedESCCardToken, callback: { (pxToken) in
            let token = getTokenFromPXToken(pxToken)
            callback(token)
        }, failure: failure)
    }
    
    open class func createToken(savedCardToken: SavedCardToken, callback : @escaping (Token) -> Void, failure: @escaping ((_ error: NSError) -> Void)) {
    
        MercadoPagoServices.createToken(savedCardToken: savedCardToken, callback: { (pxToken) in
            let token = getTokenFromPXToken(pxToken)
            callback(token)
        }, failure: failure)
    }
    
    internal class func createToken(cardTokenJSON: String, callback : @escaping (Token) -> Void, failure: @escaping ((_ error: NSError) -> Void)) {
        
        MercadoPagoServices.createToken(cardTokenJSON: cardTokenJSON, callback: { (pxToken) in
            let token = getTokenFromPXToken(pxToken)
            callback(token)
        }, failure: failure)
    }
    
    open class func getCodeDiscount(amount: Double, payerEmail: String, couponCode: String?, discountAdditionalInfo: NSDictionary?, callback: @escaping (DiscountCoupon?) -> Void, failure: @escaping ((_ error: NSError) -> Void)) {
        
        MercadoPagoServices.getCodeDiscount(amount: amount, payerEmail: payerEmail, couponCode: couponCode, discountAdditionalInfo: discountAdditionalInfo, callback: { (pxDiscount) in
            if let pxDiscount = pxDiscount {
                let discountCoupon = getDiscountCouponFromPXDiscount(pxDiscount)
                callback(discountCoupon)
            } else {
                callback(nil)
            }
        }, failure: failure)
    }
    
    open class func getDirectDiscount(amount: Double, payerEmail: String, discountAdditionalInfo: NSDictionary?, callback: @escaping (DiscountCoupon?) -> Void, failure: @escaping ((_ error: NSError) -> Void)) {
        getCodeDiscount(amount: amount, payerEmail: payerEmail, couponCode: nil, discountAdditionalInfo: discountAdditionalInfo, callback: callback, failure: failure)
    }

    open class func getInstallments(bin: String?, amount: Double, issuer: Issuer?, paymentMethodId: String, callback: @escaping ([Installment]) -> Void, failure: @escaping ((_ error: NSError) -> Void)) {

        MercadoPagoServices.getInstallments(bin: bin, amount: amount, issuerId: issuer?._id, paymentMethodId: paymentMethodId, callback: { (pxInstallments) in
            var installments: [Installment] = []
            for pxInstallment in pxInstallments {
                let installment = getInstallmentFromPXInstallment(pxInstallment)
                installments.append(installment)
            }
            callback(installments)
        }, failure: failure)
    }
    
    open class func getIssuers(paymentMethodId: String, bin: String? = nil, callback: @escaping ([Issuer]) -> Void, failure: @escaping ((_ error: NSError) -> Void)) {
        
        MercadoPagoServices.getIssuers(paymentMethodId: paymentMethodId, bin: bin, callback: { (pxIssuers) in
            var issuers: [Issuer] = []
            for pxIssuer in pxIssuers {
                let issuer = getIssuerFromPXIssuer(pxIssuer)
                issuers.append(issuer)
            }
            callback(issuers)
        }, failure: failure)
    }
    
    open class func getCustomer(additionalInfo: NSDictionary? = nil, callback: @escaping (Customer) -> Void, failure: @escaping ((_ error: NSError) -> Void)) {
        
        MercadoPagoServices.getCustomer(additionalInfo: additionalInfo, callback: { (pxCustomer) in
            let customer = getCustomerFromPXCustomer(pxCustomer)
            callback(customer)
        }, failure: failure)
        
    }
    
    open class func getCustomerByPXCustomer(_ pxCustomer: PXCustomer) -> Customer {
        let customer = Customer()
        return customer
    }
    
    open class func getIssuerByPXIssuer(_ pxIssuer: PXIssuer) -> Issuer {
        let issuer = Issuer()
        issuer._id = pxIssuer._id
        issuer.name = pxIssuer.name
        return issuer
    }
}
