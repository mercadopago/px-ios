//
//  PaymentVaultViewControllerTest.swift
//  MercadoPagoSDK
//
//  Created by Maria cristina rodriguez on 22/1/16.
//  Copyright © 2016 MercadoPago. All rights reserved.
//

import XCTest

class PaymentVaultViewControllerTest: BaseTest {

  /*  var paymentVaultViewController : MockPaymentVaultViewController?
    var mpNavigationController : MPNavigationController?
    var paymentMethodSelected : PaymentMethod?
    var tokenCreated : Token?
    var issuerSelected : Issuer?
    var payerCostSelected : PayerCost?
    
    override func setUp() {
        super.setUp()
    }
    
    override func tearDown() {
        super.tearDown()
        MercadoPagoContext.setBaseURL("")
        MercadoPagoContext.setCustomerURI("")
        MercadoPagoContext.setMerchantAccessToken("")
    }
    
    func testInit() {
        
        self.paymentVaultViewController = MockPaymentVaultViewController(amount: 2579, paymentPreference: nil, callback: { (paymentMethod, tokenId, issuer, installments) -> Void in
            
        })
        
        XCTAssertEqual(paymentVaultViewController!.merchantBaseUrl, MercadoPagoContext.baseURL())
        XCTAssertEqual(paymentVaultViewController!.publicKey, MercadoPagoContext.publicKey())
        XCTAssertEqual(paymentVaultViewController!.merchantAccessToken,  MercadoPagoContext.merchantAccessToken())
        XCTAssertNil(paymentVaultViewController?.viewModel.currentPaymentMethodSearch)
        XCTAssertNil(paymentVaultViewController?.viewModel.paymentMethods)
        
        self.simulateViewDidLoadFor(self.paymentVaultViewController!)
        let nav = UINavigationController(rootViewController: self.paymentVaultViewController!)
        
        XCTAssertNotNil(self.paymentVaultViewController?.viewModel.currentPaymentMethodSearch)
        XCTAssertTrue((self.paymentVaultViewController?.viewModel.currentPaymentMethodSearch!.count)! > 1)
        XCTAssertNotNil(paymentVaultViewController?.viewModel.paymentMethods)
        XCTAssertNotNil((paymentVaultViewController?.viewModel.paymentMethods.count)! > 1)
        XCTAssertNotNil(self.paymentVaultViewController?.paymentsTable)
        // Verify no customer payment methods
         XCTAssertTrue(self.paymentVaultViewController?.paymentsTable.numberOfRows(inSection: 0) == 0)
        // Payments options
        XCTAssertTrue((self.paymentVaultViewController?.paymentsTable.numberOfRows(inSection: 1))! > 0)
        
        XCTAssertEqual(self.paymentVaultViewController?.viewModel.amount, 2579)
        XCTAssertNil(self.paymentVaultViewController!.viewModel.paymentPreference)

    }

    /*
     * Selección de medio de pago: se excluyen medios off (solo tarjeta disponible). Se redirige al usuario al formulario de tarjeta.
     * Selección de tarjeta inicia formulario de tarjeta.
     *
     */
    func testPaymentVaultMLA_onlyCreditCard(){
        
        let excludedPaymentTypeIds = Set([PaymentTypeId.TICKET.rawValue, PaymentTypeId.BANK_TRANSFER.rawValue])
        let paymentPreference = PaymentPreference()
        
        paymentPreference.excludedPaymentTypeIds = excludedPaymentTypeIds
        self.paymentVaultViewController = MockPaymentVaultViewController(amount: 2579, paymentPreference: paymentPreference, callback: { (paymentMethod, token, issuer, payerCost) in
            XCTAssertNotNil(paymentMethod)
            // Verificar selección correcta
            XCTAssertEqual(paymentMethod, self.paymentMethodSelected)
            XCTAssertEqual(token, self.tokenCreated)
            XCTAssertEqual(issuer, self.issuerSelected)
            XCTAssertEqual(payerCost, self.payerCostSelected)
        })
        
        self.simulateViewDidLoadFor(self.paymentVaultViewController!)
        let nav = UINavigationController(rootViewController: self.paymentVaultViewController!)
        
        XCTAssertEqual(self.paymentVaultViewController!.viewModel.paymentPreference, paymentPreference)
        XCTAssertNotNil(self.paymentVaultViewController!.viewModel.currentPaymentMethodSearch)
        
        self.verifyCustomerPaymentMethodsDisplayed(0)
        
        let availablePaymentTypes = MockBuilder.MLA_PAYMENT_TYPES.subtract(excludedPaymentTypeIds)
        XCTAssertTrue(self.paymentVaultViewController!.viewModel.currentPaymentMethodSearch.count == availablePaymentTypes.count)
        
        // Se seleccionó opción de CC
        XCTAssertEqual(self.paymentVaultViewController!.viewModel.currentPaymentMethodSearch[0].idPaymentMethodSearchItem, PaymentTypeId.CREDIT_CARD.rawValue)
        
        
    }
    
    /*
     * Selección de medio de pago: sin exlusiones. Todos los medios de pago disponibles.
     * Selección de tarjeta inicia formulario de tarjeta.
     * Selección de medio off retorna el medio de pago correspondiente.
     *
     */
    func testPaymentVaultMLA_noPaymentPreference(){
        
        self.paymentVaultViewController = MockPaymentVaultViewController(amount: 2579, paymentPreference: nil, callback: { (paymentMethod, token, issuer, payerCost) in
            XCTAssertNotNil(paymentMethod)
            // Verificar selección correcta
            XCTAssertEqual(paymentMethod, self.paymentMethodSelected)
            XCTAssertEqual(token, self.tokenCreated)
            XCTAssertEqual(issuer, self.issuerSelected)
            XCTAssertEqual(payerCost, self.payerCostSelected)
        })
        
        self.simulateViewDidLoadFor(self.paymentVaultViewController!)
        let nav = UINavigationController(rootViewController: self.paymentVaultViewController!)
        
        XCTAssertNil(paymentVaultViewController?.viewModel.paymentPreference)
        XCTAssertNotNil(self.paymentVaultViewController?.viewModel.currentPaymentMethodSearch)
        XCTAssertTrue(self.paymentVaultViewController?.viewModel.currentPaymentMethodSearch.count == MockBuilder.MLA_PAYMENT_TYPES.count)
        
        self.verifyCustomerPaymentMethodsDisplayed(0)
        
        let ccCell = self.paymentVaultViewController!.tableView(self.paymentVaultViewController!.paymentsTable, cellForRowAtIndexPath: NSIndexPath(forRow: 0, inSection: 1)) as! PaymentSearchCell
        XCTAssertEqual(self.paymentVaultViewController?.viewModel.currentPaymentMethodSearch[0].description, ccCell.paymentTitle.text)
        
        let cashOptions = self.paymentVaultViewController?.viewModel.currentPaymentMethodSearch[1].children
        XCTAssertNotNil(cashOptions)
        XCTAssertTrue(cashOptions?.count == 4)
        
        let redLinkOptions = self.paymentVaultViewController?.viewModel.currentPaymentMethodSearch[2].children
        XCTAssertNotNil(redLinkOptions)
        XCTAssertTrue(redLinkOptions?.count == 2)
        
        // Selección de tarjeta de crédito
        self.paymentVaultViewController?.tableView((self.paymentVaultViewController?.paymentsTable)!, didSelectRowAtIndexPath: NSIndexPath(forRow: 0, inSection: 1))
        
    
        
    }
    
