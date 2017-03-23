//
//  CheckoutViewControllerTest.swift
//  MercadoPagoSDK
//
//  Created by Maria cristina rodriguez on 22/1/16.
//  Copyright © 2016 MercadoPago. All rights reserved.
//

import XCTest
@testable import MercadoPagoSDK

class CheckoutViewControllerTest: BaseTest {
    
    var checkoutViewController : MockCheckoutViewController?
    var preference : CheckoutPreference?
    var selectedPaymentMethod : PaymentMethod?
    var selectedPayerCost : PayerCost?
    var selectedIssuer : Issuer?
    var createdToken : Token?
    
    override func setUp() {
        super.setUp()
//        self.checkoutViewController = MockCheckoutViewController(preferenceId: MockBuilder.PREF_ID_NO_EXCLUSIONS, callback: { (payment) in
//            
//        })

    }
    
/*    override func tearDown() {
        super.tearDown()
    }
    
    func testInitParameters() {
        
        XCTAssertEqual(checkoutViewController!.preferenceId, MockBuilder.PREF_ID_NO_EXCLUSIONS)
        XCTAssertEqual(checkoutViewController!.publicKey, MercadoPagoContext.publicKey())
        XCTAssertEqual(checkoutViewController!.accessToken, MercadoPagoContext.merchantAccessToken())
        XCTAssertNil(checkoutViewController!.paymentMethod)
    }
    
    func testSetupCheckoutWithPreference(){
        
        MPServicesBuilder.getPreference(MockBuilder.PREF_ID_NO_EXCLUSIONS, success: { (preference) in
            self.preference = preference
        }) { (error) in
            
        }
        
        waitForExpectations(timeout: BaseTest.WAIT_EXPECTATION_TIME_INTERVAL, handler: nil)
        // Cargar vista
              self.simulateViewDidLoadFor(self.checkoutViewController!)
        
        // Verificar preferencia
        XCTAssertEqual(self.preference?._id, self.checkoutViewController!.preference?._id)
        
        // Verificar atributos iniciales de pantalla
        checkInitialScreenAttributes()
      
    }
    
    
    /*
     *  Todos los medios de pago disponibles.
     *  Se selecciona medio off para pago.
     *  Última pantalla es instrucciones de pago
     */
    func testCheckoutMLA_preferenceWithNoExclusionsPaymentOff(){
        self.checkoutViewController = MockCheckoutViewController(preferenceId: MockBuilder.PREF_ID_NO_EXCLUSIONS, callback: { (payment : Payment) in
            
            
        })
        
        // Metodo de pago no seleccionado
        XCTAssertNil(checkoutViewController?.paymentMethod)
        
        self.simulateViewDidLoadFor(checkoutViewController!)
        
        let navigationController = UINavigationController(rootViewController: self.checkoutViewController!)
        
        XCTAssertNotNil(checkoutViewController?.paymentMethodSearch)
        XCTAssertTrue(checkoutViewController?.paymentMethodSearch?.groups.count == MockBuilder.MLA_PAYMENT_TYPES.count)
        
        // Verificar selección de medio off
        verifyPaymentVaultSelection_paymentMethodOff("rapipago")
        
        
        // Pago con medio off
        verifyConfirmPaymentOff()
        
        // Verificar que ultima pantalla sea instrucciones de pago
        let lastViewController = self.checkoutViewController!.navigationController?.viewControllers.last
        XCTAssertNotNil(lastViewController)
        //XCTAssertTrue(lastViewController!.isKindOfClass(InstructionsViewController))
        
        
        //Verificar payment method id seleccionado en instrucciones
        //let instructionsVC = (lastViewController as! InstructionsViewController)
        //XCTAssertEqual(instructionsVC.payment.paymentMethodId, self.selectedPaymentMethod?._id)
        
    }
    
