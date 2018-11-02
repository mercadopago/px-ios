//
//  PXTrackingStore.swift
//  MercadoPagoSDK
//
//  Created by Eden Torres on 3/13/18.
//  Copyright © 2018 MercadoPago. All rights reserved.
//

import Foundation

internal class PXTrackingStore {
    static let sharedInstance = PXTrackingStore()
    static let cardIdsESC = "CARD_IDS_ESC"
    private var data = [String: Any]()

    public func addData(forKey: String, value: Any) {
        self.data[forKey] = value
    }

    public func remove(key: String) {
        data.removeValue(forKey: key)
    }

    public func removeAll() {
        data.removeAll()
    }

    public func getData(forKey: String) -> Any? {
        return self.data[forKey]
    }
}
