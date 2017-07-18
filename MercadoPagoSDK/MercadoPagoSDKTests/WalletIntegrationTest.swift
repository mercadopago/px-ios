//
//  WalletIntegrationTest.swift
//  MercadoPagoSDK
//
//  Created by Maria cristina rodriguez on 3/10/17.
//  Copyright © 2017 MercadoPago. All rights reserved.
//

import XCTest

class WalletIntegrationTest: BaseTest {

    override func setUp() {
        super.setUp()
        self.continueAfterFailure = false
    }

    override func tearDown() {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
        super.tearDown()
    }

    func testBasicFlow() {

        // Deshabilita RyC
        var fp = FlowPreference()
        fp.disableReviewAndConfirmScreen()
        // Deshabilita descuentos
        fp.disableDiscount()
        // Habilita todas las tarjetas guardadas
        fp.setMaxSavedCardsToShow(fromString: FlowPreference.SHOW_ALL_SAVED_CARDS_CODE)

        MercadoPagoCheckout.setFlowPreference(fp)
        MercadoPagoContext.setAccountMoneyAvailable(accountMoneyAvailable: true)

        // Inicia Checkout con preferencia
        let preference = MockBuilder.buildCheckoutPreference()
        let mpCheckout = MercadoPagoCheckout(publicKey: "PK_MLA", accessToken: "access_token", checkoutPreference: preference, navigationController: UINavigationController())

        var step = mpCheckout.viewModel.nextStep()
        XCTAssertEqual(step, CheckoutStep.SERVICE_GET_PREFERENCE)

        step = mpCheckout.viewModel.nextStep()
        XCTAssertEqual(step, CheckoutStep.ACTION_VALIDATE_PREFERENCE)

        step = mpCheckout.viewModel.nextStep()
        XCTAssertEqual(step, CheckoutStep.SERVICE_GET_PAYMENT_METHODS)
        MPCheckoutTestAction.loadGroupsInViewModel(mpCheckout: mpCheckout)

        step = mpCheckout.viewModel.nextStep()
        XCTAssertEqual(step, CheckoutStep.SCREEN_PAYMENT_METHOD_SELECTION)

        MPCheckoutTestAction.selectAccountMoney(mpCheckout: mpCheckout)

        var localPaymentData: PaymentData?
        let expectPaymentDataCallback = expectation(description: "paymentDataCallback")
        MercadoPagoCheckout.setPaymentDataCallback { (paymentData: PaymentData) in
            XCTAssertEqual(paymentData.paymentMethod._id, "account_money")
            expectPaymentDataCallback.fulfill()
            localPaymentData = paymentData
        }

        step = mpCheckout.viewModel.nextStep()
        XCTAssertEqual(step, CheckoutStep.ACTION_FINISH)

        // Ejecutar finish => paymentDataCallback
        mpCheckout.executeNextStep()
        waitForExpectations(timeout: 10, handler: nil)

        // Se habilita RyC
        fp = FlowPreference()
        fp.enableReviewAndConfirmScreen()
        MercadoPagoCheckout.setFlowPreference(fp)

        // Se vuelve a llamar a Checkout para que muestre RyC
        let mpCheckoutWithRyC = MercadoPagoCheckout(publicKey: "PK_MLA", accessToken: "access_token", checkoutPreference: preference, paymentData : localPaymentData!, navigationController: UINavigationController())
        step = mpCheckoutWithRyC.viewModel.nextStep()
        XCTAssertEqual(step, CheckoutStep.SERVICE_GET_PREFERENCE)

        step = mpCheckoutWithRyC.viewModel.nextStep()
        XCTAssertEqual(step, CheckoutStep.ACTION_VALIDATE_PREFERENCE)

        step = mpCheckoutWithRyC.viewModel.nextStep()
        XCTAssertEqual(step, CheckoutStep.SERVICE_GET_PAYMENT_METHODS)

        MPCheckoutTestAction.loadGroupsInViewModel(mpCheckout: mpCheckoutWithRyC)

        step = mpCheckoutWithRyC.viewModel.nextStep()
        XCTAssertEqual(step, CheckoutStep.SCREEN_REVIEW_AND_CONFIRM)
        // Se realiza pago, se llama a confirmPaymentCallback
        // Se llama a congrats con paymentResult
    }

    func testChangePaymentMethodFlow() {

        // Deshabilita RyC
        // Inicia Checkout con preferencia
        // Llama a paymentDataCallback. Dentro llama a Checkout con paymentData => RyC

        // Se modifica medio de pago => se llama a changePaymentMethodCallback y se desactiva nuevamente RyC
        // Se reinicia checkout automaticamente

        // Se vuelve a llama a paymentDataCallback. Dentro llama a Checkout con paymentData => RyC

        // Se realiza pago, se llama a confirmPaymentCallback
        // Se llama a congrats con paymentResult

    }

    func testAccountMoneyOnlyFlow() {
        // Deshabilita RyC
        // Inicia Checkout con preferencia con solo medio de pago account_money
        // Llama a paymentDataCallback. Dentro llama a Checkout con paymentData => RyC

        // Se modifica medio de pago => se llama a changePaymentMethodCallback y se desactiva nuevamente RyC
        // Se reinicia checkout automaticamente

        // Se vuelve a llama a paymentDataCallback. Dentro llama a Checkout con paymentData => RyC

        // Se realiza pago, se llama a confirmPaymentCallback
        // Se llama a congrats con paymentResult
    }

    func testCreditCardOnlyFlow() {
        // Deshabilita RyC
        // Inicia Checkout con preferencia con solo medio de pago tarjetas
        // Llama a paymentDataCallback. Dentro llama a Checkout con paymentData => RyC

        // Se modifica medio de pago => se llama a changePaymentMethodCallback y se desactiva nuevamente RyC
        // Se reinicia checkout automaticamente

        // Se vuelve a llama a paymentDataCallback. Dentro llama a Checkout con paymentData => RyC

        // Se realiza pago, se llama a confirmPaymentCallback
        // Se llama a congrats con paymentResult
    }
}
