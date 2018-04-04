//
//  CurrencyTest.swift
//  MercadoPagoSDK
//
//  Created by Maria cristina rodriguez on 1/3/16.
//  Copyright © 2016 MercadoPago. All rights reserved.
//

import XCTest

class CurrencyTest: BaseTest {

    func testInit() {
        let currency = Currency(currencyId: "id", description: "description", symbol: "symbol", decimalPlaces: 2, decimalSeparator: ".", thousandSeparator: ",")

        XCTAssertEqual(currency.currencyId, "id")
        XCTAssertEqual(currency.currencyDescription, "description")
        XCTAssertEqual(currency.symbol, "symbol")
        XCTAssertEqual(currency.decimalPlaces, 2)
        XCTAssertEqual(currency.decimalSeparator, ".")
        XCTAssertEqual(currency.thousandsSeparator, ",")
    }

}
