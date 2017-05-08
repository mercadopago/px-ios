//
//  MercadoPagoCheckoutTest.swift
//  MercadoPagoSDK
//
//  Created by Maria cristina rodriguez on 3/17/17.
//  Copyright © 2017 MercadoPago. All rights reserved.
//

import XCTest

class MercadoPagoCheckoutTest: BaseTest {

    var mpCheckout: MercadoPagoCheckout?

    override func setUp() {
        super.setUp()
        self.continueAfterFailure = false
        // Use v1 urls
        ServicePreference.MP_ENVIROMENT = ServicePreference.MP_PROD_ENV  + "/checkout"
        ServicePreference.API_VERSION = "API_VERSION"
    }

    override func tearDown() {
        super.tearDown()
        self.mpCheckout = nil
    }

    /********************************/
    /***** Init checkout tests ******/
    /********************************/

    func testInit_withCheckoutPreference() {
        let checkoutPreference = MockBuilder.buildCheckoutPreference()
        let navControllerInstance = UINavigationController()
        self.mpCheckout = MercadoPagoCheckout(publicKey: "PK_MLA", accessToken: "", checkoutPreference: checkoutPreference, navigationController: navControllerInstance)
        XCTAssertNotNil(self.mpCheckout!.viewModel)
        XCTAssertNotNil(self.mpCheckout!.viewModel.checkoutPreference)
        XCTAssertFalse(self.mpCheckout!.viewModel.paymentData.isComplete())
        XCTAssertNil(self.mpCheckout!.viewModel.paymentResult)
        XCTAssertEqual(self.mpCheckout!.navigationController, navControllerInstance)

    }

    func testInit_withPaymentData() {
        let checkoutPreference = MockBuilder.buildCheckoutPreference()
        let paymentMethod = MockBuilder.buildPaymentMethod("visa")
        let paymentData = MockBuilder.buildPaymentData(paymentMethod: paymentMethod)
        paymentData.payerCost = MockBuilder.buildPayerCost()
        paymentData.token = MockBuilder.buildToken()
        let navControllerInstance = UINavigationController()

        self.mpCheckout = MercadoPagoCheckout(publicKey: "PK_MLA", accessToken: "", checkoutPreference: checkoutPreference, paymentData : paymentData, navigationController: navControllerInstance)

        XCTAssertNotNil(self.mpCheckout!.viewModel)
        XCTAssertNotNil(self.mpCheckout!.viewModel.checkoutPreference)
        XCTAssertEqual(self.mpCheckout!.viewModel.paymentData.paymentMethod, paymentMethod)
        XCTAssertNil(self.mpCheckout!.viewModel.paymentResult)
        XCTAssertEqual(self.mpCheckout!.navigationController, navControllerInstance)
    }

    func testInit_withPaymentResult() {

        let checkoutPreference = MockBuilder.buildCheckoutPreference()
        let paymentMethod = MockBuilder.buildPaymentMethod("visa")
        let paymentData = MockBuilder.buildPaymentData(paymentMethod: paymentMethod)
        paymentData.payerCost = MockBuilder.buildPayerCost()
        paymentData.token = MockBuilder.buildToken()

        let navControllerInstance = UINavigationController()
        let paymentResult = MockBuilder.buildPaymentResult(paymentMethodId: "visa")

        self.mpCheckout = MercadoPagoCheckout(publicKey: "PK_MLA", accessToken: "", checkoutPreference: checkoutPreference, paymentData : paymentData, navigationController: navControllerInstance, paymentResult : paymentResult)

        XCTAssertNotNil(self.mpCheckout!.viewModel)
        XCTAssertNotNil(self.mpCheckout!.viewModel.checkoutPreference)
        XCTAssertEqual(self.mpCheckout!.viewModel.paymentData.paymentMethod, paymentMethod)
        XCTAssertNotNil(self.mpCheckout!.viewModel.paymentResult)
        XCTAssertEqual(self.mpCheckout!.navigationController, navControllerInstance)
    }

    /*******************************************/
    /***** Display view controllers tests ******/
    /*******************************************/

