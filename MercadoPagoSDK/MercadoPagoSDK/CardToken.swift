//
//  CardToken.swift
//  MercadoPagoSDK
//
//  Created by Matias Gualino on 31/12/14.
//  Copyright (c) 2014 com.mercadopago. All rights reserved.
//

import Foundation
import UIKit

public class CardToken : NSObject {
    
    let MIN_LENGTH_NUMBER : Int = 10
    let MAX_LENGTH_NUMBER : Int = 19
    
    public var device : Device?
    public var securityCode : String?
    
    let now = NSCalendar.currentCalendar().components([NSCalendarUnit.NSYearCalendarUnit, NSCalendarUnit.NSMonthCalendarUnit], fromDate: NSDate())
    
    public var cardNumber : String?
    public var expirationMonth : Int = 0
    public var expirationYear : Int = 0
    public var cardholder : Cardholder?
    
    
    public override init(){
        super.init()
    }
    
    public init (cardNumber: String?, expirationMonth: Int, expirationYear: Int,
        securityCode: String?, cardholderName: String, docType: String, docNumber: String) {
            super.init()
            self.cardholder = Cardholder()
            self.cardholder?.name = cardholderName
            self.cardholder?.identification = Identification()
            self.cardholder?.identification?.number = docNumber
            self.cardholder?.identification?.type = docType
            self.cardNumber = normalizeCardNumber(cardNumber!.stringByReplacingOccurrencesOfString(" ", withString: ""))
            self.expirationMonth = expirationMonth
            self.expirationYear = normalizeYear(expirationYear)
            self.securityCode = securityCode
    }
    
    public func normalizeCardNumber(number: String?) -> String? {
        if number == nil {
            return nil
        }
        return number!.stringByTrimmingCharactersInSet(NSCharacterSet.whitespaceCharacterSet()).stringByReplacingOccurrencesOfString("\\s+|-", withString: "")
    }
    
    public func validate() -> Bool {
        return validate(true)
    }
    
    public func validate(includeSecurityCode: Bool) -> Bool {
        var result : Bool = validateCardNumber() == nil  && validateExpiryDate() == nil && validateIdentification() == nil && validateCardholderName() == nil
        if (includeSecurityCode) {
            result = result && validateSecurityCode() == nil
        }
        return result
    }
    
    public func validateCardNumber() -> NSError? {
        if String.isNullOrEmpty(cardNumber) {
            return NSError(domain: "mercadopago.sdk.card.error", code: 1, userInfo: ["cardNumber" : "Ingresa el número de la tarjeta de crédito".localized])
        } else if self.cardNumber!.characters.count < MIN_LENGTH_NUMBER || self.cardNumber!.characters.count > MAX_LENGTH_NUMBER {
            return NSError(domain: "mercadopago.sdk.card.error", code: 1, userInfo: ["cardNumber" : "invalid_field".localized])
        } else {
            return nil
        }
    }
    
    public func validateCardNumber(paymentMethod: PaymentMethod) -> NSError? {
        var userInfo : [String : String]?
        cardNumber = cardNumber?.stringByReplacingOccurrencesOfString("•", withString: "")
        let validCardNumber = self.validateCardNumber()
        if validCardNumber != nil {
            return validCardNumber
        } else {
        
            let setting : Setting? = Setting.getSettingByBin(paymentMethod.settings, bin: getBin())
            
            if setting == nil {
                if userInfo == nil {
                    userInfo = [String : String]()
                }
                userInfo?.updateValue("El número de tarjeta que ingresaste no se corresponde con el tipo de tarjeta".localized, forKey: "cardNumber")
            } else {
                
                // Validate card length
                if (cardNumber!.trimSpaces().characters.count != setting?.cardNumber.length) {
                    if userInfo == nil {
                        userInfo = [String : String]()
                    }
                    userInfo?.updateValue(("invalid_card_length".localized as NSString).stringByReplacingOccurrencesOfString("%1$s", withString: "\(setting?.cardNumber.length)"), forKey: "cardNumber")
                }
                
                // Validate luhn
                if "standard" == setting?.cardNumber.validation && !checkLuhn((cardNumber?.trimSpaces())!) {
                    if userInfo == nil {
                        userInfo = [String : String]()
                    }
                    userInfo?.updateValue("El número de tarjeta que ingresaste es incorrecto".localized, forKey: "cardNumber")
                }
            }
        }
        
        if userInfo == nil {
            return nil
        } else {
            return NSError(domain: "mercadopago.sdk.card.error", code: 1, userInfo: userInfo)
        }
    }

