//
//  Card.swift
//  MercadoPagoSDK
//
//  Created by Matias Gualino on 28/12/14.
//  Copyright (c) 2014 com.mercadopago. All rights reserved.
//

import Foundation
import UIKit

@objcMembers open class Card: NSObject, CardInformation, PaymentMethodOption {

    open var cardHolder: Cardholder?
    open var customerId: String?
    open var dateCreated: Date?
    open var dateLastUpdated: Date?
    open var expirationMonth: Int = 0
    open var expirationYear: Int = 0
    open var firstSixDigits: String?
    open var idCard: String = ""
    open var lastFourDigits: String?
    open var paymentMethod: PaymentMethod?
    open var issuer: Issuer?
    open var securityCode: SecurityCode?

    open class func fromJSON(_ json: NSDictionary) -> Card {
                let card: Card = Card()
                if let customerId = JSONHandler.attemptParseToString(json["customer_id"]) {
                        card.customerId = customerId
                    }
                if let expirationMonth = JSONHandler.attemptParseToInt(json["expiration_month"]) {
                        card.expirationMonth = expirationMonth
                    }
                if let expirationYear = JSONHandler.attemptParseToInt(json["expiration_year"]) {
                        card.expirationYear = expirationYear
                    }
                card.idCard = JSONHandler.attemptParseToString(json["id"], defaultReturn: "")!
                if let lastFourDigits = JSONHandler.attemptParseToString(json["last_four_digits"]) {
                        card.lastFourDigits = lastFourDigits
                   }
                if let firstSixDigits = JSONHandler.attemptParseToString(json["first_six_digits"]) {
                        card.firstSixDigits = firstSixDigits
                    }
                if let issuerDic = json["issuer"] as? NSDictionary {
                        card.issuer = Issuer.fromJSON(issuerDic)
                    }
                if let secDic = json["security_code"] as? NSDictionary {
                        card.securityCode = SecurityCode.fromJSON(secDic)
                    }
                if let pmDic = json["payment_method"] as? NSDictionary {
                        card.paymentMethod = PaymentMethod.fromJSON(pmDic)
                    }
                if let chDic = json["card_holder"] as? NSDictionary {
                       card.cardHolder = Cardholder.fromJSON(chDic)
                   }
               if let dateLastUpdated = JSONHandler.attemptParseToString(json["date_last_updated"]) {
                        card.dateLastUpdated = Utils.getDateFromString(dateLastUpdated)
                    }
                if let dateCreated = JSONHandler.attemptParseToString(json["date_created"]) {
                        card.dateCreated = Utils.getDateFromString(dateCreated)
                    }
                return card
            }

    public func getIssuer() -> Issuer? {
        return self.issuer
    }

    open func toJSONString() -> String {
        return JSONHandler.jsonCoding(toJSON())
    }

    open func toJSON() -> [String: Any] {
        let cardHolder: Any = self.cardHolder == nil ? JSONHandler.null : self.cardHolder!.toJSON()
        let customer_id: Any = self.customerId == nil ? JSONHandler.null : self.customerId!
        let dateCreated: Any = self.dateCreated == nil ? JSONHandler.null : String(describing: self.dateCreated!)
        let dateLastUpdated: Any = self.dateLastUpdated == nil ? JSONHandler.null : String(describing: self.dateLastUpdated!)
        let firstSixDigits: Any = self.firstSixDigits == nil ? JSONHandler.null : self.firstSixDigits!
        let lastFourDigits: Any = self.lastFourDigits == nil ? JSONHandler.null : self.lastFourDigits!
        let paymentMethod: Any = self.paymentMethod == nil ? JSONHandler.null : self.paymentMethod!.toJSON()
        let issuer: Any = self.issuer == nil ? JSONHandler.null : self.issuer!.toJSON()
        let securityCode: Any = self.securityCode == nil ? JSONHandler.null : self.securityCode!.toJSON()
        let obj: [String: Any] = [
            "card_holder": cardHolder,
            "customer_id": customer_id,
            "date_created": dateCreated,
            "date_last_updated": dateLastUpdated,
            "expiration_month": self.expirationMonth,
            "expiration_year": self.expirationYear,
            "first_six_digits": firstSixDigits,
            "id": self.idCard,
            "last_four_digits": lastFourDigits,
            "payment_method": paymentMethod,
            "issuer": issuer,
            "security_code": securityCode
        ]
        return obj
    }

    open func isSecurityCodeRequired() -> Bool {
        if securityCode != nil {
            if securityCode!.length != 0 {
                return true
            } else {
                return false
            }
        } else {
            return false
        }
    }

    public func getFirstSixDigits() -> String! {
        return firstSixDigits
    }
    open func getCardDescription() -> String {
        return "terminada en " + lastFourDigits! //TODO: Make it localizable
    }

    open func getPaymentMethod() -> PaymentMethod? {
        return self.paymentMethod
    }

    open func getCardId() -> String {
        return self.idCard
    }

    open func getPaymentMethodId() -> String {
        return (self.paymentMethod?.paymentMethodId)!
    }

    open func getPaymentTypeId() -> String {
        return self.paymentMethod?.paymentTypeId ?? ""
    }

    open func getCardSecurityCode() -> SecurityCode {
        return self.securityCode!
    }

    open func getCardBin() -> String? {
        return self.firstSixDigits
    }

    open func getCardLastForDigits() -> String? {
        return self.lastFourDigits!
    }

    open func setupPaymentMethodSettings(_ settings: [Setting]) {
        self.paymentMethod?.settings = settings
    }

    open func setupPaymentMethod(_ paymentMethod: PaymentMethod) {
        self.paymentMethod = paymentMethod
    }

    public func isIssuerRequired() -> Bool {
        return self.issuer == nil
    }

    public func canBeClone() -> Bool {
        return false
    }

    /** PaymentOptionDrawable implementation */

    public func getTitle() -> String {
        return getCardDescription()
    }

    public func getSubtitle() -> String? {
        return nil
    }

    public func getImage() -> UIImage? {
        return MercadoPago.getImageForPaymentMethod(withDescription: self.getPaymentMethodId())
    }

    /** PaymentMethodOption implementation */

    public func getId() -> String {
        return String(describing: self.idCard)
    }

    public func getChildren() -> [PaymentMethodOption]? {
        return nil
    }

    public func hasChildren() -> Bool {
        return false
    }

    public func isCard() -> Bool {
        return true
    }

    public func isCustomerPaymentMethod() -> Bool {
        return true
    }

    public func getDescription() -> String {
        return ""
    }

    public func getComment() -> String {
        return ""
    }
}