    /*
     *  Todos los medios de pago disponible.
     *  Se selecciona cc para pago.
     *  Última pantalla es congrats
     */
    func testCheckoutMLA_preferenceWithNoExclusionsPaymentCreditCard(){
        
        self.checkoutViewController = MockCheckoutViewController(preferenceId: MockBuilder.PREF_ID_NO_EXCLUSIONS, callback: { (payment : Payment) in
            
        })
        
        // Metodo de pago no seleccionado
        XCTAssertNil(checkoutViewController?.paymentMethod)
        
        self.checkoutViewController = self.simulateViewDidLoadFor(checkoutViewController!) as! MockCheckoutViewController
        
        let navigationController = UINavigationController(rootViewController: self.checkoutViewController!)
        
        XCTAssertNotNil(checkoutViewController?.paymentMethodSearch)
        XCTAssertTrue(checkoutViewController?.paymentMethodSearch?.groups.count == MockBuilder.MLA_PAYMENT_TYPES.count)
        
        // Pago con tarjeta de crédito
        verifyPaymentVaultSelection_creditCard()
        
        verifyConfirmPaymentCC()
        
        // Verificar que ultima pantalla sea de pago aprobado
        let lastViewController = self.checkoutViewController!.navigationController?.viewControllers.last
        XCTAssertNotNil(lastViewController)
     //   XCTAssertTrue(lastViewController!.isKindOfClass(PaymentCongratsViewController))
        
        //Verificar payment method id seleccionado en instrucciones
     //   let congrats = (lastViewController as! PaymentCongratsViewController)
        //XCTAssertEqual(congrats.payment.paymentMethodId, self.selectedPaymentMethod?._id)
        
        
    }
    
    
    /*
     *  Solo pago con CC disponible.
     *  Se selecciona cc para pago.
     *  Última pantalla es congrats
     */
    func testCheckoutMLA_preferenceOnlyCCPaymentCreditCard(){
        
        self.checkoutViewController = MockCheckoutViewController(preferenceId: MockBuilder.PREF_ID_CC, callback: { (payment : Payment) in
            
        })
        
        
        // Metodo de pago no seleccionado
        XCTAssertNil(checkoutViewController?.paymentMethod)
        
        self.simulateViewDidLoadFor(checkoutViewController!)
        
        let navigationController = UINavigationController(rootViewController: self.checkoutViewController!)
        
        // Solo tarjeta de crédito disponible
        XCTAssertNotNil(checkoutViewController?.paymentMethodSearch)
        let excludedPaymentTypeIds = Set([PaymentTypeId.TICKET.rawValue, PaymentTypeId.BANK_TRANSFER.rawValue])
        let availablePaymentTypes = MockBuilder.MLA_PAYMENT_TYPES.subtract(excludedPaymentTypeIds)
        XCTAssertTrue(checkoutViewController?.paymentMethodSearch?.groups.count == availablePaymentTypes.count)
        
        // Pago con tarjeta de crédito
        verifyPaymentVaultSelection_creditCard()
        
        // Verificar cantidad de celdas en pantalla
        let numberOfRows = self.checkoutViewController?.tableView(self.checkoutViewController!.checkoutTable, numberOfRowsInSection: 1)
        XCTAssertEqual(numberOfRows, 4)
        
        // Crear pago con tarjeta
        verifyConfirmPaymentCC()
        
        // Verificar que ultima pantalla sea de pago aprobado
        let lastViewController = self.checkoutViewController!.navigationController?.viewControllers.last
        XCTAssertNotNil(lastViewController)
       // XCTAssertTrue(lastViewController!.isKindOfClass(PaymentCongratsViewController))
        
        
        //Verificar payment method id seleccionado en instrucciones
    //    let congrats = (lastViewController as! PaymentCongratsViewController)
        //XCTAssertEqual(congrats.payment.paymentMethodId, self.selectedPaymentMethod?._id)
        
        
    }
    
    
    
