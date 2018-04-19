//
//  MercadoPagoCheckoutViewModelTest.swift
//  MercadoPagoSDK
//
//  Created by Maria cristina rodriguez on 3/9/17.
//  Copyright © 2017 MercadoPago. All rights reserved.
//

import UIKit
import XCTest

class MercadoPagoCheckoutViewModelTest: BaseTest {

    let flowPreference = FlowPreference()
    override func setUp() {
        self.continueAfterFailure = false
        MercadoPagoContext.setAccountMoneyAvailable(accountMoneyAvailable: true)
        // Habilitar RyC para estos tests en particular
        flowPreference.enableReviewAndConfirmScreen()
        MercadoPagoCheckout.setFlowPreference(flowPreference)
    }

    override func tearDown() {
        super.tearDown()
        MercadoPagoCheckoutViewModel.flowPreference = FlowPreference()
    }

    func testNextStep_withCheckoutPreference_accountMoney() {

        // Set access_token
        MercadoPagoContext.setAccountMoneyAvailable(accountMoneyAvailable: true)
        let checkoutPreference = MockBuilder.buildCheckoutPreference()
        let mpCheckout = MercadoPagoCheckout(publicKey: "public_key", accessToken: "access_token", checkoutPreference: checkoutPreference, navigationController: UINavigationController())
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

    func testFilterPaymentMethods() {

        // Set access_token
        MercadoPagoContext.setAccountMoneyAvailable(accountMoneyAvailable: true)
        let checkoutPreference = MockBuilder.buildCheckoutPreference()
        let mpCheckout = MercadoPagoCheckout(publicKey: "public_key", accessToken: "access_token", checkoutPreference: checkoutPreference, navigationController: UINavigationController())
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
        mpCheckout.viewModel.paymentOptionSelected = mpCheckout.viewModel.search?.groups[0]
        let pmsForSelectionCards = mpCheckout.viewModel.getPaymentMethodsForSelection()
        XCTAssertEqual(pmsForSelectionCards[0].paymentTypeId, "credit_card")
        XCTAssertEqual(pmsForSelectionCards[1].paymentTypeId, "credit_card")
        XCTAssertEqual(pmsForSelectionCards[0].paymentMethodId, "visa")
        XCTAssertEqual(pmsForSelectionCards[1].paymentMethodId, "master")
        XCTAssertEqual(pmsForSelectionCards.count, 2)

        mpCheckout.viewModel.paymentOptionSelected = mpCheckout.viewModel.search?.groups[1]
        let pmsForSelectionOff = mpCheckout.viewModel.getPaymentMethodsForSelection()
        XCTAssertEqual(pmsForSelectionOff[0].paymentTypeId, "off")
        XCTAssertEqual(pmsForSelectionOff[1].paymentTypeId, "off")
        XCTAssertEqual(pmsForSelectionOff[0].paymentMethodId, "ticket")
        XCTAssertEqual(pmsForSelectionOff[1].paymentMethodId, "ticket 2")
        XCTAssertEqual(pmsForSelectionOff.count, 2)
    }
    func testPayerCostWithDiscount() {
        let viewModel = PayerCostAdditionalStepViewModel(amount: 1000, token: nil, paymentMethod: PaymentMethod(), dataSource: [Cellable](), discount: MockBuilder.buildDiscount(), email: "dummy@mail.com", mercadoPagoServicesAdapter: MercadoPagoServicesAdapter())
        let payerCostStep = AdditionalStepViewController(viewModel: viewModel, callback: {_ in })
        XCTAssertNotNil(payerCostStep.viewModel.discount)
    }

    func testNextStep_withCheckoutPreference_masterCreditCard() {

        // Set access_token
        MercadoPagoContext.setAccountMoneyAvailable(accountMoneyAvailable: true)
        let checkoutPreference = MockBuilder.buildCheckoutPreference()
        let mpCheckout = MercadoPagoCheckout(publicKey: "public_key", accessToken: "access_token", checkoutPreference: checkoutPreference, navigationController: UINavigationController())
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

    func testNextStep_withCheckoutPreference_accountMoney_noRyC() {

        // Set access_token
        MercadoPagoContext.setAccountMoneyAvailable(accountMoneyAvailable: true)

        // Deshabilitar ryc
        let fp = FlowPreference()
        fp.disableReviewAndConfirmScreen()
        MercadoPagoCheckout.setFlowPreference(fp)

        // Setear paymentDataCallback
        let expectPaymentDataCallback = expectation(description: "paymentDataCallback")
        MercadoPagoCheckout.setPaymentDataCallback { (paymentData: PaymentData) in
            XCTAssertEqual(paymentData.paymentMethod!.paymentMethodId, "account_money")
            XCTAssertNil(paymentData.issuer)
            XCTAssertNil(paymentData.payerCost)
            XCTAssertNil(paymentData.token)
            expectPaymentDataCallback.fulfill()
        }

        let checkoutPreference = MockBuilder.buildCheckoutPreference()
        let mpCheckout = MercadoPagoCheckout(publicKey: "public_key", accessToken: "access_token", checkoutPreference: checkoutPreference, navigationController: UINavigationController())

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

        // 5. Display payment methods (no exclusions)
        step = mpCheckout.viewModel.nextStep()
        XCTAssertEqual(CheckoutStep.SCREEN_PAYMENT_METHOD_SELECTION, step)

        // 6. Payment option selected : account_money => paymentDataCallback
        MPCheckoutTestAction.selectAccountMoney(mpCheckout: mpCheckout)
        step = mpCheckout.viewModel.nextStep()
        XCTAssertEqual(CheckoutStep.ACTION_FINISH, step)

        // 7. Execute finish to call paymentDataCallback
        mpCheckout.executeNextStep()

        waitForExpectations(timeout: 10, handler: nil)

    }

    func testNextStep_withPaymentDataComplete() {

        // Set access_token
        MercadoPagoContext.setAccountMoneyAvailable(accountMoneyAvailable: true)

        let checkoutPreference = MockBuilder.buildCheckoutPreference()
        let accountMoneyPaymentMethod = MockBuilder.buildPaymentMethod("account_money", paymentTypeId: "account_money")
        let paymentDataAccountMoney = MockBuilder.buildPaymentData(paymentMethod: accountMoneyPaymentMethod)

        let mpCheckout = MercadoPagoCheckout(publicKey: "public_key", accessToken: "access_token", checkoutPreference: checkoutPreference, paymentData: paymentDataAccountMoney, navigationController: UINavigationController())
        XCTAssertNotNil(mpCheckout.viewModel)

        // 0. Start
        var step = mpCheckout.viewModel.nextStep()
        XCTAssertEqual(CheckoutStep.SERVICE_GET_PREFERENCE, step)

        // 2. Validate preference
        step = mpCheckout.viewModel.nextStep()
        XCTAssertEqual(CheckoutStep.ACTION_VALIDATE_PREFERENCE, step)

        // 3. Search Payment Methods
        step = mpCheckout.viewModel.nextStep()
        XCTAssertEqual(CheckoutStep.SERVICE_GET_PAYMENT_METHODS, step)

        MPCheckoutTestAction.loadGroupsInViewModel(mpCheckout: mpCheckout)

        // 4. PaymentData complete => RyC
        step = mpCheckout.viewModel.nextStep()
        XCTAssertEqual(CheckoutStep.SCREEN_REVIEW_AND_CONFIRM, step)

        // 5. Realizar pago
        mpCheckout.viewModel.updateCheckoutModel(paymentData: paymentDataAccountMoney)
        step = mpCheckout.viewModel.nextStep()
        XCTAssertEqual(CheckoutStep.SERVICE_POST_PAYMENT, step)

        // 6. Simular Pago realizado y se muestra congrats
        let paymentMock = MockBuilder.buildPayment("account_money")
        mpCheckout.viewModel.updateCheckoutModel(payment: paymentMock)
        mpCheckout.viewModel.paymentResult = MockBuilder.buildPaymentResult()

        step = mpCheckout.viewModel.nextStep()
        XCTAssertEqual(CheckoutStep.SCREEN_PAYMENT_RESULT, step)

        // 6. Finish
        step = mpCheckout.viewModel.nextStep()
        XCTAssertEqual(CheckoutStep.ACTION_FINISH, step)

        // Ejecutar finish
        mpCheckout.executeNextStep()

    }

    func testNextStep_withPaymentResult() {

        // Set access_token

        // Init checkout
        let checkoutPreference = MockBuilder.buildCheckoutPreference()
        let visaPaymentMethod = MockBuilder.buildPaymentMethod("visa")
        let paymentDataVisa = MockBuilder.buildPaymentData(paymentMethod: visaPaymentMethod)

        let paymentResult = PaymentResult(status: "status", statusDetail: "statusDetail", paymentData: paymentDataVisa, payerEmail: "payerEmail", paymentId: "id", statementDescription: "description")

        let mpCheckout = MercadoPagoCheckout(publicKey: "public_key", accessToken: "access_token", checkoutPreference: checkoutPreference, paymentData: paymentDataVisa, paymentResult: paymentResult, navigationController: UINavigationController())
        XCTAssertNotNil(mpCheckout.viewModel)

        // 1. Search Preference
        var step = mpCheckout.viewModel.nextStep()

        XCTAssertEqual(CheckoutStep.SERVICE_GET_PREFERENCE, step)

        MPCheckoutTestAction.loadGroupsInViewModel(mpCheckout: mpCheckout)

        // 3. Muestra congrats
        step = mpCheckout.viewModel.nextStep()
        XCTAssertEqual(CheckoutStep.SCREEN_PAYMENT_RESULT, step)

        // 4. Finish
        step = mpCheckout.viewModel.nextStep()
        XCTAssertEqual(CheckoutStep.ACTION_FINISH, step)

        // Ejecutar finish
        mpCheckout.executeNextStep()

    }

    func testNextStep_withCustomerCard() {

        // Set access_token

        let checkoutPreference = MockBuilder.buildCheckoutPreference()

        let mpCheckout = MercadoPagoCheckout(publicKey: "public_key", accessToken: "access_token", checkoutPreference: checkoutPreference, navigationController: UINavigationController())
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
        let fp = FlowPreference()
        fp.disableDiscount()
        MercadoPagoCheckout.setFlowPreference(fp)

        let checkoutPreference = MockBuilder.buildCheckoutPreference()
        let mpCheckout = MercadoPagoCheckout(publicKey: "PK_MLA", accessToken: "access_token", checkoutPreference: checkoutPreference, navigationController: UINavigationController())
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

    func testNextStep_withCheckoutPreference_accountMoney_withDiscount() {

        // Set access_token
        MercadoPagoContext.setAccountMoneyAvailable(accountMoneyAvailable: true)

        // Deshabilitar descuentos
        let fp = FlowPreference()
        fp.disableDiscount()
        MercadoPagoCheckout.setFlowPreference(fp)

        let checkoutPreference = MockBuilder.buildCheckoutPreference()

        let discount = DiscountCoupon(discountId: 123)
        discount.name = "Patito Off"
        discount.coupon_amount = "30"
        discount.amount_off = "30"
        discount.currency_id = "ARS"
        discount.concept = "Descuento de patito"
        discount.amountWithoutDiscount = 300

        let mpCheckout = MercadoPagoCheckout(publicKey: "PK_MLA", accessToken: "access_token", checkoutPreference: checkoutPreference, discount: discount, navigationController: UINavigationController())
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

    /****************************************************/
    /********** ViewModel Builders Tests ****************/
    /****************************************************/

    func testHasError() {
        let checkoutPreference = MockBuilder.buildCheckoutPreference()
        let mpCheckout = MercadoPagoCheckout(publicKey: "PK_MLA", accessToken: "", checkoutPreference: checkoutPreference, navigationController: UINavigationController())

        XCTAssertFalse(mpCheckout.viewModel.hasError())

        let error = MPSDKError()
        MercadoPagoCheckoutViewModel.error = error

        XCTAssertTrue(mpCheckout.viewModel.hasError())

        MercadoPagoCheckoutViewModel.error = nil

    }

    func testPaymentVaultViewModel() {
        let checkoutPreference = MockBuilder.buildCheckoutPreference()
        let mpCheckout = MercadoPagoCheckout(publicKey: "PK_MLA", accessToken: "", checkoutPreference: checkoutPreference, navigationController: UINavigationController())

        MPCheckoutTestAction.loadGroupsInViewModel(mpCheckout: mpCheckout)

        let paymentVaultVM = mpCheckout.viewModel.paymentVaultViewModel()

        XCTAssertTrue(paymentVaultVM.isKind(of: PaymentVaultViewModel.self))
        XCTAssertEqual(paymentVaultVM.amount, checkoutPreference.getAmount())
        XCTAssertEqual(paymentVaultVM.paymentPreference, checkoutPreference.paymentPreference)
        XCTAssertEqual(paymentVaultVM.paymentPreference, checkoutPreference.paymentPreference)
    }

    func testIssuerViewModel() {
        let checkoutPreference = MockBuilder.buildCheckoutPreference()
        let mpCheckoutViewModel  = MercadoPagoCheckoutViewModel(checkoutPreference: checkoutPreference, paymentData: nil, paymentResult: nil, discount: nil)

        // Simular installments
        let issuer = MockBuilder.buildIssuer()
        mpCheckoutViewModel.issuers = [issuer]

        let issuerVM = mpCheckoutViewModel.issuerViewModel()
        XCTAssertTrue(issuerVM.isKind(of: IssuerAdditionalStepViewModel.self))
        XCTAssertEqual(issuerVM.amount, checkoutPreference.getAmount())

    }

    func testPayerCostViewModel() {
        let checkoutPreference = MockBuilder.buildCheckoutPreference()
        let mpCheckoutViewModel  = MercadoPagoCheckoutViewModel(checkoutPreference: checkoutPreference, paymentData: nil, paymentResult: nil, discount: nil)

        let issuer = MockBuilder.buildIssuer()
        mpCheckoutViewModel.issuers = [issuer]

        mpCheckoutViewModel.payerCosts = [MockBuilder.buildPayerCost()]

        let payerCostVM = mpCheckoutViewModel.payerCostViewModel()
        XCTAssertTrue(payerCostVM.isKind(of: PayerCostAdditionalStepViewModel.self))
        XCTAssertEqual(payerCostVM.amount, checkoutPreference.getAmount())

    }

    /************************************************************/
    /********** Update View Model Behavior Tests ****************/
    /************************************************************/

    func testUpdateCheckoutModel_paymentMethodSearch() {
        let checkoutPreference = MockBuilder.buildCheckoutPreference()
        let mpCheckoutViewModel  = MercadoPagoCheckoutViewModel(checkoutPreference: checkoutPreference, paymentData: nil, paymentResult: nil, discount: nil)

        let accountMoneyOption = MockBuilder.buildCustomerPaymentMethod("account_money", paymentMethodId: "account_money")
        let customerCardOption = MockBuilder.buildCustomerPaymentMethod("customerCardId", paymentMethodId: "visa")
        let creditCardOption = MockBuilder.buildPaymentMethodSearchItem("credit_card", type: PaymentMethodSearchItemType.PAYMENT_TYPE)
        let paymentMethodVisa = MockBuilder.buildPaymentMethod("visa")
        let paymentMethodAM = MockBuilder.buildPaymentMethod("account_money", paymentTypeId: "account_money")

        let paymentMethodSearchMock = MockBuilder.buildPaymentMethodSearch(groups: [creditCardOption], paymentMethods: [paymentMethodVisa, paymentMethodAM], customOptions: [customerCardOption, accountMoneyOption])

        mpCheckoutViewModel.updateCheckoutModel(paymentMethodSearch: paymentMethodSearchMock)

        XCTAssertNotNil(mpCheckoutViewModel.search)
        XCTAssertEqual(mpCheckoutViewModel.search, paymentMethodSearchMock)
        //   XCTAssertEqual(mpCheckoutViewModel.rootPaymentMethodOptions, mpCheckoutViewModel.paymentMethodOptions)
        XCTAssertEqual(mpCheckoutViewModel.availablePaymentMethods!, paymentMethodSearchMock.paymentMethods)
        //   XCTAssertEqual(mpCheckoutViewModel.customPaymentOptions, paymentMethodSearchMock.customerPaymentMethods)

    }

    func testUpdateCheckoutModel_paymentMethods() {
        let checkoutPreference = MockBuilder.buildCheckoutPreference()
        let mpCheckoutViewModel  = MercadoPagoCheckoutViewModel(checkoutPreference: checkoutPreference, paymentData: nil, paymentResult: nil, discount: nil)
        let paymentMethods = [MockBuilder.buildPaymentMethod("visa"), MockBuilder.buildPaymentMethod("amex")]

        mpCheckoutViewModel.updateCheckoutModel(paymentMethods: paymentMethods, cardToken: nil)

        XCTAssertEqual(mpCheckoutViewModel.paymentData.paymentMethod, paymentMethods[0])
        XCTAssertNil(mpCheckoutViewModel.cardToken)

        let cardToken = MockBuilder.buildCardToken()
        mpCheckoutViewModel.updateCheckoutModel(paymentMethods: paymentMethods, cardToken: cardToken)
        XCTAssertEqual(mpCheckoutViewModel.paymentData.paymentMethod, paymentMethods[0])
        XCTAssertEqual(mpCheckoutViewModel.cardToken, cardToken)

    }

    func testUpdateCheckoutModel_paymentMethodSearchOneOption() {
        let checkoutPreference = MockBuilder.buildCheckoutPreference()
        let mpCheckoutViewModel  = MercadoPagoCheckoutViewModel(checkoutPreference: checkoutPreference, paymentData: nil, paymentResult: nil, discount: nil)

        let creditCardOption = MockBuilder.buildPaymentMethodSearchItem("credit_card", type: PaymentMethodSearchItemType.PAYMENT_TYPE)
        let paymentMethodVisa = MockBuilder.buildPaymentMethod("visa")

        let paymentMethodSearchMock = MockBuilder.buildPaymentMethodSearch(groups: [creditCardOption], paymentMethods: [paymentMethodVisa])

        mpCheckoutViewModel.updateCheckoutModel(paymentMethodSearch: paymentMethodSearchMock)

        XCTAssertNotNil(mpCheckoutViewModel.search)
        XCTAssertEqual(mpCheckoutViewModel.search, paymentMethodSearchMock)
        //   XCTAssertEqual(mpCheckoutViewModel.rootPaymentMethodOptions, mpCheckoutViewModel.paymentMethodOptions)
        XCTAssertEqual(mpCheckoutViewModel.availablePaymentMethods!, paymentMethodSearchMock.paymentMethods)
        XCTAssertNil(mpCheckoutViewModel.customPaymentOptions)

        XCTAssertEqual(mpCheckoutViewModel.paymentOptionSelected!.getId(), creditCardOption.getId())

    }

    func testUpdateCheckoutModel_paymentMethod() {
        let paymentMethod = MockBuilder.buildPaymentMethod("paymentMethodId")
        let checkoutPreference = MockBuilder.buildCheckoutPreference()
        let mpCheckoutViewModel  = MercadoPagoCheckoutViewModel(checkoutPreference: checkoutPreference, paymentData: nil, paymentResult: nil, discount: nil)
        mpCheckoutViewModel.updateCheckoutModel(paymentMethod: paymentMethod)

        XCTAssertNotNil(mpCheckoutViewModel.paymentData.paymentMethod)
        XCTAssertEqual(mpCheckoutViewModel.paymentData.paymentMethod, paymentMethod)
    }

    func testUpdateCheckoutModel_paymentMethodSearchCustomOption() {
        let checkoutPreference = MockBuilder.buildCheckoutPreference()
        let mpCheckoutViewModel  = MercadoPagoCheckoutViewModel(checkoutPreference: checkoutPreference, paymentData: nil, paymentResult: nil, discount: nil)

        let accountMoneyOption = MockBuilder.buildCustomerPaymentMethod("account_money", paymentMethodId: "account_money")
        let paymentMethodAM = MockBuilder.buildPaymentMethod("account_money", paymentTypeId: "account_money")

        let paymentMethodSearchMock = MockBuilder.buildPaymentMethodSearch(groups: nil, paymentMethods: [paymentMethodAM], customOptions: [accountMoneyOption])

        mpCheckoutViewModel.updateCheckoutModel(paymentMethodSearch: paymentMethodSearchMock)

        XCTAssertNotNil(mpCheckoutViewModel.search)
        XCTAssertEqual(mpCheckoutViewModel.search, paymentMethodSearchMock)
        //   XCTAssertEqual(mpCheckoutViewModel.rootPaymentMethodOptions, mpCheckoutViewModel.paymentMethodOptions)
        XCTAssertEqual(mpCheckoutViewModel.availablePaymentMethods!, paymentMethodSearchMock.paymentMethods)

        XCTAssertEqual(mpCheckoutViewModel.paymentOptionSelected!.getId(), accountMoneyOption.getCardId())

    }

    func testUpdateCheckoutModel_paymentData() {
        let checkoutPreference = MockBuilder.buildCheckoutPreference()
        let mpCheckoutViewModel  = MercadoPagoCheckoutViewModel(checkoutPreference: checkoutPreference, paymentData: nil, paymentResult: nil, discount: nil)

        let paymentMethod = MockBuilder.buildPaymentMethod("visa")
        let paymentData = MockBuilder.buildPaymentData(paymentMethod: paymentMethod)
        mpCheckoutViewModel.updateCheckoutModel(paymentData: paymentData)

        XCTAssertTrue(mpCheckoutViewModel.readyToPay)

        paymentData.paymentMethod = nil
        mpCheckoutViewModel.updateCheckoutModel(paymentData: paymentData)

        XCTAssertNil(mpCheckoutViewModel.paymentOptionSelected)
        XCTAssertNil(mpCheckoutViewModel.search)
        XCTAssertNil(mpCheckoutViewModel.issuers)
        XCTAssertNil(mpCheckoutViewModel.cardToken)
        XCTAssertTrue(mpCheckoutViewModel.rootVC)
        XCTAssertFalse(mpCheckoutViewModel.initWithPaymentData)

    }

    func testHandleCustomerPaymentMethod() {
        let checkoutPreference = MockBuilder.buildCheckoutPreference()
        let mpCheckoutViewModel  = MercadoPagoCheckoutViewModel(checkoutPreference: checkoutPreference, paymentData: nil, paymentResult: nil, discount: nil)

        MPCheckoutTestAction.loadGroupsInViewModel(mpCheckoutViewModel: mpCheckoutViewModel)

        MPCheckoutTestAction.selectAccountMoney(mpCheckoutViewModel: mpCheckoutViewModel)

        mpCheckoutViewModel.handleCustomerPaymentMethod()

        XCTAssertEqual(mpCheckoutViewModel.paymentData.paymentMethod!.paymentMethodId, "account_money")

        MPCheckoutTestAction.selectCustomerCardOption(mpCheckoutViewModel: mpCheckoutViewModel)

        mpCheckoutViewModel.handleCustomerPaymentMethod()

        XCTAssertEqual(mpCheckoutViewModel.paymentData.paymentMethod!.paymentMethodId, "visa")
    }

    func testResetGroupSelection() {
        let checkoutPreference = MockBuilder.buildCheckoutPreference()
        let mpCheckoutViewModel  = MercadoPagoCheckoutViewModel(checkoutPreference: checkoutPreference, paymentData: nil, paymentResult: nil, discount: nil)

        MPCheckoutTestAction.loadGroupsInViewModel(mpCheckoutViewModel: mpCheckoutViewModel)

        MPCheckoutTestAction.selectAccountMoney(mpCheckoutViewModel: mpCheckoutViewModel)

        mpCheckoutViewModel.resetGroupSelection()

        XCTAssertNil(mpCheckoutViewModel.paymentOptionSelected)

    }

    func testResetInformation() {
        let checkoutPreference = MockBuilder.buildCheckoutPreference()
        let mpCheckoutViewModel  = MercadoPagoCheckoutViewModel(checkoutPreference: checkoutPreference, paymentData: nil, paymentResult: nil, discount: nil)

        MPCheckoutTestAction.loadGroupsInViewModel(mpCheckoutViewModel: mpCheckoutViewModel)

        MPCheckoutTestAction.selectAccountMoney(mpCheckoutViewModel: mpCheckoutViewModel)

        mpCheckoutViewModel.resetInformation()

        XCTAssertNil(mpCheckoutViewModel.cardToken)
        XCTAssertNil(mpCheckoutViewModel.issuers)
        XCTAssertNil(mpCheckoutViewModel.payerCosts)
        XCTAssertNil(mpCheckoutViewModel.paymentData.paymentMethod)
        XCTAssertNil(mpCheckoutViewModel.paymentData.issuer)
        XCTAssertNil(mpCheckoutViewModel.paymentData.payerCost)
        XCTAssertNil(mpCheckoutViewModel.paymentData.token)

    }

    func testCleanPaymentResult() {
        let checkoutPreference = MockBuilder.buildCheckoutPreference()
        let paymentResult = MockBuilder.buildPaymentResult("status", paymentMethodId: "paymentMethodId")
        let mpCheckoutViewModel  = MercadoPagoCheckoutViewModel(checkoutPreference: checkoutPreference, paymentData: nil, paymentResult: paymentResult, discount: nil)

        mpCheckoutViewModel.cleanPaymentResult()

        XCTAssertNil(mpCheckoutViewModel.payment)
        XCTAssertNil(mpCheckoutViewModel.paymentResult)
        XCTAssertFalse(mpCheckoutViewModel.readyToPay)

    }

    func testPrepareForClone() {

        let checkoutPreference = MockBuilder.buildCheckoutPreference()
        let paymentResult = MockBuilder.buildPaymentResult("status", paymentMethodId: "paymentMethodId")
        let mpCheckoutViewModel  = MercadoPagoCheckoutViewModel(checkoutPreference: checkoutPreference, paymentData: nil, paymentResult: paymentResult, discount: nil)

        mpCheckoutViewModel.prepareForClone()

        XCTAssertFalse(mpCheckoutViewModel.isCheckoutComplete())
        XCTAssertNil(mpCheckoutViewModel.payment)
        XCTAssertNil(mpCheckoutViewModel.paymentResult)
        XCTAssertFalse(mpCheckoutViewModel.readyToPay)
    }

    func testPrepareForNewSelection() {
        let checkoutPreference = MockBuilder.buildCheckoutPreference()
        let paymentResult = MockBuilder.buildPaymentResult("status", paymentMethodId: "paymentMethodId")
        let mpCheckoutViewModel  = MercadoPagoCheckoutViewModel(checkoutPreference: checkoutPreference, paymentData: nil, paymentResult: paymentResult, discount: nil)

        mpCheckoutViewModel.prepareForNewSelection()

        XCTAssertFalse(mpCheckoutViewModel.isCheckoutComplete())

    }

    func testShouldDisplayPaymentResutlWithFlowPreference() {
        let checkoutPreference = MockBuilder.buildCheckoutPreference()
        let paymentResult = MockBuilder.buildPaymentResult("status", paymentMethodId: "paymentMethodId")
        let mpCheckoutViewModel  = MercadoPagoCheckoutViewModel(checkoutPreference: checkoutPreference, paymentData: nil, paymentResult: paymentResult, discount: nil)

        XCTAssert(mpCheckoutViewModel.shouldDisplayPaymentResult())

        flowPreference.disablePaymentResultScreen()
        MercadoPagoCheckout.setFlowPreference(flowPreference)
        XCTAssertFalse(mpCheckoutViewModel.shouldDisplayPaymentResult())

        flowPreference.enablePaymentResultScreen()
        flowPreference.disablePaymentApprovedScreen()
        MercadoPagoCheckout.setFlowPreference(flowPreference)
        XCTAssert(mpCheckoutViewModel.shouldDisplayPaymentResult())

        mpCheckoutViewModel.paymentResult!.status = "approved"
        XCTAssertFalse(mpCheckoutViewModel.shouldDisplayPaymentResult())

        flowPreference.enablePaymentResultScreen()
        flowPreference.enablePaymentApprovedScreen()
        flowPreference.disablePaymentPendingScreen()
        MercadoPagoCheckout.setFlowPreference(flowPreference)
        XCTAssert(mpCheckoutViewModel.shouldDisplayPaymentResult())

        mpCheckoutViewModel.paymentResult!.status = "in_process"
        XCTAssertFalse(mpCheckoutViewModel.shouldDisplayPaymentResult())

        flowPreference.enablePaymentResultScreen()
        flowPreference.enablePaymentApprovedScreen()
        flowPreference.enablePaymentPendingScreen()
        flowPreference.disablePaymentRejectedScreen()
        MercadoPagoCheckout.setFlowPreference(flowPreference)
        XCTAssert(mpCheckoutViewModel.shouldDisplayPaymentResult())

        mpCheckoutViewModel.paymentResult!.status = "rejected"
        XCTAssertFalse(mpCheckoutViewModel.shouldDisplayPaymentResult())
    }

    func testEntireFlowWithCustomerCardWithESErrorInPaymentAndInTokenCreation() {

        var mpCheckout: MercadoPagoCheckout!
        let checkoutPreference = MockBuilder.buildCheckoutPreference()
        mpCheckout = MercadoPagoCheckout(publicKey: "public_key", accessToken: "access_token", checkoutPreference: checkoutPreference, navigationController: UINavigationController())
        mpCheckout.viewModel.mpESCManager = MercadoPagoESCImplementationTest()

        let flowPreference = FlowPreference()
        flowPreference.enableESC()

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

}
