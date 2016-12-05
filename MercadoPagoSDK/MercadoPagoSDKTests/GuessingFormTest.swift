//
//  GuessingFormTest.swift
//  MercadoPagoSDK
//
//  Created by Demian Tejo on 4/14/16.
//  Copyright © 2016 MercadoPago. All rights reserved.
//

import XCTest
@testable import MercadoPagoSDK

class GuessingFormTest: BaseTest {

    
     var cardFormViewController : CardFormViewController?
    
    
    override func setUp() {
        super.setUp()
        MercadoPagoContext.setPublicKey(MockBuilder.MLA_PK)
    }

    /**/
    /*Test guessing con Amex , Visa y Mastercard*/
//    func testCreditCardFormWithoutSettings(){
//        
//        self.cardFormViewController = CardFormViewController(paymentSettings: nil, amount: 1000, token: nil, paymentMethods: nil, callback: { (paymentMethod, cardToken) in
//            
//            }, callbackCancel: {
//                
//        })
//        
//        self.simulateViewDidLoadFor(self.cardFormViewController!)
//        
//        self.cardFormViewController?.textBox?.delegate = self.cardFormViewController
//       
//       self.checkCards()
//    }
//    
//    /*Test con lista de metodos de pago de parametros de entrada*/
//    func testCreditCardFormWithPaymentMethodList(){
//
//        var pms : [PaymentMethod] = []
//        
//        MPServicesBuilder.getPaymentMethods({ (paymentMethods) -> Void in
//            pms = paymentMethods!
//        }) { (error) -> Void in
//        }
//        
//        self.cardFormViewController = CardFormViewController(paymentSettings: nil, amount: 1000, token: nil, paymentMethods: pms, callback: { (paymentMethod, cardToken) in
//            
//            }, callbackCancel: {
//                
//        })
//        self.simulateViewDidLoadFor(self.cardFormViewController!)
//      
//        self.cardFormViewController?.textBox?.delegate = self.cardFormViewController
//        
//    //   self.checkCards()
//    }
//    
//    /* Test excluyendo Visa (Testea que anden el resto de las tarjeas y que rechace Visa)*/
//    func testPreferencePM(){
//        let pp :PaymentPreference? = PaymentPreference()
//        pp?.excludedPaymentMethodIds = ["visa"]
//        var pms : [PaymentMethod] = []
//        
//        MPServicesBuilder.getPaymentMethods({ (paymentMethods) -> Void in
//            pms = paymentMethods!
//        }) { (error) -> Void in
//        }
//        
//        self.cardFormViewController = CardFormViewController(paymentSettings: pp, amount: 1000, token: nil, paymentMethods: pms, callback: { (paymentMethod, cardToken) in
//            
//            }, callbackCancel: {
//                
//        })
//        self.simulateViewDidLoadFor(self.cardFormViewController!)
//        
//        self.cardFormViewController?.textBox?.delegate = self.cardFormViewController
//        
//        //MASTER
//        checkPaymentMethodGuessing(MockBuilder.MASTER_TEST_CARD_NUMBER, pmId: "master")
//        //AMEX
//        checkPaymentMethodGuessing(MockBuilder.AMEX_TEST_CARD_NUMBER, pmId: "amex")
//        //VISA
//        checkPaymentNotMachingMethodGuessing(MockBuilder.VISA_TEST_CARD_NUMBER, pmId: "visa")
//        
//    }
// 
//    
//    /* Test excluyendo Tarjeta de Credito (Testea que rechace Visa, Amex y Mastercard)*/
//    func testPreferencePT(){
//        let pp :PaymentPreference? = PaymentPreference()
//        pp?.excludedPaymentTypeIds = ["credit_card"]
//        var pms : [PaymentMethod] = []
//        
//        MPServicesBuilder.getPaymentMethods({ (paymentMethods) -> Void in
//            pms = paymentMethods!
//            //     MercadoPagoTestContext.fulfillExpectation()
//        }) { (error) -> Void in
//            // Mensaje de error correspondiente, ver que hacemos con el flujo
//        }
//        
//        self.cardFormViewController = CardFormViewController(paymentSettings: pp, amount: 1000, token: nil, paymentMethods: pms, callback: { (paymentMethod, cardToken) in
//            
//            }, callbackCancel: {
//                
//        })
//        self.simulateViewDidLoadFor(self.cardFormViewController!)
//        
//        self.cardFormViewController?.textBox?.delegate = self.cardFormViewController
//        
//        //MASTER
//        checkPaymentNotMachingMethodGuessing(MockBuilder.MASTER_TEST_CARD_NUMBER, pmId: "master")
//        //AMEX
//        checkPaymentNotMachingMethodGuessing(MockBuilder.AMEX_TEST_CARD_NUMBER, pmId: "amex")
//        //VISA
//        checkPaymentNotMachingMethodGuessing(MockBuilder.VISA_TEST_CARD_NUMBER, pmId: "visa")
//        
//    }
//    
//    /* Test sin exclusiones de Tarjeta de Credito. Selección de tarjeta guardada master*/
//    func testCreditCardFormWithMasterCustomerCard(){
//        let card = Card()
//        card.cardHolder = MockBuilder.buildCardholder()
//        card.customerId = "customerId"
//        card.firstSixDigits = "503175"
//        card.idCard = 1234
//        card.lastFourDigits = "8020"
//        card.paymentMethod = MockBuilder.buildPaymentMethod("master")
//        
//        self.cardFormViewController = CardFormViewController(paymentSettings: nil, amount: 1000, token: nil, cardInformation: card, callback: { (paymentMethod, cardToken) in
//            
//            }, callbackCancel: {
//                
//        })
//        self.simulateViewDidLoadFor(self.cardFormViewController!)
//        
//        self.cardFormViewController?.textBox?.delegate = self.cardFormViewController
//        
//        //MASTER
//        self.checkOnlyPaymentMethodGuessing(MockBuilder.MASTER_TEST_CARD_NUMBER, pmId: "master")
//
//        // Focus on cvv
//        XCTAssertEqual(self.cardFormViewController?.editingLabel, self.cardFormViewController?.cvvLabel)
//        
//        // Cvv displays on the back
//        XCTAssertEqual(self.cardFormViewController?.cvvLabel, self.cardFormViewController?.cardBack?.cardCVV)
//        
//    }
// 
//    /* Test sin exclusiones de Tarjeta de Credito. Selección de tarjeta guardada master*/
//    func testCreditCardFormWithAmexCustomerCard(){
//        let card = Card()
//        card.cardHolder = MockBuilder.buildCardholder()
//        card.customerId = "customerId"
//        card.firstSixDigits = "371180"
//        card.idCard = 1234
//        card.lastFourDigits = "7522"
//        card.paymentMethod = MockBuilder.buildPaymentMethod("amex")
//        
//        self.cardFormViewController = CardFormViewController(paymentSettings: nil, amount: 1000, token: nil, cardInformation: card, callback: { (paymentMethod, cardToken) in
//            
//            }, callbackCancel: {
//                
//        })
//        self.simulateViewDidLoadFor(self.cardFormViewController!)
//        
//        self.cardFormViewController?.textBox?.delegate = self.cardFormViewController
//        
//        self.checkOnlyPaymentMethodGuessing(MockBuilder.AMEX_TEST_CARD_NUMBER, pmId: "amex")
//        
//        
//        // Cvv displays on the front
//        XCTAssertEqual(self.cardFormViewController?.cvvLabel, self.cardFormViewController?.cardFront?.cardCVV)
//        
//        
//    }
//    
//    func checkCards (){
//        //VISA
//        checkPaymentMethodGuessing(MockBuilder.VISA_TEST_CARD_NUMBER, pmId: "visa")
//        //MASTER
//        checkPaymentMethodGuessing(MockBuilder.MASTER_TEST_CARD_NUMBER, pmId: "master")
//        //AMEX
//        checkPaymentMethodGuessing(MockBuilder.AMEX_TEST_CARD_NUMBER, pmId: "amex")
//    }
//    
//    func checkPaymentMethodGuessing(number: String, pmId: String){
//        self.checkOnlyPaymentMethodGuessing(number, pmId: pmId)
//        
//        self.cardFormViewController?.textBox?.text = "44"
//        self.cardFormViewController?.cardNumberLabel?.text = "44"
//        self.cardFormViewController?.numberLabelEmpty = false
//        self.cardFormViewController?.updateCardSkin()
//        
//        
//        XCTAssertNil(self.cardFormViewController?.cardFormManager!.paymentMethod)
//   //     XCTAssertNil(self.cardFormViewController?.cardFront?.cardLogo.image)
//     //   XCTAssertTrue(self.cardFormViewController?.cardView.backgroundColor == colorDefault!)
//        
//    }
//
//    func checkPaymentNotMachingMethodGuessing(number: String, pmId: String){
//        let binIndex = number.endIndex.advancedBy(6 - number.characters.count)
//        let binNumber = number.substringToIndex(binIndex)
//        self.cardFormViewController?.textBox?.text = binNumber
//        self.cardFormViewController?.cardNumberLabel?.text = binNumber
//        self.cardFormViewController?.numberLabelEmpty = false
//        self.cardFormViewController?.updateCardSkin()
//        XCTAssertNil(self.cardFormViewController?.cardFormManager!.paymentMethod)
//    }
//    
//    func checkOnlyPaymentMethodGuessing(number: String, pmId: String){
//        
//        self.cardFormViewController?.clearCardSkin()
//        
//        let binIndex = number.endIndex.advancedBy(6 - number.characters.count)
//        let binNumber = number.substringToIndex(binIndex)
//        let colorDefault = self.cardFormViewController?.cardView.backgroundColor
//        self.cardFormViewController?.textBox?.text = binNumber
//        self.cardFormViewController?.cardNumberLabel?.text = binNumber
//        self.cardFormViewController?.numberLabelEmpty = false
//        self.cardFormViewController?.updateCardSkin()
//        
//        XCTAssertNotNil(self.cardFormViewController?.cardFormManager!.paymentMethod)
//        let cardLogo = MercadoPago.getImageFor(self.cardFormViewController!.cardFormManager!.paymentMethod!)
//        XCTAssertEqual(self.cardFormViewController?.cardFront?.cardLogo.image, cardLogo)
//        XCTAssertEqual(self.cardFormViewController?.cardView.backgroundColor,MercadoPago.getColorFor((self.cardFormViewController?.cardFormManager!.paymentMethod)!))
//        XCTAssertEqual(self.cardFormViewController?.cardFormManager!.paymentMethod?._id, pmId)
//        
//    }

 
}
