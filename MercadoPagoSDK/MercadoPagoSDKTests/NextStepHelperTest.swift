//
//  NextStepHelperTest.swift
//  MercadoPagoSDK
//
//  Created by Maria cristina rodriguez on 3/22/17.
//  Copyright © 2017 MercadoPago. All rights reserved.
//

import XCTest

class NextStepHelperTest: BaseTest {

    override func setUp() {
        super.setUp()
        // Put setup code here. This method is called before the invocation of each test method in the class.
    }

    override func tearDown() {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
        super.tearDown()
    }

    func testShowConfirm() {
        let checkoutPreference = MockBuilder.buildCheckoutPreference()
        let mpCheckoutViewModel = MercadoPagoCheckoutViewModel(checkoutPreference: checkoutPreference, paymentData: nil, paymentResult: nil, discount: nil)
        XCTAssertFalse(mpCheckoutViewModel.showConfirm())

        mpCheckoutViewModel.paymentData.paymentMethod = MockBuilder.buildPaymentMethod("account_money")
        XCTAssertTrue(mpCheckoutViewModel.showConfirm())

        mpCheckoutViewModel.paymentData.paymentMethod = MockBuilder.buildPaymentMethod("visa")
        mpCheckoutViewModel.paymentData.token = MockBuilder.buildToken()
        mpCheckoutViewModel.paymentData.payerCost = MockBuilder.buildPayerCost()

        XCTAssertTrue(mpCheckoutViewModel.showConfirm())
    }

    func testSetPaymentOptionSelected() {
        let checkoutPreference = MockBuilder.buildCheckoutPreference()
        let mpCheckoutViewModel = MercadoPagoCheckoutViewModel(checkoutPreference: checkoutPreference, paymentData: nil, paymentResult: nil, discount: nil)

        MercadoPagoContext.setAccountMoneyAvailable(accountMoneyAvailable: true)
        MPCheckoutTestAction.loadGroupsInViewModel(mpCheckoutViewModel: mpCheckoutViewModel)

        // Account_money
        mpCheckoutViewModel.paymentData.paymentMethod = MockBuilder.buildPaymentMethod("account_money", paymentTypeId: "account_money")
        mpCheckoutViewModel.setPaymentOptionSelected()
        XCTAssertNotNil(mpCheckoutViewModel.paymentOptionSelected)
        XCTAssertEqual(mpCheckoutViewModel.paymentOptionSelected!.getId(), "account_money")

        // Visa
        mpCheckoutViewModel.paymentData.paymentMethod = MockBuilder.buildPaymentMethod("visa")
        mpCheckoutViewModel.setPaymentOptionSelected()
        XCTAssertNotNil(mpCheckoutViewModel.paymentOptionSelected)
        XCTAssertEqual(mpCheckoutViewModel.paymentOptionSelected!.getId(), "credit_card")

        // Medio off
        mpCheckoutViewModel.paymentData.paymentMethod = MockBuilder.buildPaymentMethod("off", paymentTypeId: "ticket")
        mpCheckoutViewModel.setPaymentOptionSelected()
        XCTAssertNotNil(mpCheckoutViewModel.paymentOptionSelected)
        XCTAssertEqual(mpCheckoutViewModel.paymentOptionSelected!.getId(), "off")
    }

}
