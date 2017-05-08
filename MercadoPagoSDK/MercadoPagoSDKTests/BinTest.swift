//
//  BinTest.swift
//  MercadoPagoSDK
//
//  Created by Maria cristina rodriguez on 1/3/16.
//  Copyright © 2016 MercadoPago. All rights reserved.
//

import XCTest

class BinTest: BaseTest {

    func testFromJSON() {
        let json: NSDictionary = MockManager.getMockFor("BinMask")!
        let binFromJSON = BinMask.fromJSON(json)

        XCTAssertEqual("4", binFromJSON.pattern)
        XCTAssertEqual("(487017)", binFromJSON.exclusionPattern)
        XCTAssertEqual("4", binFromJSON.installmentsPattern)
    }

    func testToJSON() {

        let bin = MockBuilder.buildBinMask()
        let binJSON = bin.toJSON()

        XCTAssertEqual("pattern", binJSON["pattern"] as! String)
        XCTAssertEqual("exclusion_pattern", binJSON["exclusion_pattern"] as! String)
        XCTAssertEqual("installments_pattern", binJSON["installments_pattern"] as! String)
    }

}
