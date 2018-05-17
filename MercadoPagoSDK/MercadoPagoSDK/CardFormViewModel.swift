//
//  CardFormViewModel.swift
//  MercadoPagoSDK
//
//  Created by Maria cristina rodriguez on 9/8/16.
//  Copyright © 2016 MercadoPago. All rights reserved.
//

import UIKit
import MercadoPagoServices

private func < <T: Comparable>(lhs: T?, rhs: T?) -> Bool {
  switch (lhs, rhs) {
  case let (l__?, r__?):
    return l__ < r__
  case (nil, _?):
    return true
  default:
    return false
  }
}

@objcMembers
open class CardFormViewModel: NSObject {

    var paymentMethods: [PaymentMethod]
    var guessedPMS: [PaymentMethod]?
    var customerCard: CardInformation?
    var token: Token?
    var cardToken: CardToken?

    let textMaskFormater = TextMaskFormater(mask: "XXXX XXXX XXXX XXXX")
    let textEditMaskFormater = TextMaskFormater(mask: "XXXX XXXX XXXX XXXX", completeEmptySpaces: false)

    var cvvEmpty: Bool = true
    var cardholderNameEmpty: Bool = true

    let animationDuration: Double = 0.6

    var promos: [PXBankDeal]?
    let mercadoPagoServicesAdapter: MercadoPagoServicesAdapter!

    public init(paymentMethods: [PaymentMethod], guessedPaymentMethods: [PaymentMethod]? = nil, customerCard: CardInformation? = nil, token: Token? = nil, mercadoPagoServicesAdapter: MercadoPagoServicesAdapter) {
        self.paymentMethods = paymentMethods
        self.guessedPMS = guessedPaymentMethods
        self.mercadoPagoServicesAdapter = mercadoPagoServicesAdapter

        if customerCard != nil {
            self.customerCard = customerCard
            self.guessedPMS = [PaymentMethod]()
            self.guessedPMS?.append((customerCard?.getPaymentMethod())!)
        }
        self.token = token
    }

    func getPaymentMethodTypeId() -> String? {
        if paymentMethods.count == 0 {
            return nil
        }
        let paymentMethod = paymentMethods[0]
        if !Array.isNullOrEmpty(self.paymentMethods) {
            let filterArray = paymentMethods.filter { return $0.paymentTypeId != paymentMethod.paymentTypeId}
            return filterArray.isEmpty ? paymentMethod.paymentTypeId : nil
        } else {
            return nil
        }
    }

    func cvvLenght() -> Int {
        var lenght: Int

        if self.customerCard != nil {
            lenght = (self.customerCard?.getCardSecurityCode().length)!
        } else {
            if (getGuessedPM()?.settings == nil)||(getGuessedPM()?.settings.count == 0) {
                lenght = 3 // Default
            } else {
                lenght = (getGuessedPM()?.settings[0].securityCode.length)!
            }
        }
        return lenght
    }

    func getLabelTextColor(cardNumber: String?) -> UIColor {
        if let cardNumber = cardNumber {
            if let bin = getBIN(cardNumber) {
                if let guessedPM = self.getGuessedPM() {
                    return (guessedPM.getFontColor(bin: bin))
                }
            }
        }
        return MPLabel.defaultColorText
    }

    func getEditingLabelColor(cardNumber: String?) -> UIColor {
        if let cardNumber = cardNumber {
            if let bin = getBIN(cardNumber) {
                if let guessedPM = self.getGuessedPM() {
                    return (guessedPM.getEditingFontColor(bin: bin))
                }
            }
        }
        return MPLabel.highlightedColorText
    }

    func getExpirationMonthFromLabel(_ expirationDateLabel: MPLabel) -> Int {
        return Utils.getExpirationMonthFromLabelText(expirationDateLabel.text!)
    }

    func getExpirationYearFromLabel(_ expirationDateLabel: MPLabel) -> Int {
        return Utils.getExpirationYearFromLabelText(expirationDateLabel.text!)
    }

    func getBIN(_ cardNumber: String) -> String? {
        if token != nil {
            return token?.firstSixDigit
        }

        var trimmedNumber = cardNumber.replacingOccurrences(of: " ", with: "")
        trimmedNumber = trimmedNumber.replacingOccurrences(of: String(textMaskFormater.emptyMaskElement), with: "")

        if trimmedNumber.count < 6 {
            return nil
        } else {
            let range = (trimmedNumber.index(trimmedNumber.startIndex, offsetBy: 6))
            let bin = String(trimmedNumber[..<range])
            return bin
        }
    }

    func isValidInputCVV(_ text: String) -> Bool {
        if text.count > self.cvvLenght() {
            return false
        }
        let num = Int(text)
        return (num != nil)
    }

