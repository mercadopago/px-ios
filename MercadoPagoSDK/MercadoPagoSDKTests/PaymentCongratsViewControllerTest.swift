//
//  PaymentCongratsViewControllerTest.swift
//  MercadoPagoSDK
//
//  Created by Maria cristina rodriguez on 21/7/16.
//  Copyright © 2016 MercadoPago. All rights reserved.
//

import XCTest
@testable import MercadoPagoSDK

class PaymentCongratsViewControllerTest: BaseTest {
    
    var paymentCongratsViewController : PaymentCongratsViewController?
    static let noRateTextAttributes = [NSForegroundColorAttributeName : UIColor(red: 67, green: 176,blue: 0), NSFontAttributeName : UIFont(name:MercadoPago.DEFAULT_FONT_NAME, size: 14) ?? UIFont.systemFont(ofSize: 14)]
    

    override func setUp() {
        super.setUp()
        MercadoPagoTestContext.addExpectation(withDescription: "")
        MercadoPagoTestContext.fulfillExpectation(withKey: "")
    }
    
    override func tearDown() {
        super.tearDown()
    }
    
    /*
     *   Pago aprobado con datos correctos y con cuotas sin interés
     */
//    func testPaymentApproved_installmentsNoRate() {
//        let currentPayment = MockBuilder.buildVisaPayment(3)
//        let paymentMethod = MockBuilder.buildPaymentMethod("visa")
//        self.paymentCongratsViewController = PaymentCongratsViewController(payment: currentPayment, paymentMethod: paymentMethod, callback: { (payment, status) in
//            self.validateCallback(payment, expectedPayment: currentPayment, status: status, statusExpected: MPStepBuilder.CongratsState.OK)
//        })
//        
//        
//        let attributedNoRateString = NSMutableAttributedString(string: " ")
//        attributedNoRateString.append(NSAttributedString(string: "Sin interés".localized, attributes :PaymentCongratsViewControllerTest.noRateTextAttributes))
//        self.simulateViewDidLoadFor(self.paymentCongratsViewController!)
//        XCTAssertEqual("approved", self.paymentCongratsViewController?.getLayoutName(currentPayment))
//        XCTAssertEqual(3, self.paymentCongratsViewController!.numberOfSectionsInTableView(self.paymentCongratsViewController!.congratsContentTable))
//        
//        let approvedPaymentCongratsHeader = self.paymentCongratsViewController!.tableView(self.paymentCongratsViewController!.congratsContentTable, cellForRowAtIndexPath: NSIndexPath(forRow: 0, inSection: 0))
//        XCTAssertTrue(approvedPaymentCongratsHeader.isKindOfClass(ApprovedPaymentHeaderTableViewCell))
//        
//        let header = self.paymentCongratsViewController!.tableView(self.paymentCongratsViewController!.congratsContentTable, cellForRowAtIndexPath: NSIndexPath(forRow: 0, inSection: 0)) as! ApprovedPaymentHeaderTableViewCell
//        XCTAssertEqual(header.subtitle.text, currentPayment.payer.email)
//        XCTAssertEqual(header.headerDescription.text, "Te enviaremos los datos a")
//        
//        let body = self.paymentCongratsViewController!.tableView(self.paymentCongratsViewController!.congratsContentTable, cellForRowAtIndexPath: NSIndexPath(forRow: 0, inSection: 1)) as! ApprovedPaymentBodyTableViewCell
//        let paymentMethodIcon = MercadoPago.getImage(currentPayment.paymentMethodId)
//        XCTAssertEqual(body.creditCardIcon.image, paymentMethodIcon)
//        XCTAssertFalse(body.creditCardIcon.hidden)
//        XCTAssertEqual(body.creditCardLabel.text!, "terminada en ".localized + currentPayment.card.lastFourDigits!)
//        XCTAssertEqual(body.voucherId.text!, "Comprobante ".localized + String(currentPayment._id))
//        let amountText = Utils.getTransactionInstallmentsDescription("3", installmentAmount: MockBuilder.INSTALLMENT_AMOUNT, additionalString: attributedNoRateString)
//        XCTAssertEqual(body.amountDescription.attributedText!, amountText)
//        
//   
//    }
//    
//    /*
//     *   Pago aprobado con datos correctos y con cuotas con interés
//     */
//    func testPaymentApproved_installmentsWithFinancialFee() {
//        let payment = MockBuilder.buildMastercardPayment(6, includeFinancingFee : true)
//        
//        let paymentMethod = MockBuilder.buildPaymentMethod("master")
//        self.paymentCongratsViewController = PaymentCongratsViewController(payment: payment, paymentMethod: paymentMethod, callback: { (payment, status) in
//            
//        })
//        
//        self.simulateViewDidLoadFor(self.paymentCongratsViewController!)
//        XCTAssertEqual("approved", self.paymentCongratsViewController?.getLayoutName(payment))
//        XCTAssertEqual(3, self.paymentCongratsViewController!.numberOfSectionsInTableView(self.paymentCongratsViewController!.congratsContentTable))
//        
//        let approvedPaymentCongratsHeader = self.paymentCongratsViewController!.tableView(self.paymentCongratsViewController!.congratsContentTable, cellForRowAtIndexPath: NSIndexPath(forRow: 0, inSection: 0))
//        XCTAssertTrue(approvedPaymentCongratsHeader.isKindOfClass(ApprovedPaymentHeaderTableViewCell))
//        
//        let header = self.paymentCongratsViewController!.tableView(self.paymentCongratsViewController!.congratsContentTable, cellForRowAtIndexPath: NSIndexPath(forRow: 0, inSection: 0)) as! ApprovedPaymentHeaderTableViewCell
//        XCTAssertEqual(header.subtitle.text, payment.payer.email)
//        XCTAssertEqual(header.headerDescription.text, "Te enviaremos los datos a")
//        
//        let body = self.paymentCongratsViewController!.tableView(self.paymentCongratsViewController!.congratsContentTable, cellForRowAtIndexPath: NSIndexPath(forRow: 0, inSection: 1)) as! ApprovedPaymentBodyTableViewCell
//        let paymentMethodIcon = MercadoPago.getImage(payment.paymentMethodId)
//        XCTAssertEqual(body.creditCardIcon.image, paymentMethodIcon)
//        XCTAssertFalse(body.creditCardIcon.hidden)
//        XCTAssertEqual(body.creditCardLabel.text!, "terminada en ".localized + payment.card.lastFourDigits!)
//        XCTAssertEqual(body.voucherId.text!, "Comprobante ".localized + String(payment._id))
//        
//        // Monto total de compra debería aparecer en pantalla
//        let additionalTextAttributes = [NSForegroundColorAttributeName : UIColor(red: 67, green: 176,blue: 0), NSFontAttributeName : UIFont(name:MercadoPago.DEFAULT_FONT_NAME, size: 14)!]
//        let additionalString = NSMutableAttributedString(string: " ")
//        additionalString.append(NSAttributedString(string : "( ", attributes: additionalTextAttributes))
//        additionalString.append(Utils.getAttributedAmount(payment.transactionDetails.totalPaidAmount, thousandSeparator: ".", decimalSeparator: ",", currencySymbol: "$", color: UIColor(red: 67, green: 176,blue: 0), fontSize : 14, baselineOffset: 3))
//        additionalString.append(NSAttributedString(string : " )", attributes: additionalTextAttributes))
//        
//        
//        let amountText = Utils.getTransactionInstallmentsDescription("6", installmentAmount: MockBuilder.INSTALLMENT_AMOUNT, additionalString: additionalString)
//        XCTAssertEqual(body.amountDescription.attributedText!, amountText)
//        
//        
//    }
//    
//    
//    /*
//     *   Pago aprobado con datos correctos y cuotas sin interes, y fee detail
//     */
//    func testPaymentApproved_installmentsWithFeeDetailsNoRate() {
//        let payment = MockBuilder.buildMastercardPayment(6)
//        let feesDetail = FeesDetail()
//        feesDetail.type = "test"
//        payment.feesDetails.append(feesDetail)
//        
//        let paymentMethod = MockBuilder.buildPaymentMethod("master")
//        self.paymentCongratsViewController = PaymentCongratsViewController(payment: payment, paymentMethod: paymentMethod, callback: { (payment, status) in
//            self.validateCallback(payment, expectedPayment: payment, status: status, statusExpected: MPStepBuilder.CongratsState.OK)
//        })
//        
//        self.simulateViewDidLoadFor(self.paymentCongratsViewController!)
//        XCTAssertEqual("approved", self.paymentCongratsViewController?.getLayoutName(payment))
//        XCTAssertEqual(3, self.paymentCongratsViewController!.numberOfSectionsInTableView(self.paymentCongratsViewController!.congratsContentTable))
//        
//        let approvedPaymentCongratsHeader = self.paymentCongratsViewController!.tableView(self.paymentCongratsViewController!.congratsContentTable, cellForRowAtIndexPath: NSIndexPath(forRow: 0, inSection: 0))
//        XCTAssertTrue(approvedPaymentCongratsHeader.isKindOfClass(ApprovedPaymentHeaderTableViewCell))
//        
//        let header = self.paymentCongratsViewController!.tableView(self.paymentCongratsViewController!.congratsContentTable, cellForRowAtIndexPath: NSIndexPath(forRow: 0, inSection: 0)) as! ApprovedPaymentHeaderTableViewCell
//        XCTAssertEqual(header.subtitle.text, payment.payer.email)
//        XCTAssertEqual(header.headerDescription.text, "Te enviaremos los datos a")
//        
//        let body = self.paymentCongratsViewController!.tableView(self.paymentCongratsViewController!.congratsContentTable, cellForRowAtIndexPath: NSIndexPath(forRow: 0, inSection: 1)) as! ApprovedPaymentBodyTableViewCell
//        let paymentMethodIcon = MercadoPago.getImage(payment.paymentMethodId)
//        XCTAssertEqual(body.creditCardIcon.image, paymentMethodIcon)
//        XCTAssertFalse(body.creditCardIcon.hidden)
//        XCTAssertEqual(body.creditCardLabel.text!, "terminada en ".localized + payment.card.lastFourDigits!)
//        XCTAssertEqual(body.voucherId.text!, "Comprobante ".localized + String(payment._id))
//        let attributedNoRateString = NSMutableAttributedString(string: " ")
//        attributedNoRateString.append(NSAttributedString(string: "Sin interés".localized, attributes :PaymentCongratsViewControllerTest.noRateTextAttributes))
//        let amountText = Utils.getTransactionInstallmentsDescription("6", installmentAmount: MockBuilder.INSTALLMENT_AMOUNT, additionalString: attributedNoRateString)
//
//        XCTAssertEqual(body.amountDescription.attributedText!, amountText)
//        
//        
//    }
//    
//    
//    /*
//     *   Pago aprobado sin datos de comprador
//     */
//    func testPaymentApproved_noPayer() {
//        let payment = MockBuilder.buildVisaPayment(3)
//        let paymentMethod = MockBuilder.buildPaymentMethod("visa")
//        payment.payer = nil
//        self.paymentCongratsViewController = PaymentCongratsViewController(payment: payment, paymentMethod: paymentMethod, callback: { (payment, status) in
//            self.validateCallback(payment, expectedPayment: payment, status: status, statusExpected: MPStepBuilder.CongratsState.OK)
//        })
//        
//        let attributedNoRateString = NSMutableAttributedString(string: " ")
//        attributedNoRateString.append(NSAttributedString(string: "Sin interés".localized, attributes :PaymentCongratsViewControllerTest.noRateTextAttributes))
//        
//        
//        self.simulateViewDidLoadFor(self.paymentCongratsViewController!)
//        XCTAssertEqual("approved", self.paymentCongratsViewController?.getLayoutName(payment))
//        XCTAssertEqual(3, self.paymentCongratsViewController!.numberOfSectionsInTableView(self.paymentCongratsViewController!.congratsContentTable))
//        
//        let approvedPaymentCongratsHeader = self.paymentCongratsViewController!.tableView(self.paymentCongratsViewController!.congratsContentTable, cellForRowAtIndexPath: NSIndexPath(forRow: 0, inSection: 0))
//        XCTAssertTrue(approvedPaymentCongratsHeader.isKindOfClass(ApprovedPaymentHeaderTableViewCell))
//        
//        let header = self.paymentCongratsViewController!.tableView(self.paymentCongratsViewController!.congratsContentTable, cellForRowAtIndexPath: NSIndexPath(forRow: 0, inSection: 0)) as! ApprovedPaymentHeaderTableViewCell
//        XCTAssertEqual(header.subtitle.text, "")
//        XCTAssertEqual(header.headerDescription.text!, "")
//        
//        let body = self.paymentCongratsViewController!.tableView(self.paymentCongratsViewController!.congratsContentTable, cellForRowAtIndexPath: NSIndexPath(forRow: 0, inSection: 1)) as! ApprovedPaymentBodyTableViewCell
//        let paymentMethodIcon = MercadoPago.getImage(payment.paymentMethodId)
//        XCTAssertEqual(body.creditCardIcon.image, paymentMethodIcon)
//        XCTAssertFalse(body.creditCardIcon.hidden)
//        XCTAssertEqual(body.creditCardLabel.text!, "terminada en ".localized + payment.card.lastFourDigits!)
//        XCTAssertEqual(body.voucherId.text!, "Comprobante ".localized + String(payment._id))
//        let amountText = Utils.getTransactionInstallmentsDescription("3", installmentAmount: MockBuilder.INSTALLMENT_AMOUNT, additionalString: attributedNoRateString)
//        XCTAssertEqual(body.amountDescription.attributedText!, amountText)
//        
//    }
//    
//    /*
//     *   Pago aprobado sin email de comprador
//     */
//    func testPaymentApproved_noEmailPayer() {
//        let payment = MockBuilder.buildVisaPayment(3)
//        let paymentMethod = MockBuilder.buildPaymentMethod("visa")
//        payment.payer.email = nil
//        self.paymentCongratsViewController = PaymentCongratsViewController(payment: payment, paymentMethod: paymentMethod, callback: { (payment, status) in
//            self.validateCallback(payment, expectedPayment: payment, status: status, statusExpected: MPStepBuilder.CongratsState.OK)
//        })
//        
//        let attributedNoRateString = NSMutableAttributedString(string: " ")
//        attributedNoRateString.append(NSAttributedString(string: "Sin interés".localized, attributes :PaymentCongratsViewControllerTest.noRateTextAttributes))
//        
//        
//        self.simulateViewDidLoadFor(self.paymentCongratsViewController!)
//        XCTAssertEqual("approved", self.paymentCongratsViewController?.getLayoutName(payment))
//        XCTAssertEqual(3, self.paymentCongratsViewController!.numberOfSectionsInTableView(self.paymentCongratsViewController!.congratsContentTable))
//        
//        let approvedPaymentCongratsHeader = self.paymentCongratsViewController!.tableView(self.paymentCongratsViewController!.congratsContentTable, cellForRowAtIndexPath: NSIndexPath(forRow: 0, inSection: 0))
//        XCTAssertTrue(approvedPaymentCongratsHeader.isKindOfClass(ApprovedPaymentHeaderTableViewCell))
//        
//        let header = self.paymentCongratsViewController!.tableView(self.paymentCongratsViewController!.congratsContentTable, cellForRowAtIndexPath: NSIndexPath(forRow: 0, inSection: 0)) as! ApprovedPaymentHeaderTableViewCell
//        XCTAssertEqual(header.subtitle.text, "")
//        XCTAssertEqual(header.headerDescription.text!, "")
//        
//        let body = self.paymentCongratsViewController!.tableView(self.paymentCongratsViewController!.congratsContentTable, cellForRowAtIndexPath: NSIndexPath(forRow: 0, inSection: 1)) as! ApprovedPaymentBodyTableViewCell
//        let paymentMethodIcon = MercadoPago.getImage(payment.paymentMethodId)
//        XCTAssertEqual(body.creditCardIcon.image, paymentMethodIcon)
//        XCTAssertFalse(body.creditCardIcon.hidden)
//        XCTAssertEqual(body.creditCardLabel.text!, "terminada en ".localized + payment.card.lastFourDigits!)
//        XCTAssertEqual(body.voucherId.text!, "Comprobante ".localized + String(payment._id))
//        let amountText = Utils.getTransactionInstallmentsDescription("3", installmentAmount: MockBuilder.INSTALLMENT_AMOUNT, additionalString: attributedNoRateString)
//        XCTAssertEqual(body.amountDescription.attributedText!, amountText)
//        
//    }
//
//    /*
//     *   Pago aprobado con email vacio de comprador
//     */
//    func testPaymentApproved_emptyEmailPayer() {
//        let payment = MockBuilder.buildVisaPayment(3)
//        let paymentMethod = MockBuilder.buildPaymentMethod("visa")
//        payment.payer.email = ""
//        self.paymentCongratsViewController = PaymentCongratsViewController(payment: payment, paymentMethod: paymentMethod, callback: { (payment, status) in
//            self.validateCallback(payment, expectedPayment: payment, status: status, statusExpected: MPStepBuilder.CongratsState.OK)
//        })
//        
//        let attributedNoRateString = NSMutableAttributedString(string: " ")
//        attributedNoRateString.append(NSAttributedString(string: "Sin interés".localized, attributes :PaymentCongratsViewControllerTest.noRateTextAttributes))
//        
//        
//        self.simulateViewDidLoadFor(self.paymentCongratsViewController!)
//        XCTAssertEqual("approved", self.paymentCongratsViewController?.getLayoutName(payment))
//        XCTAssertEqual(3, self.paymentCongratsViewController!.numberOfSectionsInTableView(self.paymentCongratsViewController!.congratsContentTable))
//        
//        let approvedPaymentCongratsHeader = self.paymentCongratsViewController!.tableView(self.paymentCongratsViewController!.congratsContentTable, cellForRowAtIndexPath: NSIndexPath(forRow: 0, inSection: 0))
//        XCTAssertTrue(approvedPaymentCongratsHeader.isKindOfClass(ApprovedPaymentHeaderTableViewCell))
//        
//        let header = self.paymentCongratsViewController!.tableView(self.paymentCongratsViewController!.congratsContentTable, cellForRowAtIndexPath: NSIndexPath(forRow: 0, inSection: 0)) as! ApprovedPaymentHeaderTableViewCell
//        XCTAssertEqual(header.subtitle.text, "")
//        XCTAssertEqual(header.headerDescription.text!, "")
//        
//        let body = self.paymentCongratsViewController!.tableView(self.paymentCongratsViewController!.congratsContentTable, cellForRowAtIndexPath: NSIndexPath(forRow: 0, inSection: 1)) as! ApprovedPaymentBodyTableViewCell
//        let paymentMethodIcon = MercadoPago.getImage(payment.paymentMethodId)
//        XCTAssertEqual(body.creditCardIcon.image, paymentMethodIcon)
//        XCTAssertFalse(body.creditCardIcon.hidden)
//        XCTAssertEqual(body.creditCardLabel.text!, "terminada en ".localized + payment.card.lastFourDigits!)
//        XCTAssertEqual(body.voucherId.text!, "Comprobante ".localized + String(payment._id))
//        let amountText = Utils.getTransactionInstallmentsDescription("3", installmentAmount: MockBuilder.INSTALLMENT_AMOUNT, additionalString: attributedNoRateString)
//        XCTAssertEqual(body.amountDescription.attributedText!, amountText)
//        
//    }
//
//    
//    /*
//     *   Pago aprobado sin datos de tarjeta
//     */
//    func testPaymentApproved_emptyCard() {
//        let payment = MockBuilder.buildMastercardPayment(3)
//        let paymentMethod = MockBuilder.buildPaymentMethod("master")
//        payment.card = nil
//        self.paymentCongratsViewController = PaymentCongratsViewController(payment: payment, paymentMethod: paymentMethod, callback: { (payment, status) in
//            self.validateCallback(payment, expectedPayment: payment, status: status, statusExpected: MPStepBuilder.CongratsState.OK)
//        })
//        
//        let attributedNoRateString = NSMutableAttributedString(string: " ")
//        attributedNoRateString.append(NSAttributedString(string: "Sin interés".localized, attributes :PaymentCongratsViewControllerTest.noRateTextAttributes))
//        
//        
//        self.simulateViewDidLoadFor(self.paymentCongratsViewController!)
//        XCTAssertEqual("approved", self.paymentCongratsViewController?.getLayoutName(payment))
//        XCTAssertEqual(3, self.paymentCongratsViewController!.numberOfSectionsInTableView(self.paymentCongratsViewController!.congratsContentTable))
//        
//        let approvedPaymentCongratsHeader = self.paymentCongratsViewController!.tableView(self.paymentCongratsViewController!.congratsContentTable, cellForRowAtIndexPath: NSIndexPath(forRow: 0, inSection: 0))
//        XCTAssertTrue(approvedPaymentCongratsHeader.isKindOfClass(ApprovedPaymentHeaderTableViewCell))
//        
//        let header = self.paymentCongratsViewController!.tableView(self.paymentCongratsViewController!.congratsContentTable, cellForRowAtIndexPath: NSIndexPath(forRow: 0, inSection: 0)) as! ApprovedPaymentHeaderTableViewCell
//        XCTAssertEqual(header.subtitle.text, payment.payer.email)
//        XCTAssertNotEqual(header.headerDescription.text!, "")
//        
//        let body = self.paymentCongratsViewController!.tableView(self.paymentCongratsViewController!.congratsContentTable, cellForRowAtIndexPath: NSIndexPath(forRow: 0, inSection: 1)) as! ApprovedPaymentBodyTableViewCell
//        XCTAssertTrue(body.creditCardIcon.hidden)
//        XCTAssertEqual(body.creditCardLabel.text!, "")
//        XCTAssertEqual(body.voucherId.text!, "Comprobante ".localized + String(payment._id))
//        let amountText = Utils.getTransactionInstallmentsDescription("3", installmentAmount: MockBuilder.INSTALLMENT_AMOUNT, additionalString: attributedNoRateString)
//        XCTAssertEqual(body.amountDescription.attributedText!, amountText)
//        
//    }
//    
//    /*
//     *   Pago aprobado sin datos de digitos de tarjeta
//     */
//    func testPaymentApproved_noCardDigitsData() {
//        let payment = MockBuilder.buildMastercardPayment(3)
//        let paymentMethod = MockBuilder.buildPaymentMethod("master")
//        payment.card.lastFourDigits = nil
//        self.paymentCongratsViewController = PaymentCongratsViewController(payment: payment, paymentMethod: paymentMethod, callback: { (payment, status) in
//            self.validateCallback(payment, expectedPayment: payment, status: status, statusExpected: MPStepBuilder.CongratsState.OK)
//        })
//        
//        let attributedNoRateString = NSMutableAttributedString(string: " ")
//        attributedNoRateString.append(NSAttributedString(string: "Sin interés".localized, attributes :PaymentCongratsViewControllerTest.noRateTextAttributes))
//        
//        
//        self.simulateViewDidLoadFor(self.paymentCongratsViewController!)
//        XCTAssertEqual("approved", self.paymentCongratsViewController?.getLayoutName(payment))
//        XCTAssertEqual(3, self.paymentCongratsViewController!.numberOfSectionsInTableView(self.paymentCongratsViewController!.congratsContentTable))
//        
//        let approvedPaymentCongratsHeader = self.paymentCongratsViewController!.tableView(self.paymentCongratsViewController!.congratsContentTable, cellForRowAtIndexPath: NSIndexPath(forRow: 0, inSection: 0))
//        XCTAssertTrue(approvedPaymentCongratsHeader.isKindOfClass(ApprovedPaymentHeaderTableViewCell))
//        
//        let header = self.paymentCongratsViewController!.tableView(self.paymentCongratsViewController!.congratsContentTable, cellForRowAtIndexPath: NSIndexPath(forRow: 0, inSection: 0)) as! ApprovedPaymentHeaderTableViewCell
//        XCTAssertEqual(header.subtitle.text, payment.payer.email)
//        XCTAssertNotEqual(header.headerDescription.text!, "")
//        
//        let body = self.paymentCongratsViewController!.tableView(self.paymentCongratsViewController!.congratsContentTable, cellForRowAtIndexPath: NSIndexPath(forRow: 0, inSection: 1)) as! ApprovedPaymentBodyTableViewCell
//        XCTAssertTrue(body.creditCardIcon.hidden)
//        XCTAssertEqual(body.creditCardLabel.text, "")
//        XCTAssertEqual(body.voucherId.text!, "Comprobante ".localized + String(payment._id))
//        let amountText = Utils.getTransactionInstallmentsDescription("3", installmentAmount: MockBuilder.INSTALLMENT_AMOUNT, additionalString: attributedNoRateString)
//        XCTAssertEqual(body.amountDescription.attributedText!, amountText)
//        
//    }
//    
//    /*
//     *   Pago aprobado con digitos de tarjeta vacio
//     */
//    func testPaymentApproved_emptyCardDigits() {
//        let payment = MockBuilder.buildMastercardPayment(3)
//        let paymentMethod = MockBuilder.buildPaymentMethod("master")
//        payment.card.lastFourDigits = ""
//        self.paymentCongratsViewController = PaymentCongratsViewController(payment: payment, paymentMethod: paymentMethod, callback: { (payment, status) in
//            self.validateCallback(payment, expectedPayment: payment, status: status, statusExpected: MPStepBuilder.CongratsState.OK)
//        })
//        
//        let attributedNoRateString = NSMutableAttributedString(string: " ")
//        attributedNoRateString.append(NSAttributedString(string: "Sin interés".localized, attributes :PaymentCongratsViewControllerTest.noRateTextAttributes))
//        
//        
//        self.simulateViewDidLoadFor(self.paymentCongratsViewController!)
//        XCTAssertEqual("approved", self.paymentCongratsViewController?.getLayoutName(payment))
//        XCTAssertEqual(3, self.paymentCongratsViewController!.numberOfSectionsInTableView(self.paymentCongratsViewController!.congratsContentTable))
//        
//        let approvedPaymentCongratsHeader = self.paymentCongratsViewController!.tableView(self.paymentCongratsViewController!.congratsContentTable, cellForRowAtIndexPath: NSIndexPath(forRow: 0, inSection: 0))
//        XCTAssertTrue(approvedPaymentCongratsHeader.isKindOfClass(ApprovedPaymentHeaderTableViewCell))
//        
//        let header = self.paymentCongratsViewController!.tableView(self.paymentCongratsViewController!.congratsContentTable, cellForRowAtIndexPath: NSIndexPath(forRow: 0, inSection: 0)) as! ApprovedPaymentHeaderTableViewCell
//        XCTAssertEqual(header.subtitle.text, payment.payer.email)
//        XCTAssertNotEqual(header.headerDescription.text!, "")
//        
//        let body = self.paymentCongratsViewController!.tableView(self.paymentCongratsViewController!.congratsContentTable, cellForRowAtIndexPath: NSIndexPath(forRow: 0, inSection: 1)) as! ApprovedPaymentBodyTableViewCell
//        XCTAssertTrue(body.creditCardIcon.hidden)
//        XCTAssertEqual(body.creditCardLabel.text!, "")
//        XCTAssertEqual(body.voucherId.text!, "Comprobante ".localized + String(payment._id))
//        let amountText = Utils.getTransactionInstallmentsDescription("3", installmentAmount: MockBuilder.INSTALLMENT_AMOUNT, additionalString: attributedNoRateString)
//        XCTAssertEqual(body.amountDescription.attributedText!, amountText)
//        
//    }
//    
//    /*
//     *   Pago aprobado sin datos de payment method
//     */
//    func testPaymentApproved_noPaymentMethod() {
//        let payment = MockBuilder.buildMastercardPayment(3)
//        let paymentMethod = MockBuilder.buildPaymentMethod("master")
//        payment.paymentMethodId = nil
//        self.paymentCongratsViewController = PaymentCongratsViewController(payment: payment, paymentMethod: paymentMethod, callback: { (payment, status) in
//            self.validateCallback(payment, expectedPayment: payment, status: status, statusExpected: MPStepBuilder.CongratsState.OK)
//        })
//        
//        let attributedNoRateString = NSMutableAttributedString(string: " ")
//        attributedNoRateString.append(NSAttributedString(string: "Sin interés".localized, attributes :PaymentCongratsViewControllerTest.noRateTextAttributes))
//        
//        
//        self.simulateViewDidLoadFor(self.paymentCongratsViewController!)
//        XCTAssertEqual("approved", self.paymentCongratsViewController?.getLayoutName(payment))
//        XCTAssertEqual(3, self.paymentCongratsViewController!.numberOfSectionsInTableView(self.paymentCongratsViewController!.congratsContentTable))
//        
//        let approvedPaymentCongratsHeader = self.paymentCongratsViewController!.tableView(self.paymentCongratsViewController!.congratsContentTable, cellForRowAtIndexPath: NSIndexPath(forRow: 0, inSection: 0))
//        XCTAssertTrue(approvedPaymentCongratsHeader.isKindOfClass(ApprovedPaymentHeaderTableViewCell))
//        
//        let header = self.paymentCongratsViewController!.tableView(self.paymentCongratsViewController!.congratsContentTable, cellForRowAtIndexPath: NSIndexPath(forRow: 0, inSection: 0)) as! ApprovedPaymentHeaderTableViewCell
//        XCTAssertEqual(header.subtitle.text, payment.payer.email)
//        XCTAssertNotEqual(header.headerDescription.text!, "")
//        
//        let body = self.paymentCongratsViewController!.tableView(self.paymentCongratsViewController!.congratsContentTable, cellForRowAtIndexPath: NSIndexPath(forRow: 0, inSection: 1)) as! ApprovedPaymentBodyTableViewCell
//        XCTAssertTrue(body.creditCardIcon.hidden)
//        XCTAssertEqual(body.creditCardLabel.text!, "")
//        XCTAssertEqual(body.voucherId.text!, "Comprobante ".localized + String(payment._id))
//        let amountText = Utils.getTransactionInstallmentsDescription("3", installmentAmount: MockBuilder.INSTALLMENT_AMOUNT, additionalString: attributedNoRateString)
//        XCTAssertEqual(body.amountDescription.attributedText!, amountText)
//        
//    }
//    
//    /*
//     *   Pago aprobado con paymentMethod invalido
//     */
//    func testPaymentApproved_invalidPaymentMethod() {
//        let payment = MockBuilder.buildPayment("test", installments: 3)
//        let paymentMethod = MockBuilder.buildPaymentMethod("test")
//        self.paymentCongratsViewController = PaymentCongratsViewController(payment: payment, paymentMethod: paymentMethod, callback: { (payment, status) in
//            self.validateCallback(payment, expectedPayment: payment, status: status, statusExpected: MPStepBuilder.CongratsState.OK)
//        })
//        
//        let attributedNoRateString = NSMutableAttributedString(string: " ")
//        attributedNoRateString.append(NSAttributedString(string: "Sin interés".localized, attributes :PaymentCongratsViewControllerTest.noRateTextAttributes))
//        
//        
//        self.simulateViewDidLoadFor(self.paymentCongratsViewController!)
//        XCTAssertEqual("approved", self.paymentCongratsViewController?.getLayoutName(payment))
//        XCTAssertEqual(3, self.paymentCongratsViewController!.numberOfSectionsInTableView(self.paymentCongratsViewController!.congratsContentTable))
//        
//        let approvedPaymentCongratsHeader = self.paymentCongratsViewController!.tableView(self.paymentCongratsViewController!.congratsContentTable, cellForRowAtIndexPath: NSIndexPath(forRow: 0, inSection: 0))
//        XCTAssertTrue(approvedPaymentCongratsHeader.isKindOfClass(ApprovedPaymentHeaderTableViewCell))
//        
//        let header = self.paymentCongratsViewController!.tableView(self.paymentCongratsViewController!.congratsContentTable, cellForRowAtIndexPath: NSIndexPath(forRow: 0, inSection: 0)) as! ApprovedPaymentHeaderTableViewCell
//        XCTAssertEqual(header.subtitle.text, payment.payer.email)
//        XCTAssertNotEqual(header.headerDescription.text!, "")
//        
//        let body = self.paymentCongratsViewController!.tableView(self.paymentCongratsViewController!.congratsContentTable, cellForRowAtIndexPath: NSIndexPath(forRow: 0, inSection: 1)) as! ApprovedPaymentBodyTableViewCell
//        XCTAssertTrue(body.creditCardIcon.hidden)
//        XCTAssertEqual(body.creditCardLabel.text!, "")
//        XCTAssertEqual(body.voucherId.text!, "Comprobante ".localized + String(payment._id))
//        let amountText = Utils.getTransactionInstallmentsDescription("3", installmentAmount: MockBuilder.INSTALLMENT_AMOUNT, additionalString: attributedNoRateString)
//        XCTAssertEqual(body.amountDescription.attributedText!, amountText)
//        
//    }
//    
//    /*
//     *   Pago aprobado con paymentMethodId vacio
//     */
//    func testPaymentApproved_emptyPaymentMethod() {
//        let payment = MockBuilder.buildPayment("test", installments: 3)
//        let paymentMethod = MockBuilder.buildPaymentMethod("")
//        self.paymentCongratsViewController = PaymentCongratsViewController(payment: payment, paymentMethod: paymentMethod, callback: { (payment, status) in
//            self.validateCallback(payment, expectedPayment: payment, status: status, statusExpected: MPStepBuilder.CongratsState.OK)
//        })
//        
//        let attributedNoRateString = NSMutableAttributedString(string: " ")
//        attributedNoRateString.append(NSAttributedString(string: "Sin interés".localized, attributes :PaymentCongratsViewControllerTest.noRateTextAttributes))
//        
//        
//        self.simulateViewDidLoadFor(self.paymentCongratsViewController!)
//        XCTAssertEqual("approved", self.paymentCongratsViewController?.getLayoutName(payment))
//        XCTAssertEqual(3, self.paymentCongratsViewController!.numberOfSectionsInTableView(self.paymentCongratsViewController!.congratsContentTable))
//        
//        let approvedPaymentCongratsHeader = self.paymentCongratsViewController!.tableView(self.paymentCongratsViewController!.congratsContentTable, cellForRowAtIndexPath: NSIndexPath(forRow: 0, inSection: 0))
//        XCTAssertTrue(approvedPaymentCongratsHeader.isKindOfClass(ApprovedPaymentHeaderTableViewCell))
//        
//        let header = self.paymentCongratsViewController!.tableView(self.paymentCongratsViewController!.congratsContentTable, cellForRowAtIndexPath: NSIndexPath(forRow: 0, inSection: 0)) as! ApprovedPaymentHeaderTableViewCell
//        XCTAssertEqual(header.subtitle.text, payment.payer.email)
//        XCTAssertNotEqual(header.headerDescription.text!, "")
//        
//        let body = self.paymentCongratsViewController!.tableView(self.paymentCongratsViewController!.congratsContentTable, cellForRowAtIndexPath: NSIndexPath(forRow: 0, inSection: 1)) as! ApprovedPaymentBodyTableViewCell
//        XCTAssertTrue(body.creditCardIcon.hidden)
//        XCTAssertEqual(body.creditCardLabel.text!, "")
//        XCTAssertEqual(body.voucherId.text!, "Comprobante ".localized + String(payment._id))
//        let amountText = Utils.getTransactionInstallmentsDescription("3", installmentAmount: MockBuilder.INSTALLMENT_AMOUNT, additionalString: attributedNoRateString)
//        XCTAssertEqual(body.amountDescription.attributedText!, amountText)
//        
//    }
//
//    /*
//     *   Pago aprobado sin cuotas
//     */
//    func testPaymentApproved_installmentsNull() {
//        let payment = MockBuilder.buildPayment("test", installments: 0)
//        let paymentMethod = MockBuilder.buildPaymentMethod("")
//        self.paymentCongratsViewController = PaymentCongratsViewController(payment: payment, paymentMethod: paymentMethod, callback: { (payment, status) in
//            self.validateCallback(payment, expectedPayment: payment, status: status, statusExpected: MPStepBuilder.CongratsState.OK)
//        })
//        
//        let attributedNoRateString = NSMutableAttributedString(string: " ")
//        
//        
//        self.simulateViewDidLoadFor(self.paymentCongratsViewController!)
//        XCTAssertEqual("approved", self.paymentCongratsViewController?.getLayoutName(payment))
//        XCTAssertEqual(3, self.paymentCongratsViewController!.numberOfSectionsInTableView(self.paymentCongratsViewController!.congratsContentTable))
//        
//        let approvedPaymentCongratsHeader = self.paymentCongratsViewController!.tableView(self.paymentCongratsViewController!.congratsContentTable, cellForRowAtIndexPath: NSIndexPath(forRow: 0, inSection: 0))
//        XCTAssertTrue(approvedPaymentCongratsHeader.isKindOfClass(ApprovedPaymentHeaderTableViewCell))
//        
//        let header = self.paymentCongratsViewController!.tableView(self.paymentCongratsViewController!.congratsContentTable, cellForRowAtIndexPath: NSIndexPath(forRow: 0, inSection: 0)) as! ApprovedPaymentHeaderTableViewCell
//        XCTAssertEqual(header.subtitle.text, payment.payer.email)
//        XCTAssertNotEqual(header.headerDescription.text!, "")
//        
//        let body = self.paymentCongratsViewController!.tableView(self.paymentCongratsViewController!.congratsContentTable, cellForRowAtIndexPath: NSIndexPath(forRow: 0, inSection: 1)) as! ApprovedPaymentBodyTableViewCell
//        XCTAssertTrue(body.creditCardIcon.hidden)
//        XCTAssertEqual(body.creditCardLabel.text!, "")
//        XCTAssertEqual(body.voucherId.text!, "Comprobante ".localized + String(payment._id))
//        let amountText = Utils.getTransactionInstallmentsDescription("3", installmentAmount: MockBuilder.INSTALLMENT_AMOUNT, additionalString: attributedNoRateString)
//        XCTAssertNotEqual(body.amountDescription.attributedText!, amountText)
//        
//    }
//    
//    /*
//     *   Pago aprobado con número inválido de cuotas
//     */
//    func testPaymentApproved_invalidInstallments() {
//        let payment = MockBuilder.buildPayment("test", installments: 1)
//        payment.transactionDetails.installmentAmount = -100
//        let paymentMethod = MockBuilder.buildPaymentMethod("")
//        self.paymentCongratsViewController = PaymentCongratsViewController(payment: payment, paymentMethod: paymentMethod, callback: { (payment, status) in
//            self.validateCallback(payment, expectedPayment: payment, status: status, statusExpected: MPStepBuilder.CongratsState.OK)
//        })
//    
//        
//        self.simulateViewDidLoadFor(self.paymentCongratsViewController!)
//        XCTAssertEqual("approved", self.paymentCongratsViewController?.getLayoutName(payment))
//        XCTAssertEqual(3, self.paymentCongratsViewController!.numberOfSectionsInTableView(self.paymentCongratsViewController!.congratsContentTable))
//        
//        let approvedPaymentCongratsHeader = self.paymentCongratsViewController!.tableView(self.paymentCongratsViewController!.congratsContentTable, cellForRowAtIndexPath: NSIndexPath(forRow: 0, inSection: 0))
//        XCTAssertTrue(approvedPaymentCongratsHeader.isKindOfClass(ApprovedPaymentHeaderTableViewCell))
//        
//        let header = self.paymentCongratsViewController!.tableView(self.paymentCongratsViewController!.congratsContentTable, cellForRowAtIndexPath: NSIndexPath(forRow: 0, inSection: 0)) as! ApprovedPaymentHeaderTableViewCell
//        XCTAssertEqual(header.subtitle.text, payment.payer.email)
//        XCTAssertNotEqual(header.headerDescription.text!, "")
//        
//        let body = self.paymentCongratsViewController!.tableView(self.paymentCongratsViewController!.congratsContentTable, cellForRowAtIndexPath: NSIndexPath(forRow: 0, inSection: 1)) as! ApprovedPaymentBodyTableViewCell
//        XCTAssertTrue(body.creditCardIcon.hidden)
//        XCTAssertEqual(body.creditCardLabel.text!, "")
//        XCTAssertEqual(body.voucherId.text!, "Comprobante ".localized + String(payment._id))
//    
//        XCTAssertTrue(body.amountDescription.hidden)
//        
//    }
//
//    /*
//     *   Pago aprobado sin detalle de transacción
//     */
//    func testPaymentApproved_noTransactionDetail() {
//        let payment = MockBuilder.buildPayment("test", installments: 3)
//        payment.transactionDetails = nil
//        let paymentMethod = MockBuilder.buildPaymentMethod("")
//        self.paymentCongratsViewController = PaymentCongratsViewController(payment: payment, paymentMethod: paymentMethod, callback: { (payment, status) in
//            self.validateCallback(payment, expectedPayment: payment, status: status, statusExpected: MPStepBuilder.CongratsState.OK)
//        })
//        
//        self.simulateViewDidLoadFor(self.paymentCongratsViewController!)
//        XCTAssertEqual("approved", self.paymentCongratsViewController?.getLayoutName(payment))
//        XCTAssertEqual(3, self.paymentCongratsViewController!.numberOfSectionsInTableView(self.paymentCongratsViewController!.congratsContentTable))
//        
//        let approvedPaymentCongratsHeader = self.paymentCongratsViewController!.tableView(self.paymentCongratsViewController!.congratsContentTable, cellForRowAtIndexPath: NSIndexPath(forRow: 0, inSection: 0))
//        XCTAssertTrue(approvedPaymentCongratsHeader.isKindOfClass(ApprovedPaymentHeaderTableViewCell))
//        
//        let header = self.paymentCongratsViewController!.tableView(self.paymentCongratsViewController!.congratsContentTable, cellForRowAtIndexPath: NSIndexPath(forRow: 0, inSection: 0)) as! ApprovedPaymentHeaderTableViewCell
//        XCTAssertEqual(header.subtitle.text, payment.payer.email)
//        XCTAssertNotEqual(header.headerDescription.text!, "")
//        
//        let body = self.paymentCongratsViewController!.tableView(self.paymentCongratsViewController!.congratsContentTable, cellForRowAtIndexPath: NSIndexPath(forRow: 0, inSection: 1)) as! ApprovedPaymentBodyTableViewCell
//        XCTAssertTrue(body.creditCardIcon.hidden)
//        XCTAssertEqual(body.creditCardLabel.text!, "")
//        XCTAssertEqual(body.voucherId.text!, "Comprobante ".localized + String(payment._id))
//        XCTAssertTrue(body.amountDescription.hidden)
//        
//    }
//    
//    /*
//     *   Pago aprobado con total de monto inválido
//     */
//    func testPaymentApproved_totalPaidAmountInvalid() {
//        
//        let payment = MockBuilder.buildPayment("test", installments: 3, includeFinancingFee: true)
//        payment.transactionDetails.totalPaidAmount = 0
//        let paymentMethod = MockBuilder.buildPaymentMethod("")
//        self.paymentCongratsViewController = PaymentCongratsViewController(payment: payment, paymentMethod: paymentMethod, callback: { (payment, status) in
//            
//        })
//        
//        self.simulateViewDidLoadFor(self.paymentCongratsViewController!)
//        XCTAssertEqual("approved", self.paymentCongratsViewController?.getLayoutName(payment))
//        XCTAssertEqual(3, self.paymentCongratsViewController!.numberOfSectionsInTableView(self.paymentCongratsViewController!.congratsContentTable))
//        
//        let approvedPaymentCongratsHeader = self.paymentCongratsViewController!.tableView(self.paymentCongratsViewController!.congratsContentTable, cellForRowAtIndexPath: NSIndexPath(forRow: 0, inSection: 0))
//        XCTAssertTrue(approvedPaymentCongratsHeader.isKindOfClass(ApprovedPaymentHeaderTableViewCell))
//        
//        let header = self.paymentCongratsViewController!.tableView(self.paymentCongratsViewController!.congratsContentTable, cellForRowAtIndexPath: NSIndexPath(forRow: 0, inSection: 0)) as! ApprovedPaymentHeaderTableViewCell
//        XCTAssertEqual(header.subtitle.text, payment.payer.email)
//        XCTAssertNotEqual(header.headerDescription.text!, "")
//        
//        let body = self.paymentCongratsViewController!.tableView(self.paymentCongratsViewController!.congratsContentTable, cellForRowAtIndexPath: NSIndexPath(forRow: 0, inSection: 1)) as! ApprovedPaymentBodyTableViewCell
//        XCTAssertTrue(body.creditCardIcon.hidden)
//        XCTAssertEqual(body.creditCardLabel.text!, "")
//        XCTAssertEqual(body.voucherId.text!, "Comprobante ".localized + String(payment._id))
//        XCTAssertTrue(body.amountDescription.hidden)
//        
//    }
//    
//    /*
//     * Pago aprobado con callback OK
//     */
//    func testPaymentApproved_okCallback() {
//        
//        let currentPayment = MockBuilder.buildMastercardPayment(3, includeFinancingFee: true)
//        let paymentMethod = MockBuilder.buildPaymentMethod("master")
//        self.paymentCongratsViewController = PaymentCongratsViewController(payment: currentPayment, paymentMethod: paymentMethod, callback: { (payment, status) in
//            XCTAssertEqual(payment._id, currentPayment._id)
//            XCTAssertEqual(status, MPStepBuilder.CongratsState.OK)
//        })
//        
//        self.simulateViewDidLoadFor(self.paymentCongratsViewController!)
//        XCTAssertEqual("approved", self.paymentCongratsViewController?.getLayoutName(currentPayment))
//        XCTAssertEqual(3, self.paymentCongratsViewController!.numberOfSectionsInTableView(self.paymentCongratsViewController!.congratsContentTable))
//    
//        let exitButton = self.paymentCongratsViewController!.tableView(self.paymentCongratsViewController!.congratsContentTable, cellForRowAtIndexPath: NSIndexPath(forRow: 0, inSection: 2)) as? ExitButtonTableViewCell
//        XCTAssertNotNil(exitButton)
//        
//        exitButton!.invokeDefaultCallback()
//        
//    }
//    
//    
//    /*
//     * Pago RECHAZADO con statusDetail HighRisk
//     */
//    func testPaymentRejected_statusDetailHighRisk() {
//        let currentPayment = MockBuilder.buildMastercardPayment(3, includeFinancingFee: true)
//        currentPayment.status = "rejected"
//        currentPayment.statusDetail = "rejected_high_risk"
//        let paymentMethod = MockBuilder.buildPaymentMethod("master")
//        self.paymentCongratsViewController = PaymentCongratsViewController(payment: currentPayment, paymentMethod: paymentMethod, callback: { (payment, status) in
//            XCTAssertEqual(payment._id, currentPayment._id)
//            XCTAssertEqual(status, MPStepBuilder.CongratsState.OK)
//        })
//        
//        self.simulateViewDidLoadFor(self.paymentCongratsViewController!)
//        let header = self.paymentCongratsViewController!.tableView(self.paymentCongratsViewController!.congratsContentTable, cellForRowAtIndexPath: NSIndexPath(forRow: 0, inSection: 0)) as? RejectedPaymentHeaderTableViewCell
//        XCTAssertNotNil(header)
//        XCTAssertEqual(header!.title.text, "Por seguridad, tuvimos que rechazar tu pago")
//        XCTAssertEqual(header!.subtitle.text, "Si quieres pagar con el dinero de tu cuenta, contáctate con Atención al Cliente de MercadoPago. O si prefieres, puedes elegir otro medio de pago.")
//        
//        
//        let exitButton = self.paymentCongratsViewController!.tableView(self.paymentCongratsViewController!.congratsContentTable, cellForRowAtIndexPath: NSIndexPath(forRow: 0, inSection: 2)) as? ExitButtonTableViewCell
//        XCTAssertNotNil(exitButton)
//        
//        exitButton!.invokeDefaultCallback()
//        
//    }
//    
//    /*
//     * Pago RECHAZADO con statusDetail insufficient_amount
//     */
//    func testPaymentRejected_statusInsufficientAmount() {
//        
//        let currentPayment = MockBuilder.buildVisaPayment(3, includeFinancingFee: true)
//        currentPayment.status = "rejected"
//        currentPayment.statusDetail = "cc_rejected_insufficient_amount"
//        let paymentMethod = MockBuilder.buildPaymentMethod("visa", name: "Visa")
//        self.paymentCongratsViewController = PaymentCongratsViewController(payment: currentPayment, paymentMethod: paymentMethod, callback: { (payment, status) in
//            XCTAssertEqual(payment._id, currentPayment._id)
//            XCTAssertEqual(status, MPStepBuilder.CongratsState.OK)
//        })
//        
//        self.simulateViewDidLoadFor(self.paymentCongratsViewController!)
//        let body = self.paymentCongratsViewController!.tableView(self.paymentCongratsViewController!.congratsContentTable, cellForRowAtIndexPath: NSIndexPath(forRow: 0, inSection: 0)) as? RejectedPaymentHeaderTableViewCell
//        XCTAssertNotNil(body)
//        XCTAssertEqual(body!.title.text, "Tu Visa no tiene fondos suficientes")
//        XCTAssertEqual(body!.subtitle.text, "¡No te desanimes! Puedes elegir otro medio de pago.")
//        
//        
//        let exitButton = self.paymentCongratsViewController!.tableView(self.paymentCongratsViewController!.congratsContentTable, cellForRowAtIndexPath: NSIndexPath(forRow: 0, inSection: 2)) as? ExitButtonTableViewCell
//        XCTAssertNotNil(exitButton)
//        exitButton!.invokeDefaultCallback()
//        
//        
//    }
//    
//    /*
//     * Pago RECHAZADO con statusDetail OtherReason
//     */
//    func testPaymentRejected_statusOtherReason() {
//        
//        let currentPayment = MockBuilder.buildVisaPayment(3, includeFinancingFee: true, status: "rejected", statusDetail : "cc_rejected_other_reason")
//        let paymentMethod = MockBuilder.buildPaymentMethod("visa", name: "Visa")
//        self.paymentCongratsViewController = PaymentCongratsViewController(payment: currentPayment, paymentMethod: paymentMethod, callback: { (payment, status) in
//            XCTAssertEqual(payment._id, currentPayment._id)
//            XCTAssertEqual(status, MPStepBuilder.CongratsState.OK)
//        })
//        
//        self.simulateViewDidLoadFor(self.paymentCongratsViewController!)
//        let body = self.paymentCongratsViewController!.tableView(self.paymentCongratsViewController!.congratsContentTable, cellForRowAtIndexPath: NSIndexPath(forRow: 0, inSection: 0)) as? RejectedPaymentHeaderTableViewCell
//        XCTAssertNotNil(body)
//        XCTAssertEqual(body!.title.text, "Visa no procesó el pago")
//        XCTAssertEqual(body!.subtitle.text, "Usa otra tarjeta u otro medio de pago.")
//        
//        
//        let exitButton = self.paymentCongratsViewController!.tableView(self.paymentCongratsViewController!.congratsContentTable, cellForRowAtIndexPath: NSIndexPath(forRow: 0, inSection: 2)) as? ExitButtonTableViewCell
//        XCTAssertNotNil(exitButton)
//        
//        exitButton!.invokeDefaultCallback()
//        
//    }
//
//    
//    /*
//     * Pago RECHAZADO con statusDetail MaxAttempts
//     */
//    func testPaymentRejected_statusMaxAttempts() {
//        
//        let currentPayment = MockBuilder.buildVisaPayment(3, includeFinancingFee: true, status: "rejected", statusDetail : "cc_rejected_max_attempts")
//        let paymentMethod = MockBuilder.buildPaymentMethod("visa")
//        self.paymentCongratsViewController = PaymentCongratsViewController(payment: currentPayment, paymentMethod: paymentMethod, callback: { (payment, status) in
//            self.validateCallback(payment, expectedPayment: currentPayment, status: status, statusExpected: MPStepBuilder.CongratsState.OK)
//        })
//        
//        self.simulateViewDidLoadFor(self.paymentCongratsViewController!)
//        let body = self.paymentCongratsViewController!.tableView(self.paymentCongratsViewController!.congratsContentTable, cellForRowAtIndexPath: NSIndexPath(forRow: 0, inSection: 0)) as? RejectedPaymentHeaderTableViewCell
//        XCTAssertNotNil(body)
//        XCTAssertEqual(body!.title.text, "Llegaste al límite de intentos permitidos")
//        XCTAssertEqual(body!.subtitle.text, "Elige otra tarjeta u otro medio de pago.")
//        
//        
//        let exitButton = self.paymentCongratsViewController!.tableView(self.paymentCongratsViewController!.congratsContentTable, cellForRowAtIndexPath: NSIndexPath(forRow: 0, inSection: 2)) as? ExitButtonTableViewCell
//        XCTAssertNotNil(exitButton)
//        
//        exitButton!.invokeDefaultCallback()
//        
//        
//    }
//    
//    /*
//     * Pago RECHAZADO con statusDetail DuplicatedPayment
//     */
//    func testPaymentRejected_statusDuplicatedPayment() {
//        
//        let currentPayment = MockBuilder.buildMastercardPayment(3, includeFinancingFee : true, status : "rejected", statusDetail : "cc_rejected_duplicated_payment")
//        let paymentMethod = MockBuilder.buildPaymentMethod("master", name: "Mastercard")
//        self.paymentCongratsViewController = PaymentCongratsViewController(payment: currentPayment, paymentMethod: paymentMethod, callback: { (payment, status) in
//            self.validateCallback(payment, expectedPayment: currentPayment, status: status, statusExpected: MPStepBuilder.CongratsState.OK)
//        })
//        
//        self.simulateViewDidLoadFor(self.paymentCongratsViewController!)
//        let body = self.paymentCongratsViewController!.tableView(self.paymentCongratsViewController!.congratsContentTable, cellForRowAtIndexPath: NSIndexPath(forRow: 0, inSection: 0)) as? RejectedPaymentHeaderTableViewCell
//        XCTAssertNotNil(body)
//        XCTAssertEqual(body!.title.text, "Mastercard no procesó el pago")
//        XCTAssertEqual(body!.subtitle.text, "Si necesitas volver a pagar usa otra tarjeta u otro medio de pago.")
//        
//        
//        let exitButton = self.paymentCongratsViewController!.tableView(self.paymentCongratsViewController!.congratsContentTable, cellForRowAtIndexPath: NSIndexPath(forRow: 0, inSection: 2)) as? ExitButtonTableViewCell
//        XCTAssertNotNil(exitButton)
//        
//        exitButton!.invokeDefaultCallback()
//        
//        
//    }
//
//    
//    /*
//     * Pago RECHAZADO con statusDetail CardDisabled
//     */
//    func testPaymentRejected_statusCardDisabled() {
//        
//        let currentPayment = MockBuilder.buildPayment("amex", installments: 3, includeFinancingFee: true)
//        currentPayment.statusDetail = "cc_rejected_card_disabled"
//        currentPayment.status = "rejected"
//        let paymentMethod = MockBuilder.buildPaymentMethod("amex", name: "Amex")
//        self.paymentCongratsViewController = PaymentCongratsViewController(payment: currentPayment, paymentMethod: paymentMethod, callback: { (payment, status) in
//            self.validateCallback(payment, expectedPayment: currentPayment, status: status, statusExpected: MPStepBuilder.CongratsState.OK)
//        })
//        
//        self.simulateViewDidLoadFor(self.paymentCongratsViewController!)
//        let body = self.paymentCongratsViewController!.tableView(self.paymentCongratsViewController!.congratsContentTable, cellForRowAtIndexPath: NSIndexPath(forRow: 0, inSection: 0)) as? RejectedPaymentHeaderTableViewCell
//        XCTAssertNotNil(body)
//        XCTAssertEqual(body!.title.text, "Llama a Amex para que active tu tarjeta")
//        XCTAssertEqual(body!.subtitle.text, "El teléfono está al dorso de tu tarjeta.")
//        
//        
//        let exitButton = self.paymentCongratsViewController!.tableView(self.paymentCongratsViewController!.congratsContentTable, cellForRowAtIndexPath: NSIndexPath(forRow: 0, inSection: 2)) as? ExitButtonTableViewCell
//        XCTAssertNotNil(exitButton)
//        
//        exitButton!.invokeDefaultCallback()
//        
//    }
//    
//    /*
//     * Pago RECHAZADO con statusDetail BadFilledOther
//     */
//    func testPaymentRejected_statusBadFilledOther() {
//        
//        let currentPayment = MockBuilder.buildVisaPayment(3, includeFinancingFee: true, status: "rejected", statusDetail : "cc_rejected_bad_filled_other")
//        let paymentMethod = MockBuilder.buildPaymentMethod("visa", name: "Visa")
//        self.paymentCongratsViewController = PaymentCongratsViewController(payment: currentPayment, paymentMethod: paymentMethod, callback: { (payment, status) in
//            self.validateCallback(payment, expectedPayment: currentPayment, status: status, statusExpected: MPStepBuilder.CongratsState.OK)
//        })
//        
//        self.simulateViewDidLoadFor(self.paymentCongratsViewController!)
//        let body = self.paymentCongratsViewController!.tableView(self.paymentCongratsViewController!.congratsContentTable, cellForRowAtIndexPath: NSIndexPath(forRow: 0, inSection: 0)) as? RejectedPaymentHeaderTableViewCell
//        XCTAssertNotNil(body)
//        XCTAssertEqual(body!.title.text, "Uy, no pudimos procesar el pago")
//        XCTAssertEqual(body!.subtitle.text, "Algún dato de tu Visa es incorrecto.")
//        
//        
//        let exitButton = self.paymentCongratsViewController!.tableView(self.paymentCongratsViewController!.congratsContentTable, cellForRowAtIndexPath: NSIndexPath(forRow: 0, inSection: 2)) as? ExitButtonTableViewCell
//        XCTAssertNotNil(exitButton)
//        
//        exitButton!.invokeDefaultCallback()
//        
//    }
//    
//    /*
//     * Pago RECHAZADO con statusDetail BadFilledCardNumber
//     */
//    func testPaymentRejected_statusBadFilledCardNumber() {
//        
//        let currentPayment = MockBuilder.buildPayment("visa", installments: 3, includeFinancingFee: true, status: "rejected", statusDetail: "cc_rejected_bad_filled_card_number")
//        let paymentMethod = MockBuilder.buildPaymentMethod("visa", name: "Visa")
//        self.paymentCongratsViewController = PaymentCongratsViewController(payment: currentPayment, paymentMethod: paymentMethod, callback: { (payment, status) in
//            self.validateCallback(payment, expectedPayment: currentPayment, status: status, statusExpected: MPStepBuilder.CongratsState.OK)
//        })
//        self.simulateViewDidLoadFor(self.paymentCongratsViewController!)
//        let body = self.paymentCongratsViewController!.tableView(self.paymentCongratsViewController!.congratsContentTable, cellForRowAtIndexPath: NSIndexPath(forRow: 0, inSection: 0)) as? RejectedPaymentHeaderTableViewCell
//        XCTAssertNotNil(body)
//        XCTAssertEqual(body!.title.text, "Uy, no pudimos procesar el pago")
//        XCTAssertEqual(body!.subtitle.text, "El número de tu Visa es incorrecto.")
//        
//        
//        let exitButton = self.paymentCongratsViewController!.tableView(self.paymentCongratsViewController!.congratsContentTable, cellForRowAtIndexPath: NSIndexPath(forRow: 0, inSection: 2)) as? ExitButtonTableViewCell
//        XCTAssertNotNil(exitButton)
//        
//        exitButton!.invokeDefaultCallback()
//        
//    }
//    
//    /*
//     * Pago RECHAZADO con statusDetail BadFilledSecurityCode
//     */
//    func testPaymentRejected_statusBadFilledSecurityCode() {
//        
//        let currentPayment = MockBuilder.buildPayment("visa", installments: 3, includeFinancingFee: true, status: "rejected", statusDetail: "cc_rejected_bad_filled_security_code")
//        let paymentMethod = MockBuilder.buildPaymentMethod("visa")
//        self.paymentCongratsViewController = PaymentCongratsViewController(payment: currentPayment, paymentMethod: paymentMethod, callback: { (payment, status) in
//            self.validateCallback(payment, expectedPayment: currentPayment, status: status, statusExpected: MPStepBuilder.CongratsState.OK)
//        })
//        
//        self.simulateViewDidLoadFor(self.paymentCongratsViewController!)
//        let body = self.paymentCongratsViewController!.tableView(self.paymentCongratsViewController!.congratsContentTable, cellForRowAtIndexPath: NSIndexPath(forRow: 0, inSection: 0)) as? RejectedPaymentHeaderTableViewCell
//        XCTAssertNotNil(body)
//        XCTAssertEqual(body!.title.text, "Uy, no pudimos procesar el pago")
//        XCTAssertEqual(body!.subtitle.text, "El código de seguridad no es el correcto.")
//        
//        
//        let exitButton = self.paymentCongratsViewController!.tableView(self.paymentCongratsViewController!.congratsContentTable, cellForRowAtIndexPath: NSIndexPath(forRow: 0, inSection: 2)) as? ExitButtonTableViewCell
//        XCTAssertNotNil(exitButton)
//        
//        exitButton!.invokeDefaultCallback()
//        
//        
//        
//    }
//
//    /*
//     * Pago RECHAZADO con statusDetail BadFilledDate
//     */
//    func testPaymentRejected_statusBadFilledDate() {
//        
//        let currentPayment = MockBuilder.buildVisaPayment(3, includeFinancingFee: true, status: "rejected", statusDetail: "cc_rejected_bad_filled_date")
//        let paymentMethod = MockBuilder.buildPaymentMethod("visa")
//        self.paymentCongratsViewController = PaymentCongratsViewController(payment: currentPayment, paymentMethod: paymentMethod, callback: { (payment, status) in
//            self.validateCallback(payment, expectedPayment: currentPayment, status: status, statusExpected: MPStepBuilder.CongratsState.OK)
//        })
//        
//        self.simulateViewDidLoadFor(self.paymentCongratsViewController!)
//        let body = self.paymentCongratsViewController!.tableView(self.paymentCongratsViewController!.congratsContentTable, cellForRowAtIndexPath: NSIndexPath(forRow: 0, inSection: 0)) as? RejectedPaymentHeaderTableViewCell
//        XCTAssertNotNil(body)
//        XCTAssertEqual(body!.title.text, "Uy, no pudimos procesar el pago")
//        XCTAssertEqual(body!.subtitle.text, "La fecha de vencimiento no es la correcta.")
//        
//        
//        let exitButton = self.paymentCongratsViewController!.tableView(self.paymentCongratsViewController!.congratsContentTable, cellForRowAtIndexPath: NSIndexPath(forRow: 0, inSection: 2)) as? ExitButtonTableViewCell
//        XCTAssertNotNil(exitButton)
//        
//        exitButton!.invokeDefaultCallback()
//        
//    }
//    
//    /*
//     * Pago RECHAZADO con statusDetail invalido
//     */
//    func testPaymentRejected_statusDetailInvalid() {
//        
//        let currentPayment = MockBuilder.buildVisaPayment(3, includeFinancingFee: true, status: "rejected", statusDetail: "test_invalid_status_detail")
//        let paymentMethod = MockBuilder.buildPaymentMethod("visa", name: "Visa")
//        self.paymentCongratsViewController = PaymentCongratsViewController(payment: currentPayment, paymentMethod: paymentMethod, callback: { (payment, status) in
//            self.validateCallback(payment, expectedPayment: currentPayment, status: status, statusExpected: MPStepBuilder.CongratsState.OK)
//        })
//        
//        self.simulateViewDidLoadFor(self.paymentCongratsViewController!)
//        let body = self.paymentCongratsViewController!.tableView(self.paymentCongratsViewController!.congratsContentTable, cellForRowAtIndexPath: NSIndexPath(forRow: 0, inSection: 0)) as? RejectedPaymentHeaderTableViewCell
//        XCTAssertNotNil(body)
//        XCTAssertEqual(body!.title.text, "Uy, no pudimos procesar el pago".localized)
//        XCTAssertEqual(body!.subtitle.text, "Algún dato de tu Visa es incorrecto.".localized)
//        
//        let exitButton = self.paymentCongratsViewController!.tableView(self.paymentCongratsViewController!.congratsContentTable, cellForRowAtIndexPath: NSIndexPath(forRow: 0, inSection: 2)) as? ExitButtonTableViewCell
//        XCTAssertNotNil(exitButton)
//        
//        exitButton!.invokeDefaultCallback()
//        
//        
//    }
//
//    /*
//     * Pago PENDING con statusDetail nulo
//     */
//    func testPaymentInProcess_statusDetailInvalid() {
//        
//        let currentPayment = MockBuilder.buildVisaPayment(3, includeFinancingFee: true, status: "in_process")
//        currentPayment.statusDetail = nil
//        let paymentMethod = MockBuilder.buildPaymentMethod("visa")
//        self.paymentCongratsViewController = PaymentCongratsViewController(payment: currentPayment, paymentMethod: paymentMethod, callback: { (payment, status) in
//            self.validateCallback(payment, expectedPayment: currentPayment, status: status, statusExpected: MPStepBuilder.CongratsState.OK)
//        })
//        
//        self.simulateViewDidLoadFor(self.paymentCongratsViewController!)
//        let body = self.paymentCongratsViewController!.tableView(self.paymentCongratsViewController!.congratsContentTable, cellForRowAtIndexPath: NSIndexPath(forRow: 0, inSection: 0)) as? PendingPaymentHeaderTableViewCell
//        XCTAssertNotNil(body)
//        XCTAssertEqual(body!.subtitle.text, "")
//        
//        let exitButton = self.paymentCongratsViewController!.tableView(self.paymentCongratsViewController!.congratsContentTable, cellForRowAtIndexPath: NSIndexPath(forRow: 0, inSection: 2)) as? ExitButtonTableViewCell
//        XCTAssertNotNil(exitButton)
//        
//        exitButton!.invokeDefaultCallback()
//        
//    }
//    
//    /*
//     * Pago PENDING con statusDetail vacio
//     */
//    func testPaymentInProcess_statusDetailEmpty() {
//        
//        let currentPayment = MockBuilder.buildVisaPayment(3, includeFinancingFee: true, status: "in_process", statusDetail: "")
//        let paymentMethod = MockBuilder.buildPaymentMethod("visa")
//        self.paymentCongratsViewController = PaymentCongratsViewController(payment: currentPayment, paymentMethod: paymentMethod, callback: { (payment, status) in
//            self.validateCallback(payment, expectedPayment: currentPayment, status: status, statusExpected: MPStepBuilder.CongratsState.OK)
//        })
//        
//        self.simulateViewDidLoadFor(self.paymentCongratsViewController!)
//        let body = self.paymentCongratsViewController!.tableView(self.paymentCongratsViewController!.congratsContentTable, cellForRowAtIndexPath: NSIndexPath(forRow: 0, inSection: 0)) as? PendingPaymentHeaderTableViewCell
//        XCTAssertNotNil(body)
//        XCTAssertEqual(body!.subtitle.text, "")
//        
//        let exitButton = self.paymentCongratsViewController!.tableView(self.paymentCongratsViewController!.congratsContentTable, cellForRowAtIndexPath: NSIndexPath(forRow: 0, inSection: 2)) as? ExitButtonTableViewCell
//        XCTAssertNotNil(exitButton)
//        
//        exitButton!.invokeDefaultCallback()
//        
//    }
//    
//    /*
//     * Pago PENDING con statusDetail pendingReviewManual
//     */
//    func testPaymentInProcess_statusDetailPendingReviewManual() {
//        
//        let currentPayment = MockBuilder.buildVisaPayment(3, includeFinancingFee: true, status: "in_process", statusDetail: "pending_review_manual")
//        let paymentMethod = MockBuilder.buildPaymentMethod("visa")
//        self.paymentCongratsViewController = PaymentCongratsViewController(payment: currentPayment, paymentMethod: paymentMethod, callback: { (payment, status) in
//            self.validateCallback(payment, expectedPayment: currentPayment, status: status, statusExpected: MPStepBuilder.CongratsState.OK)
//        })
//        
//        self.simulateViewDidLoadFor(self.paymentCongratsViewController!)
//        let body = self.paymentCongratsViewController!.tableView(self.paymentCongratsViewController!.congratsContentTable, cellForRowAtIndexPath: NSIndexPath(forRow: 0, inSection: 0)) as? PendingPaymentHeaderTableViewCell
//        XCTAssertNotNil(body)
//        XCTAssertEqual(body!.subtitle.text, "En poquitas horas te diremos por e-mail si se acreditó o si necesitamos más información.".localized)
//        
//        let exitButton = self.paymentCongratsViewController!.tableView(self.paymentCongratsViewController!.congratsContentTable, cellForRowAtIndexPath: NSIndexPath(forRow: 0, inSection: 2)) as? ExitButtonTableViewCell
//        XCTAssertNotNil(exitButton)
//        
//        exitButton!.invokeDefaultCallback()
//        
//    }
//    
//    
//    /*
//     * Pago PENDING con statusDetail pendingReviewManual
//     */
//    func testPaymentInProcess_statusDetailPendingContingency() {
//        
//        let currentPayment = MockBuilder.buildVisaPayment(3, includeFinancingFee: true, status: "in_process", statusDetail: "pending_contingency")
//        let paymentMethod = MockBuilder.buildPaymentMethod("visa")
//        self.paymentCongratsViewController = PaymentCongratsViewController(payment: currentPayment, paymentMethod: paymentMethod, callback: { (payment, status) in
//            self.validateCallback(payment, expectedPayment: currentPayment, status: status, statusExpected: MPStepBuilder.CongratsState.OK)
//        })
//        
//        self.simulateViewDidLoadFor(self.paymentCongratsViewController!)
//        let body = self.paymentCongratsViewController!.tableView(self.paymentCongratsViewController!.congratsContentTable, cellForRowAtIndexPath: NSIndexPath(forRow: 0, inSection: 0)) as? PendingPaymentHeaderTableViewCell
//        XCTAssertNotNil(body)
//        XCTAssertEqual(body!.subtitle.text, "En menos de 1 hora te enviaremos por e-mail el resultado.".localized)
//        
//        let exitButton = self.paymentCongratsViewController!.tableView(self.paymentCongratsViewController!.congratsContentTable, cellForRowAtIndexPath: NSIndexPath(forRow: 0, inSection: 2)) as? ExitButtonTableViewCell
//        XCTAssertNotNil(exitButton)
//        
//        exitButton!.invokeDefaultCallback()
//        
//    }
//
//    /*
//     * Pago RECHAZO con statusDetail CALL_FOR_AUTH
//     */
//    func testPaymentCallForAuth_statusDetailPendingContingency() {
//        
//        let currentPayment = MockBuilder.buildPayment("amex", installments: 3, includeFinancingFee: true)
//        currentPayment.status = "rejected"
//        currentPayment.statusDetail = "cc_rejected_call_for_authorize"
//        let paymentMethod = MockBuilder.buildPaymentMethod("amex", name: "Amex")
//        self.paymentCongratsViewController = PaymentCongratsViewController(payment: currentPayment, paymentMethod: paymentMethod, callback: { (payment, status) in
//            self.validateCallback(payment, expectedPayment: currentPayment, status: status, statusExpected: MPStepBuilder.CongratsState.OK)
//        })
//        
//        self.simulateViewDidLoadFor(self.paymentCongratsViewController!)
//        let header = self.paymentCongratsViewController!.tableView(self.paymentCongratsViewController!.congratsContentTable, cellForRowAtIndexPath: NSIndexPath(forRow: 0, inSection: 0)) as? AuthorizePaymentHeaderTableViewCell
//        XCTAssertNotNil(header)
//        
//        let expectedTitle = NSMutableAttributedString(string: "Debes autorizar ante ".localized + "Amex" + " el pago de ".localized)
//        let attributedAmount = Utils.getAttributedAmount(currentPayment.transactionDetails.totalPaidAmount, thousandSeparator: ".", decimalSeparator: ",", currencySymbol: "$", color: UIColor(red: 102, green: 102, blue: 102))
//        expectedTitle.append(attributedAmount)
//        expectedTitle.append(NSMutableAttributedString(string : " a MercadoPago".localized))
//        
//     //   XCTAssertEqual(header!.title.attributedText, expectedTitle)
//      
//        
//        let body = self.paymentCongratsViewController!.tableView(self.paymentCongratsViewController!.congratsContentTable, cellForRowAtIndexPath: NSIndexPath(forRow: 0, inSection: 1)) as? AuthorizePaymentBodyTableViewCell
//        XCTAssertNotNil(body)
//        XCTAssertEqual(body!.completeCardButton.currentTitle, "Ya hablé con Amex y me autorizó".localized)
//        //XCTAssertEqual(body!.cancelButton)
//        
//        let exitButton = self.paymentCongratsViewController!.tableView(self.paymentCongratsViewController!.congratsContentTable, cellForRowAtIndexPath: NSIndexPath(forRow: 0, inSection: 2)) as? ExitButtonTableViewCell
//        XCTAssertNotNil(exitButton)
//        
//        exitButton!.invokeDefaultCallback()
//        
//    }
//    /*
//     * Pago RECHAZO con paymentMethodId nulo
//     */
//    func testPaymentCallForAuth_noPaymentMethodId() {
//        
//        let currentPayment = MockBuilder.buildPayment("amex", installments: 3, includeFinancingFee: true)
//        currentPayment.status = "rejected"
//        currentPayment.statusDetail = "cc_rejected_call_for_authorize"
//        let paymentMethod = MockBuilder.buildPaymentMethod("amex", name : "Amex")
//        //TODO
//        //paymentMethod.name = nil
//        self.paymentCongratsViewController = PaymentCongratsViewController(payment: currentPayment, paymentMethod: paymentMethod, callback: { (payment, status) in
//            self.validateCallback(payment, expectedPayment: currentPayment, status: status, statusExpected: MPStepBuilder.CongratsState.OK)
//        })
//        
//        self.simulateViewDidLoadFor(self.paymentCongratsViewController!)
//        let header = self.paymentCongratsViewController!.tableView(self.paymentCongratsViewController!.congratsContentTable, cellForRowAtIndexPath: NSIndexPath(forRow: 0, inSection: 0)) as? AuthorizePaymentHeaderTableViewCell
//        XCTAssertNotNil(header)
//        
//        let expectedTitle = "Debes autorizar el pago ante tu tarjeta".localized
//        
//       // XCTAssertEqual(header!.title.attributedText, expectedTitle)
//        
//        
//        let body = self.paymentCongratsViewController!.tableView(self.paymentCongratsViewController!.congratsContentTable, cellForRowAtIndexPath: NSIndexPath(forRow: 0, inSection: 1)) as? AuthorizePaymentBodyTableViewCell
//        XCTAssertNotNil(body)
//        XCTAssertEqual(body!.completeCardButton.currentTitle, "Ya hablé con Amex y me autorizó".localized)
//        //XCTAssertEqual(body!.cancelButton)
//        
//        let exitButton = self.paymentCongratsViewController!.tableView(self.paymentCongratsViewController!.congratsContentTable, cellForRowAtIndexPath: NSIndexPath(forRow: 0, inSection: 2)) as? ExitButtonTableViewCell
//        XCTAssertNotNil(exitButton)
//        
//        exitButton!.invokeDefaultCallback()
//        
//    }
//    
//    /*
//     * Pago RECHAZO con statusDetail CALL_FOR_AUTH Se presiona sobre el botón "Ya autoricé..."
//     */
//    func testPaymentCallForAuth_cardEntityAuthorizedClicked() {
//        
//        let currentPayment = MockBuilder.buildMastercardPayment(3, includeFinancingFee : true, status : "rejected", statusDetail : "cc_rejected_call_for_authorize")
//        let paymentMethod = MockBuilder.buildPaymentMethod("master", name : "Mastercard")
//        self.paymentCongratsViewController = PaymentCongratsViewController(payment: currentPayment, paymentMethod: paymentMethod, callback: { (payment, status) in
//            self.validateCallback(payment, expectedPayment: currentPayment, status: status, statusExpected: MPStepBuilder.CongratsState.CANCEL_SELECT_OTHER)
//        })
//        
//        self.simulateViewDidLoadFor(self.paymentCongratsViewController!)
//        let header = self.paymentCongratsViewController!.tableView(self.paymentCongratsViewController!.congratsContentTable, cellForRowAtIndexPath: NSIndexPath(forRow: 0, inSection: 0)) as? AuthorizePaymentHeaderTableViewCell
//        XCTAssertNotNil(header)
//        
//        let expectedTitle = "Debes autorizar el pago ante tu tarjeta".localized
//        
//        //XCTAssertEqual(header!.title.attributedText, expectedTitle)
//        
//        
//        let body = self.paymentCongratsViewController!.tableView(self.paymentCongratsViewController!.congratsContentTable, cellForRowAtIndexPath: NSIndexPath(forRow: 0, inSection: 1)) as? AuthorizePaymentBodyTableViewCell
//        XCTAssertNotNil(body)
//        XCTAssertEqual(body!.completeCardButton.currentTitle, "Ya hablé con Mastercard y me autorizó".localized)
//        //XCTAssertEqual(body!.cancelButton)
//        body?.invokeDefaultCallback()
//        
//    }
//    
//    /*
//     * Pago RECHAZO con statusDetail CALL_FOR_AUTH Se presiona sobre el botón "Ya autoricé..."
//     */
//    func testPaymentCallForAuth_cardAnotherPaymentMethodClicked() {
//        
//        let currentPayment = MockBuilder.buildMastercardPayment(3, includeFinancingFee : true, status : "rejected", statusDetail : "cc_rejected_call_for_authorize")
//        let paymentMethod = MockBuilder.buildPaymentMethod("master", name : "Mastercard")
//        self.paymentCongratsViewController = PaymentCongratsViewController(payment: currentPayment, paymentMethod: paymentMethod, callback: { (payment, status) in
//            self.validateCallback(payment, expectedPayment: currentPayment, status: status, statusExpected: MPStepBuilder.CongratsState.CANCEL_SELECT_OTHER)
//        })
//        
//        self.simulateViewDidLoadFor(self.paymentCongratsViewController!)
//        let header = self.paymentCongratsViewController!.tableView(self.paymentCongratsViewController!.congratsContentTable, cellForRowAtIndexPath: NSIndexPath(forRow: 0, inSection: 0)) as? AuthorizePaymentHeaderTableViewCell
//        XCTAssertNotNil(header)
//        
//        let expectedTitle = "Debes autorizar el pago ante tu tarjeta".localized
//        
//        // XCTAssertEqual(header!.title.attributedText, expectedTitle)
//        
//        
//        let body = self.paymentCongratsViewController!.tableView(self.paymentCongratsViewController!.congratsContentTable, cellForRowAtIndexPath: NSIndexPath(forRow: 0, inSection: 1)) as? AuthorizePaymentBodyTableViewCell
//        XCTAssertNotNil(body)
//        XCTAssertEqual(body!.completeCardButton.currentTitle, "Ya hablé con Mastercard y me autorizó".localized)
//        //XCTAssertEqual(body!.cancelButton)
//        body?.invokeDefaultCallback()
//        
//    }
//    
//    internal func validateCallback(payment : Payment, expectedPayment : Payment, status : MPStepBuilder.CongratsState, statusExpected: MPStepBuilder.CongratsState){
//        XCTAssertEqual(payment._id, expectedPayment._id)
//        XCTAssertEqual(status, statusExpected)
//    }
}
