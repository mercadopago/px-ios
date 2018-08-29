//
//  PaymentData.swift
//  MercadoPagoSDK
//
//  Created by Maria cristina rodriguez on 2/1/17.
//  Copyright © 2017 MercadoPago. All rights reserved.
//

import UIKit
import MercadoPagoServicesV4

@objcMembers public class PaymentData: NSObject, NSCopying {

    public var paymentMethod: PaymentMethod?
    public var issuer: Issuer?
    public var payerCost: PayerCost?
    public var token: Token?
    public var payer: Payer?
    public var transactionDetails: TransactionDetails?
    public private(set) var discount: PXDiscount?
    public private(set) var campaign: PXCampaign?
    private let paymentTypesWithoutInstallments = [PaymentTypeId.PREPAID_CARD.rawValue]

    /**
     Este metodo deberia borrar SOLO la data recolectada atraves del flujo de Checkout,
     i.e. la data ingresada por el payer 
     */
    func clearCollectedData() {
        self.paymentMethod = nil
        self.issuer = nil
        self.payerCost = nil
        self.token = nil
        self.payer?.clearCollectedData() // No borrar el payer directo
        self.transactionDetails = nil
        // No borrar el descuento
    }

    public func copy(with zone: NSZone? = nil) -> Any {
        let copyObj = PaymentData()
        copyObj.paymentMethod = paymentMethod
        copyObj.issuer = issuer
        copyObj.payerCost = payerCost
        copyObj.token = token
        copyObj.payerCost = payerCost
        copyObj.transactionDetails = transactionDetails
        copyObj.discount = discount
        copyObj.campaign = campaign
        copyObj.payer = payer
        return copyObj
    }

    func isComplete(shouldCheckForToken: Bool = true) -> Bool {

        guard let paymentMethod = self.paymentMethod else {
            return false
        }

        if paymentMethod.isEntityTypeRequired && payer?.entityType == nil {
            return false
        }

        if paymentMethod.isPayerInfoRequired && payer?.identification == nil {
            return false
        }

        if !Array.isNullOrEmpty(paymentMethod.financialInstitutions) && transactionDetails?.financialInstitution == nil {
            return false
        }

        if paymentMethod.paymentMethodId == PaymentTypeId.ACCOUNT_MONEY.rawValue || !paymentMethod.isOnlinePaymentMethod {
            return true
        }

        if paymentMethod.isIssuerRequired && self.issuer == nil {
            return false
        }

        if paymentMethod.isCard && payerCost == nil &&
            !paymentTypesWithoutInstallments.contains(paymentMethod.paymentTypeId) {
            return false
        }

        if paymentMethod.isCard && !hasToken() && shouldCheckForToken {
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
        return hasPaymentMethod() && (self.paymentMethod!.isAccountMoney || (hasToken() && !String.isNullOrEmpty(self.token!.cardId)))
    }

    public func updatePaymentDataWith(paymentMethod: PaymentMethod?) {
        guard let paymentMethod = paymentMethod else {
            return
        }
        cleanIssuer()
        cleanToken()
        cleanPayerCost()
        self.paymentMethod = paymentMethod
    }

    public func updatePaymentDataWith(token: Token?) {
        guard let token = token else {
            return
        }
        self.token = token
    }

    public func updatePaymentDataWith(payerCost: PayerCost?) {
        guard let payerCost = payerCost else {
            return
        }
        self.payerCost = payerCost
    }

    public func updatePaymentDataWith(issuer: Issuer?) {
        guard let issuer = issuer else {
            return
        }
        cleanPayerCost()
        self.issuer = issuer
    }

    public func updatePaymentDataWith(payer: Payer?) {
        guard let payer = payer else {
            return
        }
        self.payer = payer
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

    public func getNumberOfInstallments() -> Int {
        guard let installments = payerCost?.installments else {
            return 0
        }
        return installments
    }

    public func getIssuer() -> Issuer? {
        return issuer
    }

    public func getPayer() -> Payer {
        var returnedPayer = Payer()
        if let payer = payer {
            returnedPayer = payer
        }
        return returnedPayer
    }

    public func getPaymentMethod() -> PaymentMethod? {
        return paymentMethod
    }

    func toJSONString() -> String {
        return JSONHandler.jsonCoding(toJSON())
    }

    func toJSON() -> [String: Any] {
       var obj: [String: Any] = [
        "payer": payer?.toJSON() ?? ""
       ]
        if let paymentMethod = self.paymentMethod {
            obj["payment_method"] = paymentMethod.toJSON()
        }

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
            obj["discount"] = discount.toJSONDictionary()
        }

        return obj
    }

    public func setDiscount(_ discount: PXDiscount, withCampaign campaign: PXCampaign) {
        self.discount = discount
        self.campaign = campaign
    }

    public func clearDiscount() {
        self.discount = nil
        self.campaign = nil
    }

}