    /*
     * Selección de medio de pago: se excluyen tarjetas y Transferencia bancaria. Ticket únicamente disponible.
     * Solo selección de medio de ticket disponible. Se retorna el medio de pago correspondiente.
     *
     */
    func testPaymentVaultMLA_ticketAvailable(){
        
        let excludedPaymentTypeIds = Set([PaymentTypeId.CREDIT_CARD.rawValue, PaymentTypeId.BANK_TRANSFER.rawValue])
        let paymentPreference = PaymentPreference()
        
        paymentPreference.excludedPaymentTypeIds = excludedPaymentTypeIds
        self.paymentVaultViewController = MockPaymentVaultViewController(amount: 2579, paymentPreference: paymentPreference, callback: { (paymentMethod, token, issuer, payerCost) in
            XCTAssertNotNil(paymentMethod)
            // Verificar selección correcta
            XCTAssertEqual(paymentMethod, self.paymentMethodSelected)
            XCTAssertEqual(token, self.tokenCreated)
            XCTAssertEqual(issuer, self.issuerSelected)
            XCTAssertEqual(payerCost, self.payerCostSelected)
        })
        
        self.simulateViewDidLoadFor(self.paymentVaultViewController!)
        let nav = UINavigationController(rootViewController: self.paymentVaultViewController!)
        
        XCTAssertEqual(self.paymentVaultViewController?.viewModel.paymentPreference, paymentPreference)
        XCTAssertNotNil(self.paymentVaultViewController?.viewModel.currentPaymentMethodSearch)
        XCTAssertTrue(self.paymentVaultViewController?.viewModel.currentPaymentMethodSearch.count == 4)
        
        self.verifyCustomerPaymentMethodsDisplayed(0)
        
        let offlinePM = self.paymentVaultViewController!.tableView(self.paymentVaultViewController!.paymentsTable, cellForRowAtIndexPath: NSIndexPath(forRow: 0, inSection: 1)) as! OfflinePaymentMethodCell
        for paymentMethodOff in (self.paymentVaultViewController?.viewModel.currentPaymentMethodSearch)! {
            XCTAssertNotNil(offlinePM)
            XCTAssertEqual(offlinePM.comment.text, paymentMethodOff.comment)
        }
        
        
    }
    
    /*
     * Selección de medio de pago: Un solo medio de pago off disponible.
     * No se visualiza pantalla de medios de pago. Se reotrna el medio de pago correspondiente.
     *
     */
    func testPaymentVaultMLA_onePaymentMethodOff(){
        
        let excludedPaymentTypeIds = Set([PaymentTypeId.CREDIT_CARD.rawValue, PaymentTypeId.BANK_TRANSFER.rawValue])
        let excludedPaymentMethodIds = Set(arrayLiteral: "bapropagos", "rapipago", "cargavirtual")
        let paymentPreference = PaymentPreference()
        paymentPreference.excludedPaymentTypeIds = excludedPaymentTypeIds
        paymentPreference.excludedPaymentMethodIds = excludedPaymentMethodIds
        
        self.paymentVaultViewController = MockPaymentVaultViewController(amount: 2579, paymentPreference: paymentPreference, callback: { (paymentMethod, token, issuer, payerCost) in
            XCTAssertNotNil(paymentMethod)
            // Verificar selección correcta
  //          XCTAssertEqual(paymentMethod, self.paymentMethodSelected)
            XCTAssertEqual(token, self.tokenCreated)
            XCTAssertEqual(issuer, self.issuerSelected)
            XCTAssertEqual(payerCost, self.payerCostSelected)
        })
        self.simulateViewDidLoadFor(self.paymentVaultViewController!)
        let nav = UINavigationController(rootViewController: self.paymentVaultViewController!)
        
        self.verifyCustomerPaymentMethodsDisplayed(0)
        
        XCTAssertEqual(self.paymentVaultViewController?.viewModel.paymentPreference, paymentPreference)
        XCTAssertNotNil(self.paymentVaultViewController?.viewModel.currentPaymentMethodSearch)
        XCTAssertTrue(self.paymentVaultViewController?.viewModel.currentPaymentMethodSearch.count == 1)
        
        // Se seleccionó una acción por default
//        XCTAssertTrue(self.paymentVaultViewController!.optionSelected)
        
    }
 
    /*
     * Selección de medio de pago: selección de medio OFF. Sin exclusiones de pago.
     * Se visualizan los pagos del cliente
     */
    func testPaymentVaultMLAwithCustomerPaymentMethods_paymentMethodOff(){
        
        MercadoPagoContext.setBaseURL("http://url.com")
        MercadoPagoContext.setCustomerURI("/customerUri")
        MercadoPagoContext.setMerchantAccessToken(MockBuilder.MERCHANT_ACCESS_TOKEN)
        
        self.paymentVaultViewController = MockPaymentVaultViewController(amount: 2579, paymentPreference: nil, callback: { (paymentMethod, token, issuer, payerCost) in
            XCTAssertNotNil(paymentMethod)
            // Verificar selección correcta
            XCTAssertEqual(paymentMethod, self.paymentMethodSelected)
            XCTAssertEqual(token, self.tokenCreated)
            XCTAssertEqual(issuer, self.issuerSelected)
            XCTAssertEqual(payerCost, self.payerCostSelected)
        })
        
        self.simulateViewDidLoadFor(self.paymentVaultViewController!)
        let nav = UINavigationController(rootViewController: self.paymentVaultViewController!)
        
        self.verifyCustomerPaymentMethodsDisplayed(2)
        
        XCTAssertNil(self.paymentVaultViewController?.viewModel.paymentPreference)
        XCTAssertNotNil(self.paymentVaultViewController?.viewModel.currentPaymentMethodSearch)
        
        
    }
    
    /*
     * Selección de medio de pago: sin exclusiones, selección tarjeta de crédito.
     * No se visualizan los pagos del cliente por falta de configuración
     */
    func testPaymentVaultMLAwithNoCustomerPaymentMethods_creditCard(){
        
        MercadoPagoContext.setBaseURL("http://url.com")
        MercadoPagoContext.setMerchantAccessToken(MockBuilder.MERCHANT_ACCESS_TOKEN)
        
        self.paymentVaultViewController = MockPaymentVaultViewController(amount: 2579, paymentPreference: nil, callback: { (paymentMethod, token, issuer, payerCost) in
            XCTAssertNotNil(paymentMethod)
            // Verificar selección correcta
            XCTAssertEqual(paymentMethod, self.paymentMethodSelected)
            XCTAssertEqual(token, self.tokenCreated)
            XCTAssertEqual(issuer, self.issuerSelected)
            XCTAssertEqual(payerCost, self.payerCostSelected)
        })
        
        self.simulateViewDidLoadFor(self.paymentVaultViewController!)
        let nav = UINavigationController(rootViewController: self.paymentVaultViewController!)
        
        self.verifyCustomerPaymentMethodsDisplayed(0)
        
        XCTAssertNil(self.paymentVaultViewController?.viewModel.paymentPreference)
        XCTAssertNotNil(self.paymentVaultViewController?.viewModel.currentPaymentMethodSearch)
        
        self.paymentVaultViewController?.tableView((self.paymentVaultViewController?.paymentsTable)!, didSelectRowAtIndexPath: NSIndexPath(forRow: 0, inSection: 1))
        
//        XCTAssertTrue(self.paymentVaultViewController!.optionSelected)
//        XCTAssertEqual(self.paymentVaultViewController!.paymentMethodIdSelected, "credit_card")
        
    }
    
    /*
     * Selección de medio de pago: sin exclusiones, selección tarjeta de crédito.
     * No se visualizan los pagos del cliente por falta de configuración
     */
    func testPaymentVaultMLAwithoutCustomerPaymentMethods_creditCard(){
        
        MercadoPagoContext.setBaseURL("http://url.com")
        MercadoPagoContext.setCustomerURI("/customerUri")
        
        self.paymentVaultViewController = MockPaymentVaultViewController(amount: 2579, paymentPreference: nil, callback: { (paymentMethod, token, issuer, payerCost) in
            XCTAssertNotNil(paymentMethod)
            // Verificar selección correcta
            XCTAssertEqual(paymentMethod, self.paymentMethodSelected)
            XCTAssertEqual(token, self.tokenCreated)
            XCTAssertEqual(issuer, self.issuerSelected)
            XCTAssertEqual(payerCost, self.payerCostSelected)
        })
        
        self.simulateViewDidLoadFor(self.paymentVaultViewController!)
        let nav = UINavigationController(rootViewController: self.paymentVaultViewController!)
        
        self.verifyCustomerPaymentMethodsDisplayed(0)
        
        XCTAssertNil(self.paymentVaultViewController?.viewModel.paymentPreference)
        XCTAssertNotNil(self.paymentVaultViewController?.viewModel.currentPaymentMethodSearch)
        
        self.paymentVaultViewController?.tableView((self.paymentVaultViewController?.paymentsTable)!, didSelectRowAtIndexPath: NSIndexPath(forRow: 0, inSection: 1))
        
//        XCTAssertTrue(self.paymentVaultViewController!.optionSelected)
//        XCTAssertEqual(self.paymentVaultViewController!.paymentMethodIdSelected, "credit_card")
        
    }
    
