//
//  PXThreeDSDefault.swift
//  MercadoPagoSDKV4
//
//  Created by Eric Ertl on 01/03/2021.
//

import Foundation

/**
Default PX implementation of ESC for public distribution. (No-validation)
 */
final class PXThreeDSDefault: NSObject, PXThreeDSProtocol {
    func authenticate(config: PXThreeDSConfig, cardTokenID: String, cardHolderName: String, paymentMethodId: String, purchaseAmount: String, currencyId: String, decimalPlaces: Int, decimalSeparator: String, thousandsSeparator: String, siteId: String, completion: @escaping (Swift.Result<Bool, Error>) -> Void) {
        completion(.success(true))
    }
}
