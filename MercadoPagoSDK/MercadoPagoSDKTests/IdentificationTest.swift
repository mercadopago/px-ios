//
//  IdentificationTest.swift
//  MercadoPagoSDK
//
//  Created by Maria cristina rodriguez on 1/3/16.
//  Copyright © 2016 MercadoPago. All rights reserved.
//

import XCTest
@testable import MercadoPagoSDK

class IdentificationTest: BaseTest {
    
    func testInit(){
        let identification = Identification(type: "type", number: "number")
        XCTAssertEqual(identification.type, "type")
        XCTAssertEqual(identification.number, "number")
    }
    
    
    func testFromJSON(){
        let json : NSDictionary = MockManager.getMockFor("Identification")!
        let identificationFromJSON = Identification.fromJSON(json)
        XCTAssertEqual(identificationFromJSON, identificationFromJSON)
    }
    
}
