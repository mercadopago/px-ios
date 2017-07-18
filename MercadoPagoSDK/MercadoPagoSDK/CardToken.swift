//
//  CardToken.swift
//  MercadoPagoSDK
//
//  Created by Matias Gualino on 31/12/14.
//  Copyright (c) 2014 com.mercadopago. All rights reserved.
//

import Foundation
import UIKit

open class CardToken: NSObject, CardInformationForm {

    let MIN_LENGTH_NUMBER: Int = 10
    let MAX_LENGTH_NUMBER: Int = 19

    open var device: Device?
    open var securityCode: String?

    let now = (Calendar.current as NSCalendar).components([.year, .month], from: Date())

    open var cardNumber: String?
    open var expirationMonth: Int = 0
    open var expirationYear: Int = 0
    open var cardholder: Cardholder?

    public override init() {
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
            self.cardNumber = normalizeCardNumber(cardNumber!.replacingOccurrences(of: " ", with: ""))
            self.expirationMonth = expirationMonth
            self.expirationYear = 2000 + expirationYear
            self.securityCode = securityCode
    }

    open func normalizeCardNumber(_ number: String?) -> String? {
        if number == nil {
            return nil
        }
        return number!.trimmingCharacters(in: CharacterSet.whitespaces).replacingOccurrences(of: "\\s+|-", with: "")
    }

    open func validate() -> Bool {
        return validate(true)
    }

    open func validate(_ includeSecurityCode: Bool) -> Bool {
        var result: Bool = validateCardNumber() == nil  && validateExpiryDate() == nil && validateIdentification() == nil && validateCardholderName() == nil
        if includeSecurityCode {
            result = result && validateSecurityCode() == nil
        }
        return result
    }

    open func validateCardNumber() -> String? {
        if String.isNullOrEmpty(cardNumber) {
            return "Ingresa el número de la tarjeta de crédito".localized
          //  return NSError(domain: "mercadopago.sdk.card.error", code: 1, userInfo: ["cardNumber" : "Ingresa el número de la tarjeta de crédito".localized])
        } else if self.cardNumber!.characters.count < MIN_LENGTH_NUMBER || self.cardNumber!.characters.count > MAX_LENGTH_NUMBER {
            return "invalid_field".localized
          //  return NSError(domain: "mercadopago.sdk.card.error", code: 1, userInfo: ["cardNumber" : "invalid_field".localized])
        } else {
            return nil
        }
    }

    open func validateCardNumber(_ paymentMethod: PaymentMethod) -> String? {
        var userInfo: [String : String]?
        cardNumber = cardNumber?.replacingOccurrences(of: "•", with: "")
        let validCardNumber = self.validateCardNumber()
        if validCardNumber != nil {
            return validCardNumber
        } else {

            let settings: [Setting]? = Setting.getSettingByBin(paymentMethod.settings, bin: getBin())

            guard let cardSettings = settings, !Array.isNullOrEmpty(settings) else {
                if userInfo == nil {
                    userInfo = [String: String]()
                }
                return "El número de tarjeta que ingresaste no se corresponde con el tipo de tarjeta".localized
            }

                // Validate card length

                let filteredSettings = settings?.filter({return $0.cardNumber.length == cardNumber!.trimSpaces().characters.count})

                if Array.isNullOrEmpty(filteredSettings) {
                    if userInfo == nil {
                        userInfo = [String: String]()
                    }
                    if cardSettings.count>1 {
                        return "invalid_card_length_general".localized
                    } else {
                        return ("invalid_card_length".localized as NSString).replacingOccurrences(of: "%1$s", with: "\(cardSettings[0].cardNumber.length)")
                    }
                }
                // Validate luhn
                if "standard" == cardSettings[0].cardNumber.validation && !checkLuhn(cardNumber: (cardNumber?.trimSpaces())!) {
                    if userInfo == nil {
                        userInfo = [String: String]()
                    }
                    return "El número de tarjeta que ingresaste es incorrecto".localized
                 //   userInfo?.updateValue("El número de tarjeta que ingresaste es incorrecto".localized, forKey: "cardNumber")
                }
        }

        if userInfo == nil {
            return nil
        } else {
            return "El número de tarjeta que ingresaste no se corresponde con el tipo de tarjeta".localized
         //   return NSError(domain: "mercadopago.sdk.card.error", code: 1, userInfo: userInfo)
        }
    }

