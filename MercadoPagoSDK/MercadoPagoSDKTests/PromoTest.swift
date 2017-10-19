//
//  PromoTest.swift
//  MercadoPagoSDK
//
//  Created by Maria cristina rodriguez on 1/3/16.
//  Copyright © 2016 MercadoPago. All rights reserved.
//

import XCTest

class PromoTest: BaseTest {

    func testFromJSON() {
        let json: NSDictionary = MockManager.getMockFor("BankDeal")!
        let promoTypeFromJSON = BankDeal.fromJSON(json)
        XCTAssertEqual(promoTypeFromJSON, promoTypeFromJSON)
    }

    func testToJSON() {
        let promo = MockBuilder.buildBankDeal()
        let promoJSON = promo.toJSON()

        XCTAssertNotNil(promo.toJSONString())
        XCTAssertEqual("promoId", promoJSON["promoId"] as? String)
        XCTAssertEqual("legals", promoJSON["legals"] as? String)

    }
}
