//
//  PXCardToken+Business.swift
//  MercadoPagoSDKV4
//
//  Created by Eden Torres on 04/09/2018.
//

import Foundation
/// :nodoc:
extension PXCardToken: PXCardInformationForm {
    func getCardLastForDigits() -> String {
        guard let cardNumber = cardNumber else {
            return ""
        }
        let index = cardNumber.count
        return String(cardNumber[cardNumber.index(cardNumber.startIndex, offsetBy: index-4)...cardNumber.index(cardNumber.startIndex, offsetBy: index - 1)])
    }
    func getCardBin() -> String? {
        return getBin()
    }

    func isIssuerRequired() -> Bool {
        return true
    }

    func canBeClone() -> Bool {
        return false
    }
}
/// :nodoc:
extension PXCardToken {
    func normalizeCardNumber(_ number: String?) -> String? {
        guard let number = number else {
            return nil
        }
        return number.trimmingCharacters(in: CharacterSet.whitespaces).replacingOccurrences(of: "\\s+|-", with: "")
    }

    func getBin() -> String? {
        let range = cardNumber!.startIndex ..< cardNumber!.index(cardNumber!.startIndex, offsetBy: 6)
        let bin: String? = cardNumber!.count >= 6 ? String(cardNumber![range]) : nil
        return bin
    }

    @objc func isCustomerPaymentMethod() -> Bool {
        return false
    }
}