    public func validateSecurityCode()  -> NSError? {
        return validateSecurityCode(securityCode)
    }
    
    public func validateSecurityCode(securityCode: String?) -> NSError? {
        if String.isNullOrEmpty(self.securityCode) || self.securityCode!.characters.count < 3 || self.securityCode!.characters.count > 4 {
            return NSError(domain: "mercadopago.sdk.card.error", code: 1, userInfo: ["securityCode" : "invalid_field".localized])
        } else {
            return nil
        }
    }
    
    public func validateSecurityCodeWithPaymentMethod(paymentMethod: PaymentMethod) -> NSError? {
        let validSecurityCode = self.validateSecurityCode(securityCode)
        if validSecurityCode != nil {
            return validSecurityCode
        } else {
            let range = Range(start: cardNumber!.startIndex,
                end: cardNumber!.characters.startIndex.advancedBy(6))
            return validateSecurityCodeWithPaymentMethod(securityCode!, paymentMethod: paymentMethod, bin: cardNumber!.substringWithRange(range))
        }
    }
    
    public func validateSecurityCodeWithPaymentMethod(securityCode: String, paymentMethod: PaymentMethod, bin: String) -> NSError? {
        let setting : Setting? = Setting.getSettingByBin(paymentMethod.settings, bin: getBin())
        // Validate security code length
        let cvvLength = setting?.securityCode.length
        if ((cvvLength != 0) && (securityCode.characters.count != cvvLength)) {
            return NSError(domain: "mercadopago.sdk.card.error", code: 1, userInfo: ["securityCode" : ("invalid_cvv_length".localized as NSString).stringByReplacingOccurrencesOfString("%1$s", withString: "\(cvvLength)")])
        } else {
            return nil
        }
    }
    
    public func validateExpiryDate() -> NSError? {
        return validateExpiryDate(expirationMonth, year: expirationYear)
    }
    
    public func validateExpiryDate(month: Int, year: Int) -> NSError? {
        if !validateExpMonth(month) {
			return NSError(domain: "mercadopago.sdk.card.error", code: 1, userInfo: ["expiryDate" : "invalid_field".localized])
        }
        if !validateExpYear(year) {
            return NSError(domain: "mercadopago.sdk.card.error", code: 1, userInfo: ["expiryDate" : "invalid_field".localized])
        }
        
        if hasMonthPassed(self.expirationYear, month: self.expirationMonth) {
            return NSError(domain: "mercadopago.sdk.card.error", code: 1, userInfo: ["expiryDate" : "invalid_field".localized])
        }
        
        return nil
    }
    
    public func validateExpMonth(month: Int) -> Bool {
        return (month >= 1 && month <= 12)
    }
    
    public func validateExpYear(year: Int) -> Bool {
        return !hasYearPassed(year)
    }
    
    public func validateIdentification() -> NSError? {
        
        let validType = validateIdentificationType()
        if validType != nil {
            return validType
        } else {
            let validNumber = validateIdentificationNumber()
            if validNumber != nil {
                return validNumber
            }
        }
        return nil
    }
    
    public func validateIdentificationType() -> NSError? {
        
        if String.isNullOrEmpty(cardholder!.identification!.type) {
            return NSError(domain: "mercadopago.sdk.card.error", code: 1, userInfo: ["identification" : "invalid_field".localized])
        } else {
            return nil
        }
    }
    
    public func validateIdentificationNumber() -> NSError? {
        
        if String.isNullOrEmpty(cardholder!.identification!.number) {
            return NSError(domain: "mercadopago.sdk.card.error", code: 1, userInfo: ["identification" : "invalid_field".localized])
        } else {
            return nil
        }
    }
    