    open func validateSecurityCode() -> String? {
        return validateSecurityCode(securityCode)
    }

    open func validateSecurityCode(_ securityCode: String?) -> String? {
        if String.isNullOrEmpty(self.securityCode) || self.securityCode!.characters.count < 3 || self.securityCode!.characters.count > 4 {
            return "invalid_field".localized
          //  return NSError(domain: "mercadopago.sdk.card.error", code: 1, userInfo: ["securityCode" : "invalid_field".localized])
        } else {
            return nil
        }
    }

    open func validateSecurityCodeWithPaymentMethod(_ paymentMethod: PaymentMethod) -> String? {

        guard let cardNumber = cardNumber else {
            return nil
        }
        if cardNumber.characters.count < 6 {
              return nil
        }
        let validSecurityCode = self.validateSecurityCode(securityCode)
        if validSecurityCode != nil {
            return validSecurityCode
        } else {
            let range = cardNumber.startIndex ..< cardNumber.characters.index(cardNumber.characters.startIndex, offsetBy: 6)
             return validateSecurityCodeWithPaymentMethod(securityCode!, paymentMethod: paymentMethod, bin: cardNumber.substring(with: range))
        }
    }

    open func validateSecurityCodeWithPaymentMethod(_ securityCode: String, paymentMethod: PaymentMethod, bin: String) -> String? {
        let setting: [Setting]? = Setting.getSettingByBin(paymentMethod.settings, bin: getBin())
        if let settings = setting {
                let cvvLength = settings[0].securityCode.length
                if (cvvLength != 0) && (securityCode.characters.count != cvvLength) {
                    return ("invalid_cvv_length".localized as NSString).replacingOccurrences(of: "%1$s", with: "\(cvvLength)")
                    // return NSError(domain: "mercadopago.sdk.card.error", code: 1, userInfo: ["securityCode" : ("invalid_cvv_length".localized as NSString).replacingOccurrences(of: "%1$s", with: "\(cvvLength)")])
                } else {
                    return nil
                }
        }
        return nil
    }

    open func validateExpiryDate() -> String? {
        return validateExpiryDate(expirationMonth, year: expirationYear)
    }

    open func validateExpiryDate(_ month: Int, year: Int) -> String? {
        if !validateExpMonth(month) {
            return "invalid_field".localized
			//return NSError(domain: "mercadopago.sdk.card.error", code: 1, userInfo: ["expiryDate" : "invalid_field".localized])
        }
        if !validateExpYear(year) {
            return "invalid_field".localized
           // return NSError(domain: "mercadopago.sdk.card.error", code: 1, userInfo: ["expiryDate" : "invalid_field".localized])
        }

        if hasMonthPassed(self.expirationYear, month: self.expirationMonth) {
            return "invalid_field".localized
         //   return NSError(domain: "mercadopago.sdk.card.error", code: 1, userInfo: ["expiryDate" : "invalid_field".localized])
        }

        return nil
    }

    open func validateExpMonth(_ month: Int) -> Bool {
        return (month >= 1 && month <= 12)
    }

    open func validateExpYear(_ year: Int) -> Bool {
        return !hasYearPassed(year)
    }

