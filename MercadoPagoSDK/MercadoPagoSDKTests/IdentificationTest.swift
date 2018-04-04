//
//  IdentificationTest.swift
//  MercadoPagoSDK
//
//  Created by Maria cristina rodriguez on 1/3/16.
//  Copyright © 2016 MercadoPago. All rights reserved.
//

import XCTest

class IdentificationTest: BaseTest {

    func testInit() {
        let identification = Identification(type: "type", number: "number")
        XCTAssertEqual(identification.type, "type")
        XCTAssertEqual(identification.number, "number")
    }
}