    /*
     *  Solo pago con ticket disponible.
     *  Se selecciona pagofacil para pago.
     *  Última pantalla es instrucciones
     */
    func testCheckoutMLA_preferenceOnlyTicketPaymentOff(){
        
        self.checkoutViewController = MockCheckoutViewController(preferenceId: MockBuilder.PREF_ID_TICKET, callback: { (payment : Payment) in
            
        })
        
        // Metodo de pago no seleccionado
        XCTAssertNil(checkoutViewController?.paymentMethod)
        
        self.simulateViewDidLoadFor(checkoutViewController!)
        
        let navigationController = UINavigationController(rootViewController: self.checkoutViewController!)
        
        // Solo medios off disponibles
        XCTAssertNotNil(checkoutViewController?.paymentMethodSearch)
        // Solo ticket disponible
        XCTAssertTrue(checkoutViewController?.paymentMethodSearch?.groups.count == 1)
        XCTAssertNotNil(checkoutViewController!.paymentMethodSearch!.groups[0].children)
        XCTAssertTrue(checkoutViewController?.paymentMethodSearch?.groups[0].children.count == 3)
        
        // Seleccionar método de pago
        verifyPaymentVaultSelection_paymentMethodOff("pagofacil")
        
        // Verificar cantidad de celdas en pantalla
        let numberOfRows = self.checkoutViewController?.tableView(self.checkoutViewController!.checkoutTable, numberOfRowsInSection: 1)
        XCTAssertEqual(numberOfRows, 3)
        
        // Crear pago
        verifyConfirmPaymentOff()
        
        // Verificar que ultima pantalla sea de pago aprobado
        let lastViewController = self.checkoutViewController!.navigationController?.viewControllers.last
        XCTAssertNotNil(lastViewController)
     //   XCTAssertTrue(lastViewController!.isKindOfClass(InstructionsViewController))
        
        
        //Verificar payment method id seleccionado en instrucciones
    //    let instructions = (lastViewController as! InstructionsViewController)
    //    XCTAssertEqual(instructions.payment.paymentMethodId, self.selectedPaymentMethod?._id)
        
        
    }
    
    
    /*
     *  Solo pago disponible con rapipago.
     *  Última pantalla es instrucciones de rapipago.
     */
    func testCheckoutMLA_preferenceOnlyPagoFacilPaymentMethodOff(){
        
        self.checkoutViewController = MockCheckoutViewController(preferenceId: MockBuilder.PREF_ID_PAGOFACIL, callback: { (payment : Payment) in
            
        })
        
        // Metodo de pago no seleccionado
        XCTAssertNil(checkoutViewController?.paymentMethod)
        
        self.simulateViewDidLoadFor(checkoutViewController!)
        let navigationController = UINavigationController(rootViewController: self.checkoutViewController!)
        
        // Solo pagofacil disponible
        XCTAssertNotNil(checkoutViewController?.paymentMethodSearch)
        XCTAssertTrue(checkoutViewController?.paymentMethodSearch?.groups.count == 1)
        
        // Seleccionar método de pago
        verifyPaymentVaultSelection_paymentMethodOff("pagofacil")
        
        // Verificar cantidad de celdas en pantalla
        let numberOfRows = self.checkoutViewController?.tableView(self.checkoutViewController!.checkoutTable, numberOfRowsInSection: 1)
        XCTAssertEqual(numberOfRows, 3)
        
        // Crear pago con pagofacil
        verifyConfirmPaymentOff()
        
        // Verificar que ultima pantalla sea de pago aprobado
        let lastViewController = self.checkoutViewController!.navigationController?.viewControllers.last
        XCTAssertNotNil(lastViewController)
      //  XCTAssertTrue(lastViewController!.isKindOfClass(InstructionsViewController))
        
        
        //Verificar payment method id seleccionado en instrucciones
    //    let instructions = (lastViewController as! InstructionsViewController)
    //    XCTAssertEqual(instructions.payment.paymentMethodId, self.selectedPaymentMethod?._id)
        
        
    }
    