    func testCollectCheckoutPreference() {
        let checkoutPreference = MockBuilder.buildCheckoutPreference()
        let navControllerInstance = UINavigationController()
        self.mpCheckout = MercadoPagoCheckoutMock(publicKey: "PK_MLA", accessToken: "", checkoutPreference: checkoutPreference, navigationController: navControllerInstance)

        self.mpCheckout!.collectCheckoutPreference()

        // Se obtiene id de MockedResponse
        XCTAssertEqual("150216849-e131b785-10d3-48c0-a58b-2910935512e0", self.mpCheckout!.viewModel.checkoutPreference._id)

    }

    func testCollectPaymentMethodSearch() {
        let checkoutPreference = MockBuilder.buildCheckoutPreference()
        let navControllerInstance = UINavigationController()
        self.mpCheckout = MercadoPagoCheckoutMock(publicKey: "PK_MLA", accessToken: "", checkoutPreference: checkoutPreference, navigationController: navControllerInstance)

        XCTAssertNil(self.mpCheckout?.viewModel.rootPaymentMethodOptions)
        XCTAssertNil(self.mpCheckout?.viewModel.search)
        XCTAssertNil(self.mpCheckout?.viewModel.availablePaymentMethods)
        XCTAssertNil(self.mpCheckout?.viewModel.paymentMethodOptions)

        self.mpCheckout!.collectPaymentMethodSearch()

        XCTAssertNotNil(self.mpCheckout?.viewModel.rootPaymentMethodOptions)
        XCTAssertNotNil(self.mpCheckout?.viewModel.search)
        XCTAssertNotNil(self.mpCheckout?.viewModel.availablePaymentMethods)
        XCTAssertEqual(self.mpCheckout?.viewModel.availablePaymentMethods!.count, 17)
        XCTAssertNotNil(self.mpCheckout?.viewModel.paymentMethodOptions)
        XCTAssertEqual(self.mpCheckout?.viewModel.paymentMethodOptions!.count, 3)
    }

    func testCollectPaymentMethods() {

        let checkoutPreference = MockBuilder.buildCheckoutPreference()
        let navControllerInstance = UINavigationController()
        self.mpCheckout = MercadoPagoCheckout(publicKey: "PK_MLA", accessToken: "", checkoutPreference: checkoutPreference, navigationController: navControllerInstance)

        MPCheckoutTestAction.loadGroupsInViewModel(mpCheckout: self.mpCheckout!)

        self.mpCheckout?.collectPaymentMethods()

        XCTAssertNil(self.mpCheckout?.viewModel.paymentData.paymentMethod)
        XCTAssertNil(self.mpCheckout?.viewModel.paymentData.payerCost)
        XCTAssertNil(self.mpCheckout?.viewModel.paymentData.token)
        XCTAssertNil(self.mpCheckout?.viewModel.paymentData.issuer)
        XCTAssertEqual(self.mpCheckout?.navigationController.viewControllers.count, 1)
        let lastVC = self.mpCheckout!.navigationController.viewControllers[0]
        XCTAssertTrue(lastVC.isKind(of: PaymentVaultViewController.self))
    }

    func testValidatePreference() {
        let checkoutPreference = MockBuilder.buildCheckoutPreference()
        let navControllerInstance = UINavigationController()
        // Disable discount
        let fp = FlowPreference()
        fp.disableDiscount()
        MercadoPagoCheckout.setFlowPreference(fp)

        self.mpCheckout = MercadoPagoCheckoutMock(publicKey: "PK_MLA", accessToken: "", checkoutPreference: checkoutPreference, navigationController: navControllerInstance)

        self.mpCheckout!.validatePreference()
        XCTAssertEqual(navControllerInstance.viewControllers.count, 0)

        // Evitar ir a buscar preferencia. Preferencia inválida debería mostrar error
        checkoutPreference.items = nil
        checkoutPreference._id = nil
        self.mpCheckout = MercadoPagoCheckout(publicKey: "PK_MLA", accessToken: "", checkoutPreference: checkoutPreference, navigationController: navControllerInstance)
        self.mpCheckout!.validatePreference()
//        XCTAssertNotNil(MercadoPagoCheckoutViewModel.error)
//        XCTAssertNotNil(MercadoPagoCheckoutViewModel.error!.messageDetail)//,errorMessageExpected)

    }

