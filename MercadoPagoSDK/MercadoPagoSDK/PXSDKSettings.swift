//
//  PXSDKSettings.swift
//  MercadoPagoSDK
//
//  Created by Eden Torres on 11/8/17.
//  Copyright © 2017 MercadoPago. All rights reserved.
//

import Foundation
import MercadoPagoServices
import MercadoPagoPXTracking

open class PXSDKSettings: NSObject {

    open class func enableBetaServices() {
        URLConfigs.MP_SELECTED_ENV = URLConfigs.MP_TEST_ENV
        PXServicesSettings.enableBetaServices()
        // TODO: Agregar tracking
    }
}
