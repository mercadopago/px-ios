//
//  GuessingFormTest.swift
//  MercadoPagoSDK
//
//  Created by Demian Tejo on 4/14/16.
//  Copyright © 2016 MercadoPago. All rights reserved.
//

import XCTest

class GuessingFormTest: BaseTest {

    
     var cardFormViewController : CardFormViewController?
    
    
    override func setUp() {
        super.setUp()
        MercadoPagoContext.setPublicKey(MockBuilder.MLA_PK)
    }

    /**/
    /*Test guessing con Amex , Visa y Mastercard*/
    func testCreditCardFormWithoutSettings(){
        
        self.cardFormViewController = CardFormViewController(paymentSettings: nil, amount: 1000, token: nil, paymentMethods: nil, callback: { (paymentMethod, cardToken) in
            
            }, callbackCancel: {
                
        })
        
        self.simulateViewDidLoadFor(self.cardFormViewController!)
        
        self.cardFormViewController?.textBox?.delegate = self.cardFormViewController
       
       self.checkCards()
    }
    
    /*Test con lista de metodos de pago de parametros de entrada*/
    func testCreditCardFormWithPaymentMethodList(){

        var pms : [PaymentMethod] = []
        
        MPServicesBuilder.getPaymentMethods({ (paymentMethods) -> Void in
            pms = paymentMethods!
        }) { (error) -> Void in
        }
        
        self.cardFormViewController = CardFormViewController(paymentSettings: nil, amount: 1000, token: nil, paymentMethods: pms, callback: { (paymentMethod, cardToken) in
            
            }, callbackCancel: {
                
        })
        self.simulateViewDidLoadFor(self.cardFormViewController!)
      
        self.cardFormViewController?.textBox?.delegate = self.cardFormViewController
        
    //   self.checkCards()
    }
    
    /* Test excluyendo Visa (Testea que anden el resto de las tarjeas y que rechace Visa)*/
    func testPreferencePM(){
        let pp :PaymentPreference? = PaymentPreference()
        pp?.excludedPaymentMethodIds = ["visa"]
        var pms : [PaymentMethod] = []
        
        MPServicesBuilder.getPaymentMethods({ (paymentMethods) -> Void in
            pms = paymentMethods!
        }) { (error) -> Void in
        }
        
        self.cardFormViewController = CardFormViewController(paymentSettings: pp, amount: 1000, token: nil, paymentMethods: pms, callback: { (paymentMethod, cardToken) in
            
            }, callbackCancel: {
                
        })
        self.simulateViewDidLoadFor(self.cardFormViewController!)
        
        self.cardFormViewController?.textBox?.delegate = self.cardFormViewController
        
        //MASTER
        checkPaymentMethodGuessing("5031755734530604", pmId: "master")
        //AMEX
        checkPaymentMethodGuessing("371180303257522", pmId: "amex")
        //VISA
        checkPaymentNotMachingMethodGuessing("4170068810108020", pmId: "visa")
        
    }
 
    
    /* Test excluyendo Tarjeta de Credito (Testea que rechace Visa, Amex y Mastercard)*/
    func testPreferencePT(){
        let pp :PaymentPreference? = PaymentPreference()
        pp?.excludedPaymentTypeIds = ["credit_card"]
        var pms : [PaymentMethod] = []
        
        MPServicesBuilder.getPaymentMethods({ (paymentMethods) -> Void in
            pms = paymentMethods!
            //     MercadoPagoTestContext.fulfillExpectation()
        }) { (error) -> Void in
            // Mensaje de error correspondiente, ver que hacemos con el flujo
        }
        
        self.cardFormViewController = CardFormViewController(paymentSettings: pp, amount: 1000, token: nil, paymentMethods: pms, callback: { (paymentMethod, cardToken) in
            
            }, callbackCancel: {
                
        })
        self.simulateViewDidLoadFor(self.cardFormViewController!)
        
        self.cardFormViewController?.textBox?.delegate = self.cardFormViewController
        
        //MASTER
        checkPaymentNotMachingMethodGuessing("5031755734530604", pmId: "master")
        //AMEX
        checkPaymentNotMachingMethodGuessing("371180303257522", pmId: "amex")
        //VISA
        checkPaymentNotMachingMethodGuessing("4170068810108020", pmId: "visa")
        
    }
    
 
    func checkCards (){
        //VISA
        checkPaymentMethodGuessing("4170068810108020", pmId: "visa")
        //MASTER
        checkPaymentMethodGuessing("5031755734530604", pmId: "master")
        //AMEX
        checkPaymentMethodGuessing("371180303257522", pmId: "amex")
    }
    
    func checkPaymentMethodGuessing(number: String, pmId: String){
        let binIndex = number.endIndex.advancedBy(6 - number.characters.count)
        let binNumber = number.substringToIndex(binIndex)
        let colorDefault = self.cardFormViewController?.cardView.backgroundColor
        self.cardFormViewController?.textBox?.text = binNumber
        self.cardFormViewController?.cardNumberLabel?.text = binNumber
        self.cardFormViewController?.numberLabelEmpty = false
        self.cardFormViewController?.updateCardSkin()
       
        XCTAssertNotNil(self.cardFormViewController?.paymentMethod)
        XCTAssertEqual(self.cardFormViewController?.cardFront?.cardLogo.image, MercadoPago.getImageFor((self.cardFormViewController?.paymentMethod)!))
        XCTAssertEqual(self.cardFormViewController?.cardView.backgroundColor,MercadoPago.getColorFor((self.cardFormViewController?.paymentMethod)!))
        XCTAssert(self.cardFormViewController?.paymentMethod?._id == pmId)
        
        self.cardFormViewController?.textBox?.text = "44"
        self.cardFormViewController?.cardNumberLabel?.text = "44"
        self.cardFormViewController?.numberLabelEmpty = false
        self.cardFormViewController?.updateCardSkin()
        
        XCTAssertNil(self.cardFormViewController?.paymentMethod)
   //     XCTAssertNil(self.cardFormViewController?.cardFront?.cardLogo.image)
     //   XCTAssertTrue(self.cardFormViewController?.cardView.backgroundColor == colorDefault!)

        
    }

    func checkPaymentNotMachingMethodGuessing(number: String, pmId: String){
        let binIndex = number.endIndex.advancedBy(6 - number.characters.count)
        let binNumber = number.substringToIndex(binIndex)
        self.cardFormViewController?.textBox?.text = binNumber
        self.cardFormViewController?.cardNumberLabel?.text = binNumber
        self.cardFormViewController?.numberLabelEmpty = false
        self.cardFormViewController?.updateCardSkin()
        XCTAssertNil(self.cardFormViewController?.paymentMethod)
    }
 
}
