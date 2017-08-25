//
//  ShoppingPreferenceTest.swift
//  MercadoPagoSDK
//
//  Created by Demian Tejo on 8/25/17.
//  Copyright © 2017 MercadoPago. All rights reserved.
//

import XCTest

class ShoppingPreferenceTest: BaseTest {

    override func setUp() {
        super.setUp()
        // Put setup code here. This method is called before the invocation of each test method in the class.
    }

    override func tearDown() {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
        super.tearDown()
    }

    func testShoppingDecorationOneWordDescription() {
        let shoppingDecoration = ShoppingReviewPreference()
        shoppingDecoration.setOneWordDescription(oneWordDescription: "Custom Description")
        XCTAssertEqual(shoppingDecoration.getOneWordDescription(), "Custom")
    }
    func testShoppingDecorationDefaults() {
        let shoppingDecoration = ShoppingReviewPreference()
        XCTAssertEqual(shoppingDecoration.getOneWordDescription(), ShoppingReviewPreference.DEFAULT_ONE_WORD_TITLE)
        XCTAssertEqual(shoppingDecoration.getAmountTitle(), ShoppingReviewPreference.DEFAULT_AMOUNT_TITLE)
        XCTAssertEqual(shoppingDecoration.getQuantityTitle(), ShoppingReviewPreference.DEFAULT_QUANTITY_TITLE)
        XCTAssertTrue(shoppingDecoration.shouldShowAmountTitle)
        XCTAssertTrue(shoppingDecoration.shouldShowQuantityRow)
    }
    func testShoppingDecorationHiding() {
        let shoppingDecoration = ShoppingReviewPreference()
        shoppingDecoration.hideAmountTitle()
        shoppingDecoration.hideQuantityRow()
        XCTAssertFalse(shoppingDecoration.shouldShowAmountTitle)
        XCTAssertFalse(shoppingDecoration.shouldShowQuantityRow)
    }
    func testShoppingDecorationQuantityHideWhenSetEmptyString() {
        let shoppingDecoration = ShoppingReviewPreference()
        shoppingDecoration.setQuantityTitle(quantityTitle: "")
        XCTAssertFalse(shoppingDecoration.shouldShowQuantityRow)
    }

}
