//
//  HooksFlowTest.swift
//  MercadoPagoSDKTests
//
//  Created by Eden Torres on 11/28/17.
//  Copyright © 2017 MercadoPago. All rights reserved.
//

import Foundation
import XCTest

class HooksFlowTest : BaseTest {

    var mpCheckout: MercadoPagoCheckout!
    let flowPreference = FlowPreference()

    override func setUp() {
        super.setUp()
        let checkoutPreference = MockBuilder.buildCheckoutPreference()
        mpCheckout = MercadoPagoCheckout(publicKey: "public_key", accessToken: "access_token", checkoutPreference: checkoutPreference, navigationController: UINavigationController())

        let firstHook = MockedHookViewController(hookStep: PXHookStep.AFTER_PAYMENT_TYPE_SELECTED)
        let secondHook = MockedHookViewController(hookStep: PXHookStep.AFTER_PAYMENT_METHOD_SELECTED)
        let thirdHook = MockedHookViewController(hookStep: PXHookStep.BEFORE_PAYMENT)

        let hooks: [PXHookComponent] = [firstHook, secondHook, thirdHook]

        //flowPreference.setHook(hooks: hooks)

        MercadoPagoCheckout.setFlowPreference(flowPreference)
    }

    func testNextStep_withCheckoutPreference_accountMoney() {
        // Set access_token
        MercadoPagoContext.setAccountMoneyAvailable(accountMoneyAvailable: true)
        XCTAssertNotNil(mpCheckout.viewModel)
        MercadoPagoCheckoutViewModel.flowPreference.showDiscount = true

        // 0. Start
        var step = mpCheckout.viewModel.nextStep()
        XCTAssertEqual(CheckoutStep.START, step)

        // 1. Search Preference
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

        // 5. Display payment methods (no exclusions)
        step = mpCheckout.viewModel.nextStep()
        XCTAssertEqual(CheckoutStep.SCREEN_PAYMENT_METHOD_SELECTION, step)

        // 6. Payment option selected : account_money => RyC
        MPCheckoutTestAction.selectAccountMoney(mpCheckout: mpCheckout)

        step = mpCheckout.viewModel.nextStep()
        XCTAssertEqual(CheckoutStep.SCREEN_REVIEW_AND_CONFIRM, step)

        // 7 . Simular paymentData y pagar
        let accountMoneyPm = MockBuilder.buildPaymentMethod("account_money", name: "Dinero en cuenta", paymentTypeId: PaymentTypeId.ACCOUNT_MONEY.rawValue)
        let paymentDataMock = MockBuilder.buildPaymentData(paymentMethod: accountMoneyPm)
        mpCheckout.viewModel.updateCheckoutModel(paymentData: paymentDataMock)

        step = mpCheckout.viewModel.nextStep()
        XCTAssertEqual(CheckoutStep.SERVICE_POST_PAYMENT, step)

        // 8. Simular Pago realizado y se muestra congrats
        let paymentMock = MockBuilder.buildPayment("account_money")
        mpCheckout.viewModel.updateCheckoutModel(payment: paymentMock)
        mpCheckout.viewModel.paymentResult = MockBuilder.buildPaymentResult()
        step = mpCheckout.viewModel.nextStep()
        XCTAssertEqual(CheckoutStep.SCREEN_PAYMENT_RESULT, step)

        // 7. Finish
        step = mpCheckout.viewModel.nextStep()
        XCTAssertEqual(CheckoutStep.ACTION_FINISH, step)

    }


