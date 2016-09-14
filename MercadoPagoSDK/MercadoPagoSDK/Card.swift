//
//  Card.swift
//  MercadoPagoSDK
//
//  Created by Matias Gualino on 28/12/14.
//  Copyright (c) 2014 com.mercadopago. All rights reserved.
//

import Foundation
import UIKit

public class Card : NSObject, CardInformation {
    
    public var cardHolder : Cardholder?
    public var customerId : String?
    public var dateCreated : NSDate?
    public var dateLastUpdated : NSDate?
    public var expirationMonth : Int = 0
    public var expirationYear : Int = 0
    public var firstSixDigits : String?
    public var idCard : NSNumber = 0
    public var lastFourDigits : String?
    public var paymentMethod : PaymentMethod?
    public var issuer : Issuer?
    public var securityCode : SecurityCode?
    

   public class func fromJSON(json : NSDictionary) -> Card {
        let card : Card = Card()
        if json["customer_id"] != nil && !(json["customer_id"]! is NSNull) {
            card.customerId = JSON(json["customer_id"]!).asString
        }
		if json["expiration_month"] != nil && !(json["expiration_month"]! is NSNull) {
			card.expirationMonth = JSON(json["expiration_month"]!).asInt!
		}
		if json["expiration_year"] != nil && !(json["expiration_year"]! is NSNull) {
			card.expirationYear = JSON(json["expiration_year"]!).asInt!
		}
		if json["id"] != nil && !(json["id"]! is NSNull) {
			card.idCard = NSNumber(longLong: (json["id"]! as? NSString)!.longLongValue)
		}
        card.lastFourDigits = JSON(json["last_four_digits"]!).asString
        card.firstSixDigits = JSON(json["first_six_digits"]!).asString
        if let issuerDic = json["issuer"] as? NSDictionary {
            card.issuer = Issuer.fromJSON(issuerDic)
        }
        if let secDic = json["security_code"] as? NSDictionary {
            card.securityCode = SecurityCode.fromJSON(secDic)
        }
        if let pmDic = json["payment_method"] as? NSDictionary {
            card.paymentMethod = PaymentMethod.fromJSON(pmDic)
        }
        if let chDic = json["cardholder"] as? NSDictionary {
            card.cardHolder = Cardholder.fromJSON(chDic)
        }
        card.dateLastUpdated = Utils.getDateFromString(json["date_last_updated"] as? String)
        card.dateCreated = Utils.getDateFromString(json["date_created"] as? String)
        return card
    }
    
    public func toJSONString() -> String {
        return self.toJSON().toString()
    }
    
    public func toJSON() -> JSON {
        let obj:[String:AnyObject] = [
            "cardHolder" : self.cardHolder == nil ? JSON.null : self.cardHolder!.toJSON().mutableCopyOfTheObject(),
            "customer_id": self.customerId == nil ? JSON.null : self.customerId!,
            "dateCreated" : self.dateCreated == nil ? JSON.null : String(self.dateCreated!),
            "dateLastUpdated" : self.dateLastUpdated == nil ? JSON.null : String(self.dateLastUpdated!),
            "expirationMonth" : self.expirationMonth,
            "expirationYear" : self.expirationYear,
            "firstSixDigits" : self.firstSixDigits == nil ? JSON.null : self.firstSixDigits!,
            "idCard" : self.idCard,
            "lastFourDigits" : self.lastFourDigits == nil ? JSON.null : self.lastFourDigits!,
            "paymentMethod" : self.paymentMethod == nil ? JSON.null : self.paymentMethod!.toJSON().mutableCopyOfTheObject(),
            "issuer" : self.issuer == nil ? JSON.null : self.issuer!.toJSONString(),
            "securityCode" : self.securityCode == nil ? JSON.null : self.securityCode!.toJSON().mutableCopyOfTheObject()       ]
        return JSON(obj)
    }
    
    public func isSecurityCodeRequired() -> Bool {
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

    
    public func getCardDescription() -> String {
        return "terminada en " + lastFourDigits!
    }
    
    public func getPaymentMethod() -> PaymentMethod {
        return self.paymentMethod!
    }
    
    public func getCardId() -> String {
        return self.idCard.stringValue
    }
    
    public func getPaymentMethodId() -> String {
        return (self.paymentMethod?._id)!
    }
    
    public func getCardSecurityCode() -> SecurityCode {
        return self.securityCode!
    }
    
    public func getCardBin() -> String? {
        return self.firstSixDigits
    }

    public func getCardLastForDigits() -> String? {
        return self.lastFourDigits
    }
    
    public func setupPaymentMethodSettings(settings: [Setting]) {
        self.paymentMethod?.settings = settings
    }
}



public func ==(obj1: Card, obj2: Card) -> Bool {
    
    let areEqual =
        obj1.cardHolder == obj2.cardHolder &&
        obj1.customerId == obj2.customerId &&
        obj1.dateCreated == obj2.dateCreated &&
        obj1.dateLastUpdated == obj2.dateLastUpdated &&
        obj1.expirationMonth == obj2.expirationMonth &&
        obj1.firstSixDigits == obj2.firstSixDigits &&
        obj1.idCard == obj2.idCard &&
        obj1.lastFourDigits == obj2.lastFourDigits &&
        obj1.paymentMethod == obj2.paymentMethod &&
        obj1.issuer == obj2.issuer &&
        obj1.securityCode == obj2.securityCode
    return areEqual
}

