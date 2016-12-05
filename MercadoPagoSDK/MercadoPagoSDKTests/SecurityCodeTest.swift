//
//  SecurityCodeTest.swift
//  MercadoPagoSDK
//
//  Created by Maria cristina rodriguez on 1/3/16.
//  Copyright © 2016 MercadoPago. All rights reserved.
//

import XCTest
@testable import MercadoPagoSDK

class SecurityCodeTest: BaseTest {
    
    
    func testFromJSON(){
        let json : NSDictionary = MockManager.getMockFor("SecurityCode")!
        let securityCodeFromJSON = SecurityCode.fromJSON(json)
        XCTAssertEqual(securityCodeFromJSON, securityCodeFromJSON)
    }
    
}
