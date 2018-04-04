//
//  ESCFlowsTests.swift
//  MercadoPagoSDK
//
//  Created by Eden Torres on 7/20/17.
//  Copyright © 2017 MercadoPago. All rights reserved.
//

import XCTest

class ESCFlowsTests: BaseTest {

    var mpCheckout: MercadoPagoCheckout!
    override func setUp() {
        super.setUp()

        let checkoutPreference = MockBuilder.buildCheckoutPreference()
        mpCheckout = MercadoPagoCheckout(publicKey: "public_key", accessToken: "access_token", checkoutPreference: checkoutPreference, navigationController: UINavigationController())
        mpCheckout.viewModel.mpESCManager = MercadoPagoESCImplementationTest()

        let flowPreference = FlowPreference()
        flowPreference.enableESC()

        MercadoPagoCheckout.setFlowPreference(flowPreference)
    }

    func testEntireFlowWithCustomerCardWithESCNoError() {

        XCTAssertNotNil(mpCheckout.viewModel)

        // 1. Start
        var step = mpCheckout.viewModel.nextStep()
        XCTAssertEqual(CheckoutStep.START, step)

        // 1. Search preference
        step = mpCheckout.viewModel.nextStep()
        XCTAssertEqual(CheckoutStep.SERVICE_GET_PREFERENCE, step)

        //2. Buscar DirectDiscount
        step = mpCheckout.viewModel.nextStep()
        XCTAssertEqual(CheckoutStep.SERVICE_GET_DIRECT_DISCOUNT, step)

        // 3. Validate preference
        step = mpCheckout.viewModel.nextStep()
        XCTAssertEqual(CheckoutStep.ACTION_VALIDATE_PREFERENCE, step)

        // 4. Search Payment Methods
        step = mpCheckout.viewModel.nextStep()
        XCTAssertEqual(CheckoutStep.SERVICE_GET_PAYMENT_METHODS, step)
        MPCheckoutTestAction.loadGroupsInViewModel(mpCheckout: mpCheckout)

        // Simular api call a grupos
        let customerCardOption = MockBuilder.buildCustomerPaymentMethodWithESC(paymentMethodId: "visa")
        let creditCardOption = MockBuilder.buildPaymentMethodSearchItem("credit_card", type: PaymentMethodSearchItemType.PAYMENT_TYPE)
        let paymentMethodVisa = MockBuilder.buildPaymentMethod("visa")
        let paymentMethodSearchMock = MockBuilder.buildPaymentMethodSearch(groups: [creditCardOption], paymentMethods: [paymentMethodVisa], customOptions: [customerCardOption])
        mpCheckout.viewModel.updateCheckoutModel(paymentMethodSearch: paymentMethodSearchMock)

        // 5. Display payment methods (no exclusions)
        step = mpCheckout.viewModel.nextStep()
        XCTAssertEqual(CheckoutStep.SCREEN_PAYMENT_METHOD_SELECTION, step)

        // 6. Payment option selected : customer card visa => Cuotas
        mpCheckout.viewModel.updateCheckoutModel(paymentOptionSelected: customerCardOption as! PaymentMethodOption)
        step = mpCheckout.viewModel.nextStep()
        XCTAssertEqual(CheckoutStep.SERVICE_GET_PAYER_COSTS, step)
        mpCheckout.viewModel.payerCosts = MockBuilder.buildInstallment().payerCosts

        // 7. Mostrar cuotas
        step = mpCheckout.viewModel.nextStep()
        XCTAssertEqual(CheckoutStep.SCREEN_PAYER_COST, step)

        //Simular cuotas seleccionadas
        mpCheckout.viewModel.paymentData.payerCost = MockBuilder.buildPayerCost()

        // 8. Creacion de token (No pasa por security code)
        step = mpCheckout.viewModel.nextStep()
        XCTAssertEqual(CheckoutStep.SERVICE_CREATE_CARD_TOKEN, step)
        let token = MockBuilder.buildToken(withESC: true)
        mpCheckout.viewModel.updateCheckoutModel(token: token)

        // 9. RyC
        step = mpCheckout.viewModel.nextStep()
        XCTAssertEqual(CheckoutStep.SCREEN_REVIEW_AND_CONFIRM, step)

        // Simular pago
        let visaPaymentMethod = MockBuilder.buildPaymentMethod("visa")
        let paymentDataMock = MockBuilder.buildPaymentData(paymentMethod: visaPaymentMethod)
        paymentDataMock.issuer = MockBuilder.buildIssuer()
        paymentDataMock.payerCost = MockBuilder.buildPayerCost()
        paymentDataMock.token = MockBuilder.buildToken(withESC: true)
        mpCheckout.viewModel.updateCheckoutModel(paymentData: paymentDataMock)

        // 8. Post Payment
        step = mpCheckout.viewModel.nextStep()
        XCTAssertEqual(CheckoutStep.SERVICE_POST_PAYMENT, step)

        // 9. Simular pago completo => Congrats
        let paymentMock = MockBuilder.buildPayment("visa")
        mpCheckout.viewModel.updateCheckoutModel(payment: paymentMock)
        mpCheckout.viewModel.paymentResult = MockBuilder.buildPaymentResult(withESC: true)

        step = mpCheckout.viewModel.nextStep()
        XCTAssertEqual(CheckoutStep.SCREEN_PAYMENT_RESULT, step)
        XCTAssert(mpCheckout.viewModel.saveOrDeleteESC())

        // 10. Finish
        step = mpCheckout.viewModel.nextStep()
        XCTAssertEqual(CheckoutStep.ACTION_FINISH, step)

        // Ejecutar finish
        mpCheckout.executeNextStep()
    }

