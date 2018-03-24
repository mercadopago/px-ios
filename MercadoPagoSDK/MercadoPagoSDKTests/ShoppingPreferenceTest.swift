//
//  ShoppingPreferenceTest.swift
//  MercadoPagoSDK
//
//  Created by Demian Tejo on 8/25/17.
//  Copyright © 2017 MercadoPago. All rights reserved.
//

import XCTest

class ShoppingPreferenceTest: BaseTest {
    var reviewScreenPreference: ReviewScreenPreference! = nil
    override func setUp() {
        super.setUp()
        reviewScreenPreference = ReviewScreenPreference()
    }

    override func tearDown() {
        super.tearDown()
    }

    func testShoppingDecorationDefaults() {
        XCTAssertTrue(reviewScreenPreference.shouldShowAmountTitle())
        XCTAssertTrue(reviewScreenPreference.shouldShowQuantityRow())
    }
    func testShoppingDecorationHiding() {
        reviewScreenPreference.hideAmountTitle()
        reviewScreenPreference.hideQuantityRow()
        XCTAssertFalse(reviewScreenPreference.shouldShowAmountTitle())
        XCTAssertFalse(reviewScreenPreference.shouldShowQuantityRow())
    }
    func testShoppingDecorationQuantityHideWhenSetEmptyString() {
        reviewScreenPreference.setQuantityLabel(title: "")
        XCTAssertFalse(reviewScreenPreference.shouldShowQuantityRow())
    }
}
