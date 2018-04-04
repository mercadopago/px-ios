//
//  CardNumberTest.swift
//  MercadoPagoSDK
//
//  Created by Maria cristina rodriguez on 1/3/16.
//  Copyright © 2016 MercadoPago. All rights reserved.
//

import XCTest

class CardNumberTest: BaseTest {

    func testToJSON() {

        let cardNumber = MockBuilder.buildCardNumber()
        let cardJson = cardNumber.toJSON()

        XCTAssertEqual("luhn", cardJson["validation"] as! String)
        XCTAssertEqual(4, cardJson["length"] as! Int)
    }
}