    open func validateIdentification() -> String? {

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

    open func validateIdentificationType() -> String? {

        if String.isNullOrEmpty(cardholder!.identification!.type) {
            return "invalid_field".localized
         //   return NSError(domain: "mercadopago.sdk.card.error", code: 1, userInfo: ["identification" : "invalid_field".localized])
        } else {
            return nil
        }
    }

    open func validateIdentificationNumber() -> String? {

        if String.isNullOrEmpty(cardholder!.identification!.number) {
            return "invalid_field".localized
            //return NSError(domain: "mercadopago.sdk.card.error", code: 1, userInfo: ["identification" : "invalid_field".localized])
        } else {
            return nil
        }
    }

    open func validateIdentificationNumber(_ identificationType: IdentificationType?) -> String? {
        if identificationType != nil {
            if cardholder?.identification != nil && cardholder?.identification?.number != nil {
                let len = cardholder!.identification!.number!.characters.count
                let min = identificationType!.minLength
                let max = identificationType!.maxLength
                if min != 0 && max != 0 {
                    if len > max || len < min {
                        return "invalid_field".localized
                  //      return NSError(domain: "mercadopago.sdk.card.error", code: 1, userInfo: ["identification" : "invalid_field".localized])
                    } else {
                        return nil
                    }
                } else {
                    return validateIdentificationNumber()
                }
            } else {
                return "invalid_field".localized
                //return NSError(domain: "mercadopago.sdk.card.error", code: 1, userInfo: ["identification" : "invalid_field".localized])
            }
        } else {
            return validateIdentificationNumber()
        }
    }

    open func validateCardholderName() -> String? {
        if String.isNullOrEmpty(self.cardholder?.name) {
            return "invalid_field".localized
           // return NSError(domain: "mercadopago.sdk.card.error", code: 1, userInfo: ["cardholder" : "invalid_field".localized])
        } else {
            return nil
        }
    }

    open func hasYearPassed(_ year: Int) -> Bool {
        let normalized: Int = normalizeYear(year)
        return normalized < now.year!
    }

    open func hasMonthPassed(_ year: Int, month: Int) -> Bool {
        return hasYearPassed(year) || normalizeYear(year) == now.year! && month < (now.month!)
    }

    open func normalizeYear(_ year: Int) -> Int {
        if year < 100 && year >= 0 {
            let currentYear: String = String(describing: now.year)
            let range = currentYear.startIndex ..< currentYear.characters.index(currentYear.characters.endIndex, offsetBy: -2)
            let prefix: String = currentYear.substring(with: range)

			let nsReturn: NSString = prefix.appending(String(year)) as NSString
            return nsReturn.integerValue
        }
        return year
    }

    public func checkLuhn(cardNumber: String) -> Bool {
        var sum = 0
        let reversedCharacters = cardNumber.characters.reversed().map { String($0) }
        for (idx, element) in reversedCharacters.enumerated() {
            guard let digit = Int(element) else { return false }
            switch ((idx % 2 == 1), digit) {
            case (true, 9): sum += 9
            case (true, 0...8): sum += (digit * 2) % 9
            default: sum += digit

            }
        }
        return sum % 10 == 0
    }

    open func getBin() -> String? {
        let range =  cardNumber!.startIndex ..< cardNumber!.characters.index(cardNumber!.characters.startIndex, offsetBy: 6)
        let bin: String? = cardNumber!.characters.count >= 6 ? cardNumber!.substring(with: range) : nil
        return bin
    }

    open func toJSON() -> [String:Any] {

        let card_number : Any = String.isNullOrEmpty(self.cardNumber) ? JSONHandler.null : self.cardNumber!
        let cardholder : Any = (self.cardholder == nil) ? JSONHandler.null : self.cardholder!.toJSON()
        let security_code : Any = String.isNullOrEmpty(self.securityCode) ? JSONHandler.null : self.securityCode!
        let device : Any = self.device == nil ? JSONHandler.null : self.device!.toJSON()
        let obj: [String:Any] = [
            "card_number": card_number,
            "cardholder": cardholder,
            "security_code": security_code,
            "expiration_month": self.expirationMonth,
            "expiration_year": self.expirationYear,
            "device": device
        ]
        return obj
    }

    open func toJSONString() -> String {
        return JSONHandler.jsonCoding(toJSON())
    }

    open func getNumberFormated() -> NSString {

        //TODO AMEX
        var str: String
        str = (cardNumber?.insert(" ", ind: 12))!
        str = (str.insert(" ", ind: 8))
        str = (str.insert(" ", ind: 4))
        str = (str.insert(" ", ind: 0))
        return str as NSString
    }

    open func getExpirationDateFormated() -> NSString {

        var str: String

        str = String(self.expirationMonth) + "/" + String(self.expirationYear).substring(from: String(self.expirationYear).index(before: String(self.expirationYear).characters.index(before: String(self.expirationYear).endIndex)))

        return str as NSString
    }

    open func isCustomerPaymentMethod() -> Bool {
        return false
    }
    open func getCardLastForDigits() -> String? {
        let index = cardNumber?.characters.count
        return cardNumber![cardNumber!.index(cardNumber!.startIndex, offsetBy: index!-4)...cardNumber!.index(cardNumber!.startIndex, offsetBy: index!-1)]
    }
    public func getCardBin() -> String? {
        return getBin()
    }

    public func isIssuerRequired() -> Bool {
        return true
    }

    public func canBeClone() -> Bool {
        return false
    }

}
