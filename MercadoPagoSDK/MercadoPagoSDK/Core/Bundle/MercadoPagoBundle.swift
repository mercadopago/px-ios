//
//  MercadoPagoBundle.swift
//  MercadoPagoSDK
//
//  Created by Eric Ertl on 18/08/2020.
//

import Foundation

internal class MercadoPagoBundle {
    static func bundle() -> Bundle {
        let bundle = Bundle(for: MercadoPagoBundle.self)
        if let path = bundle.path(forResource: "MercadoPagoSDKResources", ofType: "bundle"),
            let resourcesBundle = Bundle(path: path) {
            return resourcesBundle
        }
        return bundle
    }
}
