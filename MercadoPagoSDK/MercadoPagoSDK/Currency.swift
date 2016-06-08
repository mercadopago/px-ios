//
//  Currency.swift
//  MercadoPagoSDK
//
//  Created by Matias Gualino on 3/3/15.
//  Copyright (c) 2015 com.mercadopago. All rights reserved.
//

import Foundation

public class Currency : NSObject {
    
    public var _id : String!
    public var _description : String!
    public var symbol : String!
    public var decimalPlaces : Int = 0
    public var decimalSeparator : Character!
    public var thousandsSeparator : Character!
    
    public init(_id: String, description: String, symbol: String, decimalPlaces: Int, decimalSeparator: Character, thousandSeparator: Character) {
        super.init()
        self._id = _id
        self._description = description
        self.symbol = symbol
        self.decimalPlaces = decimalPlaces
        self.decimalSeparator = decimalSeparator
        self.thousandsSeparator = thousandSeparator
    }
    
    public func getCurrencySymbolOrDefault() -> String {
        return self.symbol ?? "$"
    }
    
    /***
     *
     Default values are ARS values
     *
     **/
    public func getThousandsSeparatorOrDefault() -> Character {
        return self.thousandsSeparator ?? ","
    }
    
    public func getDecimalSeparatorOrDefault() -> Character {
        return self.decimalSeparator ?? ","
    }

}