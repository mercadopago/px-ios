//
//  CurrencyTest.swift
//  MercadoPagoSDK
//
//  Created by Maria cristina rodriguez on 1/3/16.
//  Copyright © 2016 MercadoPago. All rights reserved.
//

import XCTest
//@testable import MercadoPagoSDK

class CurrencyTest: BaseTest {

    var currency = Currency(_id: "id", description: "description", symbol: "$", decimalPlaces: 2, decimalSeparator: ".", thousandSeparator: ",")
    
    func testInit(){
        currency = Currency(_id: "id", description: "description", symbol: "$", decimalPlaces: 2, decimalSeparator: ".", thousandSeparator: ",")
        
        XCTAssertEqual(currency._id, "id")
        XCTAssertEqual(currency._description, "description")
        XCTAssertEqual(currency.symbol, "$")
        XCTAssertEqual(currency.decimalPlaces, 2)
        XCTAssertEqual(currency.decimalSeparator, ".")
        XCTAssertEqual(currency.thousandsSeparator, ",")
    }
    func testGetThousandsSeparatorOrDefault(){
        XCTAssertEqual(currency.getThousandsSeparatorOrDefault(), ",")
    }
    func testGetCurrencySymbolOrDefault(){
        XCTAssertEqual(currency.getCurrencySymbolOrDefault(), "$")
    }

    
}