    public func validateIdentificationNumber(identificationType: IdentificationType?) -> NSError? {
        if identificationType != nil {
            if cardholder?.identification != nil && cardholder?.identification?.number != nil {
                let len = cardholder!.identification!.number!.characters.count
                let min = identificationType!.minLength
                let max = identificationType!.maxLength
                if min != 0 && max != 0 {
                    if len > max || len < min {
                        return NSError(domain: "mercadopago.sdk.card.error", code: 1, userInfo: ["identification" : "invalid_field".localized])
                    } else {
                        return nil
                    }
                } else  {
                    return validateIdentificationNumber()
                }
            } else {
                return NSError(domain: "mercadopago.sdk.card.error", code: 1, userInfo: ["identification" : "invalid_field".localized])
            }
        } else {
            return validateIdentificationNumber()
        }
    }
    
    public func validateCardholderName() -> NSError? {
        if String.isNullOrEmpty(self.cardholder?.name) {
            return NSError(domain: "mercadopago.sdk.card.error", code: 1, userInfo: ["cardholder" : "invalid_field".localized])
        } else {
            return nil
        }
    }

    public func hasYearPassed(year: Int) -> Bool {
        let normalized : Int = normalizeYear(year)
        return normalized < now.year
    }
    
    public func hasMonthPassed(year: Int, month: Int) -> Bool {
        return hasYearPassed(year) || normalizeYear(year) == now.year && month < (now.month + 1)
    }
    
    public func normalizeYear(year: Int) -> Int {
        if year < 100 && year >= 0 {
            let currentYear : String = String(now.year)
            let range = Range(start: currentYear.startIndex,
                end: currentYear.characters.endIndex.advancedBy(-2))
            let prefix : String = currentYear.substringWithRange(range)
			
			let nsReturn : NSString = prefix + String(year)
            return nsReturn.integerValue
        }
        return year
    }
    
    public func checkLuhn(cardNumber : String) -> Bool {
        var sum : Int = 0
        var alternate = false
        if cardNumber.characters.count == 0 {
            return false
        }
        
        for var index = (cardNumber.characters.count-1); index >= 0; index-- {
            _ = NSRange(location: index, length: 1)
            var s = cardNumber as NSString
            s = s.substringWithRange(NSRange(location: index, length: 1))
            var n : Int = s.integerValue
            if (alternate)
            {
                n *= 2
                if (n > 9)
                {
                    n = (n % 10) + 1
                }
            }
            sum += n
            alternate = !alternate
        }
        
        return (sum % 10 == 0)
    }
    
    public func getBin() -> String? {
        let range = Range(start: cardNumber!.startIndex, end: cardNumber!.characters.startIndex.advancedBy(6))
        let bin :String? = cardNumber!.characters.count >= 6 ? cardNumber!.substringWithRange(range) : nil
        return bin
    }
    
    public func toJSONString() -> String {
        let obj:[String:AnyObject] = [
            "card_number": String.isNullOrEmpty(self.cardNumber) ? JSON.null : self.cardNumber!,
            "cardholder": (self.cardholder == nil) ? JSON.null : self.cardholder!.toJSON().mutableCopyOfTheObject(),
            "security_code" : String.isNullOrEmpty(self.securityCode) ? JSON.null : self.securityCode!,
            "expiration_month" : self.expirationMonth,
            "expiration_year" : self.expirationYear,
            "device" : self.device == nil ? JSON.null : self.device!.toJSONString()
        ]
        return JSON(obj).toString()
    }
    
    public func getNumberFormated() -> NSString {
        
        //TODO AMEX
        var str : String
        str = (cardNumber?.insert(" ", ind: 12))!
        str = (str.insert(" ", ind: 8))
        str = (str.insert(" ", ind: 4))
        str = (str.insert(" ", ind: 0))
        return str
    }
    
    public func getExpirationDateFormated() -> NSString {
        
        var str : String
        
        
        str = String(self.expirationMonth) + "/" + String(self.expirationYear).substringFromIndex(String(self.expirationYear).endIndex.predecessor().predecessor())

        return str
    }
    
    public func isCustomerPaymentMethod() -> Bool {
        return false
    }
}