    func testEntireFlowWithCustomerCardWithESCNoErrorRejectedPayment() {

        XCTAssertNotNil(mpCheckout.viewModel)

        // 1. Start
        var step = mpCheckout.viewModel.nextStep()
        XCTAssertEqual(CheckoutStep.START, step)

        // 1. Search preference
        step = mpCheckout.viewModel.nextStep()
        XCTAssertEqual(CheckoutStep.SERVICE_GET_PREFERENCE, step)

        //2. Buscar DirectDiscount
        step = mpCheckout.viewModel.nextStep()
        XCTAssertEqual(CheckoutStep.SERVICE_GET_DIRECT_DISCOUNT, step)

        // 3. Validate preference
        step = mpCheckout.viewModel.nextStep()
        XCTAssertEqual(CheckoutStep.ACTION_VALIDATE_PREFERENCE, step)

        // 4. Search Payment Methods
        step = mpCheckout.viewModel.nextStep()
        XCTAssertEqual(CheckoutStep.SERVICE_GET_PAYMENT_METHODS, step)
        MPCheckoutTestAction.loadGroupsInViewModel(mpCheckout: mpCheckout)

        // Simular api call a grupos
        let customerCardOption = MockBuilder.buildCustomerPaymentMethodWithESC(paymentMethodId: "visa")
        let creditCardOption = MockBuilder.buildPaymentMethodSearchItem("credit_card", type: PaymentMethodSearchItemType.PAYMENT_TYPE)
        let paymentMethodVisa = MockBuilder.buildPaymentMethod("visa")
        let paymentMethodSearchMock = MockBuilder.buildPaymentMethodSearch(groups: [creditCardOption], paymentMethods: [paymentMethodVisa], customOptions: [customerCardOption])
        mpCheckout.viewModel.updateCheckoutModel(paymentMethodSearch: paymentMethodSearchMock)

        // 5. Display payment methods (no exclusions)
        step = mpCheckout.viewModel.nextStep()
        XCTAssertEqual(CheckoutStep.SCREEN_PAYMENT_METHOD_SELECTION, step)

        // 6. Payment option selected : customer card visa => Cuotas
        mpCheckout.viewModel.updateCheckoutModel(paymentOptionSelected: customerCardOption as! PaymentMethodOption)
        step = mpCheckout.viewModel.nextStep()
        XCTAssertEqual(CheckoutStep.SERVICE_GET_PAYER_COSTS, step)
        mpCheckout.viewModel.payerCosts = MockBuilder.buildInstallment().payerCosts

        // 7. Mostrar cuotas
        step = mpCheckout.viewModel.nextStep()
        XCTAssertEqual(CheckoutStep.SCREEN_PAYER_COST, step)

        //Simular cuotas seleccionadas
        mpCheckout.viewModel.paymentData.payerCost = MockBuilder.buildPayerCost()

        // 8. Creacion de token (No pasa por security code)
        step = mpCheckout.viewModel.nextStep()
        XCTAssertEqual(CheckoutStep.SERVICE_CREATE_CARD_TOKEN, step)
        let token = MockBuilder.buildToken(withESC: true)
        mpCheckout.viewModel.updateCheckoutModel(token: token)

        // 9. RyC
        step = mpCheckout.viewModel.nextStep()
        XCTAssertEqual(CheckoutStep.SCREEN_REVIEW_AND_CONFIRM, step)

        // Simular pago
        let visaPaymentMethod = MockBuilder.buildPaymentMethod("visa")
        let paymentDataMock = MockBuilder.buildPaymentData(paymentMethod: visaPaymentMethod)
        paymentDataMock.issuer = MockBuilder.buildIssuer()
        paymentDataMock.payerCost = MockBuilder.buildPayerCost()
        paymentDataMock.token = MockBuilder.buildToken(withESC: true)
        mpCheckout.viewModel.updateCheckoutModel(paymentData: paymentDataMock)

        // 8. Post Payment
        step = mpCheckout.viewModel.nextStep()
        XCTAssertEqual(CheckoutStep.SERVICE_POST_PAYMENT, step)

        // 9. Simular pago completo => Congrats
        let paymentMock = MockBuilder.buildPayment("visa")
        paymentMock.status = "rejected"
        mpCheckout.viewModel.updateCheckoutModel(payment: paymentMock)
        mpCheckout.viewModel.paymentResult = MockBuilder.buildPaymentResult(withESC: true)
        mpCheckout.viewModel.paymentResult?.status = "rejected"
        step = mpCheckout.viewModel.nextStep()
        XCTAssertEqual(CheckoutStep.SCREEN_PAYMENT_RESULT, step)
        XCTAssertFalse(mpCheckout.viewModel.saveOrDeleteESC())

        // 10. Finish
        step = mpCheckout.viewModel.nextStep()
        XCTAssertEqual(CheckoutStep.ACTION_FINISH, step)

        // Ejecutar finish
        mpCheckout.executeNextStep()
    }

