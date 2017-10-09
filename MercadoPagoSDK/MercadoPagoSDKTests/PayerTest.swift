//
//  PayerTest.swift
//  MercadoPagoSDK
//
//  Created by Maria cristina rodriguez on 1/3/16.
//  Copyright © 2016 MercadoPago. All rights reserved.
//

import XCTest

class PayerTest: BaseTest {

    let identification = MockBuilder.buildIdentification()

    func testInit() {
        let payer = Payer(_id: "1", email: "email", identification: identification)
        XCTAssertEqual(payer._id, "1")
        XCTAssertEqual(payer.email, "email")
        XCTAssertEqual(payer.identification, identification)
    }
    func testFromJSON() {
        let json: NSDictionary = MockManager.getMockFor("Payer")!
        let payerFromJSON = Payer.fromJSON(json)
        XCTAssertEqual(payerFromJSON, payerFromJSON)
    }
}
