//
//  PromoTest.swift
//  MercadoPagoSDK
//
//  Created by Maria cristina rodriguez on 1/3/16.
//  Copyright © 2016 MercadoPago. All rights reserved.
//

import XCTest
@testable import MercadoPagoSDK

class PromoTest: BaseTest {
    
 
    func testFromJSON(){
        let json : NSDictionary = MockManager.getMockFor("Promo")!
        let promoTypeFromJSON = Promo.fromJSON(json)
        XCTAssertEqual(promoTypeFromJSON, promoTypeFromJSON)
    }
}
