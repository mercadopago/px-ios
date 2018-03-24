//
//  PXTrackingStore.swift
//  MercadoPagoSDK
//
//  Created by Eden Torres on 3/13/18.
//  Copyright © 2018 MercadoPago. All rights reserved.
//

import Foundation
internal class PXTrackingStore: NSObject {
    static let sharedInstance = PXTrackingStore()
    static let PAYMENT_METHOD_OPTIONS = "PAYMENT_METHOD_OPTIONS"
    private var data = [String: String]()

    public func addData(forKey: String, value: String) {
        self.data[forKey] = value
    }

    public func remove(key: String) {
        data.removeValue(forKey: key)
    }

    public func removeAll() {
        data.removeAll()
    }

    public func getData(forKey: String) -> String? {
        return self.data[forKey]
    }
}