    func testEntireFlowWithCustomerCardWithESErrorInTokenCreation() {
        XCTAssertNotNil(mpCheckout.viewModel)

        // 1. Start
        var step = mpCheckout.viewModel.nextStep()
        XCTAssertEqual(CheckoutStep.START, step)

        // 1. Search preference
        step = mpCheckout.viewModel.nextStep()
        XCTAssertEqual(CheckoutStep.SERVICE_GET_PREFERENCE, step)

        //2. Buscar DirectDiscount
        step = mpCheckout.viewModel.nextStep()
        XCTAssertEqual(CheckoutStep.SERVICE_GET_DIRECT_DISCOUNT, step)

        // 3. Validate preference
        step = mpCheckout.viewModel.nextStep()
        XCTAssertEqual(CheckoutStep.ACTION_VALIDATE_PREFERENCE, step)

        // 4. Search Payment Methods
        step = mpCheckout.viewModel.nextStep()
        XCTAssertEqual(CheckoutStep.SERVICE_GET_PAYMENT_METHODS, step)
        MPCheckoutTestAction.loadGroupsInViewModel(mpCheckout: mpCheckout)

        // Simular api call a grupos
        var customerCardOption = MockBuilder.buildCustomerPaymentMethodWithESC(paymentMethodId: "visa")
        let creditCardOption = MockBuilder.buildPaymentMethodSearchItem("credit_card", type: PaymentMethodSearchItemType.PAYMENT_TYPE)
        let paymentMethodVisa = MockBuilder.buildPaymentMethod("visa")
        let paymentMethodSearchMock = MockBuilder.buildPaymentMethodSearch(groups: [creditCardOption], paymentMethods: [paymentMethodVisa], customOptions: [customerCardOption])
        mpCheckout.viewModel.updateCheckoutModel(paymentMethodSearch: paymentMethodSearchMock)

        // 5. Display payment methods (no exclusions)
        step = mpCheckout.viewModel.nextStep()
        XCTAssertEqual(CheckoutStep.SCREEN_PAYMENT_METHOD_SELECTION, step)

        // 6. Payment option selected : customer card visa => Cuotas
        mpCheckout.viewModel.updateCheckoutModel(paymentOptionSelected: customerCardOption as! PaymentMethodOption)
        step = mpCheckout.viewModel.nextStep()
        XCTAssertEqual(CheckoutStep.SERVICE_GET_PAYER_COSTS, step)
        mpCheckout.viewModel.payerCosts = MockBuilder.buildInstallment().payerCosts

        // 7. Mostrar cuotas
        step = mpCheckout.viewModel.nextStep()
        XCTAssertEqual(CheckoutStep.SCREEN_PAYER_COST, step)

        // Simular cuotas seleccionadas
        mpCheckout.viewModel.paymentData.payerCost = MockBuilder.buildPayerCost()

        // 8. Creacion de token (No pasa por security code)
        step = mpCheckout.viewModel.nextStep()
        XCTAssertEqual(CheckoutStep.SERVICE_CREATE_CARD_TOKEN, step)

        // Simulate error creating token with esc
        customerCardOption = MockBuilder.buildCustomerPaymentMethod("customerCardId", paymentMethodId: "visa")
        mpCheckout.viewModel.paymentOptionSelected = customerCardOption as? PaymentMethodOption

        // 9. Mostrar SecCode (incluye creación de token)
        step = mpCheckout.viewModel.nextStep()
        XCTAssertEqual(CheckoutStep.SCREEN_SECURITY_CODE, step)
        let token = MockBuilder.buildToken(withESC: true)
        mpCheckout.viewModel.updateCheckoutModel(token: token)

        // 10. RyC
        step = mpCheckout.viewModel.nextStep()
        XCTAssertEqual(CheckoutStep.SCREEN_REVIEW_AND_CONFIRM, step)

        // Simular pago
        let visaPaymentMethod = MockBuilder.buildPaymentMethod("visa")
        let paymentDataMock = MockBuilder.buildPaymentData(paymentMethod: visaPaymentMethod)
        paymentDataMock.issuer = MockBuilder.buildIssuer()
        paymentDataMock.payerCost = MockBuilder.buildPayerCost()
        paymentDataMock.token = MockBuilder.buildToken(withESC: true)
        mpCheckout.viewModel.updateCheckoutModel(paymentData: paymentDataMock)

        // 11. Post Payment
        step = mpCheckout.viewModel.nextStep()
        XCTAssertEqual(CheckoutStep.SERVICE_POST_PAYMENT, step)

        // 12. Simular pago completo => Congrats
        let paymentMock = MockBuilder.buildPayment("visa")
        mpCheckout.viewModel.updateCheckoutModel(payment: paymentMock)
        mpCheckout.viewModel.paymentResult = MockBuilder.buildPaymentResult(withESC: true)
        step = mpCheckout.viewModel.nextStep()
        XCTAssertEqual(CheckoutStep.SCREEN_PAYMENT_RESULT, step)
        XCTAssert(mpCheckout.viewModel.saveOrDeleteESC())

        // 13. Finish
        step = mpCheckout.viewModel.nextStep()
        XCTAssertEqual(CheckoutStep.ACTION_FINISH, step)

        // Ejecutar finish
        mpCheckout.executeNextStep()
    }

