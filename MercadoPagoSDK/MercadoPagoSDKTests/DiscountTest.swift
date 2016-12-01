//
//  DiscountTest.swift
//  MercadoPagoSDK
//
//  Created by Maria cristina rodriguez on 1/3/16.
//  Copyright © 2016 MercadoPago. All rights reserved.
//

import XCTest
@testable import MercadoPagoSDK

class DiscountTest: BaseTest {
    

    func testFromJSON(){
        let json : NSDictionary = MockManager.getMockFor("Discount")!
        let discountFromJSON = Discount.fromJSON(json)
        XCTAssertEqual(discountFromJSON, discountFromJSON)
    }
    
}
