//
//  AddressTest.swift
//  MercadoPagoSDK
//
//  Created by Maria cristina rodriguez on 1/3/16.
//  Copyright © 2016 MercadoPago. All rights reserved.
//

import XCTest
@testable import MercadoPagoSDK

class AddressTest: BaseTest {

    func testInit(){
        let address = Address(streetName: "name", streetNumber: 111, zipCode: "zipCode")
        XCTAssertEqual(address.streetName, "name")
        XCTAssertEqual(address.streetNumber, 111)
        XCTAssertEqual(address.zipCode, "zipCode")
    }
    
    func testFromJSON(){
        let json : NSDictionary = MockManager.getMockFor("Address")!
        let addressFromJSON = Address.fromJSON(json)
        XCTAssertEqual(addressFromJSON, addressFromJSON)  
    }
    
    
}
