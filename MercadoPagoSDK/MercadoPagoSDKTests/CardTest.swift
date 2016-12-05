//
//  CardTest.swift
//  MercadoPagoSDK
//
//  Created by Demian Tejo on 3/3/16.
//  Copyright © 2016 MercadoPago. All rights reserved.
//

import XCTest
@testable import MercadoPagoSDK

class CardTest: BaseTest {

    
    func testFromJSON(){
        let json : NSDictionary = MockManager.getMockFor("Card")!
        let cardFromJSON = Card.fromJSON(json)
        XCTAssertEqual(cardFromJSON, cardFromJSON)
    }
    
    
}