    func testEntireFlowWithCustomerCardWithESErrorInPaymentAndInTokenCreation() {

        XCTAssertNotNil(mpCheckout.viewModel)

        // 1. Start
        var step = mpCheckout.viewModel.nextStep()
        XCTAssertEqual(CheckoutStep.START, step)

        // 1. Search preference
        step = mpCheckout.viewModel.nextStep()
        XCTAssertEqual(CheckoutStep.SERVICE_GET_PREFERENCE, step)

        //2. Buscar DirectDiscount
        step = mpCheckout.viewModel.nextStep()
        XCTAssertEqual(CheckoutStep.SERVICE_GET_DIRECT_DISCOUNT, step)

        // 3. Validate preference
        step = mpCheckout.viewModel.nextStep()
        XCTAssertEqual(CheckoutStep.ACTION_VALIDATE_PREFERENCE, step)

        // 4. Search Payment Methods
        step = mpCheckout.viewModel.nextStep()
        XCTAssertEqual(CheckoutStep.SERVICE_GET_PAYMENT_METHODS, step)
        MPCheckoutTestAction.loadGroupsInViewModel(mpCheckout: mpCheckout)

        // Simular api call a grupos
        var customerCardOption = MockBuilder.buildCustomerPaymentMethodWithESC(paymentMethodId: "visa")
        let creditCardOption = MockBuilder.buildPaymentMethodSearchItem("credit_card", type: PaymentMethodSearchItemType.PAYMENT_TYPE)
        let paymentMethodVisa = MockBuilder.buildPaymentMethod("visa")
        let paymentMethodSearchMock = MockBuilder.buildPaymentMethodSearch(groups: [creditCardOption], paymentMethods: [paymentMethodVisa], customOptions: [customerCardOption])
        mpCheckout.viewModel.updateCheckoutModel(paymentMethodSearch: paymentMethodSearchMock)

        // 5. Display payment methods (no exclusions)
        step = mpCheckout.viewModel.nextStep()
        XCTAssertEqual(CheckoutStep.SCREEN_PAYMENT_METHOD_SELECTION, step)

        // 6. Payment option selected : customer card visa => Cuotas
        mpCheckout.viewModel.updateCheckoutModel(paymentOptionSelected: customerCardOption as! PaymentMethodOption)
        step = mpCheckout.viewModel.nextStep()
        XCTAssertEqual(CheckoutStep.SERVICE_GET_PAYER_COSTS, step)
        mpCheckout.viewModel.payerCosts = MockBuilder.buildInstallment().payerCosts

        // 7. Mostrar cuotas
        step = mpCheckout.viewModel.nextStep()
        XCTAssertEqual(CheckoutStep.SCREEN_PAYER_COST, step)

        // Simular cuotas seleccionadas
        mpCheckout.viewModel.paymentData.payerCost = MockBuilder.buildPayerCost()

        // 8. Creacion de token (No pasa por security code)
        step = mpCheckout.viewModel.nextStep()
        XCTAssertEqual(CheckoutStep.SERVICE_CREATE_CARD_TOKEN, step)

        // Simulate error creating token with esc
        customerCardOption = MockBuilder.buildCustomerPaymentMethod("customerCardId", paymentMethodId: "visa")
        mpCheckout.viewModel.paymentOptionSelected = customerCardOption as? PaymentMethodOption

        // 9. Mostrar SecCode (incluye creación de token)
        step = mpCheckout.viewModel.nextStep()
        XCTAssertEqual(CheckoutStep.SCREEN_SECURITY_CODE, step)
        var token = MockBuilder.buildToken(withESC: true)
        mpCheckout.viewModel.updateCheckoutModel(token: token)

        // 10. RyC
        step = mpCheckout.viewModel.nextStep()
        XCTAssertEqual(CheckoutStep.SCREEN_REVIEW_AND_CONFIRM, step)

        // Simular pago
        let visaPaymentMethod = MockBuilder.buildPaymentMethod("visa")
        let paymentDataMock = MockBuilder.buildPaymentData(paymentMethod: visaPaymentMethod)
        paymentDataMock.issuer = MockBuilder.buildIssuer()
        paymentDataMock.payerCost = MockBuilder.buildPayerCost()
        paymentDataMock.token = MockBuilder.buildToken(withESC: true)
        mpCheckout.viewModel.updateCheckoutModel(paymentData: paymentDataMock)

        // 11. Post Payment
        step = mpCheckout.viewModel.nextStep()
        XCTAssertEqual(CheckoutStep.SERVICE_POST_PAYMENT, step)

        // 12. Simular pago error al momento de pago
        mpCheckout.viewModel.prepareForInvalidPaymentWithESC()

        // 13. Mostrar SecCode (incluye creación de token)
        step = mpCheckout.viewModel.nextStep()
        XCTAssertEqual(CheckoutStep.SCREEN_SECURITY_CODE, step)
        token = MockBuilder.buildToken(withESC: true)
        mpCheckout.viewModel.updateCheckoutModel(token: token)

        // Simular pago
        paymentDataMock.issuer = MockBuilder.buildIssuer()
        paymentDataMock.payerCost = MockBuilder.buildPayerCost()
        paymentDataMock.token = MockBuilder.buildToken(withESC: true)
        mpCheckout.viewModel.updateCheckoutModel(paymentData: paymentDataMock)

        // 14. Post Payment
        step = mpCheckout.viewModel.nextStep()
        XCTAssertEqual(CheckoutStep.SERVICE_POST_PAYMENT, step)

        // 15. Simular pago completo => Congrats
        let paymentMock = MockBuilder.buildPayment("visa")
        mpCheckout.viewModel.updateCheckoutModel(payment: paymentMock)
        mpCheckout.viewModel.paymentResult = MockBuilder.buildPaymentResult(withESC: true)
        step = mpCheckout.viewModel.nextStep()
        XCTAssertEqual(CheckoutStep.SCREEN_PAYMENT_RESULT, step)
        XCTAssert(mpCheckout.viewModel.saveOrDeleteESC())

        // 16. Finish
        step = mpCheckout.viewModel.nextStep()
        XCTAssertEqual(CheckoutStep.ACTION_FINISH, step)

        // Ejecutar finish
        mpCheckout.executeNextStep()
    }

