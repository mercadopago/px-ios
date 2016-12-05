//
//  CardNumberTest.swift
//  MercadoPagoSDK
//
//  Created by Maria cristina rodriguez on 1/3/16.
//  Copyright © 2016 MercadoPago. All rights reserved.
//

import XCTest
@testable import MercadoPagoSDK

class CardNumberTest: BaseTest {
    
    func testFromJSON(){
        let json : NSDictionary = MockManager.getMockFor("CardNumber")!
        let cardNumberFromJSON = CardNumber.fromJSON(json)
        XCTAssertEqual(cardNumberFromJSON, cardNumberFromJSON)
    }
}
