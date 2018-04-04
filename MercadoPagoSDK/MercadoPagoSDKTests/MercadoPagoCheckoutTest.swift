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
        URLConfigs.MP_ENVIROMENT = URLConfigs.MP_PROD_ENV  + "/checkout"
        URLConfigs.API_VERSION = "API_VERSION"
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
        self.mpCheckout = MercadoPagoCheckout(publicKey: "PK_MLA", checkoutPreference: checkoutPreference, navigationController: navControllerInstance)
        XCTAssertNotNil(self.mpCheckout!.viewModel)
        XCTAssertNotNil(self.mpCheckout!.viewModel.checkoutPreference)
        XCTAssertFalse(self.mpCheckout!.viewModel.paymentData.isComplete())
        XCTAssertNil(self.mpCheckout!.viewModel.paymentResult)
        XCTAssertEqual(self.mpCheckout!.navigationController, navControllerInstance)
        XCTAssertEqual(MercadoPagoContext.publicKey(), "PK_MLA")
        XCTAssertEqual(MercadoPagoContext.payerAccessToken(), "")

    }

    func testInit_withPaymentData() {
        let checkoutPreference = MockBuilder.buildCheckoutPreference()
        let paymentMethod = MockBuilder.buildPaymentMethod("visa")
        let paymentData = MockBuilder.buildPaymentData(paymentMethod: paymentMethod)
        paymentData.payerCost = MockBuilder.buildPayerCost()
        paymentData.token = MockBuilder.buildToken()
        let navControllerInstance = UINavigationController()

        self.mpCheckout = MercadoPagoCheckout(publicKey: "PK_MLA", checkoutPreference: checkoutPreference, paymentData: paymentData, navigationController: navControllerInstance)

        XCTAssertNotNil(self.mpCheckout!.viewModel)
        XCTAssertNotNil(self.mpCheckout!.viewModel.checkoutPreference)
        XCTAssertEqual(self.mpCheckout!.viewModel.paymentData.paymentMethod, paymentMethod)
        XCTAssertNil(self.mpCheckout!.viewModel.paymentResult)
        XCTAssertEqual(self.mpCheckout!.navigationController, navControllerInstance)
        XCTAssertEqual(MercadoPagoContext.publicKey(), "PK_MLA")
        XCTAssertEqual(MercadoPagoContext.payerAccessToken(), "")
    }

    func testInit_withPaymentResult() {

        let checkoutPreference = MockBuilder.buildCheckoutPreference()
        let paymentMethod = MockBuilder.buildPaymentMethod("visa")
        let paymentData = MockBuilder.buildPaymentData(paymentMethod: paymentMethod)
        paymentData.payerCost = MockBuilder.buildPayerCost()
        paymentData.token = MockBuilder.buildToken()

        let navControllerInstance = UINavigationController()
        let paymentResult = MockBuilder.buildPaymentResult(paymentMethodId: "visa")
        paymentResult.paymentData = paymentData

        self.mpCheckout = MercadoPagoCheckout(publicKey: "PK_MLA", accessToken: "lala", checkoutPreference: checkoutPreference, paymentData: paymentData, paymentResult: paymentResult, navigationController: navControllerInstance)

        XCTAssertNotNil(self.mpCheckout!.viewModel)
        XCTAssertNotNil(self.mpCheckout!.viewModel.checkoutPreference)
        XCTAssertEqual(self.mpCheckout!.viewModel.paymentData.paymentMethod, paymentMethod)
        XCTAssertNotNil(self.mpCheckout!.viewModel.paymentResult)
        XCTAssertEqual(self.mpCheckout!.navigationController, navControllerInstance)
        XCTAssertEqual(MercadoPagoContext.publicKey(), "PK_MLA")
        XCTAssertEqual(MercadoPagoContext.payerAccessToken(), "lala")
    }

    /*******************************************/
    /***** Display view controllers tests ******/
    /*******************************************/

    func testCollectCheckoutPreference() {
        let checkoutPreference = MockBuilder.buildCheckoutPreference()
        checkoutPreference.preferenceId = "sarasa"
        let navControllerInstance = UINavigationController()
        self.mpCheckout = MercadoPagoCheckoutMock(publicKey: "PK_MLA", accessToken: "", checkoutPreference: checkoutPreference, navigationController: navControllerInstance)

        self.mpCheckout!.getCheckoutPreference()

        // Se obtiene id de MockedResponse
        XCTAssertEqual("NO_EXCLUSIONS", self.mpCheckout!.viewModel.checkoutPreference.preferenceId)

    }

    func testCollectPaymentMethods() {

        let checkoutPreference = MockBuilder.buildCheckoutPreference()
        let navControllerInstance = UINavigationController()
        self.mpCheckout = MercadoPagoCheckout(publicKey: "PK_MLA", accessToken: "", checkoutPreference: checkoutPreference, navigationController: navControllerInstance)

        MPCheckoutTestAction.loadGroupsInViewModel(mpCheckout: self.mpCheckout!)

        self.mpCheckout?.showPaymentMethodsScreen()

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
        checkoutPreference.preferenceId = nil
        self.mpCheckout = MercadoPagoCheckout(publicKey: "PK_MLA", accessToken: "", checkoutPreference: checkoutPreference, navigationController: navControllerInstance)
        self.mpCheckout!.validatePreference()
    }

    func testCollectCard() {

        let checkoutPreference = MockBuilder.buildCheckoutPreference()
        let navControllerInstance = UINavigationController()
        self.mpCheckout = MercadoPagoCheckout(publicKey: "PK_MLA", accessToken: "", checkoutPreference: checkoutPreference, navigationController: navControllerInstance)

        self.mpCheckout?.showCardForm()

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
        mpCheckout!.viewModel.identificationTypes = MockBuilder.buildIdentificationTypes()
        self.mpCheckout?.showIdentificationScreen()

        XCTAssertNil(self.mpCheckout?.viewModel.paymentData.paymentMethod)
        XCTAssertNil(self.mpCheckout?.viewModel.paymentData.payerCost)
        XCTAssertNil(self.mpCheckout?.viewModel.paymentData.token)
        XCTAssertNil(self.mpCheckout?.viewModel.paymentData.issuer)
        XCTAssertEqual(self.mpCheckout?.navigationController.viewControllers.count, 1)
        let lastVC = self.mpCheckout!.navigationController.viewControllers[0]
        XCTAssertTrue(lastVC.isKind(of: IdentificationViewController.self))
    }

    func testStartIssuersScreen() {
        let checkoutPreference = MockBuilder.buildCheckoutPreference()
        let navControllerInstance = UINavigationController()
        self.mpCheckout = MercadoPagoCheckout(publicKey: "PK_MLA", accessToken: "", checkoutPreference: checkoutPreference, navigationController: navControllerInstance)

        let issuers = [MockBuilder.buildIssuer()]
        self.mpCheckout?.viewModel.issuers = issuers

        self.mpCheckout?.showIssuersScreen()

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

        let payerCost = [MockBuilder.buildPayerCost(installments: 1, installmentRate: 0, hasCFT: false)]
        self.mpCheckout?.viewModel.payerCosts = payerCost

        self.mpCheckout?.showPayerCostScreen()

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

        self.mpCheckout?.showReviewAndConfirmScreen()

        XCTAssertNotNil(self.mpCheckout?.viewModel.paymentData.paymentMethod)
        XCTAssertEqual(self.mpCheckout?.navigationController.viewControllers.count, 1)
        let lastVC = self.mpCheckout!.navigationController.viewControllers[0]
        XCTAssertTrue(lastVC.isKind(of: PXReviewViewController.self))
    }

    func testDisplayPaymentResult_onlinePayment() {
        let checkoutPreference = MockBuilder.buildCheckoutPreference()
        let navControllerInstance = UINavigationController()
        self.mpCheckout = MercadoPagoCheckout(publicKey: "PK_MLA", accessToken: "", checkoutPreference: checkoutPreference, navigationController: navControllerInstance)

        let paymentMethod = MockBuilder.buildPaymentMethod("visa")
        self.mpCheckout!.viewModel.payment = MockBuilder.buildPayment("visa")
        self.mpCheckout!.viewModel.paymentData = MockBuilder.buildPaymentData(paymentMethod: paymentMethod)

        self.mpCheckout!.showPaymentResultScreen()
        XCTAssertNotNil(self.mpCheckout?.viewModel.paymentResult)
        XCTAssertEqual(self.mpCheckout?.navigationController.viewControllers.count, 1)
        let lastVC = self.mpCheckout!.navigationController.viewControllers[0]
        XCTAssertTrue(lastVC.isKind(of: PXResultViewController.self))

    }

    func testDisplayPaymentResult_offlinePayment() {
        let checkoutPreference = MockBuilder.buildCheckoutPreference()
        let navControllerInstance = UINavigationController()
        self.mpCheckout = MercadoPagoCheckout(publicKey: "PK_MLB", accessToken: "", checkoutPreference: checkoutPreference, navigationController: navControllerInstance)

        let paymentMethod = MockBuilder.buildPaymentMethod("bolbradesco", paymentTypeId: "bank_transfer")
        self.mpCheckout!.viewModel.payment = MockBuilder.buildPayment("bolbradesco")
        self.mpCheckout!.viewModel.paymentData = MockBuilder.buildPaymentData(paymentMethod: paymentMethod)
        self.mpCheckout?.viewModel.instructionsInfo = MockBuilder.buildInstructionsInfo(paymentMethod: paymentMethod)

        self.mpCheckout!.showPaymentResultScreen()

        XCTAssertNotNil(self.mpCheckout?.viewModel.paymentResult)
        XCTAssertEqual(self.mpCheckout?.navigationController.viewControllers.count, 1)
        let lastVC = self.mpCheckout!.navigationController.viewControllers[0]
        XCTAssertTrue(lastVC.isKind(of: PXResultViewController.self))

    }

    func testShowBankInterestWarning() {
        var site = "MCO"
        MercadoPagoContext.setSiteID(site)
        XCTAssertEqual(true, MercadoPagoCheckout.showBankInterestWarning())

        site = "MLA"
        MercadoPagoContext.setSiteID(site)
        XCTAssertEqual(false, MercadoPagoCheckout.showBankInterestWarning())
    }

    func testShowPayerCostDescription() {
        var site = "MCO"
        MercadoPagoContext.setSiteID(site)
        XCTAssertEqual(false, MercadoPagoCheckout.showPayerCostDescription())

        site = "MLA"
        MercadoPagoContext.setSiteID(site)
        XCTAssertEqual(true, MercadoPagoCheckout.showPayerCostDescription())
    }

    func testSetBinaryMode() {
        let checkoutPreference = MockBuilder.buildCheckoutPreference()
        let navControllerInstance = UINavigationController()
        self.mpCheckout = MercadoPagoCheckout(publicKey: "PK_MLA", accessToken: "", checkoutPreference: checkoutPreference, navigationController: navControllerInstance)

        //Test Default Binary Mode
        XCTAssertEqual(false, self.mpCheckout?.viewModel.binaryMode)

        //Test setBinaryMode Method
        self.mpCheckout?.setBinaryMode(true)
        XCTAssertEqual(true, self.mpCheckout?.viewModel.binaryMode)

        self.mpCheckout?.setBinaryMode(false)
        XCTAssertEqual(false, self.mpCheckout?.viewModel.binaryMode)
    }

    func testWhenCreateNewCardTokenFailsWithInvalidIdNumberThenDoNotExecuteNextStep() {
        MercadoPagoCheckoutViewModel.error = nil
        let navControllerInstance = UINavigationController()
        let checkoutPreference = MockBuilder.buildCheckoutPreference()
        let dummyExecutionCheckout = MercadoPagoCheckoutMock(publicKey: "PK_MLA_INVALID_ID_TEST", accessToken: "", checkoutPreference: checkoutPreference, navigationController: navControllerInstance)

        self.mpCheckout = dummyExecutionCheckout

        mpCheckout?.viewModel.updateCheckoutModel(paymentMethods: [MockBuilder.buildPaymentMethod("visa")], cardToken: MockBuilder.buildCardToken())

        mpCheckout?.viewModel.cardToken?.cardNumber = "invalid_identification_number"

        mpCheckout?.createNewCardToken()
        XCTAssertNil(MercadoPagoCheckoutViewModel.error)
    }
}

open class MercadoPagoCheckoutMock: MercadoPagoCheckout {
    var executedNextStep: Bool = false
    override func executeNextStep() {
        executedNextStep = true
    }
}
