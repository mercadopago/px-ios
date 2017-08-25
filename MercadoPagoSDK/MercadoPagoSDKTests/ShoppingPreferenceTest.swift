//
//  ShoppingPreferenceTest.swift
//  MercadoPagoSDK
//
//  Created by Demian Tejo on 8/25/17.
//  Copyright © 2017 MercadoPago. All rights reserved.
//

import XCTest

class ShoppingPreferenceTest: BaseTest {
    var shoppingDecoration: ShoppingReviewPreference! = nil
    override func setUp() {
        super.setUp()
        shoppingDecoration = ShoppingReviewPreference()
        // Put setup code here. This method is called before the invocation of each test method in the class.
    }

    override func tearDown() {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
        super.tearDown()
    }

    func testShoppingDecorationOneWordDescription() {
        shoppingDecoration.setOneWordDescription(oneWordDescription: "Custom Description")
        XCTAssertEqual(shoppingDecoration.getOneWordDescription(), "Custom")
    }
    func testShoppingDecorationDefaults() {
        XCTAssertEqual(shoppingDecoration.getOneWordDescription(), ShoppingReviewPreference.DEFAULT_ONE_WORD_TITLE)
        XCTAssertEqual(shoppingDecoration.getAmountTitle(), ShoppingReviewPreference.DEFAULT_AMOUNT_TITLE)
        XCTAssertEqual(shoppingDecoration.getQuantityTitle(), ShoppingReviewPreference.DEFAULT_QUANTITY_TITLE)
        XCTAssertTrue(shoppingDecoration.shouldShowAmountTitle)
        XCTAssertTrue(shoppingDecoration.shouldShowQuantityRow)
    }
    func testShoppingDecorationHiding() {
        shoppingDecoration.hideAmountTitle()
        shoppingDecoration.hideQuantityRow()
        XCTAssertFalse(shoppingDecoration.shouldShowAmountTitle)
        XCTAssertFalse(shoppingDecoration.shouldShowQuantityRow)
    }
    func testShoppingDecorationQuantityHideWhenSetEmptyString() {
        shoppingDecoration.setQuantityTitle(quantityTitle: "")
        XCTAssertFalse(shoppingDecoration.shouldShowQuantityRow)
    }

}
