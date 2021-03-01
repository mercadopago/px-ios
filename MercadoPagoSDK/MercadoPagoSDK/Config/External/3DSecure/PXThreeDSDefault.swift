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
    func authenticate(cardTokenID: String, completion: @escaping ((Bool) -> ())) {
        completion(true)
    }
}