    func testEntireFlowWithCustomerCardWithESErrorInPayment() {

        XCTAssertNotNil(mpCheckout.viewModel)

        // 1. Start
        var step = mpCheckout.viewModel.nextStep()
        XCTAssertEqual(CheckoutStep.START, step)

        // 1. Search preference
        step = mpCheckout.viewModel.nextStep()
        XCTAssertEqual(CheckoutStep.SERVICE_GET_PREFERENCE, step)

        //2. Buscar DirectDiscount
        step = mpCheckout.viewModel.nextStep()
        XCTAssertEqual(CheckoutStep.SERVICE_GET_DIRECT_DISCOUNT, step)

        // 3. Validate preference
        step = mpCheckout.viewModel.nextStep()
        XCTAssertEqual(CheckoutStep.ACTION_VALIDATE_PREFERENCE, step)

        // 4. Search Payment Methods
        step = mpCheckout.viewModel.nextStep()
        XCTAssertEqual(CheckoutStep.SERVICE_GET_PAYMENT_METHODS, step)
        MPCheckoutTestAction.loadGroupsInViewModel(mpCheckout: mpCheckout)

        // Simular api call a grupos
        var customerCardOption = MockBuilder.buildCustomerPaymentMethodWithESC(paymentMethodId: "visa")
        let creditCardOption = MockBuilder.buildPaymentMethodSearchItem("credit_card", type: PaymentMethodSearchItemType.PAYMENT_TYPE)
        let paymentMethodVisa = MockBuilder.buildPaymentMethod("visa")
        let paymentMethodSearchMock = MockBuilder.buildPaymentMethodSearch(groups: [creditCardOption], paymentMethods: [paymentMethodVisa], customOptions: [customerCardOption])
        mpCheckout.viewModel.updateCheckoutModel(paymentMethodSearch: paymentMethodSearchMock)

        // 5. Display payment methods (no exclusions)
        step = mpCheckout.viewModel.nextStep()
        XCTAssertEqual(CheckoutStep.SCREEN_PAYMENT_METHOD_SELECTION, step)

        // 6. Payment option selected : customer card visa => Cuotas
        mpCheckout.viewModel.updateCheckoutModel(paymentOptionSelected: customerCardOption as! PaymentMethodOption)
        step = mpCheckout.viewModel.nextStep()
        XCTAssertEqual(CheckoutStep.SERVICE_GET_PAYER_COSTS, step)
        mpCheckout.viewModel.payerCosts = MockBuilder.buildInstallment().payerCosts

        // 7. Mostrar cuotas
        step = mpCheckout.viewModel.nextStep()
        XCTAssertEqual(CheckoutStep.SCREEN_PAYER_COST, step)

        // Simular cuotas seleccionadas
        mpCheckout.viewModel.paymentData.payerCost = MockBuilder.buildPayerCost()

        // 8. Creacion de token (No pasa por security code)
        step = mpCheckout.viewModel.nextStep()
        XCTAssertEqual(CheckoutStep.SERVICE_CREATE_CARD_TOKEN, step)
        var token = MockBuilder.buildToken(withESC: true)
        mpCheckout.viewModel.updateCheckoutModel(token: token)

        // 9. RyC
        step = mpCheckout.viewModel.nextStep()
        XCTAssertEqual(CheckoutStep.SCREEN_REVIEW_AND_CONFIRM, step)

        // Simular pago
        let visaPaymentMethod = MockBuilder.buildPaymentMethod("visa")
        let paymentDataMock = MockBuilder.buildPaymentData(paymentMethod: visaPaymentMethod)
        paymentDataMock.issuer = MockBuilder.buildIssuer()
        paymentDataMock.payerCost = MockBuilder.buildPayerCost()
        paymentDataMock.token = MockBuilder.buildToken(withESC: true)
        mpCheckout.viewModel.updateCheckoutModel(paymentData: paymentDataMock)

        // 10. Post Payment
        step = mpCheckout.viewModel.nextStep()
        XCTAssertEqual(CheckoutStep.SERVICE_POST_PAYMENT, step)

        // 11. Simular pago error al momento de pago
        mpCheckout.viewModel.prepareForInvalidPaymentWithESC()
        customerCardOption = MockBuilder.buildCustomerPaymentMethod("customerCardId", paymentMethodId: "visa")
        mpCheckout.viewModel.paymentOptionSelected = customerCardOption as? PaymentMethodOption

        // 12. Mostrar SecCode (incluye creación de token)
        step = mpCheckout.viewModel.nextStep()
        XCTAssertEqual(CheckoutStep.SCREEN_SECURITY_CODE, step)
        token = MockBuilder.buildToken(withESC: true)
        mpCheckout.viewModel.updateCheckoutModel(token: token)

        // Simular pago
        paymentDataMock.issuer = MockBuilder.buildIssuer()
        paymentDataMock.payerCost = MockBuilder.buildPayerCost()
        paymentDataMock.token = MockBuilder.buildToken(withESC: true)
        mpCheckout.viewModel.updateCheckoutModel(paymentData: paymentDataMock)

        // 13. Post Payment
        step = mpCheckout.viewModel.nextStep()
        XCTAssertEqual(CheckoutStep.SERVICE_POST_PAYMENT, step)

        // 14. Simular pago completo => Congrats
        let paymentMock = MockBuilder.buildPayment("visa")
        mpCheckout.viewModel.updateCheckoutModel(payment: paymentMock)
        mpCheckout.viewModel.paymentResult = MockBuilder.buildPaymentResult(withESC: true)
        step = mpCheckout.viewModel.nextStep()
        XCTAssertEqual(CheckoutStep.SCREEN_PAYMENT_RESULT, step)
        XCTAssert(mpCheckout.viewModel.saveOrDeleteESC())

        // 15. Finish
        step = mpCheckout.viewModel.nextStep()
        XCTAssertEqual(CheckoutStep.ACTION_FINISH, step)

        // Ejecutar finish
        mpCheckout.executeNextStep()
    }

