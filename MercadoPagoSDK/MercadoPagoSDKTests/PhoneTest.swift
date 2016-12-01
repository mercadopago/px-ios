//
//  PhoneTest.swift
//  MercadoPagoSDK
//
//  Created by Maria cristina rodriguez on 1/3/16.
//  Copyright © 2016 MercadoPago. All rights reserved.
//

import XCTest
@testable import MercadoPagoSDK

class PhoneTest: BaseTest {
    
    
    
    func testFromJSON(){
        let json : NSDictionary = MockManager.getMockFor("Phone")!
        let phoneTypeFromJSON = Phone.fromJSON(json)
        XCTAssertEqual(phoneTypeFromJSON, phoneTypeFromJSON)
    }
}
