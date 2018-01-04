//
//  PXCardToken.swift
//  MercadoPagoSDK
//
//  Created by Eden Torres on 10/20/17.
//  Copyright © 2017 MercadoPago. All rights reserved.
//

import Foundation
open class PXCardToken: NSObject, Codable {

    open var cardholder: PXCardHolder?
    open var cardNumber: String?
    open var device: PXDevice = PXDevice()
    open var expirationMonth: Int?
    open var expirationYear: Int?
    open var securityCode: String?

    // For validations
    let MIN_LENGTH_NUMBER: Int = 10
    let MAX_LENGTH_NUMBER: Int = 19
    let now = (Calendar.current as NSCalendar).components([.year, .month], from: Date())

    public enum PXCardTokenKeys: String, CodingKey {
        case cardholder
        case cardNumber = "card_number"
        case device
        case expirationMonth = "expiration_month"
        case expirationYear = "expiration_year"
        case securityCode = "security_code"
    }

    public func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: PXCardTokenKeys.self)
        try container.encodeIfPresent(self.cardholder, forKey: .cardholder)
        try container.encodeIfPresent(self.cardNumber, forKey: .cardNumber)
        try container.encodeIfPresent(self.device, forKey: .device)
        try container.encodeIfPresent(self.expirationMonth, forKey: .expirationMonth)
        try container.encodeIfPresent(self.expirationYear, forKey: .expirationYear)
        try container.encodeIfPresent(self.securityCode, forKey: .securityCode)
    }

    open func toJSONString() throws -> String? {
        let encoder = JSONEncoder()
        let data = try encoder.encode(self)
        return String(data: data, encoding: .utf8)
    }

    open func toJSON() throws -> Data {
        let encoder = JSONEncoder()
        return try encoder.encode(self)
    }

    open class func fromJSON(data: Data) throws -> PXCardToken {
        return try JSONDecoder().decode(PXCardToken.self, from: data)
    }
}

extension PXCardToken {

    open func validateCardNumber(_ paymentMethod: PXPaymentMethod) -> Bool {
        var userInfo: [String: String]?
        cardNumber = cardNumber?.replacingOccurrences(of: "•", with: "")
        if !self.validateCardNumber() {
            return false
        } else {

            let settings: [PXSetting]? = PXSetting.getSettingByBin(paymentMethod.settings, bin: getBin())

            guard let cardSettings = settings, !Array.isNullOrEmpty(settings) else {
                if userInfo == nil {
                    userInfo = [String: String]()
                }
                return false
            }

            // Validate card length
            let filteredSettings = cardSettings.filter({return $0.cardNumber?.length == cardNumber!.trimSpaces().characters.count})

            if Array.isNullOrEmpty(filteredSettings) {
                if userInfo == nil {
                    userInfo = [String: String]()
                }
                if cardSettings.count > 1 {
                    return false
                } else {
                    return false
                }
            }
            // Validate luhn
            if "standard" == cardSettings[0].cardNumber?.validation && !checkLuhn(cardNumber: (cardNumber?.trimSpaces())!) {
                if userInfo == nil {
                    userInfo = [String: String]()
                }
                return false
            }
        }

        if userInfo == nil {
            return true
        } else {
            return false
        }
    }

    open func validateSecurityCode(_ paymentMethod: PXPaymentMethod) -> Bool {

        guard let cardNumber = cardNumber else {
            return true
        }
        if cardNumber.characters.count < 6 {
            return true
        }

        if !self.validateSecurityCode(securityCode: securityCode) {
            return false
        } else {
            let range = cardNumber.startIndex ..< cardNumber.characters.index(cardNumber.characters.startIndex, offsetBy: 6)
            return validateSecurityCodeWithPaymentMethod(securityCode!, paymentMethod: paymentMethod, bin: cardNumber.substring(with: range))
        }
    }

