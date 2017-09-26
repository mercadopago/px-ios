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
        // Put setup code here. This method is called before the invocation of each test method in the class.
    }

    override func tearDown() {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
        super.tearDown()
    }

    func testShoppingDecorationDefaults() {
        XCTAssertEqual(reviewScreenPreference.getAmountTitle(), ReviewScreenPreference.DEFAULT_AMOUNT_TITLE)
        XCTAssertEqual(reviewScreenPreference.getQuantityTitle(), ReviewScreenPreference.DEFAULT_QUANTITY_TITLE)
        XCTAssertTrue(reviewScreenPreference.shouldShowAmountTitle)
        XCTAssertTrue(reviewScreenPreference.shouldShowQuantityRow)
    }
    func testShoppingDecorationHiding() {
        reviewScreenPreference.hideAmountTitle()
        reviewScreenPreference.hideQuantityRow()
        XCTAssertFalse(reviewScreenPreference.shouldShowAmountTitle)
        XCTAssertFalse(reviewScreenPreference.shouldShowQuantityRow)
    }
    func testShoppingDecorationQuantityHideWhenSetEmptyString() {
        reviewScreenPreference.setQuantityTitle(title: "")
        XCTAssertFalse(reviewScreenPreference.shouldShowQuantityRow)
    }

}
