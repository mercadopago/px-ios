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

    init(servicePreference: ServicePreference? = nil) {
        super.init()
    }

    open func getCheckoutPreference(checkoutPreferenceId: String, callback : @escaping (CheckoutPreference) -> Void, failure: @escaping ((_ error: NSError) -> Void)) {
        callback(MockBuilder.buildCheckoutPreference())
    }

    open func getInstructions(paymentId: String, paymentTypeId: String, callback : @escaping (InstructionsInfo) -> Void, failure: @escaping ((_ error: NSError) -> Void)) {
        callback(MockBuilder.buildInstructionsInfo(paymentMethod: MockBuilder.buildPaymentMethod(paymentId)))
    }

    open func getPaymentMethodSearch(amount: Double, excludedPaymentTypesIds: Set<String>?, excludedPaymentMethodsIds: Set<String>?, defaultPaymentMethod: String?, payer: Payer, site: String, callback : @escaping (PaymentMethodSearch) -> Void, failure: @escaping ((_ error: NSError) -> Void)) {
        callback(MockBuilder.buildPaymentMethodSearchComplete())
    }

    open func createPayment(url: String, uri: String, transactionId: String? = nil, paymentData: NSDictionary, query: [String: String]? = nil, callback : @escaping (Payment) -> Void, failure: @escaping ((_ error: NSError) -> Void)) {
        callback(MockBuilder.buildPayment("visa"))
    }

    open func createToken(cardToken: CardToken, callback : @escaping (Token) -> Void, failure: @escaping ((_ error: PXError) -> Void)) {
        if cardToken.cardNumber == "invalid_identification_number" {
            let cause: [String: String] = ["code": "324", "description": "Invalid parameter 'cardholder.identification.number'"]
            let apiException = PXApiException()

            let pxCause = PXCause(code: "324", description: "Invalid parameter 'cardholder.identification.number'" )
            apiException.cause = [pxCause]
            apiException.error = "400"
            apiException.status = 400
            let error = PXError(domain: "mercadopago.sdk.GatewayService.getToken", code: 400, userInfo: ["cause": [cause]], apiException: apiException)

            failure(error)
        }
        callback(MockBuilder.buildToken())
    }

    open func createToken(savedESCCardToken: SavedESCCardToken, callback : @escaping (Token) -> Void, failure: @escaping ((_ error: NSError) -> Void)) {
        callback(MockBuilder.buildToken())
    }

    open func createToken(savedCardToken: SavedCardToken, callback : @escaping (Token) -> Void, failure: @escaping ((_ error: NSError) -> Void)) {
        callback(MockBuilder.buildToken())
    }

    internal func createToken(cardTokenJSON: String, callback : @escaping (Token) -> Void, failure: @escaping ((_ error: NSError) -> Void)) {
        callback(MockBuilder.buildToken())
    }

    open func cloneToken(tokenId: String, securityCode: String, callback : @escaping (Token) -> Void, failure: @escaping ((_ error: NSError) -> Void)) {
        callback(MockBuilder.buildToken())
    }

    open func getBankDeals(callback : @escaping ([PXBankDeal]) -> Void, failure: @escaping ((_ error: NSError) -> Void)) {
        callback([MockBuilder.buildPXBankDeal()])
    }

    open func getIdentificationTypes(callback: @escaping ([IdentificationType]) -> Void, failure: @escaping ((_ error: NSError) -> Void)) {
        callback(MockBuilder.buildIdentificationTypes())
    }

    open func getCodeDiscount(amount: Double, payerEmail: String, couponCode: String?, callback: @escaping (DiscountCoupon?) -> Void, failure: @escaping ((_ error: NSError) -> Void)) {
        callback(MockBuilder.buildDiscount())
    }

    open func getDirectDiscount(amount: Double, payerEmail: String, callback: @escaping (DiscountCoupon?) -> Void, failure: @escaping ((_ error: NSError) -> Void)) {
        callback(MockBuilder.buildDiscount())
    }

    open func getInstallments(bin: String?, amount: Double, issuer: Issuer?, paymentMethodId: String, callback: @escaping ([Installment]) -> Void, failure: @escaping ((_ error: NSError) -> Void)) {
        callback([MockBuilder.buildInstallment()])
    }

    open func getIssuers(paymentMethodId: String, bin: String? = nil, callback: @escaping ([Issuer]) -> Void, failure: @escaping ((_ error: NSError) -> Void)) {
        callback([MockBuilder.buildIssuer()])
    }

    open func getCustomer(callback: @escaping (Customer) -> Void, failure: @escaping ((_ error: NSError) -> Void)) {
        callback(MockBuilder.buildCustomer())
    }
}
