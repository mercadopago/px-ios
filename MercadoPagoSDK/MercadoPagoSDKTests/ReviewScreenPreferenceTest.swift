//
//  ReviewScreenPreferenceTest.swift
//  MercadoPagoSDK
//
//  Created by Eden Torres on 3/2/17.
//  Copyright © 2017 MercadoPago. All rights reserved.
//

import XCTest

class ReviewScreenPreferenceTest: BaseTest {

    let reviewScreenPreference = ReviewScreenPreference()
    var mpCheckout: MercadoPagoCheckout! = nil

    override func setUp() {
        super.setUp()
        self.createCheckout()
        MercadoPagoContext.setLanguage(language: Languages._ENGLISH)
    }

    func createCheckout() {
        let checkoutPreference = MockBuilder.buildCheckoutPreference()
        let navControllerInstance = UINavigationController()
        self.mpCheckout = MercadoPagoCheckout(publicKey: "PK_MLA", accessToken: "", checkoutPreference: checkoutPreference, navigationController: navControllerInstance)
    }

    func testIsChangePaymentMethodDisable() {
        XCTAssert(reviewScreenPreference.isChangeMethodOptionEnabled())

        reviewScreenPreference.disableChangeMethodOption()
        XCTAssertFalse(reviewScreenPreference.isChangeMethodOptionEnabled())

        reviewScreenPreference.enableChangeMethodOption()
        XCTAssert(reviewScreenPreference.isChangeMethodOptionEnabled())
    }
}
