//
//  RefundTest.swift
//  MercadoPagoSDK
//
//  Created by Maria cristina rodriguez on 1/3/16.
//  Copyright © 2016 MercadoPago. All rights reserved.
//

import XCTest
@testable import MercadoPagoSDK

class RefundTest: BaseTest {
    
    func testFromJSON(){
        let json : NSDictionary = MockManager.getMockFor("Refund")!
        let refundTypeFromJSON = Refund.fromJSON(json)
        XCTAssertEqual(refundTypeFromJSON, refundTypeFromJSON)
    }
}
