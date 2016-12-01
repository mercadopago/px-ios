//
//  OrderTest.swift
//  MercadoPagoSDK
//
//  Created by Maria cristina rodriguez on 1/3/16.
//  Copyright © 2016 MercadoPago. All rights reserved.
//

import XCTest
@testable import MercadoPagoSDK

class OrderTest: BaseTest {

 
    
    func testFromJSON(){
        let json : NSDictionary = MockManager.getMockFor("Order")!
        let orderFromJSON = Order.fromJSON(json)
        XCTAssertEqual(orderFromJSON, orderFromJSON)
    }
    
}
