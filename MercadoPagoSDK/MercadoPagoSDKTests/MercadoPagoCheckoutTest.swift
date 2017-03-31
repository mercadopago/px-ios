//
//  MercadoPagoCheckoutTest.swift
//  MercadoPagoSDK
//
//  Created by Maria cristina rodriguez on 3/17/17.
//  Copyright © 2017 MercadoPago. All rights reserved.
//

import XCTest

class MercadoPagoCheckoutTest: BaseTest {
    
    var mpCheckout : MercadoPagoCheckout?
    
    override func setUp() {
        super.setUp()
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
        self.mpCheckout = MercadoPagoCheckout(checkoutPreference: checkoutPreference, navigationController: navControllerInstance)
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
        
        self.mpCheckout = MercadoPagoCheckout(checkoutPreference: checkoutPreference, paymentData : paymentData, navigationController: navControllerInstance)
        
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
        
        self.mpCheckout = MercadoPagoCheckout(checkoutPreference: checkoutPreference, paymentData : paymentData, navigationController: navControllerInstance, paymentResult : paymentResult)
        
        XCTAssertNotNil(self.mpCheckout!.viewModel)
        XCTAssertNotNil(self.mpCheckout!.viewModel.checkoutPreference)
        XCTAssertEqual(self.mpCheckout!.viewModel.paymentData.paymentMethod, paymentMethod)
        XCTAssertNotNil(self.mpCheckout!.viewModel.paymentResult)
        XCTAssertEqual(self.mpCheckout!.navigationController, navControllerInstance)
    }
    
    /*******************************************/
    /***** Display view controllers tests ******/
    /*******************************************/
    
    func testCollectPaymentMethods(){
        
        let checkoutPreference = MockBuilder.buildCheckoutPreference()
        let navControllerInstance = UINavigationController()
        self.mpCheckout = MercadoPagoCheckout(checkoutPreference: checkoutPreference, navigationController: navControllerInstance)
        
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
    
    func testCollectCard(){
        
        let checkoutPreference = MockBuilder.buildCheckoutPreference()
        let navControllerInstance = UINavigationController()
        self.mpCheckout = MercadoPagoCheckout(checkoutPreference: checkoutPreference, navigationController: navControllerInstance)
        
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
        self.mpCheckout = MercadoPagoCheckout(checkoutPreference: checkoutPreference, navigationController: navControllerInstance)
        
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
        self.mpCheckout = MercadoPagoCheckout(checkoutPreference: checkoutPreference, navigationController: navControllerInstance)
        
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
        self.mpCheckout = MercadoPagoCheckout(checkoutPreference: checkoutPreference, navigationController: navControllerInstance)
        
        self.mpCheckout?.collectCreditDebit()
        
        XCTAssertNil(self.mpCheckout?.viewModel.paymentData.paymentMethod)
        XCTAssertNil(self.mpCheckout?.viewModel.paymentData.payerCost)
        XCTAssertNil(self.mpCheckout?.viewModel.paymentData.token)
        XCTAssertNil(self.mpCheckout?.viewModel.paymentData.issuer)
        XCTAssertEqual(self.mpCheckout?.navigationController.viewControllers.count, 1)
        let lastVC = self.mpCheckout!.navigationController.viewControllers[0]
        XCTAssertTrue(lastVC.isKind(of: AdditionalStepViewController.self))
    }
    
    func testStartPayerCostScreen(){
        let checkoutPreference = MockBuilder.buildCheckoutPreference()
        let navControllerInstance = UINavigationController()
        self.mpCheckout = MercadoPagoCheckout(checkoutPreference: checkoutPreference, navigationController: navControllerInstance)
        
        self.mpCheckout?.collectCreditDebit()
        
        XCTAssertNil(self.mpCheckout?.viewModel.paymentData.paymentMethod)
        XCTAssertNil(self.mpCheckout?.viewModel.paymentData.payerCost)
        XCTAssertNil(self.mpCheckout?.viewModel.paymentData.token)
        XCTAssertNil(self.mpCheckout?.viewModel.paymentData.issuer)
        XCTAssertEqual(self.mpCheckout?.navigationController.viewControllers.count, 1)
        let lastVC = self.mpCheckout!.navigationController.viewControllers[0]
        XCTAssertTrue(lastVC.isKind(of: AdditionalStepViewController.self))
    }
    
    func testCollectPaymentData(){
        let checkoutPreference = MockBuilder.buildCheckoutPreference()
        let navControllerInstance = UINavigationController()
        self.mpCheckout = MercadoPagoCheckout(checkoutPreference: checkoutPreference, navigationController: navControllerInstance)
        
        MPCheckoutTestAction.loadGroupsInViewModel(mpCheckout: self.mpCheckout!)
        MPCheckoutTestAction.selectAccountMoney(mpCheckout: self.mpCheckout!)
        
        self.mpCheckout?.collectPaymentData()
        
        XCTAssertNotNil(self.mpCheckout?.viewModel.paymentData.paymentMethod)
        XCTAssertEqual(self.mpCheckout?.navigationController.viewControllers.count, 1)
        let lastVC = self.mpCheckout!.navigationController.viewControllers[0]
        XCTAssertTrue(lastVC.isKind(of: CheckoutViewController.self))
    }
    
}