    /*
     * Selección de medio de pago: sin exclusiones, selección tarjeta de crédito.
     * Se visualizan los medio de pagos del cliente
     */
    func testPaymentVaultMLAwithCustomerPaymentMethods_masterCustomerCardSelected(){
        
        MercadoPagoContext.setBaseURL("http://url.com")
        MercadoPagoContext.setCustomerURI("/customerUri")
        MercadoPagoContext.setMerchantAccessToken(MockBuilder.MERCHANT_ACCESS_TOKEN)
        
        self.paymentVaultViewController = MockPaymentVaultViewController(amount: 2579, paymentPreference: nil, callback: { (paymentMethod, token, issuer, payerCost) in
            XCTAssertNotNil(paymentMethod)
            // Verificar selección correcta
            XCTAssertEqual(paymentMethod, self.paymentMethodSelected)
            XCTAssertEqual(token, self.tokenCreated)
            XCTAssertEqual(issuer, self.issuerSelected)
            XCTAssertEqual(payerCost, self.payerCostSelected)
        })
        
        self.simulateViewDidLoadFor(self.paymentVaultViewController!)
        let nav = UINavigationController(rootViewController: self.paymentVaultViewController!)
        
        self.verifyCustomerPaymentMethodsDisplayed(2)
        
        XCTAssertNil(self.paymentVaultViewController?.viewModel.paymentPreference)
        XCTAssertNotNil(self.paymentVaultViewController?.viewModel.currentPaymentMethodSearch)
        
        // Selección de tarjeta guardada de master
        self.paymentVaultViewController?.tableView((self.paymentVaultViewController?.paymentsTable)!, didSelectRowAtIndexPath: NSIndexPath(forRow: 0, inSection: 0))
        //TODO
       
    }
    
    /*
     * Selección de medio de pago: sin exclusiones, selección de medio off.
     * Se visualizan los medio de pagos del cliente en la primer pantalla. No se visualizan en la siguiente.
     */
    func testPaymentVaultMLAwithCustomerPaymentMethods_rapipagoSelected(){
        
        MercadoPagoContext.setBaseURL("http://url.com")
        MercadoPagoContext.setCustomerURI("/customerUri")
        MercadoPagoContext.setMerchantAccessToken(MockBuilder.MERCHANT_ACCESS_TOKEN)
        
        self.paymentVaultViewController = MockPaymentVaultViewController(amount: 2579, paymentPreference: nil, callback: { (paymentMethod, token, issuer, payerCost) in
            XCTAssertNotNil(paymentMethod)
            // Verificar selección correcta
            XCTAssertEqual(paymentMethod, self.paymentMethodSelected)
            XCTAssertEqual(token, self.tokenCreated)
            XCTAssertEqual(issuer, self.issuerSelected)
            XCTAssertEqual(payerCost, self.payerCostSelected)
        })
        
        self.simulateViewDidLoadFor(self.paymentVaultViewController!)
        let nav = UINavigationController(rootViewController: self.paymentVaultViewController!)
        
        self.verifyCustomerPaymentMethodsDisplayed(2)
        
        XCTAssertNil(self.paymentVaultViewController?.viewModel.paymentPreference)
        XCTAssertNotNil(self.paymentVaultViewController?.viewModel.currentPaymentMethodSearch)
        
        // Selección de tarjeta guardada de master
        self.paymentVaultViewController?.tableView((self.paymentVaultViewController?.paymentsTable)!, didSelectRowAtIndexPath: NSIndexPath(forRow: 1, inSection: 1))
        //TODO
        self.paymentVaultViewController?.navigationController?.viewControllers
        
    }
    
    func verifyCustomerPaymentMethodsDisplayed(customerPaymentMethodsCount : Int){
        if customerPaymentMethodsCount > 0 {
            XCTAssertNotNil(self.paymentVaultViewController!.viewModel.customerCards)
        } else {
            XCTAssertNil(self.paymentVaultViewController!.viewModel.customerCards)
        }
        
        XCTAssertTrue(self.paymentVaultViewController?.viewModel.customerCards ==  nil || (self.paymentVaultViewController?.viewModel.customerCards?.count == customerPaymentMethodsCount) )
        XCTAssertTrue(self.paymentVaultViewController?.numberOfSectionsInTableView((self.paymentVaultViewController?.paymentsTable)!) == 2)
        
        let expectedNumberOfRows = customerPaymentMethodsCount > 3 ? 3 : customerPaymentMethodsCount
        XCTAssertTrue(self.paymentVaultViewController?.tableView((self.paymentVaultViewController?.paymentsTable)!, numberOfRowsInSection: 0) == expectedNumberOfRows)

    }
    
    /*
     * Selección de medio de pago: sin exclusiones de pago.
     * Se visualizan los medios de pago del cliente en MP
     */
    func testPaymentVaultMLAwithCustomerPaymentMethodsFromGroups_selectPayWithMP(){
    
        
        self.paymentVaultViewController = MockPaymentVaultViewController(amount: 2000, paymentPreference: nil, callback: { (paymentMethod, token, issuer, payerCost) in
            XCTAssertNotNil(paymentMethod)
            // Verificar selección correcta
            XCTAssertEqual(paymentMethod, self.paymentMethodSelected)
            XCTAssertEqual(token, self.tokenCreated)
            XCTAssertEqual(issuer, self.issuerSelected)
            XCTAssertEqual(payerCost, self.payerCostSelected)
        })
        
        self.simulateViewDidLoadFor(self.paymentVaultViewController!)
        let nav = UINavigationController(rootViewController: self.paymentVaultViewController!)
        
        self.verifyCustomerPaymentMethodsDisplayed(5)
        
        XCTAssertNil(self.paymentVaultViewController?.viewModel.paymentPreference)
        XCTAssertNotNil(self.paymentVaultViewController?.viewModel.currentPaymentMethodSearch)
        
    }

    func testGetCellFor(){
        let paymentMethodSearchItem = PaymentMethodSearchItem()
        paymentMethodSearchItem.showIcon = false
        paymentMethodSearchItem.description = "description"
        
        self.paymentVaultViewController = MockPaymentVaultViewController(amount: 2579, paymentPreference: nil, callback: { (paymentMethod, token, issuer, payerCost) in
        })
        self.simulateViewDidLoadFor(self.paymentVaultViewController!)
        
        let paymentSearchCell = self.paymentVaultViewController?.getCellFor(paymentMethodSearchItem)
        XCTAssertTrue(paymentSearchCell!.isKindOfClass(PaymentTitleViewCell))
        XCTAssertEqual((paymentSearchCell as! PaymentTitleViewCell).paymentTitle.text, "description")
        
        paymentMethodSearchItem.showIcon = true
        paymentMethodSearchItem.idPaymentMethodSearchItem = "invalid_id"
        paymentMethodSearchItem.comment = "comment"
        let paymentTitleAndCommentCell = self.paymentVaultViewController?.getCellFor(paymentMethodSearchItem)
    
        XCTAssertTrue(paymentTitleAndCommentCell!.isKindOfClass(PaymentTitleAndCommentViewCell))
        XCTAssertEqual((paymentTitleAndCommentCell as! PaymentTitleAndCommentViewCell).paymentComment.text, "comment")
        
        
        paymentMethodSearchItem.type = PaymentMethodSearchItemType.PAYMENT_METHOD
        paymentMethodSearchItem.idPaymentMethodSearchItem = "rapipago"
                let offlinePaymentMethodCell = self.paymentVaultViewController?.getCellFor(paymentMethodSearchItem)
        
        XCTAssertTrue(offlinePaymentMethodCell!.isKindOfClass(OfflinePaymentMethodCell))
        XCTAssertEqual((offlinePaymentMethodCell as! OfflinePaymentMethodCell).comment.text, "comment")
        
        paymentMethodSearchItem.comment = ""
        paymentMethodSearchItem.idPaymentMethodSearchItem = "cargavirtual"
        let offlinePaymentMethodWithDescriptionCell = self.paymentVaultViewController?.getCellFor(paymentMethodSearchItem)
        
        XCTAssertTrue(offlinePaymentMethodWithDescriptionCell!.isKindOfClass(OfflinePaymentMethodWithDescriptionCell))
        XCTAssertEqual((offlinePaymentMethodWithDescriptionCell as! OfflinePaymentMethodWithDescriptionCell).paymentDescription.text, "description")
        
        
    }
    
