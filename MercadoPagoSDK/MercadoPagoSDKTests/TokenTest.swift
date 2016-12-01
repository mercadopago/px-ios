//
//  TokenTest.swift
//  MercadoPagoSDK
//
//  Created by Maria cristina rodriguez on 1/3/16.
//  Copyright © 2016 MercadoPago. All rights reserved.
//

import XCTest
@testable import MercadoPagoSDK

class TokenTest: BaseTest {
    
    let date = NSDate()
    let modificationDate = NSDate()
    let dueDate = NSDate()
    
    
    func testFromJSON(){
        let json : NSDictionary = MockManager.getMockFor("Token")!
        let tokenCodeFromJSON = Token.fromJSON(json)
        XCTAssertEqual(tokenCodeFromJSON, tokenCodeFromJSON)
    }
}
