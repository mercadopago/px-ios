//
//  PXCurrency.swift
//  MercadoPagoSDK
//
//  Created by Eden Torres on 10/20/17.
//  Copyright © 2017 MercadoPago. All rights reserved.
//

import Foundation
open class PXCurrency: NSObject {

    open var id: String!
    open var _description: String!
    open var symbol: String!
    open var decimalPlaces: Int!
    open var decimalSeparator: String!
    open var thousandSeparator: String!

    public init (id: String, description: String, symbol: String, decimalPlaces: Int, decimalSeparator: String, thousandSeparator: String){
        self.id = id
        self._description = description
        self.symbol = symbol
        self.decimalPlaces = decimalPlaces
        self.decimalSeparator = decimalSeparator
        self.thousandSeparator = thousandSeparator
    }
}