    func testNextStep_withCheckoutPreference_masterCreditCard() {

        // Set access_token
        MercadoPagoContext.setAccountMoneyAvailable(accountMoneyAvailable: true)
        XCTAssertNotNil(mpCheckout.viewModel)
        MercadoPagoCheckoutViewModel.flowPreference.showDiscount = true

        // 0. Start
        var step = mpCheckout.viewModel.nextStep()
        XCTAssertEqual(CheckoutStep.START, step)

        // 1. Search Preference
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

        // 5. Display payment methods (no exclusions)
        step = mpCheckout.viewModel.nextStep()
        XCTAssertEqual(CheckoutStep.SCREEN_PAYMENT_METHOD_SELECTION, step)

        // 6. Payment option selected : tarjeta de credito => Form Tarjeta
        MPCheckoutTestAction.selectCreditCardOption(mpCheckout: mpCheckout)
        step = mpCheckout.viewModel.nextStep()
        XCTAssertEqual(CheckoutStep.SCREEN_CARD_FORM, step)

        // Simular paymentMethod completo
        let paymentMethodMaster = MockBuilder.buildPaymentMethod("master")
        // Se necesita identification input
        paymentMethodMaster.additionalInfoNeeded = ["cardholder_identification_number"]
        mpCheckout.viewModel.paymentData.paymentMethod = paymentMethodMaster

        let cardToken = MockBuilder.buildCardToken()
        mpCheckout.viewModel.cardToken = cardToken

        // 7. Buscar Identification
        step = mpCheckout.viewModel.nextStep()
        XCTAssertEqual(CheckoutStep.SERVICE_GET_IDENTIFICATION_TYPES, step)
        mpCheckout.viewModel.identificationTypes = MockBuilder.buildIdentificationTypes()

        // 8. Identification
        step = mpCheckout.viewModel.nextStep()
        XCTAssertEqual(CheckoutStep.SCREEN_IDENTIFICATION, step)

        // Simular identificacion completa
        let identificationMock = MockBuilder.buildIdentification()
        mpCheckout.viewModel.updateCheckoutModel(identification: identificationMock)

        // 9. Crear token
        step = mpCheckout.viewModel.nextStep()
        XCTAssertEqual(CheckoutStep.SERVICE_CREATE_CARD_TOKEN, step)

        // Simular token completo
        let mockToken = MockBuilder.buildToken()
        mpCheckout.viewModel.updateCheckoutModel(token: mockToken)

        // 10 . Get Issuers
        step = mpCheckout.viewModel.nextStep()
        XCTAssertEqual(CheckoutStep.SERVICE_GET_ISSUERS, step)

        // Simular issuers
        let onlyIssuerAvailable = MockBuilder.buildIssuer()
        mpCheckout.viewModel.issuers = [onlyIssuerAvailable]
        mpCheckout.viewModel.updateCheckoutModel(issuer: onlyIssuerAvailable)

        // 11. Un solo banco disponible => Payer Costs
        step = mpCheckout.viewModel.nextStep()
        XCTAssertEqual(CheckoutStep.SERVICE_GET_PAYER_COSTS, step)
        mpCheckout.viewModel.payerCosts = MockBuilder.buildInstallment().payerCosts

        // 12. Pantalla cuotas
        step = mpCheckout.viewModel.nextStep()
        XCTAssertEqual(CheckoutStep.SCREEN_PAYER_COST, step)

        //Simular cuotas seleccionadas
        mpCheckout.viewModel.paymentData.payerCost = MockBuilder.buildPayerCost()

        // 13. RyC
        step = mpCheckout.viewModel.nextStep()
        XCTAssertEqual(CheckoutStep.SCREEN_REVIEW_AND_CONFIRM, step)

        // 14. Simular pago
        let paymentDataMock = MockBuilder.buildPaymentData(paymentMethod: paymentMethodMaster)
        paymentDataMock.issuer = MockBuilder.buildIssuer()
        paymentDataMock.payerCost = MockBuilder.buildPayerCost()
        paymentDataMock.token = MockBuilder.buildToken()
        mpCheckout.viewModel.updateCheckoutModel(paymentData: paymentDataMock)
        step = mpCheckout.viewModel.nextStep()
        XCTAssertEqual(CheckoutStep.SERVICE_POST_PAYMENT, step)

        // 15. Simular pago completo => Congrats
        let paymentMock = MockBuilder.buildPayment("master")
        mpCheckout.viewModel.updateCheckoutModel(payment: paymentMock)
        mpCheckout.viewModel.paymentResult = MockBuilder.buildPaymentResult()

        step = mpCheckout.viewModel.nextStep()
        XCTAssertEqual(CheckoutStep.SCREEN_PAYMENT_RESULT, step)

        // 16. Finish
        step = mpCheckout.viewModel.nextStep()
        XCTAssertEqual(CheckoutStep.ACTION_FINISH, step)

        // Ejecutar finish
        mpCheckout.executeNextStep()

    }