    /*
     *  Todos los medios de pago disponible.
     *  Se selecciona cc para pago.
     *  Última pantalla es congrats
     */
    func testCheckoutMLA_preferenceSet(){
        
        let preference = MockBuilder.buildCheckoutPreference()
        self.checkoutViewController = MockCheckoutViewController(preferenceId: MockBuilder.PREF_ID_NO_EXCLUSIONS, callback: { (payment : Payment) in

        })
        self.checkoutViewController?.preference = preference
        
        // Metodo de pago no seleccionado
        XCTAssertNil(checkoutViewController?.paymentMethod)
        
        self.checkoutViewController = self.simulateViewDidLoadFor(checkoutViewController!) as! MockCheckoutViewController
        
        let navigationController = UINavigationController(rootViewController: self.checkoutViewController!)
        
        XCTAssertNotNil(checkoutViewController?.paymentMethodSearch)
        XCTAssertTrue(checkoutViewController?.paymentMethodSearch?.groups.count == MockBuilder.MLA_PAYMENT_TYPES.count)
        
        // Pago con tarjeta de crédito
        verifyPaymentVaultSelection_creditCard()
        
        verifyConfirmPaymentCC()
        
        // Verificar que ultima pantalla sea de pago aprobado
        let lastViewController = self.checkoutViewController!.navigationController?.viewControllers.last
        XCTAssertNotNil(lastViewController)
        //   XCTAssertTrue(lastViewController!.isKindOfClass(PaymentCongratsViewController))
        
        //Verificar payment method id seleccionado en instrucciones
        //   let congrats = (lastViewController as! PaymentCongratsViewController)
        //XCTAssertEqual(congrats.payment.paymentMethodId, self.selectedPaymentMethod?._id)
        
        
    }
    
    func testNumberOfSections(){
        self.checkoutViewController = MockCheckoutViewController(preferenceId: MockBuilder.PREF_ID_NO_EXCLUSIONS, callback: { (payment : Payment) in
            
        })
        let numberOfSections = self.checkoutViewController?.numberOfSectionsInTableView((self.checkoutViewController?.checkoutTable)!)
        XCTAssertTrue(numberOfSections == 0)
        
        self.checkoutViewController?.paymentMethod = MockBuilder.buildPaymentMethod("amex")
    }
    
    func verifyPaymentVaultSelection_paymentMethodOff(paymentMethodId : String){
        
        self.selectedPaymentMethod = Utils.findPaymentMethod((self.checkoutViewController?.paymentMethodSearch!.paymentMethods)!, paymentMethodId: paymentMethodId)
        
        // Selección de medio off
        checkoutViewController?.navigationController?.popViewController(animated: true)
        checkoutViewController?.paymentVaultCallback(selectedPaymentMethod!, token: nil, issuer: nil, payerCost: nil)
        
        XCTAssertEqual(checkoutViewController?.paymentMethod, selectedPaymentMethod)
    
    }
    
    
    func verifyPaymentVaultSelection_creditCard(){
        
        self.selectedPaymentMethod = Utils.findPaymentMethod((self.checkoutViewController?.paymentMethodSearch!.paymentMethods)!, paymentMethodId: "visa")
        self.selectedPayerCost = MockBuilder.buildPayerCost()
        self.selectedIssuer = MockBuilder.buildIssuer()
        self.createdToken = MockBuilder.buildToken()
        
        // Selección Tarjeta
        checkoutViewController?.paymentVaultCallback(selectedPaymentMethod!, token: self.createdToken, issuer: self.selectedIssuer, payerCost: self.selectedPayerCost)
        
        XCTAssertEqual(checkoutViewController?.paymentMethod, selectedPaymentMethod)
        XCTAssertEqual(checkoutViewController?.payerCost, self.selectedPayerCost)
        XCTAssertEqual(checkoutViewController?.issuer, self.selectedIssuer)
        XCTAssertEqual(checkoutViewController?.token, self.createdToken)
        
    }
    
