//
//  PXHookStore.swift
//  MercadoPagoSDK
//
//  Created by Eden Torres on 11/28/17.
//  Copyright © 2017 MercadoPago. All rights reserved.
//

import Foundation

open class PXCheckoutStore: NSObject {

    static let sharedInstance = PXCheckoutStore()
    private var data = [String: Any]()
    var checkoutPreference: CheckoutPreference?
    var paymentData = PaymentData()
    var paymentOptionSelected: PaymentMethodOption?

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

    public func getPaymentData() -> PaymentData {
        return paymentData
    }

    public func getPaymentOptionSelected() -> PaymentMethodOption? {
        return paymentOptionSelected
    }

    public func getCheckoutPreference() -> CheckoutPreference? {
        return checkoutPreference
    }

    func clean() {
        removeAll()
        checkoutPreference = nil
        paymentData = PaymentData()
        paymentOptionSelected = nil
    }
}
