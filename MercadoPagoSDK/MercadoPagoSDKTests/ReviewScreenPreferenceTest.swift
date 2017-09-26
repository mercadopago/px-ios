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
    }

    func createCheckout() {
        let checkoutPreference = MockBuilder.buildCheckoutPreference()
        let navControllerInstance = UINavigationController()
        self.mpCheckout = MercadoPagoCheckout(publicKey: "PK_MLA", accessToken: "", checkoutPreference: checkoutPreference, navigationController: navControllerInstance)
    }

    func testSetTitle() {

        XCTAssertEqual(reviewScreenPreference.getTitle(), "Revisa tu pago".localized)

        reviewScreenPreference.setTitle(title: "1")
        self.mpCheckout.setReviewScreenPreference(reviewScreenPreference)

        XCTAssertEqual(self.mpCheckout.viewModel.reviewScreenPreference.getTitle(), "1")
    }

    func testSetConfirmButtonText() {

        XCTAssertEqual(reviewScreenPreference.getConfirmButtonText(), "Confirmar".localized)

        reviewScreenPreference.setConfirmButtonText(confirmButtonText: "1")
        self.mpCheckout.setReviewScreenPreference(reviewScreenPreference)

        XCTAssertEqual(self.mpCheckout.viewModel.reviewScreenPreference.getConfirmButtonText(), "1")
    }

    func testSetCancelButtonText() {

        XCTAssertEqual(reviewScreenPreference.getCancelButtonTitle(), "Cancelar Pago".localized)

        reviewScreenPreference.setCancelButtonText(cancelButtonText: "1")
        self.mpCheckout.setReviewScreenPreference(reviewScreenPreference)

        XCTAssertEqual(self.mpCheckout.viewModel.reviewScreenPreference.getCancelButtonTitle(), "1")
    }

    func testIsChangePaymentMethodDisable() {
        XCTAssert(reviewScreenPreference.isChangeMethodOptionEnabled())

        reviewScreenPreference.disableChangeMethodOption()

        XCTAssertFalse(reviewScreenPreference.isChangeMethodOptionEnabled())

        reviewScreenPreference.enableChangeMethodOption()

        XCTAssert(reviewScreenPreference.isChangeMethodOptionEnabled())
    }
}