    func testsCellForRow(){
        self.paymentVaultViewController = MockPaymentVaultViewController(amount: 2000, paymentPreference: nil, callback: { (paymentMethod, token, issuer, payerCost) in
            XCTAssertNotNil(paymentMethod)
            // Verificar selección correcta
            XCTAssertEqual(paymentMethod, self.paymentMethodSelected)
            XCTAssertEqual(token, self.tokenCreated)
            XCTAssertEqual(issuer, self.issuerSelected)
            XCTAssertEqual(payerCost, self.payerCostSelected)
        })
        self.simulateViewDidLoadFor(self.paymentVaultViewController!)
        let cell = self.paymentVaultViewController?.tableView((self.paymentVaultViewController?.paymentsTable)!, cellForRowAtIndexPath: NSIndexPath(forRow: 0, inSection: 0))

        let cell2 = self.paymentVaultViewController?.tableView((self.paymentVaultViewController?.paymentsTable)!, cellForRowAtIndexPath: NSIndexPath(forRow: 0, inSection: 1))

    }
    
    func testsDidSelectRow(){
        self.paymentVaultViewController = MockPaymentVaultViewController(amount: 2000, paymentPreference: nil, callback: { (paymentMethod, token, issuer, payerCost) in
            XCTAssertNotNil(paymentMethod)
            // Verificar selección correcta
            XCTAssertEqual(paymentMethod, self.paymentMethodSelected)
            XCTAssertEqual(token, self.tokenCreated)
            XCTAssertEqual(issuer, self.issuerSelected)
            XCTAssertEqual(payerCost, self.payerCostSelected)
        })
        self.simulateViewDidLoadFor(self.paymentVaultViewController!)
        
    }
}

class PaymentVaultViewModelTest: BaseTest {
    
    var paymentVaultViewModel : PaymentVaultViewModel?

    
    override func setUp() {
        super.setUp()
        self.paymentVaultViewModel = PaymentVaultViewModel(amount : 200, paymentPrefence : nil)
    }
    
    override func tearDown() {
        super.tearDown()
    }
    
    func testValidCustomerInfoAvailable(){
        MercadoPagoContext.setBaseURL("http://url.com")
        MercadoPagoContext.setCustomerURI("/customerUri")
        MercadoPagoContext.setMerchantAccessToken(MockBuilder.MERCHANT_ACCESS_TOKEN)
        
        XCTAssertTrue(self.paymentVaultViewModel!.shouldGetCustomerCardsInfo())
    }
    
    func testValidCustomerInfo_invalidInfoAvailable(){
        MercadoPagoContext.setBaseURL("http://url.com")
        MercadoPagoContext.setMerchantAccessToken(MockBuilder.MERCHANT_ACCESS_TOKEN)
        
        XCTAssertFalse(self.paymentVaultViewModel!.shouldGetCustomerCardsInfo())
        
        MercadoPagoContext.setBaseURL("")
        MercadoPagoContext.setCustomerURI("/customerUri")
        
        XCTAssertFalse(self.paymentVaultViewModel!.shouldGetCustomerCardsInfo())
        
        MercadoPagoContext.setMerchantAccessToken("")
        MercadoPagoContext.setBaseURL("http://url.com")
        XCTAssertFalse(self.paymentVaultViewModel!.shouldGetCustomerCardsInfo())
        
        MercadoPagoContext.setBaseURL("")
        XCTAssertFalse(self.paymentVaultViewModel!.shouldGetCustomerCardsInfo())
    }
    
    func testGetCustomerCardsToDisplayCount(){
        
        XCTAssertEqual(self.paymentVaultViewModel!.getCustomerPaymentMethodsToDisplayCount(), 0)
        
        let card = CustomerPaymentMethod()
        card._id = "cardMock"
        self.paymentVaultViewModel!.customerCards = []
        self.paymentVaultViewModel!.customerCards?.append(card)
        
        XCTAssertEqual(self.paymentVaultViewModel!.getCustomerPaymentMethodsToDisplayCount(), 1)
        
        let secondCard = CustomerPaymentMethod()
        secondCard._id = "cardMock"
        self.paymentVaultViewModel!.customerCards!.append(secondCard)
        
        let thirdCard = CustomerPaymentMethod()
        thirdCard._id = "cardMock"
        self.paymentVaultViewModel!.customerCards!.append(thirdCard)
        
        XCTAssertEqual(self.paymentVaultViewModel!.getCustomerPaymentMethodsToDisplayCount(), 3)
        
        let fourthCard = Card()
        self.paymentVaultViewModel!.customerCards!.append(fourthCard)
        
        XCTAssertEqual(self.paymentVaultViewModel!.getCustomerPaymentMethodsToDisplayCount(), 3)
        
        self.paymentVaultViewModel!.customerCards!.remove(at: 3)
        
        XCTAssertEqual(self.paymentVaultViewModel!.getCustomerPaymentMethodsToDisplayCount(), 3)
        
        self.paymentVaultViewModel!.customerCards!.remove(at: 2)
        
        XCTAssertEqual(self.paymentVaultViewModel!.getCustomerPaymentMethodsToDisplayCount(), 2)
        
        self.paymentVaultViewModel!.customerCards!.removeAll()
        
        XCTAssertEqual(self.paymentVaultViewModel!.getCustomerPaymentMethodsToDisplayCount(), 0)
    }
    
    func testGetExcludedPaymentTypeIds() {
        
        let noExcludedPaymentTypeIds = self.paymentVaultViewModel?.getExcludedPaymentTypeIds()
        XCTAssertNil(noExcludedPaymentTypeIds)
        
        let paymentPreference = PaymentPreference()
        paymentPreference.excludedPaymentTypeIds = ["ticket", "credit_card"]
        paymentPreference.excludedPaymentMethodIds = ["red_link"]
        
        self.paymentVaultViewModel = PaymentVaultViewModel(amount: 100, paymentPrefence: paymentPreference)
        
        let twoExcludedPaymentTypeIds = self.paymentVaultViewModel?.getExcludedPaymentTypeIds()
        XCTAssertEqual(twoExcludedPaymentTypeIds?.count, 2)
        

    }
    
    func testGetExcludedPaymentMethodIds() {
        
        let noExcludedPaymentMethodIds = self.paymentVaultViewModel?.getExcludedPaymentMethodIds()
        XCTAssertNil(noExcludedPaymentMethodIds)
        
        let paymentPreference = PaymentPreference()
        paymentPreference.excludedPaymentTypeIds = ["ticket", "credit_card"]
        paymentPreference.excludedPaymentMethodIds = ["red_link", "cargavirtual", "visa", "amex"]
        
        self.paymentVaultViewModel = PaymentVaultViewModel(amount: 100, paymentPrefence: paymentPreference)
        
        let twoExcludedPaymentMethodIds = self.paymentVaultViewModel?.getExcludedPaymentMethodIds()
        XCTAssertEqual(twoExcludedPaymentMethodIds?.count, 4)
        
    }
    
*/

}

class PaymentVaultViewModelTest: BaseTest {

    var instance: PaymentVaultViewModel?

    let mockPmSearchitem = MockBuilder.buildPaymentMethodSearchItem("pmId")

    override func setUp() {

    //let paymentMethodSearch = MockBuilder.buildPaymentMethodSearch(paymentMethods : [paymentMethodOff, paymentMethodCreditCard])

        instance = PaymentVaultViewModel(amount: 1.0, paymentPrefence : nil, paymentMethodOptions: [mockPmSearchitem], customerPaymentOptions: nil, isRoot: true, email: "sarasa@hotmail.com", mercadoPagoServicesAdapter: MercadoPagoServicesAdapter())
    }

