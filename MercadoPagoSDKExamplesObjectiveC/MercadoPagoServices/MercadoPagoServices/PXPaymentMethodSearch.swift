//
//  PXPaymentMethodSearch.swift
//  MercadoPagoSDK
//
//  Created by Eden Torres on 10/20/17.
//  Copyright © 2017 MercadoPago. All rights reserved.
//

import Foundation
open class PXPaymentMethodSearch: NSObject {
    open var paymentMethodSearchItem: [PXPaymentMethodSearchItem]!
    open var customOptionSearchItems: [PXCustomOptionSearchItem]!
    open var paymentMethods: [PXPaymentMethod]!
    open var cards: [PXCard]!
    open var defaultOption: PXPaymentMethodSearchItem!
    
    open class func fromJSON(_ json: NSDictionary) -> PXPaymentMethodSearch {
        let pxPaymentMethodSearch: PXPaymentMethodSearch = PXPaymentMethodSearch()
        return pxPaymentMethodSearch
    }
}