    func checkInitialScreenAttributes(){
        // Verificar descripción de compra
        XCTAssertTrue(checkoutViewController!.displayPreferenceDescription)
        
        let sections = checkoutViewController?.numberOfSectionsInTableView((checkoutViewController?.checkoutTable)!)
        XCTAssertEqual(sections, 0)
        
    }
    
    
    func verifyConfirmPaymentOff() {
        let termsAndConditionsCell = checkoutViewController!.tableView(checkoutViewController!.checkoutTable, cellForRowAtIndexPath: NSIndexPath(forRow: 3, inSection: 1)) as!TermsAndConditionsViewCell
        XCTAssertNotNil(termsAndConditionsCell)
        let paymentButton = termsAndConditionsCell.paymentButton
        
        // Verificar que este disponible botón de pago y pagar
        XCTAssertTrue(paymentButton.enabled.boolValue)
        self.checkoutViewController!.confirmPayment()
        waitForExpectations(timeout: BaseTest.WAIT_EXPECTATION_TIME_INTERVAL, handler: nil)
        
    }
    
    func verifyConfirmPaymentCC(){
        let termsAndConditionsCell = checkoutViewController!.tableView(checkoutViewController!.checkoutTable, cellForRowAtIndexPath: NSIndexPath(forRow: 3, inSection: 1)) as! TermsAndConditionsViewCell
        XCTAssertNotNil(termsAndConditionsCell)
        let paymentButton = termsAndConditionsCell.paymentButton
        
        XCTAssertTrue(paymentButton.enabled.boolValue)
        self.checkoutViewController!.confirmPayment()
        waitForExpectations(timeout: BaseTest.WAIT_EXPECTATION_TIME_INTERVAL, handler: nil)

    }*/
    
}

class CheckoutViewModelTest : BaseTest {

    var instance : CheckoutViewModel?
    
    let mockPaymentMethodSearchItem = MockBuilder.buildPaymentMethodSearchItem("paymentMethodId")
    
    override func setUp() {
        self.instance = CheckoutViewModel(checkoutPreference: CheckoutPreference(), paymentData: PaymentData(), paymentOptionSelected: mockPaymentMethodSearchItem as! PaymentMethodOption)
    }
    
    func testIsPaymentMethodSelectedCard(){
        
        XCTAssertFalse(self.instance!.isPaymentMethodSelectedCard())
        
        self.instance!.paymentData.paymentMethod = MockBuilder.buildPaymentMethod("rapipago", name: "rapipago", paymentTypeId: PaymentTypeId.TICKET.rawValue)
        XCTAssertFalse(self.instance!.isPaymentMethodSelectedCard())
        
        self.instance!.paymentData.paymentMethod = MockBuilder.buildPaymentMethod("visa", name: "visa", paymentTypeId: PaymentTypeId.CREDIT_CARD.rawValue)
        XCTAssertTrue(self.instance!.isPaymentMethodSelectedCard())
        
        self.instance!.paymentData.paymentMethod = MockBuilder.buildPaymentMethod("debmaster", name: "master", paymentTypeId: PaymentTypeId.DEBIT_CARD.rawValue)
        XCTAssertTrue(self.instance!.isPaymentMethodSelectedCard())
    }
    
    func testNumberOfSections(){
        
        let preference = MockBuilder.buildCheckoutPreference()
        self.instance!.preference = preference
        
        XCTAssertEqual(6, self.instance!.numberOfSections())
    
    }
    
    func testIsPaymentMethodSelected(){
        
        self.instance!.paymentData.paymentMethod = MockBuilder.buildPaymentMethod("rapipago", name: "rapipago", paymentTypeId: PaymentTypeId.TICKET.rawValue)
        
        XCTAssertTrue(self.instance!.isPaymentMethodSelected())
        
        self.instance!.paymentData.paymentMethod = nil
            
        XCTAssertFalse(self.instance!.isPaymentMethodSelected())
        
    }
    
