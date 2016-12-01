//
//  CardholderTest.swift
//  MercadoPagoSDK
//
//  Created by Maria cristina rodriguez on 1/3/16.
//  Copyright © 2016 MercadoPago. All rights reserved.
//

import XCTest
@testable import MercadoPagoSDK

class CardholderTest: BaseTest {
    
    func testFromJSON(){
        let json : NSDictionary = MockManager.getMockFor("Cardholder")!
        let cardholderFromJSON = Cardholder.fromJSON(json)
        XCTAssertEqual(cardholderFromJSON, cardholderFromJSON)
    }
}
