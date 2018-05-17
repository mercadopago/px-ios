//
//  Currency.swift
//  MercadoPagoSDK
//
//  Created by Matias Gualino on 3/3/15.
//  Copyright (c) 2015 com.mercadopago. All rights reserved.
//

import Foundation

@objcMembers open class Currency: NSObject {

    open var currencyId: String!
    open var currencyDescription: String!
    open var symbol: String!
    open var decimalPlaces: Int!
    open var decimalSeparator: String!
    open var thousandsSeparator: String!

    public override init() {
        super.init()
    }

    public init(currencyId: String, description: String, symbol: String, decimalPlaces: Int, decimalSeparator: String, thousandSeparator: String) {
        super.init()
        self.currencyId = currencyId
        self.currencyDescription = description
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
        if String.isNullOrEmpty( self.thousandsSeparator) {
            return "."
        }
        return self.thousandsSeparator
    }

    open func getDecimalPlacesOrDefault() -> Int {
        if  self.decimalPlaces == 0 {
            return 2
        }
        return self.decimalPlaces
    }

    open func getDecimalSeparatorOrDefault() -> String {
        if String.isNullOrEmpty(self.decimalSeparator) {
            return ","
        }
        return self.decimalSeparator
    }

}