    func testIsUniquePaymentMethodAvailable(){
        /*let paymentMethodOff = MockBuilder.buildPaymentMethod("rapipago", name: "rapipago", paymentTypeId: PaymentTypeId.TICKET.rawValue)
        let paymentMethodCreditCard = MockBuilder.buildPaymentMethod("master", name: "master", paymentTypeId: PaymentTypeId.CREDIT_CARD.rawValue)
        
        var paymentMethodSearch = MockBuilder.buildPaymentMethodSearch(paymentMethods : [paymentMethodOff, paymentMethodCreditCard])
        
        self.instance!.paymentMethodSearch = paymentMethodSearch
        XCTAssertFalse(self.instance!.isUniquePaymentMethodAvailable())
        
        paymentMethodSearch = MockBuilder.buildPaymentMethodSearch(paymentMethods : [ paymentMethodCreditCard])
        
        self.instance!.paymentMethodSearch = paymentMethodSearch
        XCTAssertTrue(self.instance!.isUniquePaymentMethodAvailable())*/
    }
    
    func testNumberOfRowsInMainSectionWithOfflinePaymentMethod(){
        let paymentMethodOff = MockBuilder.buildPaymentMethod("redlink", name: "redlink", paymentTypeId: PaymentTypeId.ATM.rawValue)
        self.instance!.paymentData.paymentMethod = paymentMethodOff
        
        let result = self.instance!.numberOfRowsInMainSection()
        XCTAssertEqual(2, result)
    }

    func testNumberOfRowsInMainSectionWithCreditCardPaymentMethod() {
        let paymentMethodCreditCard = MockBuilder.buildPaymentMethod("master", name: "master", paymentTypeId: PaymentTypeId.CREDIT_CARD.rawValue)
        self.instance!.paymentData.paymentMethod = paymentMethodCreditCard
        
        let result = self.instance!.numberOfRowsInMainSection()
        XCTAssertEqual(3, result)
    }
    
    func testIsPreferenceLoaded(){
        XCTAssertTrue(self.instance!.isPreferenceLoaded())
        
        let preference = MockBuilder.buildCheckoutPreference()
        self.instance!.preference = preference
        XCTAssertTrue(self.instance!.isPreferenceLoaded())
    }
    
    func testGetTotalAmount() {
        let paymentMethodCreditCard = MockBuilder.buildPaymentMethod("master", name: "master", paymentTypeId: PaymentTypeId.CREDIT_CARD.rawValue)
        self.instance!.paymentData.paymentMethod = paymentMethodCreditCard
        self.instance!.paymentData.payerCost = MockBuilder.buildPayerCost()
        self.instance!.paymentData.payerCost!.totalAmount = 10
        var totalAmount = self.instance!.getTotalAmount()
        XCTAssertEqual(totalAmount, self.instance!.paymentData.payerCost!.totalAmount)
        
        let checkoutPreference = MockBuilder.buildCheckoutPreference()
        self.instance!.preference = checkoutPreference
        self.instance!.paymentData.payerCost = nil
        totalAmount = self.instance!.getTotalAmount()
        XCTAssertEqual(totalAmount, checkoutPreference.getAmount())
    }
    
    func testShouldDisplayNoRate(){
        
        // No payerCost loaded
        XCTAssertFalse(self.instance!.shouldDisplayNoRate())
        
        // PayerCost with installmentRate
        let payerCost = MockBuilder.buildPayerCost()
        payerCost.installmentRate = 10.0
        self.instance!.paymentData.payerCost = payerCost
        XCTAssertFalse(self.instance!.shouldDisplayNoRate())
        
        // PayerCost with no installmentRate but one installment
        let payerCostOneInstallment = MockBuilder.buildPayerCost()
        payerCostOneInstallment.installmentRate = 0.0
        payerCostOneInstallment.installments = 1
        self.instance!.paymentData.payerCost = payerCostOneInstallment
        XCTAssertFalse(self.instance!.shouldDisplayNoRate())
        
        // PayerCost with no installmentRate and few installments
        let payerCostWithNoRate = MockBuilder.buildPayerCost()
        payerCostWithNoRate.installmentRate = 0.0
        payerCostWithNoRate.installments = 6
        self.instance!.paymentData.payerCost = payerCostWithNoRate
        XCTAssertTrue(self.instance!.shouldDisplayNoRate())
    }

}
