//
//  PXESCDefault.swift
//  MercadoPagoSDK
//
//  Created by Eric Ertl on 20/08/2020.
//

import Foundation

/**
Default PX implementation of ESC for public distribution. (No-validation)
 */
final class PXESCDefault: NSObject, PXESCProtocol {
    func hasESCEnable() -> Bool {
        return false
    }

    func getESC(config: PXESCConfig, cardId: String, firstSixDigits: String, lastFourDigits: String) -> String? {
        return nil
    }

    @discardableResult
    func saveESC(config: PXESCConfig, cardId: String, esc: String) -> Bool {
        return false
    }

    @discardableResult
    func saveESC(config: PXESCConfig, firstSixDigits: String, lastFourDigits: String, esc: String) -> Bool {
        return false
    }

    @discardableResult
    func saveESC(config: PXESCConfig, token: PXToken, esc: String) -> Bool {
        return false
    }

    func deleteESC(config: PXESCConfig, cardId: String, reason: PXESCDeleteReason, detail: String?) {

    }

    func deleteESC(config: PXESCConfig, firstSixDigits: String, lastFourDigits: String, reason: PXESCDeleteReason, detail: String?) {

    }

    func deleteESC(config: PXESCConfig, token: PXToken, reason: PXESCDeleteReason, detail: String?) {

    }

    func deleteAllESC(config: PXESCConfig) {

    }

    func getSavedCardIds(config: PXESCConfig) -> [String] {
        return []
    }
}