    func testShouldGetCustomerCardsInfo() {

//        XCTAssertFalse(instance!.shouldGetCustomerCardsInfo())
//        
//        MercadoPagoContext.setBaseURL("baseUrl")
//        XCTAssertFalse(instance!.shouldGetCustomerCardsInfo())
//        
//        MercadoPagoContext.setCustomerURI("customerUri")
//        MercadoPagoContext.setMerchantAccessToken("merchantAT")
//        XCTAssertTrue(instance!.shouldGetCustomerCardsInfo())
//        
//        // CustomerUri invalid
//        MercadoPagoContext.setCustomerURI("")
//        MercadoPagoContext.setMerchantAccessToken("merchantAT")
//        XCTAssertFalse(instance!.shouldGetCustomerCardsInfo())
//        
//        //Valid input but no root viewController
//        MercadoPagoContext.setCustomerURI("customeruri")
//        instance!.isRoot = false
//        XCTAssertFalse(instance!.shouldGetCustomerCardsInfo())
//        
//        //Root vc, valid input but customerCards loaded already
//        instance!.isRoot = true
//        instance!.customerPaymentOptions = [MockBuilder.buildCard()]
//        XCTAssertFalse(instance!.shouldGetCustomerCardsInfo())

    }

    func testSetMaxSavedCardsInFlowPreference() {

        //Initialize Flow Preference
        let flowPreference = FlowPreference()
        flowPreference.setMaxSavedCardsToShow(fromInt: 5)
        MercadoPagoCheckout.setFlowPreference(flowPreference)

        //Load saved cards
        let cardMock = MockBuilder.buildCard()
        instance!.customerPaymentOptions = [cardMock, cardMock, cardMock, cardMock, cardMock, cardMock]
        let customerCardsToDisplay = instance!.getCustomerPaymentMethodsToDisplayCount()

        XCTAssertEqual(MercadoPagoCheckoutViewModel.flowPreference.getMaxSavedCardsToShow(), 5)
        XCTAssertEqual(MercadoPagoCheckoutViewModel.flowPreference.getMaxSavedCardsToShow(), customerCardsToDisplay)
        XCTAssertFalse(MercadoPagoCheckoutViewModel.flowPreference.isShowAllSavedCardsEnabled())
    }

    func testSetMoreMaxSavedCardsThanWeHaveInFlowPreference() {

        //Initialize Flow Preference
        let flowPreference = FlowPreference()
        flowPreference.setMaxSavedCardsToShow(fromInt: 8)
        MercadoPagoCheckout.setFlowPreference(flowPreference)

        //Load saved cards
        let cardMock = MockBuilder.buildCard()
        instance!.customerPaymentOptions = [cardMock, cardMock, cardMock, cardMock, cardMock, cardMock]
        let customerCardsToDisplay = instance!.getCustomerPaymentMethodsToDisplayCount()

        //Show the cards we have
        XCTAssertEqual(MercadoPagoCheckoutViewModel.flowPreference.getMaxSavedCardsToShow(), 8)
        XCTAssertEqual(customerCardsToDisplay, 6)
        XCTAssertFalse(MercadoPagoCheckoutViewModel.flowPreference.isShowAllSavedCardsEnabled())
    }

    func testSetMaxSavedCardsWithInvalidIntInFlowPreference() {

        //Initialize Flow Preference
        let flowPreference = FlowPreference()
        flowPreference.setMaxSavedCardsToShow(fromInt: 0)
        MercadoPagoCheckout.setFlowPreference(flowPreference)

        //Load saved cards
        let cardMock = MockBuilder.buildCard()
        instance!.customerPaymentOptions = [cardMock, cardMock, cardMock, cardMock, cardMock, cardMock]
        let customerCardsToDisplay = instance!.getCustomerPaymentMethodsToDisplayCount()

        XCTAssertEqual(MercadoPagoCheckoutViewModel.flowPreference.getMaxSavedCardsToShow(), FlowPreference.DEFAULT_MAX_SAVED_CARDS_TO_SHOW)
        XCTAssertEqual(MercadoPagoCheckoutViewModel.flowPreference.getMaxSavedCardsToShow(), customerCardsToDisplay)
        XCTAssertFalse(MercadoPagoCheckoutViewModel.flowPreference.isShowAllSavedCardsEnabled())
    }

    func testSetDefaultSavedCardsInFlowPreference() {

        //Initialize Flow Preference
        let flowPreference = FlowPreference()
        MercadoPagoCheckout.setFlowPreference(flowPreference)

        //Load saved cards
        let cardMock = MockBuilder.buildCard()
        instance!.customerPaymentOptions = [cardMock, cardMock, cardMock, cardMock, cardMock, cardMock]
        let customerCardsToDisplay = instance!.getCustomerPaymentMethodsToDisplayCount()

        XCTAssertEqual(MercadoPagoCheckoutViewModel.flowPreference.getMaxSavedCardsToShow(), FlowPreference.DEFAULT_MAX_SAVED_CARDS_TO_SHOW)
        XCTAssertEqual(MercadoPagoCheckoutViewModel.flowPreference.getMaxSavedCardsToShow(), customerCardsToDisplay)
        XCTAssertFalse(MercadoPagoCheckoutViewModel.flowPreference.isShowAllSavedCardsEnabled())
    }

    func testSetDefaultSavedCardsWithoutFlowPreference() {

        //Load saved cards
        let cardMock = MockBuilder.buildCard()
        instance!.customerPaymentOptions = [cardMock, cardMock, cardMock, cardMock, cardMock, cardMock]
        let customerCardsToDisplay = instance!.getCustomerPaymentMethodsToDisplayCount()

        XCTAssertEqual(MercadoPagoCheckoutViewModel.flowPreference.getMaxSavedCardsToShow(), FlowPreference.DEFAULT_MAX_SAVED_CARDS_TO_SHOW)
        XCTAssertEqual(MercadoPagoCheckoutViewModel.flowPreference.getMaxSavedCardsToShow(), customerCardsToDisplay)
        XCTAssertFalse(MercadoPagoCheckoutViewModel.flowPreference.isShowAllSavedCardsEnabled())
    }

    func testSetAllSavedCardsInFlowPreference() {

        //Initialize Flow Preference
        let flowPreference = FlowPreference()
        flowPreference.setMaxSavedCardsToShow(fromString: FlowPreference.SHOW_ALL_SAVED_CARDS_CODE)
        MercadoPagoCheckout.setFlowPreference(flowPreference)

        //Load saved cards
        let cardMock = MockBuilder.buildCard()
        instance!.customerPaymentOptions = [cardMock, cardMock, cardMock, cardMock, cardMock, cardMock]
        let customerCardsToDisplay = instance!.getCustomerPaymentMethodsToDisplayCount()

        XCTAssertEqual(customerCardsToDisplay, 6)
        XCTAssertTrue(MercadoPagoCheckoutViewModel.flowPreference.isShowAllSavedCardsEnabled())
    }

    func testSetAllSavedCardsWithInvalidStringInFlowPreference() {

        //Initialize Flow Preference
        let flowPreference = FlowPreference()
        flowPreference.setMaxSavedCardsToShow(fromString: "invalid")
        MercadoPagoCheckout.setFlowPreference(flowPreference)

        //Load saved cards
        let cardMock = MockBuilder.buildCard()
        instance!.customerPaymentOptions = [cardMock, cardMock, cardMock, cardMock, cardMock, cardMock]
        let customerCardsToDisplay = instance!.getCustomerPaymentMethodsToDisplayCount()

        XCTAssertEqual(customerCardsToDisplay, FlowPreference.DEFAULT_MAX_SAVED_CARDS_TO_SHOW)
        XCTAssertEqual(MercadoPagoCheckoutViewModel.flowPreference.getMaxSavedCardsToShow(), customerCardsToDisplay)
        XCTAssertFalse(MercadoPagoCheckoutViewModel.flowPreference.isShowAllSavedCardsEnabled())
    }

    func testSetAllSavedCardsWithEmptyStringInFlowPreference() {

        //Initialize Flow Preference
        let flowPreference = FlowPreference()
        flowPreference.setMaxSavedCardsToShow(fromString: "")
        MercadoPagoCheckout.setFlowPreference(flowPreference)

        //Load saved cards
        let cardMock = MockBuilder.buildCard()
        instance!.customerPaymentOptions = [cardMock, cardMock, cardMock, cardMock, cardMock, cardMock]
        let customerCardsToDisplay = instance!.getCustomerPaymentMethodsToDisplayCount()

        XCTAssertEqual(customerCardsToDisplay, FlowPreference.DEFAULT_MAX_SAVED_CARDS_TO_SHOW)
        XCTAssertEqual(MercadoPagoCheckoutViewModel.flowPreference.getMaxSavedCardsToShow(), customerCardsToDisplay)
        XCTAssertFalse(MercadoPagoCheckoutViewModel.flowPreference.isShowAllSavedCardsEnabled())
    }

