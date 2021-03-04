//
//  PXThreeDSProtocol.swift
//  MercadoPagoSDKV4
//
//  Created by Eric Ertl on 01/03/2021.
//

import Foundation

@objc public protocol PXThreeDSProtocol: NSObjectProtocol {
    func authenticate(config: PXThreeDSConfig, cardTokenID: String, cardHolderName: String, paymentMethodId: String, purchaseAmount: String, currencyId: String, decimalPlaces: Int, decimalSeparator: String, thousandsSeparator: String, siteId: String, completion: @escaping ((Bool) -> ()))
}
