//
//  PaymentData.swift
//  MercadoPagoSDK
//
//  Created by Maria cristina rodriguez on 2/1/17.
//  Copyright © 2017 MercadoPago. All rights reserved.
//

import UIKit

public class PaymentData: NSObject {

    public var paymentMethod: PaymentMethod!
    public var issuer: Issuer?
    public var payerCost: PayerCost?
    public var token: Token?
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
