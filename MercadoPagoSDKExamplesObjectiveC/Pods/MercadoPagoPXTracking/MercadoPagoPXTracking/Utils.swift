//
//  Utils.swift
//  MercadoPagoPXTracking
//
//  Created by Eden Torres on 10/30/17.
//  Copyright © 2017 Mercado Pago. All rights reserved.
//

import Foundation
class Utils: NSObject {

    private static let kSdkSettingsFile = "mpx_tracking_settings"

    open class func getBundle() -> Bundle? {
        return Bundle(for:Utils.self)
    }

    internal static func getSetting<T>(identifier: String) -> T {
        let path = Utils.getBundle()!.path(forResource: kSdkSettingsFile, ofType: "plist")
        let dictPM = NSDictionary(contentsOfFile: path!)
        return dictPM![identifier] as! T
    }
}