    open func validateExpiryDate(_ month: Int, year: Int) -> Bool {
        if !validateExpMonth(month) {
            return false
        }
        if !validateExpYear(year) {
            return false
        }

        if hasDatePassed(year: self.expirationYear, month: self.expirationMonth) {
            return false
        }

        return true
    }

    open func validateCardholderName() -> Bool {
        return !String.isNullOrEmpty(self.cardholder?.name)
    }

    open func validateIdentificationNumber(_ identificationType: PXIdentificationType?) -> Bool {
        if identificationType != nil {
            if cardholder?.identification != nil && cardholder?.identification?.number != nil {
                let len = cardholder!.identification!.number!.characters.count
                let min = identificationType!.minLength!
                let max = identificationType!.maxLength!
                if min != 0 && max != 0 {
                    if len > max || len < min {
                        return false
                    } else {
                        return true
                    }
                } else {
                    return validateIdentificationNumber()
                }
            } else {
                return false
            }
        } else {
            return validateIdentificationNumber()
        }
    }

    internal func getBin() -> String? {
        let range =  cardNumber!.startIndex ..< cardNumber!.characters.index(cardNumber!.characters.startIndex, offsetBy: 6)
        let bin: String? = cardNumber!.characters.count >= 6 ? cardNumber!.substring(with: range) : nil
        return bin
    }

    internal func validateCardNumber() -> Bool {
        if String.isNullOrEmpty(cardNumber) {
            return false
        } else if self.cardNumber!.characters.count < MIN_LENGTH_NUMBER || self.cardNumber!.characters.count > MAX_LENGTH_NUMBER {
            return false
        }

        return true
    }

    internal func validateSecurityCode(securityCode: String?) -> Bool {
        if String.isNullOrEmpty(self.securityCode) || self.securityCode!.characters.count < 3 || self.securityCode!.characters.count > 4 {
            return false
        }
        return true
    }

    internal func validateSecurityCodeWithPaymentMethod(_ securityCode: String, paymentMethod: PXPaymentMethod, bin: String) -> Bool {
        let setting: [PXSetting]? = PXSetting.getSettingByBin(paymentMethod.settings, bin: getBin())
        if let settings = setting {
            if let securityCodeLenght = settings[0].securityCode?.length {
                if (securityCodeLenght != 0) && (securityCode.characters.count != securityCodeLenght) {
                    return false
                } else {
                    return true
                }
            }
        }
        return true
    }

    internal func validateExpMonth(_ month: Int) -> Bool {
        return (month >= 1 && month <= 12)
    }

    internal func validateExpYear(_ year: Int) -> Bool {
        return !hasYearPassed(year)
    }

    internal func validateIdentificationType() -> Bool {
        return !String.isNullOrEmpty(cardholder!.identification!.type)
    }

    internal func validateIdentificationNumber() -> Bool {
        return String.isNullOrEmpty(cardholder!.identification!.number)
    }

    internal func hasYearPassed(_ year: Int) -> Bool {
        let normalized: Int = normalizeYear(year)
        return normalized < now.year!
    }

    internal func hasMonthPassed(_ month: Int) -> Bool {
        return month < (now.month!)
    }

    internal func hasDatePassed(year: Int?, month: Int?) -> Bool {
        guard let year = year, let month = month else {
            return true
        }
        return hasYearPassed(year) || normalizeYear(year) == now.year! && hasMonthPassed(month)
    }

    internal func normalizeYear(_ year: Int) -> Int {
        if year < 100 && year >= 0 {
            let currentYear: String = String(describing: now.year)
            let range = currentYear.startIndex ..< currentYear.characters.index(currentYear.characters.endIndex, offsetBy: -2)
            let prefix: String = currentYear.substring(with: range)

            let nsReturn: NSString = prefix.appending(String(year)) as NSString
            return nsReturn.integerValue
        }
        return year
    }

    internal func checkLuhn(cardNumber: String) -> Bool {
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
}
