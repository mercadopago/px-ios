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
    
    override func setUp() {
        self.continueAfterFailure = false
    }
    
    override func tearDown() {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
        super.tearDown()
    }
    
    
    func testNextStep_withCheckoutPreference_accountMoney() {
        
        // Set access_token
        MercadoPagoContext.setPayerAccessToken("access_token")
        MercadoPagoContext.setAccountMoneyAvailable(accountMoneyAvailable: true)
        let checkoutPreference = MockBuilder.buildCheckoutPreference()
        let mpCheckout = MercadoPagoCheckout(checkoutPreference: checkoutPreference, navigationController: UINavigationController())
        XCTAssertNotNil(mpCheckout.viewModel)
        
        // 1. Search Preference
        var step = mpCheckout.viewModel.nextStep()
        XCTAssertEqual(CheckoutStep.SEARCH_PREFERENCE, step)
        
        // 2. Search Payment Methods
        step = mpCheckout.viewModel.nextStep()
        XCTAssertEqual(CheckoutStep.SEARCH_PAYMENT_METHODS, step)
        
        MPCheckoutTestAction.loadGroupsInViewModel(mpCheckout: mpCheckout)
        
        // 3. Display payment methods (no exclusions)
        step = mpCheckout.viewModel.nextStep()
        XCTAssertEqual(CheckoutStep.PAYMENT_METHOD_SELECTION, step)
        
        // 4. Payment option selected : account_money => RyC
        MPCheckoutTestAction.selectAccountMoney(mpCheckout: mpCheckout)
        
        step = mpCheckout.viewModel.nextStep()
        XCTAssertEqual(CheckoutStep.REVIEW_AND_CONFIRM, step)
        
        // 5 . Simular paymentData y pagar
        let accountMoneyPm = MockBuilder.buildPaymentMethod("account_money", name: "Dinero en cuenta", paymentTypeId: PaymentTypeId.ACCOUNT_MONEY.rawValue)
        let paymentDataMock = MockBuilder.buildPaymentData(paymentMethod: accountMoneyPm)
        mpCheckout.viewModel.updateCheckoutModel(paymentData: paymentDataMock)
        
        step = mpCheckout.viewModel.nextStep()
        XCTAssertEqual(CheckoutStep.POST_PAYMENT, step)
        
        // 6. Simular Pago realizado y se muestra congrats
        let paymentMock = MockBuilder.buildPayment("account_money")
        mpCheckout.viewModel.updateCheckoutModel(payment: paymentMock)
        step = mpCheckout.viewModel.nextStep()
        XCTAssertEqual(CheckoutStep.CONGRATS, step)
        
        // 7. Finish
        step = mpCheckout.viewModel.nextStep()
        XCTAssertEqual(CheckoutStep.FINISH, step)
        
      
        
    }
    
    func testNextStep_withCheckoutPreference_masterCreditCard(){
        
        // Set access_token
        MercadoPagoContext.setPayerAccessToken("access_token")
        MercadoPagoContext.setAccountMoneyAvailable(accountMoneyAvailable: true)
        let checkoutPreference = MockBuilder.buildCheckoutPreference()
        let mpCheckout = MercadoPagoCheckout(checkoutPreference: checkoutPreference, navigationController: UINavigationController())
        XCTAssertNotNil(mpCheckout.viewModel)
        
        // 1. Search Preference
        var step = mpCheckout.viewModel.nextStep()
        XCTAssertEqual(CheckoutStep.SEARCH_PREFERENCE, step)
        
        // 2. Search Payment Methods
        step = mpCheckout.viewModel.nextStep()
        XCTAssertEqual(CheckoutStep.SEARCH_PAYMENT_METHODS, step)
        
        MPCheckoutTestAction.loadGroupsInViewModel(mpCheckout: mpCheckout)
        
        // 3. Display payment methods (no exclusions)
        step = mpCheckout.viewModel.nextStep()
        XCTAssertEqual(CheckoutStep.PAYMENT_METHOD_SELECTION, step)
        
        // 4. Payment option selected : tarjeta de credito => Form Tarjeta
        MPCheckoutTestAction.selectCreditCardOption(mpCheckout: mpCheckout)
        step = mpCheckout.viewModel.nextStep()
        XCTAssertEqual(CheckoutStep.CARD_FORM, step)
        
        // Simular paymentMethod completo
        let paymentMethodMaster = MockBuilder.buildPaymentMethod("master")
        // Se necesita identification input
        paymentMethodMaster.additionalInfoNeeded = ["cardholder_identification_number"]
        mpCheckout.viewModel.paymentData.paymentMethod = paymentMethodMaster
        
        let cardToken = MockBuilder.buildCardToken()
        mpCheckout.viewModel.cardToken = cardToken
        
        // 5. Identification
        step = mpCheckout.viewModel.nextStep()
        XCTAssertEqual(CheckoutStep.IDENTIFICATION, step)
        
        // Simular identificacion completa
        let identificationMock = MockBuilder.buildIdentification()
        mpCheckout.viewModel.updateCheckoutModel(identification: identificationMock)
        
        // 6 . Get Issuers
        step = mpCheckout.viewModel.nextStep()
        XCTAssertEqual(CheckoutStep.GET_ISSUERS, step)
        
        // Simular issuers
        let onlyIssuerAvailable = MockBuilder.buildIssuer()
        mpCheckout.viewModel.issuers = [onlyIssuerAvailable]
        mpCheckout.viewModel.updateCheckoutModel(issuer: onlyIssuerAvailable)
        
        // 6. Un solo banco disponible => Payer Costs
        step = mpCheckout.viewModel.nextStep()
        XCTAssertEqual(CheckoutStep.GET_PAYER_COSTS, step)
        mpCheckout.viewModel.installment = MockBuilder.buildInstallment()

        // 7. Pantalla cuotas
        step = mpCheckout.viewModel.nextStep()
        XCTAssertEqual(CheckoutStep.PAYER_COST_SCREEN, step)
        
        //Simular cuotas seleccionadas 
        mpCheckout.viewModel.paymentData.payerCost = MockBuilder.buildPayerCost()
        
        // 8. Crear token
        step = mpCheckout.viewModel.nextStep()
        XCTAssertEqual(CheckoutStep.CREATE_CARD_TOKEN, step)
        
        // Simular token completo
        let mockToken = MockBuilder.buildToken()
        mpCheckout.viewModel.updateCheckoutModel(token: mockToken)
        
        // 8. RyC
        step = mpCheckout.viewModel.nextStep()
        XCTAssertEqual(CheckoutStep.REVIEW_AND_CONFIRM, step)
        
        
        // 9. Simular pago
        let paymentDataMock = MockBuilder.buildPaymentData(paymentMethod: paymentMethodMaster)
        paymentDataMock.issuer = MockBuilder.buildIssuer()
        paymentDataMock.payerCost = MockBuilder.buildPayerCost()
        paymentDataMock.token = MockBuilder.buildToken()
        mpCheckout.viewModel.updateCheckoutModel(paymentData: paymentDataMock)
        step = mpCheckout.viewModel.nextStep()
        XCTAssertEqual(CheckoutStep.POST_PAYMENT, step)
        
        // 10. Simular pago completo => Congrats
        let paymentMock = MockBuilder.buildPayment("master")
        mpCheckout.viewModel.updateCheckoutModel(payment: paymentMock)
        step = mpCheckout.viewModel.nextStep()
        XCTAssertEqual(CheckoutStep.CONGRATS, step)
        
        // 11. Finish
        step = mpCheckout.viewModel.nextStep()
        XCTAssertEqual(CheckoutStep.FINISH, step)
        
        // Ejecutar finish
        mpCheckout.executeNextStep()

    }

    func testNextStep_withCheckoutPreference_accountMoney_noRyC(){
        
        // Set access_token
        MercadoPagoContext.setPayerAccessToken("access_token")
        MercadoPagoContext.setAccountMoneyAvailable(accountMoneyAvailable: true)
        
        // Deshabilitar ryc
        let fp = FlowPreference()
        fp.disableReviewAndConfirmScreen()
        MercadoPagoCheckout.setFlowPreference(fp)
        
        let checkoutPreference = MockBuilder.buildCheckoutPreference()
        let mpCheckout = MercadoPagoCheckout(checkoutPreference: checkoutPreference, navigationController: UINavigationController())
        
        XCTAssertNotNil(mpCheckout.viewModel)
        
        // 1. Search Preference
        var step = mpCheckout.viewModel.nextStep()
        XCTAssertEqual(CheckoutStep.SEARCH_PREFERENCE, step)
        
        // 2. Search Payment Methods
        step = mpCheckout.viewModel.nextStep()
        XCTAssertEqual(CheckoutStep.SEARCH_PAYMENT_METHODS, step)
        
        MPCheckoutTestAction.loadGroupsInViewModel(mpCheckout: mpCheckout)
        
        // 3. Display payment methods (no exclusions)
        step = mpCheckout.viewModel.nextStep()
        XCTAssertEqual(CheckoutStep.PAYMENT_METHOD_SELECTION, step)
        
        // 4. Payment option selected : account_money => paymentDataCallback
        MPCheckoutTestAction.selectAccountMoney(mpCheckout : mpCheckout)
        step = mpCheckout.viewModel.nextStep()
        XCTAssertEqual(CheckoutStep.FINISH, step)

        // Setear paymentDataCallback
        let expectPaymentDataCallback = expectation(description: "paymentDataCallback")
        MercadoPagoCheckout.setPaymentDataCallback { (paymentData : PaymentData) in
            XCTAssertEqual(paymentData.paymentMethod._id, "account_money")
            XCTAssertNil(paymentData.issuer)
            XCTAssertNil(paymentData.payerCost)
            XCTAssertNil(paymentData.token)
            expectPaymentDataCallback.fulfill()
        }
        
        // Ejecutar finish
        mpCheckout.executeNextStep()
        
        waitForExpectations(timeout: 10, handler: nil)
        
    }
    
    func testNextStep_withPaymentDataComplete() {
        
        // Set access_token
        MercadoPagoContext.setPayerAccessToken("access_token")
        MercadoPagoContext.setAccountMoneyAvailable(accountMoneyAvailable: true)
        
        let checkoutPreference = MockBuilder.buildCheckoutPreference()
        let accountMoneyPaymentMethod = MockBuilder.buildPaymentMethod("account_money", paymentTypeId : "account_money")
        let paymentDataAccountMoney = MockBuilder.buildPaymentData(paymentMethod: accountMoneyPaymentMethod)
        
        let mpCheckout = MercadoPagoCheckout(checkoutPreference: checkoutPreference, paymentData : paymentDataAccountMoney, navigationController: UINavigationController())
        XCTAssertNotNil(mpCheckout.viewModel)
        
        // 1. Search Preference
        var step = mpCheckout.viewModel.nextStep()
        XCTAssertEqual(CheckoutStep.SEARCH_PREFERENCE, step)
        
        // 2. Search Payment Methods
        step = mpCheckout.viewModel.nextStep()
        XCTAssertEqual(CheckoutStep.SEARCH_PAYMENT_METHODS, step)

        MPCheckoutTestAction.loadGroupsInViewModel(mpCheckout: mpCheckout)
        
        // 3. PaymentData complete => RyC
        step = mpCheckout.viewModel.nextStep()
        XCTAssertEqual(CheckoutStep.REVIEW_AND_CONFIRM, step)
        
        // 4. Realizar pago
        mpCheckout.viewModel.updateCheckoutModel(paymentData: paymentDataAccountMoney)
        step = mpCheckout.viewModel.nextStep()
        XCTAssertEqual(CheckoutStep.POST_PAYMENT, step)
        
        
        // 5. Simular Pago realizado y se muestra congrats
        let paymentMock = MockBuilder.buildPayment("account_money")
        mpCheckout.viewModel.updateCheckoutModel(payment: paymentMock)
        step = mpCheckout.viewModel.nextStep()
        XCTAssertEqual(CheckoutStep.CONGRATS, step)
        
        
        
        // 6. Finish
        step = mpCheckout.viewModel.nextStep()
        XCTAssertEqual(CheckoutStep.FINISH, step)
        
        // Ejecutar finish
        mpCheckout.executeNextStep()

    }
    
    func testNextStep_withPaymentResult() {
        
        // Set access_token
        MercadoPagoContext.setPayerAccessToken("access_token")
        
        // Init checkout
        let checkoutPreference = MockBuilder.buildCheckoutPreference()
        let visaPaymentMethod = MockBuilder.buildPaymentMethod("visa")
        let paymentDataVisa = MockBuilder.buildPaymentData(paymentMethod: visaPaymentMethod)
        
        let paymentResult = PaymentResult(status: "status", statusDetail: "statusDetail", paymentData: paymentDataVisa, payerEmail: "payerEmail", id: "id", statementDescription: "description")
        
        let mpCheckout = MercadoPagoCheckout(checkoutPreference: checkoutPreference, navigationController: UINavigationController(), paymentResult : paymentResult)
        XCTAssertNotNil(mpCheckout.viewModel)
        
        // 1. Search preference
        var step = mpCheckout.viewModel.nextStep()
        XCTAssertEqual(CheckoutStep.SEARCH_PREFERENCE, step)
  
        MPCheckoutTestAction.loadGroupsInViewModel(mpCheckout: mpCheckout)
        
        // 3. Muestra congrats
        step = mpCheckout.viewModel.nextStep()
        XCTAssertEqual(CheckoutStep.CONGRATS, step)
        
        // 4. Finish
        step = mpCheckout.viewModel.nextStep()
        XCTAssertEqual(CheckoutStep.FINISH, step)
        
        // Ejecutar finish
        mpCheckout.executeNextStep()
        
    }
    
    func testNextStep_withCustomerCard() {
        
        // Set access_token
        MercadoPagoContext.setPayerAccessToken("access_token")
        
        let checkoutPreference = MockBuilder.buildCheckoutPreference()
        
        let mpCheckout = MercadoPagoCheckout(checkoutPreference: checkoutPreference, navigationController: UINavigationController())
        XCTAssertNotNil(mpCheckout.viewModel)
        
        // 1. Search preference
        var step = mpCheckout.viewModel.nextStep()
        XCTAssertEqual(CheckoutStep.SEARCH_PREFERENCE, step)
        
        // 2. Search Payment Methods
        step = mpCheckout.viewModel.nextStep()
        XCTAssertEqual(CheckoutStep.SEARCH_PAYMENT_METHODS, step)
        
        MPCheckoutTestAction.loadGroupsInViewModel(mpCheckout: mpCheckout)
        
        // 3. Display payment methods (no exclusions)
        step = mpCheckout.viewModel.nextStep()
        XCTAssertEqual(CheckoutStep.PAYMENT_METHOD_SELECTION, step)
        
        // 4. Payment option selected : customer card visa => Cuotas
        MPCheckoutTestAction.selectCustomerCardOption(mpCheckout: mpCheckout)
        step = mpCheckout.viewModel.nextStep()
        XCTAssertEqual(CheckoutStep.GET_PAYER_COSTS, step)
        mpCheckout.viewModel.installment = MockBuilder.buildInstallment()
        
        // 5. Mostrar cuotas
        step = mpCheckout.viewModel.nextStep()
        XCTAssertEqual(CheckoutStep.PAYER_COST_SCREEN, step)
        
        //Simular cuotas seleccionadas
        mpCheckout.viewModel.paymentData.payerCost = MockBuilder.buildPayerCost()
        
        // 6. Mostrar SecCode (incluye creación de token)
        step = mpCheckout.viewModel.nextStep()
        XCTAssertEqual(CheckoutStep.SECURITY_CODE_ONLY, step)
        let token = MockBuilder.buildToken()
        mpCheckout.viewModel.updateCheckoutModel(token: token)
        
        // 7. RyC
        step = mpCheckout.viewModel.nextStep()
        XCTAssertEqual(CheckoutStep.REVIEW_AND_CONFIRM, step)
    
        // Simular pago
        let visaPaymentMethod = MockBuilder.buildPaymentMethod("visa")
        let paymentDataMock = MockBuilder.buildPaymentData(paymentMethod: visaPaymentMethod)
        paymentDataMock.issuer = MockBuilder.buildIssuer()
        paymentDataMock.payerCost = MockBuilder.buildPayerCost()
        paymentDataMock.token = MockBuilder.buildToken()
        mpCheckout.viewModel.updateCheckoutModel(paymentData: paymentDataMock)
        
        // 8. Post Payment
        step = mpCheckout.viewModel.nextStep()
        XCTAssertEqual(CheckoutStep.POST_PAYMENT, step)
        
        // 9. Simular pago completo => Congrats
        let paymentMock = MockBuilder.buildPayment("visa")
        mpCheckout.viewModel.updateCheckoutModel(payment: paymentMock)
        step = mpCheckout.viewModel.nextStep()
        XCTAssertEqual(CheckoutStep.CONGRATS, step)
        
        // 10. Finish
        step = mpCheckout.viewModel.nextStep()
        XCTAssertEqual(CheckoutStep.FINISH, step)
        
        // Ejecutar finish
        mpCheckout.executeNextStep()

        
    }

    
    
}
