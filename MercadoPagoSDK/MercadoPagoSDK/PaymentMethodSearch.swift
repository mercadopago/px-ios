//
//  PaymentMethodsSearch.swift
//  MercadoPagoSDK
//
//  Created by Maria cristina rodriguez on 15/1/16.
//  Copyright © 2016 MercadoPago. All rights reserved.
//
import Foundation

open class PaymentMethodSearch: NSObject {

    var groups: [PaymentMethodSearchItem]!
    var paymentMethods: [PaymentMethod]!
    var customerPaymentMethods: [CardInformation]?
    var cards: [Card]?
    var defaultOption: PaymentMethodSearchItem?

    func getPaymentOptionsCount() -> Int {
        let customOptionsCount = (self.customerPaymentMethods != nil) ? self.customerPaymentMethods!.count : 0
        let groupsOptionsCount = (self.groups != nil) ? self.groups!.count : 0
        return customOptionsCount + groupsOptionsCount
    }
}
