//
//  BinTest.swift
//  MercadoPagoSDK
//
//  Created by Maria cristina rodriguez on 1/3/16.
//  Copyright © 2016 MercadoPago. All rights reserved.
//

import XCTest

class BinTest: BaseTest {
    
    
    
    func testFromJSON(){
        let json : NSDictionary = MockManager.getMockFor("BinMask")!
        let binFromJSON = BinMask.fromJSON(json)
        XCTAssertEqual(binFromJSON, binFromJSON)
    }
    
    
}