    func testCollectCard() {

        let checkoutPreference = MockBuilder.buildCheckoutPreference()
        let navControllerInstance = UINavigationController()
        self.mpCheckout = MercadoPagoCheckout(publicKey: "PK_MLA", accessToken: "", checkoutPreference: checkoutPreference, navigationController: navControllerInstance)

        self.mpCheckout?.collectCard()

        XCTAssertNil(self.mpCheckout?.viewModel.paymentData.paymentMethod)
        XCTAssertNil(self.mpCheckout?.viewModel.paymentData.payerCost)
        XCTAssertNil(self.mpCheckout?.viewModel.paymentData.token)
        XCTAssertNil(self.mpCheckout?.viewModel.paymentData.issuer)
        XCTAssertEqual(self.mpCheckout?.navigationController.viewControllers.count, 1)
        let lastVC = self.mpCheckout!.navigationController.viewControllers[0]
        XCTAssertTrue(lastVC.isKind(of: CardFormViewController.self))
    }

    func testCollectIdentification() {
        let checkoutPreference = MockBuilder.buildCheckoutPreference()
        let navControllerInstance = UINavigationController()
        self.mpCheckout = MercadoPagoCheckout(publicKey: "PK_MLA", accessToken: "", checkoutPreference: checkoutPreference, navigationController: navControllerInstance)

        self.mpCheckout?.collectIdentification()

        XCTAssertNil(self.mpCheckout?.viewModel.paymentData.paymentMethod)
        XCTAssertNil(self.mpCheckout?.viewModel.paymentData.payerCost)
        XCTAssertNil(self.mpCheckout?.viewModel.paymentData.token)
        XCTAssertNil(self.mpCheckout?.viewModel.paymentData.issuer)
        XCTAssertEqual(self.mpCheckout?.navigationController.viewControllers.count, 1)
        let lastVC = self.mpCheckout!.navigationController.viewControllers[0]
        XCTAssertTrue(lastVC.isKind(of: IdentificationViewController.self))
    }

    func testCollectCreditDebit() {
        let checkoutPreference = MockBuilder.buildCheckoutPreference()
        let navControllerInstance = UINavigationController()
        self.mpCheckout = MercadoPagoCheckout(publicKey: "PK_MLA", accessToken: "", checkoutPreference: checkoutPreference, navigationController: navControllerInstance)

        self.mpCheckout?.collectCreditDebit()

        XCTAssertNil(self.mpCheckout?.viewModel.paymentData.paymentMethod)
        XCTAssertNil(self.mpCheckout?.viewModel.paymentData.payerCost)
        XCTAssertNil(self.mpCheckout?.viewModel.paymentData.token)
        XCTAssertNil(self.mpCheckout?.viewModel.paymentData.issuer)
        XCTAssertEqual(self.mpCheckout?.navigationController.viewControllers.count, 1)
        let lastVC = self.mpCheckout!.navigationController.viewControllers[0]
        XCTAssertTrue(lastVC.isKind(of: AdditionalStepViewController.self))
    }

    func testStartIssuersScreen() {
        let checkoutPreference = MockBuilder.buildCheckoutPreference()
        let navControllerInstance = UINavigationController()
        self.mpCheckout = MercadoPagoCheckout(publicKey: "PK_MLA", accessToken: "", checkoutPreference: checkoutPreference, navigationController: navControllerInstance)

        self.mpCheckout?.collectCreditDebit()

        XCTAssertNil(self.mpCheckout?.viewModel.paymentData.paymentMethod)
        XCTAssertNil(self.mpCheckout?.viewModel.paymentData.payerCost)
        XCTAssertNil(self.mpCheckout?.viewModel.paymentData.token)
        XCTAssertNil(self.mpCheckout?.viewModel.paymentData.issuer)
        XCTAssertEqual(self.mpCheckout?.navigationController.viewControllers.count, 1)
        let lastVC = self.mpCheckout!.navigationController.viewControllers[0]
        XCTAssertTrue(lastVC.isKind(of: AdditionalStepViewController.self))
    }