    func testEntireFlowWithCustomerCardWithESCNoErrorFlowPreferenceDisable() {

        let flowPreference = MockBuilder.buildFlowPreferenceWithoutESC()
        MercadoPagoCheckout.setFlowPreference(flowPreference)

        XCTAssertNotNil(mpCheckout.viewModel)

        // 1. Start
        var step = mpCheckout.viewModel.nextStep()
        XCTAssertEqual(CheckoutStep.START, step)

        // 1. Search preference
        step = mpCheckout.viewModel.nextStep()
        XCTAssertEqual(CheckoutStep.SERVICE_GET_PREFERENCE, step)

        //2. Buscar DirectDiscount
        step = mpCheckout.viewModel.nextStep()
        XCTAssertEqual(CheckoutStep.SERVICE_GET_DIRECT_DISCOUNT, step)

        // 3. Validate preference
        step = mpCheckout.viewModel.nextStep()
        XCTAssertEqual(CheckoutStep.ACTION_VALIDATE_PREFERENCE, step)

        // 4. Search Payment Methods
        step = mpCheckout.viewModel.nextStep()
        XCTAssertEqual(CheckoutStep.SERVICE_GET_PAYMENT_METHODS, step)
        MPCheckoutTestAction.loadGroupsInViewModel(mpCheckout: mpCheckout)

        // Simular api call a grupos
        var customerCardOption = MockBuilder.buildCustomerPaymentMethodWithESC(paymentMethodId: "visa")
        let creditCardOption = MockBuilder.buildPaymentMethodSearchItem("credit_card", type: PaymentMethodSearchItemType.PAYMENT_TYPE)
        let paymentMethodVisa = MockBuilder.buildPaymentMethod("visa")
        let paymentMethodSearchMock = MockBuilder.buildPaymentMethodSearch(groups: [creditCardOption], paymentMethods: [paymentMethodVisa], customOptions: [customerCardOption])
        mpCheckout.viewModel.updateCheckoutModel(paymentMethodSearch: paymentMethodSearchMock)

        // 5. Display payment methods (no exclusions)
        step = mpCheckout.viewModel.nextStep()
        XCTAssertEqual(CheckoutStep.SCREEN_PAYMENT_METHOD_SELECTION, step)

        // 6. Payment option selected : customer card visa => Cuotas
        mpCheckout.viewModel.updateCheckoutModel(paymentOptionSelected: customerCardOption as! PaymentMethodOption)
        step = mpCheckout.viewModel.nextStep()
        XCTAssertEqual(CheckoutStep.SERVICE_GET_PAYER_COSTS, step)
        mpCheckout.viewModel.payerCosts = MockBuilder.buildInstallment().payerCosts

        // 7. Mostrar cuotas
        step = mpCheckout.viewModel.nextStep()
        XCTAssertEqual(CheckoutStep.SCREEN_PAYER_COST, step)

        //Simular cuotas seleccionadas
        mpCheckout.viewModel.paymentData.payerCost = MockBuilder.buildPayerCost()

        // 8. Mostrar SecCode (incluye creación de token)
        step = mpCheckout.viewModel.nextStep()
        XCTAssertEqual(CheckoutStep.SCREEN_SECURITY_CODE, step)
        let token = MockBuilder.buildToken(withESC: true)
        mpCheckout.viewModel.updateCheckoutModel(token: token)

        // 9. RyC
        step = mpCheckout.viewModel.nextStep()
        XCTAssertEqual(CheckoutStep.SCREEN_REVIEW_AND_CONFIRM, step)

        // Simular pago
        let visaPaymentMethod = MockBuilder.buildPaymentMethod("visa")
        let paymentDataMock = MockBuilder.buildPaymentData(paymentMethod: visaPaymentMethod)
        paymentDataMock.issuer = MockBuilder.buildIssuer()
        paymentDataMock.payerCost = MockBuilder.buildPayerCost()
        paymentDataMock.token = MockBuilder.buildToken(withESC: true)
        mpCheckout.viewModel.updateCheckoutModel(paymentData: paymentDataMock)

        // 8. Post Payment
        step = mpCheckout.viewModel.nextStep()
        XCTAssertEqual(CheckoutStep.SERVICE_POST_PAYMENT, step)

        // 9. Simular pago completo => Congrats
        let paymentMock = MockBuilder.buildPayment("visa")
        mpCheckout.viewModel.updateCheckoutModel(payment: paymentMock)
        mpCheckout.viewModel.paymentResult = MockBuilder.buildPaymentResult(withESC: true)
        step = mpCheckout.viewModel.nextStep()
        XCTAssertEqual(CheckoutStep.SCREEN_PAYMENT_RESULT, step)
        XCTAssertFalse(mpCheckout.viewModel.saveOrDeleteESC())

        // 10. Finish
        step = mpCheckout.viewModel.nextStep()
        XCTAssertEqual(CheckoutStep.ACTION_FINISH, step)

        // Ejecutar finish
        mpCheckout.executeNextStep()
    }

}
open class MercadoPagoESCImplementationTest: NSObject, MercadoPagoESC {

    public func hasESCEnable() -> Bool {
        return MercadoPagoCheckoutViewModel.flowPreference.isESCEnable()
    }

    public func getESC(cardId: String) -> String? {
        if hasESCEnable() {
            if cardId == "esc" {
                return "111"
            }
        }
        return nil
    }
    public func saveESC(cardId: String, esc: String) -> Bool {
        if hasESCEnable() {
            return true
        }
        return false
    }

    public func deleteESC(cardId: String) {

    }

    public func deleteAllESC() {

    }
}
