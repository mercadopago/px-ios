//
//  MercadoPagoESC.swift
//  MercadoPagoSDK
//
//  Created by Eden Torres on 7/21/17.
//  Copyright © 2017 MercadoPago. All rights reserved.
//

import Foundation

@objc
public protocol MercadoPagoESC: NSObjectProtocol {

    func hasESCEnable() -> Bool

    func getESC(cardId: String) -> String?

    func saveESC(cardId: String, esc: String) -> Bool

    func deleteESC(cardId: String)

    func deleteAllESC()
}