    func testSetAllSavedCardsAndAccountMoneyInFlowPreference() {

        //Initialize Flow Preference
        let flowPreference = FlowPreference()
        flowPreference.setMaxSavedCardsToShow(fromString: FlowPreference.SHOW_ALL_SAVED_CARDS_CODE)
        MercadoPagoCheckout.setFlowPreference(flowPreference)

        //Load saved cards
        let cardMock = MockBuilder.buildCard()
        let mockAccountMoney = MockBuilder.buildCustomerPaymentMethod(paymentMethodId: "account_money", paymentTypeId: "account_money")

        let customerCards: [CardInformation] = [mockAccountMoney, cardMock, cardMock, cardMock, cardMock, cardMock, cardMock]
        instance!.customerPaymentOptions = customerCards

        let customerCardsToDisplay = instance!.getCustomerPaymentMethodsToDisplayCount()

        XCTAssertEqual(customerCardsToDisplay, 7)
        XCTAssertTrue(MercadoPagoCheckoutViewModel.flowPreference.isShowAllSavedCardsEnabled())
    }

    func testGetCustomerPaymentMethodsToDisplayCount() {

        //No customerCards loaded
        var customerCardsToDisplay = instance!.getCustomerPaymentMethodsToDisplayCount()
        XCTAssertEqual(0, customerCardsToDisplay)

        let cardMock = MockBuilder.buildCard()
        instance?.customerPaymentOptions = [cardMock]
        customerCardsToDisplay = instance!.getCustomerPaymentMethodsToDisplayCount()
        XCTAssertEqual(1, customerCardsToDisplay)

        instance!.customerPaymentOptions = [cardMock, cardMock]
        customerCardsToDisplay = instance!.getCustomerPaymentMethodsToDisplayCount()
        XCTAssertEqual(2, customerCardsToDisplay)

        // MaxSavedCardsToShow value should be 3
        XCTAssertEqual(3, MercadoPagoCheckoutViewModel.flowPreference.getMaxSavedCardsToShow())

        instance!.customerPaymentOptions = [cardMock, cardMock, cardMock, cardMock, cardMock, cardMock]
        customerCardsToDisplay = instance!.getCustomerPaymentMethodsToDisplayCount()

        XCTAssertEqual(MercadoPagoCheckoutViewModel.flowPreference.getMaxSavedCardsToShow(), customerCardsToDisplay)

        // Verify custom MaxSavedCardsToShow
        MercadoPagoCheckoutViewModel.flowPreference.maxSavedCardsToShow = 5

        customerCardsToDisplay = instance!.getCustomerPaymentMethodsToDisplayCount()
        XCTAssertEqual(MercadoPagoCheckoutViewModel.flowPreference.getMaxSavedCardsToShow(), customerCardsToDisplay)

    }

    func testGetDisplayedPaymentMethodsCount() {

        // Payment methods not loaded
        var paymentMethodCount = instance!.getDisplayedPaymentMethodsCount()
//        XCTAssertEqual(0, paymentMethodCount)

        // Payment methods not loaded
        let mockPaymentMethodSearchItem = MockBuilder.buildPaymentMethodSearchItem("paymentMethodId")
        instance!.paymentMethodOptions = [mockPaymentMethodSearchItem]
        paymentMethodCount = instance!.getDisplayedPaymentMethodsCount()
        XCTAssertEqual(1, paymentMethodCount)

        // Payment methods not loaded
        instance!.paymentMethodOptions = [mockPaymentMethodSearchItem, mockPaymentMethodSearchItem, mockPaymentMethodSearchItem]
        paymentMethodCount = instance!.getDisplayedPaymentMethodsCount()
        XCTAssertEqual(3, paymentMethodCount)

        // Display 3 payment methods from search and two cards
        let cardMock = MockBuilder.buildCard()
        instance!.customerPaymentOptions = [cardMock, cardMock]
        paymentMethodCount = instance!.getDisplayedPaymentMethodsCount()
        XCTAssertEqual(5, paymentMethodCount)

        // Display 3 payment methods from search and 3 cards (max available)
        instance!.customerPaymentOptions = [cardMock, cardMock, cardMock, cardMock]
        paymentMethodCount = instance!.getDisplayedPaymentMethodsCount()
        XCTAssertEqual(6, paymentMethodCount)

        // Verify custom MaxSavedCardsToShow
        MercadoPagoCheckoutViewModel.flowPreference.maxSavedCardsToShow = 4
        paymentMethodCount = instance!.getDisplayedPaymentMethodsCount()
        XCTAssertEqual(7, paymentMethodCount)
    }

    func testGetExcludedPaymentTypeIds() {

        var paymentTypeIdsExcluded = instance?.getExcludedPaymentTypeIds()
        XCTAssertNil(paymentTypeIdsExcluded)

        let pp = PaymentPreference()
        pp.excludedPaymentTypeIds = ["pm1", "pm2", "pm3"]

        instance = PaymentVaultViewModel(amount: 1.0, paymentPrefence : pp, paymentMethodOptions: [mockPmSearchitem], customerPaymentOptions: nil, isRoot: true, email: "sarasa@hotmail.com", mercadoPagoServicesAdapter: MercadoPagoServicesAdapter())
        paymentTypeIdsExcluded = instance?.getExcludedPaymentTypeIds()
        XCTAssertEqual(pp.excludedPaymentTypeIds, paymentTypeIdsExcluded)

    }

    func testGetExcludedPaymentMethodIds() {

        var paymentMethodIdsExcluded = instance!.getExcludedPaymentMethodIds()
        XCTAssertNil(paymentMethodIdsExcluded)

        let pp = PaymentPreference()
        pp.excludedPaymentMethodIds = ["pmA", "pmB", "pmC"]

        instance = PaymentVaultViewModel(amount: 1.0, paymentPrefence : pp, paymentMethodOptions: [mockPmSearchitem], customerPaymentOptions: nil, isRoot: true, email: "sarasa@hotmail.com", mercadoPagoServicesAdapter: MercadoPagoServicesAdapter())
        paymentMethodIdsExcluded = instance!.getExcludedPaymentMethodIds()
        XCTAssertEqual(pp.excludedPaymentMethodIds, paymentMethodIdsExcluded)

    }

    func testGetPaymentPreferenceDefaultPaymentMethodId() {

        var defaultPaymentMethodId = instance!.getPaymentPreferenceDefaultPaymentMethodId()
        XCTAssertNil(defaultPaymentMethodId)

        let pp = PaymentPreference()
        pp.defaultPaymentMethodId = "defaultPaymentMethodId"

        instance = PaymentVaultViewModel(amount: 1.0, paymentPrefence : pp, paymentMethodOptions: [mockPmSearchitem], customerPaymentOptions: nil, isRoot: true, email: "sarasa@hotmail.com", mercadoPagoServicesAdapter: MercadoPagoServicesAdapter())
        defaultPaymentMethodId = instance!.getPaymentPreferenceDefaultPaymentMethodId()
        XCTAssertEqual("defaultPaymentMethodId", defaultPaymentMethodId)
    }

    func testIsCustomerPaymentMethodOptionSelected() {

        // No customer cards available
        var wasCustomerCardSelected = instance!.isCustomerPaymentMethodOptionSelected(2)
        XCTAssertFalse(wasCustomerCardSelected)

        let cardMock = MockBuilder.buildCard()
        instance!.customerPaymentOptions = [cardMock, cardMock, cardMock, cardMock, cardMock]
        wasCustomerCardSelected = instance!.isCustomerPaymentMethodOptionSelected(0)
        XCTAssertTrue(wasCustomerCardSelected)

        // Max customer payment methods is 3
        wasCustomerCardSelected = instance!.isCustomerPaymentMethodOptionSelected(3)
        XCTAssertFalse(wasCustomerCardSelected)

        // Verify custom MaxSavedCardsToShow
        MercadoPagoCheckoutViewModel.flowPreference.maxSavedCardsToShow = 5
        wasCustomerCardSelected = instance!.isCustomerPaymentMethodOptionSelected(3)
        XCTAssertTrue(wasCustomerCardSelected)

        wasCustomerCardSelected = instance!.isCustomerPaymentMethodOptionSelected(6)
        XCTAssertFalse(wasCustomerCardSelected)
    }