    func testStartPayerCostScreen() {
        let checkoutPreference = MockBuilder.buildCheckoutPreference()
        let navControllerInstance = UINavigationController()
        self.mpCheckout = MercadoPagoCheckout(publicKey: "PK_MLA", accessToken: "", checkoutPreference: checkoutPreference, navigationController: navControllerInstance)

        self.mpCheckout?.collectCreditDebit()

        XCTAssertNil(self.mpCheckout?.viewModel.paymentData.paymentMethod)
        XCTAssertNil(self.mpCheckout?.viewModel.paymentData.payerCost)
        XCTAssertNil(self.mpCheckout?.viewModel.paymentData.token)
        XCTAssertNil(self.mpCheckout?.viewModel.paymentData.issuer)
        XCTAssertEqual(self.mpCheckout?.navigationController.viewControllers.count, 1)
        let lastVC = self.mpCheckout!.navigationController.viewControllers[0]
        XCTAssertTrue(lastVC.isKind(of: AdditionalStepViewController.self))
    }

    func testCollectPaymentData() {
        let checkoutPreference = MockBuilder.buildCheckoutPreference()
        let navControllerInstance = UINavigationController()
        self.mpCheckout = MercadoPagoCheckout(publicKey: "PK_MLA", accessToken: "", checkoutPreference: checkoutPreference, navigationController: navControllerInstance)

        MPCheckoutTestAction.loadGroupsInViewModel(mpCheckout: self.mpCheckout!)
        MPCheckoutTestAction.selectAccountMoney(mpCheckout: self.mpCheckout!)

        self.mpCheckout?.collectPaymentData()

        XCTAssertNotNil(self.mpCheckout?.viewModel.paymentData.paymentMethod)
        XCTAssertEqual(self.mpCheckout?.navigationController.viewControllers.count, 1)
        let lastVC = self.mpCheckout!.navigationController.viewControllers[0]
        XCTAssertTrue(lastVC.isKind(of: CheckoutViewController.self))
    }

    func testDisplayPaymentResult_onlinePayment() {
        let checkoutPreference = MockBuilder.buildCheckoutPreference()
        let navControllerInstance = UINavigationController()
        self.mpCheckout = MercadoPagoCheckout(publicKey: "PK_MLA", accessToken: "", checkoutPreference: checkoutPreference, navigationController: navControllerInstance)

        let paymentMethod = MockBuilder.buildPaymentMethod("visa")
        self.mpCheckout!.viewModel.payment = MockBuilder.buildPayment("visa")
        self.mpCheckout!.viewModel.paymentData = MockBuilder.buildPaymentData(paymentMethod: paymentMethod)

        self.mpCheckout!.displayPaymentResult()
        XCTAssertNotNil(self.mpCheckout?.viewModel.paymentResult)
        XCTAssertEqual(self.mpCheckout?.navigationController.viewControllers.count, 1)
        let lastVC = self.mpCheckout!.navigationController.viewControllers[0]
        XCTAssertTrue(lastVC.isKind(of: PaymentResultViewController.self))

    }

    func testDisplayPaymentResult_offlinePayment() {
        let checkoutPreference = MockBuilder.buildCheckoutPreference()
        let navControllerInstance = UINavigationController()
        self.mpCheckout = MercadoPagoCheckout(publicKey: "PK_MLA", accessToken: "", checkoutPreference: checkoutPreference, navigationController: navControllerInstance)

        let paymentMethod = MockBuilder.buildPaymentMethod("rapipago", paymentTypeId : "ticket")
        self.mpCheckout!.viewModel.payment = MockBuilder.buildPayment("rapipago")
        self.mpCheckout!.viewModel.paymentData = MockBuilder.buildPaymentData(paymentMethod: paymentMethod)

        self.mpCheckout!.displayPaymentResult()

        XCTAssertNotNil(self.mpCheckout?.viewModel.paymentResult)
        XCTAssertEqual(self.mpCheckout?.navigationController.viewControllers.count, 1)
        let lastVC = self.mpCheckout!.navigationController.viewControllers[0]
        XCTAssertTrue(lastVC.isKind(of: InstructionsViewController.self))

    }
}

open class MercadoPagoCheckoutMock: MercadoPagoCheckout {

    override func executeNextStep() {
        // Do nothing
    }
}
