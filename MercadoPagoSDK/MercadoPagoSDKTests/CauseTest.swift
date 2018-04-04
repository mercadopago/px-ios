//
//  CauseTest.swift
//  MercadoPagoSDK
//
//  Created by Mauro Reverter on 7/6/17.
//  Copyright © 2017 MercadoPago. All rights reserved.
//

import XCTest

class CauseTest: BaseTest {

    func testFromJSON() {
        let json: NSDictionary = MockManager.getMockFor("Cause")!
        let causeFromJSON = Cause.fromJSON(json)
        let cause = Cause()
        cause.code = "324"
        cause.causeDescription = "Invalid parameter 'cardholder.identification.number'"

        XCTAssertEqual(causeFromJSON.code, cause.code)
        XCTAssertEqual(causeFromJSON.causeDescription, cause.causeDescription)
    }
}