    func testHasOnlyGroupsPaymentMethodAvailable() {

        var result = instance!.hasOnlyGroupsPaymentMethodAvailable()
        XCTAssertTrue(result)

        let mockPmSearchitem = MockBuilder.buildPaymentMethodSearchItem("pmId")
        instance!.paymentMethodOptions = [mockPmSearchitem]
        result = instance!.hasOnlyGroupsPaymentMethodAvailable()
        XCTAssertTrue(result)

        let mockAnotherPmSearchitem = MockBuilder.buildPaymentMethodSearchItem("pmIdAnother")
        instance!.paymentMethodOptions = [mockPmSearchitem, mockAnotherPmSearchitem]
        result = instance!.hasOnlyGroupsPaymentMethodAvailable()
        XCTAssertFalse(result)

        instance!.paymentMethodOptions = [mockPmSearchitem]
        let mockCard = MockBuilder.buildCard()
        instance!.customerPaymentOptions = [mockCard]
        result = instance!.hasOnlyGroupsPaymentMethodAvailable()
        XCTAssertFalse(result)

    }

    func testHasOnlyCustomerPaymentMethodAvailable() {
        var result = instance!.hasOnlyCustomerPaymentMethodAvailable()
        XCTAssertFalse(result)

        let mockPmSearchitem = MockBuilder.buildPaymentMethodSearchItem("pmId")
        instance!.paymentMethodOptions = [mockPmSearchitem]
        result = instance!.hasOnlyCustomerPaymentMethodAvailable()
        XCTAssertFalse(result)

        instance!.paymentMethodOptions = []
        let mockCard = MockBuilder.buildCard()
        instance!.customerPaymentOptions = [mockCard]
        result = instance!.hasOnlyCustomerPaymentMethodAvailable()
        XCTAssertTrue(result)

        instance!.customerPaymentOptions = [mockCard, mockCard]
        result = instance!.hasOnlyCustomerPaymentMethodAvailable()
        XCTAssertFalse(result)

    }

    func testSetPaymentMethodSearch() {

//        let pm = MockBuilder.buildPaymentMethod("id")
//        let anotherPm = MockBuilder.buildPaymentMethod("anotherId")
//        let pms = [pm, anotherPm]
//        instance!.setPaymentMethodSearch(paymentMethods: pms)
//        XCTAssertEqual(pms, instance!.paymentMethods)
//        XCTAssertNil(instance!.currentPaymentMethodSearch)
//        XCTAssertNil(instance!.customerCards)
//        XCTAssertNil(instance!.defaultPaymentOption)
//        
//        let mockPmSearchitem = MockBuilder.buildPaymentMethodSearchItem("pmId")
//        let mockAnotherPmSearchitem = MockBuilder.buildPaymentMethodSearchItem("anotherPmId")
//        let mockOneMorePmSearchitem = MockBuilder.buildPaymentMethodSearchItem("oneMorePmId")
//        let paymentMethodSearchitems = [mockPmSearchitem, mockAnotherPmSearchitem, mockOneMorePmSearchitem]
//        instance!.setPaymentMethodSearch(paymentMethods: pms, paymentMethodSearchItems: paymentMethodSearchitems)
//        XCTAssertEqual(pms, instance!.paymentMethods)
//        XCTAssertEqual(paymentMethodSearchitems, instance!.currentPaymentMethodSearch)
//        XCTAssertNil(instance!.customerCards)
//        XCTAssertNil(instance!.defaultPaymentOption)
//        
//        let mockCard = MockBuilder.buildCustomerPaymentMethod(paymentMethodId: "visa", paymentTypeId: "credit_card")
//        let mockAnotherCard = MockBuilder.buildCustomerPaymentMethod(paymentMethodId: "amex", paymentTypeId: "credit_card")
//        let mockOneAnotherCard = MockBuilder.buildCustomerPaymentMethod(paymentMethodId: "master", paymentTypeId: "credit_card")
//        let cards : [CardInformation] = [mockCard, mockAnotherCard, mockOneAnotherCard]
//        instance!.setPaymentMethodSearch(paymentMethods: pms, paymentMethodSearchItems: paymentMethodSearchitems, customerPaymentMethods: cards)
//        XCTAssertEqual(paymentMethodSearchitems, instance!.currentPaymentMethodSearch)
//        XCTAssertEqual(pms, instance!.paymentMethods)
//        XCTAssertNotNil(instance!.customerCards)
//        XCTAssertEqual(3, instance!.customerCards!.count)
//        XCTAssertNil(instance!.defaultPaymentOption)
//        
//        let mockAccountMoney = MockBuilder.buildCustomerPaymentMethod(paymentMethodId: "account_money", paymentTypeId: "account_money")
//        let customerCards : [CardInformation] = [mockAccountMoney, mockCard]
//        instance!.setPaymentMethodSearch(paymentMethods: pms, paymentMethodSearchItems: paymentMethodSearchitems, customerPaymentMethods: customerCards)
//        XCTAssertEqual(paymentMethodSearchitems, instance!.currentPaymentMethodSearch)
//        XCTAssertEqual(pms, instance!.paymentMethods)
//        XCTAssertNotNil(instance!.customerCards)
//        XCTAssertEqual(1, instance!.customerCards!.count)
//        XCTAssertEqual(instance!.customerCards![0].getPaymentMethodId(), "visa")

    }

    func testSetPaymentMethodSearchResponse() {
//        let mockPmSearchitem = MockBuilder.buildPaymentMethodSearchItem("pmId")
//        let mockAnotherPmSearchitem = MockBuilder.buildPaymentMethodSearchItem("anotherPmId")
//        let mockOneMorePmSearchitem = MockBuilder.buildPaymentMethodSearchItem("oneMorePmId")
//        
//        let paymentMethodSearchResponse = PaymentMethodSearch()
//        paymentMethodSearchResponse.groups = [mockPmSearchitem, mockAnotherPmSearchitem, mockOneMorePmSearchitem]
//        instance!.setPaymentMethodSearchResponse(paymentMethodSearchResponse)
//        //FALTA
    }

    /**
     *  getPaymentMethodOption() for groups payment methods
     */
    func testGetPaymentMethodOptionNoCustomerCard() {
        let mockPmSearchitem = MockBuilder.buildPaymentMethodSearchItem("pmId")
        let mockAnotherPmSearchitem = MockBuilder.buildPaymentMethodSearchItem("anotherPmId")
        let mockOneMorePmSearchitem = MockBuilder.buildPaymentMethodSearchItem("oneMorePmId")
        let mockOneLastPmSearchitem = MockBuilder.buildPaymentMethodSearchItem("oneLastPmId")
        instance!.paymentMethodOptions = [mockPmSearchitem, mockAnotherPmSearchitem, mockOneMorePmSearchitem, mockOneLastPmSearchitem]
        var result = instance!.getPaymentMethodOption(row : 0)
        XCTAssertEqual("pmId", result.getImageDescription())

        result = instance!.getPaymentMethodOption(row : 2)
        XCTAssertEqual("oneMorePmId", result.getImageDescription())

        result = instance!.getPaymentMethodOption(row : 3)
        XCTAssertEqual("oneLastPmId", result.getImageDescription())
    }

    /**
     *  getPaymentMethodOption() with customer cards
     */
    func testGetPaymentMethodOptionWithCustomerCards() {

        let mockCard = MockBuilder.buildCustomerPaymentMethod(paymentMethodId: "amex", paymentTypeId: "credit_card")
        let anotherMockCard = MockBuilder.buildCustomerPaymentMethod(paymentMethodId: "visa", paymentTypeId: "credit_card")
        instance!.customerPaymentOptions = [mockCard, anotherMockCard]

        let mockPmSearchitem = MockBuilder.buildPaymentMethodSearchItem("pmId")
        let mockAnotherPmSearchitem = MockBuilder.buildPaymentMethodSearchItem("anotherPmId")
        let mockOneMorePmSearchitem = MockBuilder.buildPaymentMethodSearchItem("oneMorePmId")
        let mockOneLastPmSearchitem = MockBuilder.buildPaymentMethodSearchItem("oneLastPmId")
        instance!.paymentMethodOptions = [mockPmSearchitem, mockAnotherPmSearchitem, mockOneMorePmSearchitem, mockOneLastPmSearchitem]

        var result = instance!.getPaymentMethodOption(row : 3)
        XCTAssertEqual("anotherPmId", result.getImageDescription())

        result = instance!.getPaymentMethodOption(row : 1)
        XCTAssertEqual("visa", result.getImageDescription())

        result = instance!.getPaymentMethodOption(row : 5)
        XCTAssertEqual("oneLastPmId", result.getImageDescription())
    }

