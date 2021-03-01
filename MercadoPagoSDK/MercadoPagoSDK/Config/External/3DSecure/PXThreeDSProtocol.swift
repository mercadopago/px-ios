//
//  PXThreeDSProtocol.swift
//  MercadoPagoSDKV4
//
//  Created by Eric Ertl on 01/03/2021.
//

import Foundation

@objc public protocol PXThreeDSProtocol: NSObjectProtocol {
    func authenticate(cardTokenID: String, completion: @escaping ((Bool) -> ()))
}
