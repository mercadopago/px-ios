//
//  PaymentData.swift
//  MercadoPagoSDK
//
//  Created by Maria cristina rodriguez on 2/1/17.
//  Copyright © 2017 MercadoPago. All rights reserved.
//

import UIKit

public class PaymentData: NSObject {

    private var paymentMethod: PaymentMethod!
    private var issuer: Issuer?
    private var payerCost: PayerCost?
    private var token: Token?
    public var payer = Payer()
    public var transactionDetails: TransactionDetails?
    public var discount: DiscountCoupon?

    func clearCollectedData() {
        self.paymentMethod = nil
        self.issuer = nil
        self.payerCost = nil
        self.token = nil
        self.payer.clearCollectedData()
        self.transactionDetails = nil
        // No borrar el descuento
    }

    func isComplete() -> Bool {

        if paymentMethod == nil {
            return false
        }

        if paymentMethod.isEntityTypeRequired() && payer.entityType == nil {
            return false
        }

        if !Array.isNullOrEmpty(paymentMethod.financialInstitutions) && transactionDetails?.financialInstitution == nil {
            return false
        }

        if paymentMethod._id == PaymentTypeId.ACCOUNT_MONEY.rawValue || !paymentMethod.isOnlinePaymentMethod() {
            return true
        }

        if paymentMethod!.isCard() && (token == nil || payerCost == nil) {

            if (paymentMethod.paymentTypeId == PaymentTypeId.DEBIT_CARD.rawValue || paymentMethod.paymentTypeId == PaymentTypeId.PREPAID_CARD.rawValue ) && token != nil {
                return true
            }
            return false
        }

        return true
    }

    func hasToken() -> Bool {
        return token != nil
    }

    func hasIssuer() -> Bool {
        return issuer != nil
    }

    func hasPayerCost() -> Bool {
        return payerCost != nil
    }

    func hasPaymentMethod() -> Bool {
        return paymentMethod != nil
    }

    func hasCustomerPaymentOption() -> Bool {
        return hasPaymentMethod() && (self.paymentMethod.isAccountMoney() || (hasToken() && !String.isNullOrEmpty(self.token!.cardId)))
    }

    public func updatePaymentDataWith(paymentMethod: PaymentMethod) {
        cleanIssuer()
        cleanToken()
        cleanPayerCost()
        self.paymentMethod = paymentMethod
    }

    public func updatePaymentDataWith(token: Token) {
        self.token = token
    }

    public func updatePaymentDataWith(payerCost: PayerCost) {
        self.payerCost = payerCost
    }

    public func updatePaymentDataWith(issuer: Issuer) {
        cleanPayerCost()
        self.issuer = issuer
    }

    public func cleanToken() {
        self.token = nil
    }

    public func cleanPayerCost() {
        self.payerCost = nil
    }

    func cleanIssuer() {
        self.issuer = nil
    }

    func cleanPaymentMethod() {
        self.paymentMethod = nil
    }

   public func getToken() -> Token? {
        return token
    }

    public func getPayerCost() -> PayerCost? {
        return payerCost
    }

    public func getIssuer() -> Issuer? {
        return issuer
    }

    public func getPaymentMethod() -> PaymentMethod {
        return paymentMethod
    }

    func toJSONString() -> String {
        return JSONHandler.jsonCoding(toJSON())
    }

    func toJSON() -> [String:Any] {
       var obj: [String:Any] = [
            "payment_method": self.paymentMethod.toJSON(),
            "payer": payer.toJSON()
       ]

        if let payerCost = self.payerCost {
            obj["payer_cost"] = payerCost.toJSON()
        }

        if let token = self.token {
            obj["card_token"] = token.toJSON()
        }

        if let issuer = self.issuer {
            obj["issuer"] = issuer.toJSON()
        }

        if let discount = self.discount {
            obj["discount"] = discount.toJSON()
        }

        return obj
    }

}