    /**
     *  getPaymentMethodOption() with more customer cards than max of customer cards set
     */
    func testGetPaymentMethodOptionWithCustomerCardsAndMaxCustomerCardChanged() {

        let mockCard = MockBuilder.buildCustomerPaymentMethod(paymentMethodId: "amex", paymentTypeId: "credit_card")
        let anotherMockCard = MockBuilder.buildCustomerPaymentMethod(paymentMethodId: "visa", paymentTypeId: "credit_card")
        let oneMoreMockCard = MockBuilder.buildCustomerPaymentMethod(paymentMethodId: "master", paymentTypeId: "credit_card")
        let oneLastMockCard = MockBuilder.buildCustomerPaymentMethod(paymentMethodId: "elo", paymentTypeId: "credit_card")
        let thisIsTheLastMockCardIPromise = MockBuilder.buildCustomerPaymentMethod(paymentMethodId: "hipercard", paymentTypeId: "credit_card")
        instance!.customerPaymentOptions = [mockCard, anotherMockCard, oneMoreMockCard, oneLastMockCard, thisIsTheLastMockCardIPromise]

        let mockPmSearchitem = MockBuilder.buildPaymentMethodSearchItem("pmId")
        let mockAnotherPmSearchitem = MockBuilder.buildPaymentMethodSearchItem("anotherPmId")
        let mockOneMorePmSearchitem = MockBuilder.buildPaymentMethodSearchItem("oneMorePmId")
        let mockOneLastPmSearchitem = MockBuilder.buildPaymentMethodSearchItem("oneLastPmId")
        instance!.paymentMethodOptions = [mockPmSearchitem, mockAnotherPmSearchitem, mockOneMorePmSearchitem, mockOneLastPmSearchitem]

        var result = instance!.getPaymentMethodOption(row : 3)
        XCTAssertEqual("pmId", result.getImageDescription())

        result = instance!.getPaymentMethodOption(row : 1)
        XCTAssertEqual("visa", result.getImageDescription())

        result = instance!.getPaymentMethodOption(row : 2)
        XCTAssertEqual("master", result.getImageDescription())

        result = instance!.getPaymentMethodOption(row : 6)
        XCTAssertEqual("oneLastPmId", result.getImageDescription())

        //Change MaxSavedCardsToShow
        MercadoPagoCheckoutViewModel.flowPreference.maxSavedCardsToShow = 5

        result = instance!.getPaymentMethodOption(row : 3)
        XCTAssertEqual("elo", result.getImageDescription())

        result = instance!.getPaymentMethodOption(row : 0)
        XCTAssertEqual("amex", result.getImageDescription())

        result = instance!.getPaymentMethodOption(row : 4)
        XCTAssertEqual("hipercard", result.getImageDescription())

        result = instance!.getPaymentMethodOption(row : 5)
        XCTAssertEqual("pmId", result.getImageDescription())

        result = instance!.getPaymentMethodOption(row : 8)
        XCTAssertEqual("oneLastPmId", result.getImageDescription())

        //Change MaxSavedCardsToShow
        MercadoPagoCheckoutViewModel.flowPreference.maxSavedCardsToShow = 2

        result = instance!.getPaymentMethodOption(row : 2)
        XCTAssertEqual("pmId", result.getImageDescription())

        result = instance!.getPaymentMethodOption(row : 1)
        XCTAssertEqual("visa", result.getImageDescription())
    }

    /**
     *  optionSelected() for credit_card
     */
    func testOptionSelectedNewCard() {

//        let currentNavigationController = UINavigationController()
//        let cardPaymentMethodSearchitem = MockBuilder.buildPaymentMethodSearchItem("credit_card", type: PaymentMethodSearchItemType.PAYMENT_TYPE)
//        instance!.optionSelected(cardPaymentMethodSearchitem, navigationController: currentNavigationController, cancelPaymentCallback: {})
//        
//        XCTAssertNotNil(currentNavigationController.viewControllers)
//        XCTAssertTrue(currentNavigationController.viewControllers.count > 0)
//        XCTAssertTrue(currentNavigationController.viewControllers[0] is CardFormViewController)

    }

    /**
     *  optionSelected() for offline payment method
     */
    func testOptionSelectedOfflinePaymentmethod() {

//        let currentNavigationController = UINavigationController()
//        
//        let offlinePayment = MockBuilder.buildPaymentMethod("rapipago")
//        instance!.paymentMethods = [offlinePayment]
//        let offlinePaymentMethodSelected = MockBuilder.buildPaymentMethodSearchItem("rapipago", type: PaymentMethodSearchItemType.PAYMENT_METHOD)
//        self.instance!.callback = {
//            (paymentMethod: PaymentMethod, token:Token?, issuer: Issuer?, payerCost: PayerCost?) -> Void in
//            XCTAssertEqual("rapipago", paymentMethod._id)
//            XCTAssertNil(token)
//            XCTAssertNil(issuer)
//            XCTAssertNil(payerCost)
//            
//        }
//        
//        instance!.optionSelected(offlinePaymentMethodSelected, navigationController: currentNavigationController, cancelPaymentCallback: {})
//        XCTAssertEqual(0, currentNavigationController.viewControllers.count)
    }

    /**
     *  customerOptionSelected() for amex credit card
     */
    func testCustomerOptionSelected() {
//        let currentNavigationController = UINavigationController()
//        let visibleViewController = UIViewController()
//        let amexPaymentMethod = MockBuilder.buildPaymentMethod("amex")
//        let setting = Setting()
//        let securityCode = SecurityCode()
//        securityCode.length = 4
//        setting.securityCode = securityCode
//        amexPaymentMethod.settings = [setting]
//        let banamexPaymentMethod = MockBuilder.buildPaymentMethod("banamex")
//        instance!.paymentMethods = [banamexPaymentMethod, amexPaymentMethod]
//        
//        let customerCard = MockBuilder.buildCustomerPaymentMethod(paymentMethodId: "amex", paymentTypeId: "credit_card")
//        
//        instance!.customerOptionSelected(customerCardSelected: customerCard, navigationController: currentNavigationController, visibleViewController: visibleViewController)

    }

    /**
     *  customerOptionSelected() for account_money
     */
    func testCustomerOptionSelectedAccountMoney() {
        let currentNavigationController = UINavigationController()
        let visibleViewController = UIViewController()
        let amexPaymentMethod = MockBuilder.buildPaymentMethod("amex")
        let setting = Setting()
        let securityCode = SecurityCode()
        securityCode.length = 4
        setting.securityCode = securityCode
        amexPaymentMethod.settings = [setting]
        let accountMoney = MockBuilder.buildPaymentMethod("account_money")
        instance!.paymentMethods = [accountMoney, amexPaymentMethod]

        let customerCard = MockBuilder.buildCustomerPaymentMethod(paymentMethodId: "account_money", paymentTypeId: "account_money")

        instance!.callback = {
            (paymentMethod: PaymentMethod, token: Token?, issuer: Issuer?, payerCost: PayerCost?) -> Void in
            XCTAssertEqual("account_money", paymentMethod._id)
            XCTAssertNil(token)
            XCTAssertNil(issuer)
            XCTAssertNil(payerCost)
        }

        //instance!.optionSelected(customerCard as PaymentMethodOption as! PaymentMethodSearchItem, navigationController: currentNavigationController, cancelPaymentCallback: nil)

    }

    override func tearDown() {
        // Restore default value
        super.tearDown()
        MercadoPagoCheckoutViewModel.flowPreference.maxSavedCardsToShow = FlowPreference.DEFAULT_MAX_SAVED_CARDS_TO_SHOW
    }

}