    func validateCardNumber(_ cardNumberLabel: UILabel, expirationDateLabel: MPLabel, cvvLabel: UILabel, cardholderNameLabel: MPLabel) -> Bool {

        if self.guessedPMS == nil {
            return false
        }

        self.tokenHidratate(cardNumberLabel.text!, expirationDate: expirationDateLabel.text!, cvv: cvvLabel.text!, cardholderName: cardholderNameLabel.text!)

        let errorMethod = self.cardToken!.validateCardNumber(getGuessedPM()!)
        if (errorMethod) != nil {
            return false
        }
        return true
    }

    func validateCardholderName(_ cardNumberLabel: UILabel, expirationDateLabel: MPLabel, cvvLabel: UILabel, cardholderNameLabel: MPLabel) -> Bool {

        self.tokenHidratate(cardNumberLabel.text!, expirationDate: expirationDateLabel.text!, cvv: cvvLabel.text!, cardholderName: cardholderNameLabel.text!)

        if self.cardToken!.validateCardholderName() != nil {
            return false
        }
        return true
    }

    func validateCvv(_ cardNumberLabel: UILabel, expirationDateLabel: MPLabel, cvvLabel: UILabel, cardholderNameLabel: MPLabel) -> Bool {

        self.tokenHidratate(cardNumberLabel.text!, expirationDate: expirationDateLabel.text!, cvv: cvvLabel.text!, cardholderName: cardholderNameLabel.text!)

        if (cvvLabel.text!.replacingOccurrences(of: "•", with: "").count < self.getGuessedPM()?.secCodeLenght()) {
            return false
        }
        let errorMethod = self.cardToken!.validateSecurityCode()
        if (errorMethod) != nil {
            return false
        }
        return true
    }

    func validateExpirationDate(_ cardNumberLabel: UILabel, expirationDateLabel: MPLabel, cvvLabel: UILabel, cardholderNameLabel: MPLabel) -> Bool {

        self.tokenHidratate(cardNumberLabel.text!, expirationDate: expirationDateLabel.text!, cvv: cvvLabel.text!, cardholderName: cardholderNameLabel.text!)
        let errorMethod = self.cardToken!.validateExpiryDate()
        if (errorMethod) != nil {
            return false
        }
        return true
    }

    /*TODO : deberia validarse esto acá???*/
    func isAmexCard(_ cardNumber: String) -> Bool {
        if self.getBIN(cardNumber) == nil {
            return false
        }
        if self.guessedPMS != nil {
            return self.getGuessedPM()!.isAmex
        } else {
            return false
        }
    }

    func matchedPaymentMethod (_ cardNumber: String) -> [PaymentMethod]? {

        if self.guessedPMS != nil {
            return self.guessedPMS
        }

        if getBIN(cardNumber) == nil {
            return nil
        }

        var paymentMethods = [PaymentMethod]()

        for paymentMethod in self.paymentMethods {
            if paymentMethod.conformsToBIN(getBIN(cardNumber)!) {
                paymentMethods.append(paymentMethod.cloneWithBIN(getBIN(cardNumber)!)!)
            }
        }
        if paymentMethods.isEmpty {
            return nil
        } else {
            return paymentMethods
        }

    }

    func tokenHidratate(_ cardNumber: String, expirationDate: String, cvv: String, cardholderName: String) {
        let number = cardNumber
        let year = Utils.getExpirationYearFromLabelText(expirationDate)
        let month = Utils.getExpirationMonthFromLabelText(expirationDate)
        let secCode = cvvEmpty ? "" :cvv
        let name = cardholderNameEmpty ? "" : cardholderName

        self.cardToken = CardToken(cardNumber: number, expirationMonth: month, expirationYear: year, securityCode: secCode, cardholderName: name, docType: "", docNumber: "")
    }

    func buildSavedCardToken(_ cvv: String) -> CardToken {
        let securityCode = self.customerCard!.isSecurityCodeRequired() ? cvv : ""
        self.cardToken = SavedCardToken(card: self.customerCard!, securityCode: securityCode, securityCodeRequired: self.customerCard!.isSecurityCodeRequired())
        return self.cardToken!
    }
    func getGuessedPM() -> PaymentMethod? {
        if let card = customerCard {
            return card.getPaymentMethod()
        } else {
           return guessedPMS?[0]
        }
    }
    func hasGuessedPM() -> Bool {
        if guessedPMS == nil || guessedPMS?.count == 0 {
            return false
        } else {
            return true
        }
    }

    func showBankDeals() -> Bool {
        return !Array.isNullOrEmpty(self.promos) && CardFormViewController.showBankDeals && MercadoPagoCheckoutViewModel.servicePreference.shouldShowBankDeals()
    }

    func shoudShowOnlyOneCardMessage() -> Bool {
        return paymentMethods.count == 1
    }

    func getOnlyOneCardAvailableMessage() -> String {
        let defaultMessage = "Método de pago no soportado".localized
        if Array.isNullOrEmpty(paymentMethods) {
            return defaultMessage
        }
        if !String.isNullOrEmpty(paymentMethods[0].name) {
            return "Solo puedes pagar con ".localized + paymentMethods[0].name
        } else {
            return defaultMessage
        }
    }
}
