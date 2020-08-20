//
//  PXESCProtocol.swift
//  MercadoPagoSDK
//
//  Created by Eden Torres on 7/21/17.
//  Copyright © 2017 MercadoPago. All rights reserved.
//

import Foundation

@objc public protocol PXESCProtocol: NSObjectProtocol {
    func hasESCEnable() -> Bool
    func getESC(config: PXESCConfig, cardId: String, firstSixDigits: String, lastFourDigits: String) -> String?
    @discardableResult func saveESC(config: PXESCConfig, cardId: String, esc: String) -> Bool
    @discardableResult func saveESC(config: PXESCConfig, firstSixDigits: String, lastFourDigits: String, esc: String) -> Bool
    @discardableResult func saveESC(config: PXESCConfig, token: PXToken, esc: String) -> Bool
    func deleteESC(config: PXESCConfig, cardId: String, reason: PXESCDeleteReason, detail: String?)
    func deleteESC(config: PXESCConfig, firstSixDigits: String, lastFourDigits: String, reason: PXESCDeleteReason, detail: String?)
    func deleteESC(config: PXESCConfig, token: PXToken, reason: PXESCDeleteReason, detail: String?)
    func deleteAllESC(config: PXESCConfig)
    func getSavedCardIds(config: PXESCConfig) -> [String]
}
