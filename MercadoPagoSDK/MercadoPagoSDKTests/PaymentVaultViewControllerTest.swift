//
//  PaymentVaultViewControllerTest.swift
//  MercadoPagoSDK
//
//  Created by Maria cristina rodriguez on 22/1/16.
//  Copyright © 2016 MercadoPago. All rights reserved.
//

import XCTest
@testable import MercadoPagoSDK

class PaymentVaultViewControllerTest: BaseTest {
    
    var paymentVaultViewController : MockPaymentVaultViewController?
    //var mpNavigationController : MPNavigationController?
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
    
//    func testInit() {
//        
//        self.paymentVaultViewController = MockPaymentVaultViewController(amount: 2579, paymentPreference: nil, callback: { (paymentMethod, tokenId, issuer, installments) -> Void in
//            
//        })
//        
//        XCTAssertEqual(paymentVaultViewController!.merchantBaseUrl, MercadoPagoContext.baseURL())
//        XCTAssertEqual(paymentVaultViewController!.publicKey, MercadoPagoContext.publicKey())
//        XCTAssertEqual(paymentVaultViewController!.merchantAccessToken,  MercadoPagoContext.merchantAccessToken())
//        XCTAssertNil(paymentVaultViewController?.viewModel.currentPaymentMethodSearch)
//        XCTAssertNil(paymentVaultViewController?.viewModel.paymentMethods)
//        
//        self.simulateViewDidLoadFor(self.paymentVaultViewController!)
//        let nav = UINavigationController(rootViewController: self.paymentVaultViewController!)
//        
//        XCTAssertNotNil(self.paymentVaultViewController?.viewModel.currentPaymentMethodSearch)
//        XCTAssertTrue((self.paymentVaultViewController?.viewModel.currentPaymentMethodSearch!.count)! > 1)
//        XCTAssertNotNil(paymentVaultViewController?.viewModel.paymentMethods)
//        XCTAssertNotNil((paymentVaultViewController?.viewModel.paymentMethods.count)! > 1)
//        XCTAssertNotNil(self.paymentVaultViewController?.paymentsTable)
//        // Verify no customer payment methods
//         XCTAssertTrue(self.paymentVaultViewController?.paymentsTable.numberOfRows(inSection: 0) == 0)
//        // Payments options
//        XCTAssertTrue((self.paymentVaultViewController?.paymentsTable.numberOfRows(inSection: 1))! > 0)
//        
//        XCTAssertEqual(self.paymentVaultViewController?.viewModel.amount, 2579)
//        XCTAssertNil(self.paymentVaultViewController!.viewModel.paymentPreference)
//
//    }
//
//    /*
//     * Selección de medio de pago: se excluyen medios off (solo tarjeta disponible). Se redirige al usuario al formulario de tarjeta.
//     * Selección de tarjeta inicia formulario de tarjeta.
//     *
//     */
//    func testPaymentVaultMLA_onlyCreditCard(){
//        
//        let excludedPaymentTypeIds = Set([PaymentTypeId.TICKET.rawValue, PaymentTypeId.BANK_TRANSFER.rawValue])
//        let paymentPreference = PaymentPreference()
//        
//        paymentPreference.excludedPaymentTypeIds = excludedPaymentTypeIds
//        self.paymentVaultViewController = MockPaymentVaultViewController(amount: 2579, paymentPreference: paymentPreference, callback: { (paymentMethod, token, issuer, payerCost) in
//            XCTAssertNotNil(paymentMethod)
//            // Verificar selección correcta
//            XCTAssertEqual(paymentMethod, self.paymentMethodSelected)
//            XCTAssertEqual(token, self.tokenCreated)
//            XCTAssertEqual(issuer, self.issuerSelected)
//            XCTAssertEqual(payerCost, self.payerCostSelected)
//        })
//        
//        self.simulateViewDidLoadFor(self.paymentVaultViewController!)
//        let nav = UINavigationController(rootViewController: self.paymentVaultViewController!)
//        
//        XCTAssertEqual(self.paymentVaultViewController!.viewModel.paymentPreference, paymentPreference)
//        XCTAssertNotNil(self.paymentVaultViewController!.viewModel.currentPaymentMethodSearch)
//        
//        self.verifyCustomerPaymentMethodsDisplayed(0)
//        
//        let availablePaymentTypes = MockBuilder.MLA_PAYMENT_TYPES.subtract(excludedPaymentTypeIds)
//        XCTAssertTrue(self.paymentVaultViewController!.viewModel.currentPaymentMethodSearch.count == availablePaymentTypes.count)
//        
//        // Se seleccionó opción de CC
//        XCTAssertEqual(self.paymentVaultViewController!.viewModel.currentPaymentMethodSearch[0].idPaymentMethodSearchItem, PaymentTypeId.CREDIT_CARD.rawValue)
//        
//        
//    }
//    
//    /*
//     * Selección de medio de pago: sin exlusiones. Todos los medios de pago disponibles.
//     * Selección de tarjeta inicia formulario de tarjeta.
//     * Selección de medio off retorna el medio de pago correspondiente.
//     *
//     */
//    func testPaymentVaultMLA_noPaymentPreference(){
//        
//        self.paymentVaultViewController = MockPaymentVaultViewController(amount: 2579, paymentPreference: nil, callback: { (paymentMethod, token, issuer, payerCost) in
//            XCTAssertNotNil(paymentMethod)
//            // Verificar selección correcta
//            XCTAssertEqual(paymentMethod, self.paymentMethodSelected)
//            XCTAssertEqual(token, self.tokenCreated)
//            XCTAssertEqual(issuer, self.issuerSelected)
//            XCTAssertEqual(payerCost, self.payerCostSelected)
//        })
//        
//        self.simulateViewDidLoadFor(self.paymentVaultViewController!)
//        let nav = UINavigationController(rootViewController: self.paymentVaultViewController!)
//        
//        XCTAssertNil(paymentVaultViewController?.viewModel.paymentPreference)
//        XCTAssertNotNil(self.paymentVaultViewController?.viewModel.currentPaymentMethodSearch)
//        XCTAssertTrue(self.paymentVaultViewController?.viewModel.currentPaymentMethodSearch.count == MockBuilder.MLA_PAYMENT_TYPES.count)
//        
//        self.verifyCustomerPaymentMethodsDisplayed(0)
//        
//        let ccCell = self.paymentVaultViewController!.tableView(self.paymentVaultViewController!.paymentsTable, cellForRowAtIndexPath: NSIndexPath(forRow: 0, inSection: 1)) as! PaymentSearchCell
//        XCTAssertEqual(self.paymentVaultViewController?.viewModel.currentPaymentMethodSearch[0].description, ccCell.paymentTitle.text)
//        
//        let cashOptions = self.paymentVaultViewController?.viewModel.currentPaymentMethodSearch[1].children
//        XCTAssertNotNil(cashOptions)
//        XCTAssertTrue(cashOptions?.count == 4)
//        
//        let redLinkOptions = self.paymentVaultViewController?.viewModel.currentPaymentMethodSearch[2].children
//        XCTAssertNotNil(redLinkOptions)
//        XCTAssertTrue(redLinkOptions?.count == 2)
//        
//        // Selección de tarjeta de crédito
//        self.paymentVaultViewController?.tableView((self.paymentVaultViewController?.paymentsTable)!, didSelectRowAtIndexPath: NSIndexPath(forRow: 0, inSection: 1))
//        
//    
//        
//    }
//    
//    /*
//     * Selección de medio de pago: se excluyen tarjetas y Transferencia bancaria. Ticket únicamente disponible.
//     * Solo selección de medio de ticket disponible. Se retorna el medio de pago correspondiente.
//     *
//     */
//    func testPaymentVaultMLA_ticketAvailable(){
//        
//        let excludedPaymentTypeIds = Set([PaymentTypeId.CREDIT_CARD.rawValue, PaymentTypeId.BANK_TRANSFER.rawValue])
//        let paymentPreference = PaymentPreference()
//        
//        paymentPreference.excludedPaymentTypeIds = excludedPaymentTypeIds
//        self.paymentVaultViewController = MockPaymentVaultViewController(amount: 2579, paymentPreference: paymentPreference, callback: { (paymentMethod, token, issuer, payerCost) in
//            XCTAssertNotNil(paymentMethod)
//            // Verificar selección correcta
//            XCTAssertEqual(paymentMethod, self.paymentMethodSelected)
//            XCTAssertEqual(token, self.tokenCreated)
//            XCTAssertEqual(issuer, self.issuerSelected)
//            XCTAssertEqual(payerCost, self.payerCostSelected)
//        })
//        
//        self.simulateViewDidLoadFor(self.paymentVaultViewController!)
//        let nav = UINavigationController(rootViewController: self.paymentVaultViewController!)
//        
//        XCTAssertEqual(self.paymentVaultViewController?.viewModel.paymentPreference, paymentPreference)
//        XCTAssertNotNil(self.paymentVaultViewController?.viewModel.currentPaymentMethodSearch)
//        XCTAssertTrue(self.paymentVaultViewController?.viewModel.currentPaymentMethodSearch.count == 4)
//        
//        self.verifyCustomerPaymentMethodsDisplayed(0)
//        
//        let offlinePM = self.paymentVaultViewController!.tableView(self.paymentVaultViewController!.paymentsTable, cellForRowAtIndexPath: NSIndexPath(forRow: 0, inSection: 1)) as! OfflinePaymentMethodCell
//        for paymentMethodOff in (self.paymentVaultViewController?.viewModel.currentPaymentMethodSearch)! {
//            XCTAssertNotNil(offlinePM)
//            XCTAssertEqual(offlinePM.comment.text, paymentMethodOff.comment)
//        }
//        
//        
//    }
//    
//    /*
//     * Selección de medio de pago: Un solo medio de pago off disponible.
//     * No se visualiza pantalla de medios de pago. Se reotrna el medio de pago correspondiente.
//     *
//     */
//    func testPaymentVaultMLA_onePaymentMethodOff(){
//        
//        let excludedPaymentTypeIds = Set([PaymentTypeId.CREDIT_CARD.rawValue, PaymentTypeId.BANK_TRANSFER.rawValue])
//        let excludedPaymentMethodIds = Set(arrayLiteral: "bapropagos", "rapipago", "cargavirtual")
//        let paymentPreference = PaymentPreference()
//        paymentPreference.excludedPaymentTypeIds = excludedPaymentTypeIds
//        paymentPreference.excludedPaymentMethodIds = excludedPaymentMethodIds
//        
//        self.paymentVaultViewController = MockPaymentVaultViewController(amount: 2579, paymentPreference: paymentPreference, callback: { (paymentMethod, token, issuer, payerCost) in
//            XCTAssertNotNil(paymentMethod)
//            // Verificar selección correcta
//  //          XCTAssertEqual(paymentMethod, self.paymentMethodSelected)
//            XCTAssertEqual(token, self.tokenCreated)
//            XCTAssertEqual(issuer, self.issuerSelected)
//            XCTAssertEqual(payerCost, self.payerCostSelected)
//        })
//        self.simulateViewDidLoadFor(self.paymentVaultViewController!)
//        let nav = UINavigationController(rootViewController: self.paymentVaultViewController!)
//        
//        self.verifyCustomerPaymentMethodsDisplayed(0)
//        
//        XCTAssertEqual(self.paymentVaultViewController?.viewModel.paymentPreference, paymentPreference)
//        XCTAssertNotNil(self.paymentVaultViewController?.viewModel.currentPaymentMethodSearch)
//        XCTAssertTrue(self.paymentVaultViewController?.viewModel.currentPaymentMethodSearch.count == 1)
//        
//        // Se seleccionó una acción por default
////        XCTAssertTrue(self.paymentVaultViewController!.optionSelected)
//        
//    }
// 
//    /*
//     * Selección de medio de pago: selección de medio OFF. Sin exclusiones de pago.
//     * Se visualizan los pagos del cliente
//     */
//    func testPaymentVaultMLAwithCustomerPaymentMethods_paymentMethodOff(){
//        
//        MercadoPagoContext.setBaseURL("http://url.com")
//        MercadoPagoContext.setCustomerURI("/customerUri")
//        MercadoPagoContext.setMerchantAccessToken(MockBuilder.MERCHANT_ACCESS_TOKEN)
//        
//        self.paymentVaultViewController = MockPaymentVaultViewController(amount: 2579, paymentPreference: nil, callback: { (paymentMethod, token, issuer, payerCost) in
//            XCTAssertNotNil(paymentMethod)
//            // Verificar selección correcta
//            XCTAssertEqual(paymentMethod, self.paymentMethodSelected)
//            XCTAssertEqual(token, self.tokenCreated)
//            XCTAssertEqual(issuer, self.issuerSelected)
//            XCTAssertEqual(payerCost, self.payerCostSelected)
//        })
//        
//        self.simulateViewDidLoadFor(self.paymentVaultViewController!)
//        let nav = UINavigationController(rootViewController: self.paymentVaultViewController!)
//        
//        self.verifyCustomerPaymentMethodsDisplayed(2)
//        
//        XCTAssertNil(self.paymentVaultViewController?.viewModel.paymentPreference)
//        XCTAssertNotNil(self.paymentVaultViewController?.viewModel.currentPaymentMethodSearch)
//        
//        
//    }
//    
//    /*
//     * Selección de medio de pago: sin exclusiones, selección tarjeta de crédito.
//     * No se visualizan los pagos del cliente por falta de configuración
//     */
//    func testPaymentVaultMLAwithNoCustomerPaymentMethods_creditCard(){
//        
//        MercadoPagoContext.setBaseURL("http://url.com")
//        MercadoPagoContext.setMerchantAccessToken(MockBuilder.MERCHANT_ACCESS_TOKEN)
//        
//        self.paymentVaultViewController = MockPaymentVaultViewController(amount: 2579, paymentPreference: nil, callback: { (paymentMethod, token, issuer, payerCost) in
//            XCTAssertNotNil(paymentMethod)
//            // Verificar selección correcta
//            XCTAssertEqual(paymentMethod, self.paymentMethodSelected)
//            XCTAssertEqual(token, self.tokenCreated)
//            XCTAssertEqual(issuer, self.issuerSelected)
//            XCTAssertEqual(payerCost, self.payerCostSelected)
//        })
//        
//        self.simulateViewDidLoadFor(self.paymentVaultViewController!)
//        let nav = UINavigationController(rootViewController: self.paymentVaultViewController!)
//        
//        self.verifyCustomerPaymentMethodsDisplayed(0)
//        
//        XCTAssertNil(self.paymentVaultViewController?.viewModel.paymentPreference)
//        XCTAssertNotNil(self.paymentVaultViewController?.viewModel.currentPaymentMethodSearch)
//        
//        self.paymentVaultViewController?.tableView((self.paymentVaultViewController?.paymentsTable)!, didSelectRowAtIndexPath: NSIndexPath(forRow: 0, inSection: 1))
//        
////        XCTAssertTrue(self.paymentVaultViewController!.optionSelected)
////        XCTAssertEqual(self.paymentVaultViewController!.paymentMethodIdSelected, "credit_card")
//        
//    }
//    
//    /*
//     * Selección de medio de pago: sin exclusiones, selección tarjeta de crédito.
//     * No se visualizan los pagos del cliente por falta de configuración
//     */
//    func testPaymentVaultMLAwithoutCustomerPaymentMethods_creditCard(){
//        
//        MercadoPagoContext.setBaseURL("http://url.com")
//        MercadoPagoContext.setCustomerURI("/customerUri")
//        
//        self.paymentVaultViewController = MockPaymentVaultViewController(amount: 2579, paymentPreference: nil, callback: { (paymentMethod, token, issuer, payerCost) in
//            XCTAssertNotNil(paymentMethod)
//            // Verificar selección correcta
//            XCTAssertEqual(paymentMethod, self.paymentMethodSelected)
//            XCTAssertEqual(token, self.tokenCreated)
//            XCTAssertEqual(issuer, self.issuerSelected)
//            XCTAssertEqual(payerCost, self.payerCostSelected)
//        })
//        
//        self.simulateViewDidLoadFor(self.paymentVaultViewController!)
//        let nav = UINavigationController(rootViewController: self.paymentVaultViewController!)
//        
//        self.verifyCustomerPaymentMethodsDisplayed(0)
//        
//        XCTAssertNil(self.paymentVaultViewController?.viewModel.paymentPreference)
//        XCTAssertNotNil(self.paymentVaultViewController?.viewModel.currentPaymentMethodSearch)
//        
//        self.paymentVaultViewController?.tableView((self.paymentVaultViewController?.paymentsTable)!, didSelectRowAtIndexPath: NSIndexPath(forRow: 0, inSection: 1))
//        
////        XCTAssertTrue(self.paymentVaultViewController!.optionSelected)
////        XCTAssertEqual(self.paymentVaultViewController!.paymentMethodIdSelected, "credit_card")
//        
//    }
//    
//    /*
//     * Selección de medio de pago: sin exclusiones, selección tarjeta de crédito.
//     * Se visualizan los medio de pagos del cliente
//     */
//    func testPaymentVaultMLAwithCustomerPaymentMethods_masterCustomerCardSelected(){
//        
//        MercadoPagoContext.setBaseURL("http://url.com")
//        MercadoPagoContext.setCustomerURI("/customerUri")
//        MercadoPagoContext.setMerchantAccessToken(MockBuilder.MERCHANT_ACCESS_TOKEN)
//        
//        self.paymentVaultViewController = MockPaymentVaultViewController(amount: 2579, paymentPreference: nil, callback: { (paymentMethod, token, issuer, payerCost) in
//            XCTAssertNotNil(paymentMethod)
//            // Verificar selección correcta
//            XCTAssertEqual(paymentMethod, self.paymentMethodSelected)
//            XCTAssertEqual(token, self.tokenCreated)
//            XCTAssertEqual(issuer, self.issuerSelected)
//            XCTAssertEqual(payerCost, self.payerCostSelected)
//        })
//        
//        self.simulateViewDidLoadFor(self.paymentVaultViewController!)
//        let nav = UINavigationController(rootViewController: self.paymentVaultViewController!)
//        
//        self.verifyCustomerPaymentMethodsDisplayed(2)
//        
//        XCTAssertNil(self.paymentVaultViewController?.viewModel.paymentPreference)
//        XCTAssertNotNil(self.paymentVaultViewController?.viewModel.currentPaymentMethodSearch)
//        
//        // Selección de tarjeta guardada de master
//        self.paymentVaultViewController?.tableView((self.paymentVaultViewController?.paymentsTable)!, didSelectRowAtIndexPath: NSIndexPath(forRow: 0, inSection: 0))
//        //TODO
//       
//    }
//    
//    /*
//     * Selección de medio de pago: sin exclusiones, selección de medio off.
//     * Se visualizan los medio de pagos del cliente en la primer pantalla. No se visualizan en la siguiente.
//     */
//    func testPaymentVaultMLAwithCustomerPaymentMethods_rapipagoSelected(){
//        
//        MercadoPagoContext.setBaseURL("http://url.com")
//        MercadoPagoContext.setCustomerURI("/customerUri")
//        MercadoPagoContext.setMerchantAccessToken(MockBuilder.MERCHANT_ACCESS_TOKEN)
//        
//        self.paymentVaultViewController = MockPaymentVaultViewController(amount: 2579, paymentPreference: nil, callback: { (paymentMethod, token, issuer, payerCost) in
//            XCTAssertNotNil(paymentMethod)
//            // Verificar selección correcta
//            XCTAssertEqual(paymentMethod, self.paymentMethodSelected)
//            XCTAssertEqual(token, self.tokenCreated)
//            XCTAssertEqual(issuer, self.issuerSelected)
//            XCTAssertEqual(payerCost, self.payerCostSelected)
//        })
//        
//        self.simulateViewDidLoadFor(self.paymentVaultViewController!)
//        let nav = UINavigationController(rootViewController: self.paymentVaultViewController!)
//        
//        self.verifyCustomerPaymentMethodsDisplayed(2)
//        
//        XCTAssertNil(self.paymentVaultViewController?.viewModel.paymentPreference)
//        XCTAssertNotNil(self.paymentVaultViewController?.viewModel.currentPaymentMethodSearch)
//        
//        // Selección de tarjeta guardada de master
//        self.paymentVaultViewController?.tableView((self.paymentVaultViewController?.paymentsTable)!, didSelectRowAtIndexPath: NSIndexPath(forRow: 1, inSection: 1))
//        //TODO
//        self.paymentVaultViewController?.navigationController?.viewControllers
//        
//    }
//    
//    func verifyCustomerPaymentMethodsDisplayed(customerPaymentMethodsCount : Int){
//        if customerPaymentMethodsCount > 0 {
//            XCTAssertNotNil(self.paymentVaultViewController!.viewModel.customerCards)
//        } else {
//            XCTAssertNil(self.paymentVaultViewController!.viewModel.customerCards)
//        }
//        
//        XCTAssertTrue(self.paymentVaultViewController?.viewModel.customerCards ==  nil || (self.paymentVaultViewController?.viewModel.customerCards?.count == customerPaymentMethodsCount) )
//        XCTAssertTrue(self.paymentVaultViewController?.numberOfSectionsInTableView((self.paymentVaultViewController?.paymentsTable)!) == 2)
//        
//        let expectedNumberOfRows = customerPaymentMethodsCount > 3 ? 3 : customerPaymentMethodsCount
//        XCTAssertTrue(self.paymentVaultViewController?.tableView((self.paymentVaultViewController?.paymentsTable)!, numberOfRowsInSection: 0) == expectedNumberOfRows)
//
//    }
//    
//    /*
//     * Selección de medio de pago: sin exclusiones de pago.
//     * Se visualizan los medios de pago del cliente en MP
//     */
//    func testPaymentVaultMLAwithCustomerPaymentMethodsFromGroups_selectPayWithMP(){
//    
//        
//        self.paymentVaultViewController = MockPaymentVaultViewController(amount: 2000, paymentPreference: nil, callback: { (paymentMethod, token, issuer, payerCost) in
//            XCTAssertNotNil(paymentMethod)
//            // Verificar selección correcta
//            XCTAssertEqual(paymentMethod, self.paymentMethodSelected)
//            XCTAssertEqual(token, self.tokenCreated)
//            XCTAssertEqual(issuer, self.issuerSelected)
//            XCTAssertEqual(payerCost, self.payerCostSelected)
//        })
//        
//        self.simulateViewDidLoadFor(self.paymentVaultViewController!)
//        let nav = UINavigationController(rootViewController: self.paymentVaultViewController!)
//        
//        self.verifyCustomerPaymentMethodsDisplayed(5)
//        
//        XCTAssertNil(self.paymentVaultViewController?.viewModel.paymentPreference)
//        XCTAssertNotNil(self.paymentVaultViewController?.viewModel.currentPaymentMethodSearch)
//        
//    }
//
//    func testGetCellFor(){
//        let paymentMethodSearchItem = PaymentMethodSearchItem()
//        paymentMethodSearchItem.showIcon = false
//        paymentMethodSearchItem.description = "description"
//        
//        self.paymentVaultViewController = MockPaymentVaultViewController(amount: 2579, paymentPreference: nil, callback: { (paymentMethod, token, issuer, payerCost) in
//        })
//        self.simulateViewDidLoadFor(self.paymentVaultViewController!)
//        
//        let paymentSearchCell = self.paymentVaultViewController?.getCellFor(paymentMethodSearchItem)
//        XCTAssertTrue(paymentSearchCell!.isKindOfClass(PaymentTitleViewCell))
//        XCTAssertEqual((paymentSearchCell as! PaymentTitleViewCell).paymentTitle.text, "description")
//        
//        paymentMethodSearchItem.showIcon = true
//        paymentMethodSearchItem.idPaymentMethodSearchItem = "invalid_id"
//        paymentMethodSearchItem.comment = "comment"
//        let paymentTitleAndCommentCell = self.paymentVaultViewController?.getCellFor(paymentMethodSearchItem)
//    
//        XCTAssertTrue(paymentTitleAndCommentCell!.isKindOfClass(PaymentTitleAndCommentViewCell))
//        XCTAssertEqual((paymentTitleAndCommentCell as! PaymentTitleAndCommentViewCell).paymentComment.text, "comment")
//        
//        
//        paymentMethodSearchItem.type = PaymentMethodSearchItemType.PAYMENT_METHOD
//        paymentMethodSearchItem.idPaymentMethodSearchItem = "rapipago"
//                let offlinePaymentMethodCell = self.paymentVaultViewController?.getCellFor(paymentMethodSearchItem)
//        
//        XCTAssertTrue(offlinePaymentMethodCell!.isKindOfClass(OfflinePaymentMethodCell))
//        XCTAssertEqual((offlinePaymentMethodCell as! OfflinePaymentMethodCell).comment.text, "comment")
//        
//        paymentMethodSearchItem.comment = ""
//        paymentMethodSearchItem.idPaymentMethodSearchItem = "cargavirtual"
//        let offlinePaymentMethodWithDescriptionCell = self.paymentVaultViewController?.getCellFor(paymentMethodSearchItem)
//        
//        XCTAssertTrue(offlinePaymentMethodWithDescriptionCell!.isKindOfClass(OfflinePaymentMethodWithDescriptionCell))
//        XCTAssertEqual((offlinePaymentMethodWithDescriptionCell as! OfflinePaymentMethodWithDescriptionCell).paymentDescription.text, "description")
//        
//        
//    }
//    
//    func testsCellForRow(){
//        self.paymentVaultViewController = MockPaymentVaultViewController(amount: 2000, paymentPreference: nil, callback: { (paymentMethod, token, issuer, payerCost) in
//            XCTAssertNotNil(paymentMethod)
//            // Verificar selección correcta
//            XCTAssertEqual(paymentMethod, self.paymentMethodSelected)
//            XCTAssertEqual(token, self.tokenCreated)
//            XCTAssertEqual(issuer, self.issuerSelected)
//            XCTAssertEqual(payerCost, self.payerCostSelected)
//        })
//        self.simulateViewDidLoadFor(self.paymentVaultViewController!)
//        let cell = self.paymentVaultViewController?.tableView((self.paymentVaultViewController?.paymentsTable)!, cellForRowAtIndexPath: NSIndexPath(forRow: 0, inSection: 0))
//
//        let cell2 = self.paymentVaultViewController?.tableView((self.paymentVaultViewController?.paymentsTable)!, cellForRowAtIndexPath: NSIndexPath(forRow: 0, inSection: 1))
//
//    }
//    
//    func testsDidSelectRow(){
//        self.paymentVaultViewController = MockPaymentVaultViewController(amount: 2000, paymentPreference: nil, callback: { (paymentMethod, token, issuer, payerCost) in
//            XCTAssertNotNil(paymentMethod)
//            // Verificar selección correcta
//            XCTAssertEqual(paymentMethod, self.paymentMethodSelected)
//            XCTAssertEqual(token, self.tokenCreated)
//            XCTAssertEqual(issuer, self.issuerSelected)
//            XCTAssertEqual(payerCost, self.payerCostSelected)
//        })
//        self.simulateViewDidLoadFor(self.paymentVaultViewController!)
//        
//    }
//}
//
//class PaymentVaultViewModelTest: BaseTest {
//    
//    var paymentVaultViewModel : PaymentVaultViewModel?
//
//    
//    override func setUp() {
//        super.setUp()
//        self.paymentVaultViewModel = PaymentVaultViewModel(amount : 200, paymentPrefence : nil)
//    }
//    
//    override func tearDown() {
//        super.tearDown()
//    }
//    
//    func testValidCustomerInfoAvailable(){
//        MercadoPagoContext.setBaseURL("http://url.com")
//        MercadoPagoContext.setCustomerURI("/customerUri")
//        MercadoPagoContext.setMerchantAccessToken(MockBuilder.MERCHANT_ACCESS_TOKEN)
//        
//        XCTAssertTrue(self.paymentVaultViewModel!.shouldGetCustomerCardsInfo())
//    }
//    
//    func testValidCustomerInfo_invalidInfoAvailable(){
//        MercadoPagoContext.setBaseURL("http://url.com")
//        MercadoPagoContext.setMerchantAccessToken(MockBuilder.MERCHANT_ACCESS_TOKEN)
//        
//        XCTAssertFalse(self.paymentVaultViewModel!.shouldGetCustomerCardsInfo())
//        
//        MercadoPagoContext.setBaseURL("")
//        MercadoPagoContext.setCustomerURI("/customerUri")
//        
//        XCTAssertFalse(self.paymentVaultViewModel!.shouldGetCustomerCardsInfo())
//        
//        MercadoPagoContext.setMerchantAccessToken("")
//        MercadoPagoContext.setBaseURL("http://url.com")
//        XCTAssertFalse(self.paymentVaultViewModel!.shouldGetCustomerCardsInfo())
//        
//        MercadoPagoContext.setBaseURL("")
//        XCTAssertFalse(self.paymentVaultViewModel!.shouldGetCustomerCardsInfo())
//    }
//    
//    func testGetCustomerCardsToDisplayCount(){
//        
//        XCTAssertEqual(self.paymentVaultViewModel!.getCustomerPaymentMethodsToDisplayCount(), 0)
//        
//        let card = CustomerPaymentMethod()
//        card._id = "cardMock"
//        self.paymentVaultViewModel!.customerCards = []
//        self.paymentVaultViewModel!.customerCards?.append(card)
//        
//        XCTAssertEqual(self.paymentVaultViewModel!.getCustomerPaymentMethodsToDisplayCount(), 1)
//        
//        let secondCard = CustomerPaymentMethod()
//        secondCard._id = "cardMock"
//        self.paymentVaultViewModel!.customerCards!.append(secondCard)
//        
//        let thirdCard = CustomerPaymentMethod()
//        thirdCard._id = "cardMock"
//        self.paymentVaultViewModel!.customerCards!.append(thirdCard)
//        
//        XCTAssertEqual(self.paymentVaultViewModel!.getCustomerPaymentMethodsToDisplayCount(), 3)
//        
//        let fourthCard = Card()
//        self.paymentVaultViewModel!.customerCards!.append(fourthCard)
//        
//        XCTAssertEqual(self.paymentVaultViewModel!.getCustomerPaymentMethodsToDisplayCount(), 3)
//        
//        self.paymentVaultViewModel!.customerCards!.remove(at: 3)
//        
//        XCTAssertEqual(self.paymentVaultViewModel!.getCustomerPaymentMethodsToDisplayCount(), 3)
//        
//        self.paymentVaultViewModel!.customerCards!.remove(at: 2)
//        
//        XCTAssertEqual(self.paymentVaultViewModel!.getCustomerPaymentMethodsToDisplayCount(), 2)
//        
//        self.paymentVaultViewModel!.customerCards!.removeAll()
//        
//        XCTAssertEqual(self.paymentVaultViewModel!.getCustomerPaymentMethodsToDisplayCount(), 0)
//    }
//    
//    func testGetExcludedPaymentTypeIds() {
//        
//        let noExcludedPaymentTypeIds = self.paymentVaultViewModel?.getExcludedPaymentTypeIds()
//        XCTAssertNil(noExcludedPaymentTypeIds)
//        
//        let paymentPreference = PaymentPreference()
//        paymentPreference.excludedPaymentTypeIds = ["ticket", "credit_card"]
//        paymentPreference.excludedPaymentMethodIds = ["red_link"]
//        
//        self.paymentVaultViewModel = PaymentVaultViewModel(amount: 100, paymentPrefence: paymentPreference)
//        
//        let twoExcludedPaymentTypeIds = self.paymentVaultViewModel?.getExcludedPaymentTypeIds()
//        XCTAssertEqual(twoExcludedPaymentTypeIds?.count, 2)
//        
//
//    }
//    
//    func testGetExcludedPaymentMethodIds() {
//        
//        let noExcludedPaymentMethodIds = self.paymentVaultViewModel?.getExcludedPaymentMethodIds()
//        XCTAssertNil(noExcludedPaymentMethodIds)
//        
//        let paymentPreference = PaymentPreference()
//        paymentPreference.excludedPaymentTypeIds = ["ticket", "credit_card"]
//        paymentPreference.excludedPaymentMethodIds = ["red_link", "cargavirtual", "visa", "amex"]
//        
//        self.paymentVaultViewModel = PaymentVaultViewModel(amount: 100, paymentPrefence: paymentPreference)
//        
//        let twoExcludedPaymentMethodIds = self.paymentVaultViewModel?.getExcludedPaymentMethodIds()
//        XCTAssertEqual(twoExcludedPaymentMethodIds?.count, 4)
//        
//    }
    

    
    
}



