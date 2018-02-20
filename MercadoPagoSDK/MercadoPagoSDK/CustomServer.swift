//
//  CustomServer.swift
//  MercadoPagoSDK
//
//  Created by Matias Gualino on 31/12/14.
//  Copyright (c) 2014 com.mercadopago. All rights reserved.
//

import Foundation
import UIKit

open class CustomServer: NSObject {
    static let mercadoPagoServicesAdapter = MercadoPagoServicesAdapter()
    open static func createCheckoutPreference(url: String, uri: String, bodyInfo: NSDictionary? = nil, callback: @escaping (CheckoutPreference) -> Void, failure: @escaping ((_ error: NSError) -> Void)) {
        
        mercadoPagoServicesAdapter.createCheckoutPreference(url: url, uri: uri, bodyInfo: bodyInfo, callback: callback, failure: failure)
    }
}
