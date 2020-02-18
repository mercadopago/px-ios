//
//  MercadoPagoESC.swift
//  MercadoPagoSDK
//
//  Created by Eden Torres on 7/21/17.
//  Copyright © 2017 MercadoPago. All rights reserved.
//

import Foundation

@objc
internal protocol MercadoPagoESC: NSObjectProtocol {

    func hasESCEnable() -> Bool

    func getESC(cardId: String, firstSixDigits: String, lastFourDigits: String) -> String?

    @discardableResult func saveESC(cardId: String, esc: String) -> Bool

    @discardableResult func saveESC(firstSixDigits: String, lastFourDigits: String, esc: String) -> Bool

    @discardableResult func saveESC(token: PXToken, esc: String) -> Bool

    @objc func deleteESC(cardId: String, reason: PXESCErrorReason, detail: String?)

    func deleteESC(firstSixDigits: String, lastFourDigits: String, reason: PXESCErrorReason, detail: String?)

    func deleteESC(token: PXToken, reason: PXESCErrorReason, detail: String?)

    func deleteAllESC()

    func getSavedCardIds() -> [String]
}
