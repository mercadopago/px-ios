//
//  PXToken+Business.swift
//  MercadoPagoSDKV4
//
//  Created by Eden Torres on 01/08/2018.
//

import Foundation

/// :nodoc:
extension PXToken: PXCardInformationForm {
    func getBin() -> String? {
        var bin: String?
        if firstSixDigits.count > 0 {
            let range = firstSixDigits.startIndex ..< firstSixDigits.index(firstSixDigits.startIndex, offsetBy: 6)
            bin = firstSixDigits.count >= 6 ? String(firstSixDigits[range]) : nil
        }

        return bin
    }

    public func getCardBin() -> String? {
        return firstSixDigits
    }

    public func getCardLastForDigits() -> String {
        return lastFourDigits
    }

    public func isIssuerRequired() -> Bool {
        return true
    }

    public func canBeClone() -> Bool {
        return true
    }
}
