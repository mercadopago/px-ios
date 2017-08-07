//
//  Currency.swift
//  MercadoPagoSDK
//
//  Created by Matias Gualino on 3/3/15.
//  Copyright (c) 2015 com.mercadopago. All rights reserved.
//

import Foundation

open class Currency: NSObject {

    open var _id: String!
    open var _description: String!
    open var symbol: String!
    open var decimalPlaces: Int!
    open var decimalSeparator: String!
    open var thousandsSeparator: String!

    public override init() {
        super.init()
    }

    public init(_id: String, description: String, symbol: String, decimalPlaces: Int, decimalSeparator: String, thousandSeparator: String) {
        super.init()
        self._id = _id
        self._description = description
        self.symbol = symbol
        self.decimalPlaces = decimalPlaces
        self.decimalSeparator = decimalSeparator
        self.thousandsSeparator = thousandSeparator
    }

    open func getCurrencySymbolOrDefault() -> String {
        return self.symbol ?? "$"
    }

    /***
     *
     Default values are ARS values
     *
     **/
    open func getThousandsSeparatorOrDefault() -> String {
        return self.thousandsSeparator ?? ","
    }

    open func getDecimalPlacesOrDefault() -> Int {
        return self.decimalPlaces ?? 2
    }

    open func getDecimalSeparatorOrDefault() -> String {
        return self.decimalSeparator ?? ","
    }

}
