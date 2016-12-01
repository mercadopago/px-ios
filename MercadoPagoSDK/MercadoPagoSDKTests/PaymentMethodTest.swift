//
//  PaymentMethodTest.swift
//  MercadoPagoSDK
//
//  Created by Maria cristina rodriguez on 1/3/16.
//  Copyright © 2016 MercadoPago. All rights reserved.
//

import XCTest
@testable import MercadoPagoSDK

class PaymentMethodTest: BaseTest {
    
    func testIsIssuerRequired(){
        
    }
} 

func testFromJSON(){
    let json : NSDictionary = MockManager.getMockFor("PaymentMethod")!
    let paymentMethodFromJSON = PaymentMethodSearchItem.fromJSON(json)
    XCTAssertEqual(paymentMethodFromJSON, paymentMethodFromJSON)
}