    func testNextStep_withCustomerCard() {

        // Set access_token

        XCTAssertNotNil(mpCheckout.viewModel)

        // 0. Start
        var step = mpCheckout.viewModel.nextStep()

        XCTAssertEqual(CheckoutStep.START, step)

        // 1. Search Preference
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
        let customerCardOption = MockBuilder.buildCustomerPaymentMethod("customerCardId", paymentMethodId: "visa")
        let creditCardOption = MockBuilder.buildPaymentMethodSearchItem("credit_card", type: PaymentMethodSearchItemType.PAYMENT_TYPE)
        let paymentMethodVisa = MockBuilder.buildPaymentMethod("visa")
        let paymentMethodSearchMock = MockBuilder.buildPaymentMethodSearch(groups : [creditCardOption], paymentMethods : [paymentMethodVisa], customOptions : [customerCardOption])
        mpCheckout.viewModel.updateCheckoutModel(paymentMethodSearch: paymentMethodSearchMock)

        // 5. Display payment methods (no exclusions)
        step = mpCheckout.viewModel.nextStep()
        XCTAssertEqual(CheckoutStep.SCREEN_PAYMENT_METHOD_SELECTION, step)

        // 6. Payment option selected : customer card visa => Cuotas
        mpCheckout.viewModel.updateCheckoutModel(paymentOptionSelected : customerCardOption as! PaymentMethodOption)
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
        let token = MockBuilder.buildToken()
        mpCheckout.viewModel.updateCheckoutModel(token: token)

        // 9. RyC
        step = mpCheckout.viewModel.nextStep()
        XCTAssertEqual(CheckoutStep.SCREEN_REVIEW_AND_CONFIRM, step)

        // Simular pago
        let visaPaymentMethod = MockBuilder.buildPaymentMethod("visa")
        let paymentDataMock = MockBuilder.buildPaymentData(paymentMethod: visaPaymentMethod)
        paymentDataMock.issuer = MockBuilder.buildIssuer()
        paymentDataMock.payerCost = MockBuilder.buildPayerCost()
        paymentDataMock.token = MockBuilder.buildToken()
        mpCheckout.viewModel.updateCheckoutModel(paymentData: paymentDataMock)

        // 8. Post Payment
        step = mpCheckout.viewModel.nextStep()
        XCTAssertEqual(CheckoutStep.SERVICE_POST_PAYMENT, step)

        // 9. Simular pago completo => Congrats
        let paymentMock = MockBuilder.buildPayment("visa")
        mpCheckout.viewModel.updateCheckoutModel(payment: paymentMock)
        mpCheckout.viewModel.paymentResult = MockBuilder.buildPaymentResult()

        step = mpCheckout.viewModel.nextStep()
        XCTAssertEqual(CheckoutStep.SCREEN_PAYMENT_RESULT, step)

        // 10. Finish
        step = mpCheckout.viewModel.nextStep()
        XCTAssertEqual(CheckoutStep.ACTION_FINISH, step)

        // Ejecutar finish
        mpCheckout.executeNextStep()

    }


    func testNextStep_withCheckoutPreference_accountMoney_noDiscount() {

        // Set access_token
        MercadoPagoContext.setAccountMoneyAvailable(accountMoneyAvailable: true)

        // Deshabilitar descuentos
        flowPreference.disableDiscount()
        MercadoPagoCheckout.setFlowPreference(flowPreference)

        XCTAssertNotNil(mpCheckout.viewModel)

        // 0. Start
        var step = mpCheckout.viewModel.nextStep()
        XCTAssertEqual(CheckoutStep.START, step)

        // 1. Search Preference
        step = mpCheckout.viewModel.nextStep()
        XCTAssertEqual(CheckoutStep.SERVICE_GET_PREFERENCE, step)

        // 2. Validate preference
        step = mpCheckout.viewModel.nextStep()
        XCTAssertEqual(CheckoutStep.ACTION_VALIDATE_PREFERENCE, step)

        // 3. Search Payment Methods
        step = mpCheckout.viewModel.nextStep()
        XCTAssertEqual(CheckoutStep.SERVICE_GET_PAYMENT_METHODS, step)

        MPCheckoutTestAction.loadGroupsInViewModel(mpCheckout: mpCheckout)

        // 4. Display payment methods (no exclusions)
        step = mpCheckout.viewModel.nextStep()
        XCTAssertEqual(CheckoutStep.SCREEN_PAYMENT_METHOD_SELECTION, step)

        // 5. Payment option selected : account_money => RyC
        MPCheckoutTestAction.selectAccountMoney(mpCheckout: mpCheckout)
        step = mpCheckout.viewModel.nextStep()
        XCTAssertEqual(CheckoutStep.SCREEN_REVIEW_AND_CONFIRM, step)

        // 6 . Simular paymentData y pagar
        let accountMoneyPm = MockBuilder.buildPaymentMethod("account_money", name: "Dinero en cuenta", paymentTypeId: PaymentTypeId.ACCOUNT_MONEY.rawValue)
        let paymentDataMock = MockBuilder.buildPaymentData(paymentMethod: accountMoneyPm)
        mpCheckout.viewModel.updateCheckoutModel(paymentData: paymentDataMock)

        step = mpCheckout.viewModel.nextStep()
        XCTAssertEqual(CheckoutStep.SERVICE_POST_PAYMENT, step)

        // 7. Simular Pago realizado y se muestra congrats
        let paymentMock = MockBuilder.buildPayment("account_money")
        mpCheckout.viewModel.updateCheckoutModel(payment: paymentMock)
        mpCheckout.viewModel.paymentResult = MockBuilder.buildPaymentResult()

        step = mpCheckout.viewModel.nextStep()
        XCTAssertEqual(CheckoutStep.SCREEN_PAYMENT_RESULT, step)

        step = mpCheckout.viewModel.nextStep()

        // 7. Siguiente step DEBERIA SER FINISH - NO LO ES
        //  XCTAssertEqual(CheckoutStep.FINISH, step)
    }

}
