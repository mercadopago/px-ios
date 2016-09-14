//
//  CardViewModelManagerTest.swift
//  MercadoPagoSDK
//
//  Created by Maria cristina rodriguez on 9/8/16.
//  Copyright © 2016 MercadoPago. All rights reserved.
//

import XCTest

class CardViewModelManagerTest: BaseTest {

    var cardFormManager : CardViewModelManager?
    
    override func setUp() {
        super.setUp()
    }
    
    override func tearDown() {
        super.tearDown()
    }
    
    func testCvvLengthDefaultValue() {
        self.cardFormManager = CardViewModelManager(amount: 10, paymentMethods: nil, paymentMethod: nil, customerCard: nil, token: nil, paymentSettings: nil)
        
        let cvvLengthDefault = self.cardFormManager?.cvvLenght()
        XCTAssertEqual(cvvLengthDefault, 3)
    }
    
    func testCvvLengthCustomerCardLength () {
        let customerCard = MockBuilder.buildCard()
        self.cardFormManager = CardViewModelManager(amount: 10, paymentMethods: nil, paymentMethod: nil, customerCard: customerCard, token: nil, paymentSettings: nil)
        
        let cvvLengthFromCustomerCard = self.cardFormManager?.cvvLenght()
        XCTAssertEqual(cvvLengthFromCustomerCard, customerCard.getCardSecurityCode().length)
    }
    
    func testCvvLengthPaymentMethodSettingLength() {
        let paymentMethod = MockBuilder.buildPaymentMethod("amex")
        let setting = Setting()
        setting.securityCode = SecurityCode()
        setting.securityCode.length = 4
        setting.securityCode.cardLocation = "front"
        paymentMethod.settings = [setting]
        self.cardFormManager = CardViewModelManager(amount: 10, paymentMethods: nil, paymentMethod: paymentMethod, customerCard: nil, token: nil, paymentSettings: nil)
        
        let cvvLengthFromPaymentMethodSetting = self.cardFormManager?.cvvLenght()
        XCTAssertEqual(cvvLengthFromPaymentMethodSetting, paymentMethod.secCodeLenght())
    }
    
    func testGetLabelTextColorDefaultColor() {
        self.cardFormManager = CardViewModelManager(amount: 10, paymentMethods: nil, paymentMethod: nil, customerCard: nil, token: nil, paymentSettings: nil)
        
        let color = self.cardFormManager?.getLabelTextColor()
        XCTAssertEqual(color, MPLabel.defaultColorText)
    }
    
    func testGetLabelTextColorPaymentMethodColor() {
        let paymentMethod = MockBuilder.buildPaymentMethod("visa")
        self.cardFormManager = CardViewModelManager(amount: 10, paymentMethods: nil, paymentMethod: paymentMethod, customerCard: nil, token: nil, paymentSettings: nil)
        
        let color = self.cardFormManager?.getLabelTextColor()
        let expectedColor = MercadoPago.getEditingFontColorFor(paymentMethod)
        XCTAssertEqual(color, expectedColor)
    }
    
    func testGetEditingLabelColorDefaultColor() {
        self.cardFormManager = CardViewModelManager(amount: 10, paymentMethods: nil, paymentMethod: nil, customerCard: nil, token: nil, paymentSettings: nil)
        
        let color = self.cardFormManager?.getLabelTextColor()
        XCTAssertEqual(color, MPLabel.highlightedColorText)
    }
    
    func testGetEditingLabelColorPaymentMethodColor() {
        let paymentMethod = MockBuilder.buildPaymentMethod("master")
        self.cardFormManager = CardViewModelManager(amount: 10, paymentMethods: nil, paymentMethod: paymentMethod, customerCard: nil, token: nil, paymentSettings: nil)
        
        let color = self.cardFormManager?.getLabelTextColor()
        let expectedColor = MercadoPago.getEditingFontColorFor(paymentMethod)
        XCTAssertEqual(color, expectedColor)
    }
    
    func testGetExpirationDateFromLabel(){
        let label = MPLabel()
        label.text = "11/22"
        
        self.cardFormManager = CardViewModelManager(amount: 10, paymentMethods: nil, paymentMethod: nil, customerCard: nil, token: nil, paymentSettings: nil)
        
        let year = self.cardFormManager?.getExpirationYearFromLabel(label)
        XCTAssertEqual(year, 22)
        
        let month = self.cardFormManager?.getExpirationMonthFromLabel(label)
        XCTAssertEqual(month, 11)
        
    }
    
    func testGetBIN(){
        let cardNumber = "12345677777777"
        
        self.cardFormManager = CardViewModelManager(amount: 10, paymentMethods: nil, paymentMethod: nil, customerCard: nil, token: nil, paymentSettings: nil)
        
        let bin = self.cardFormManager?.getBIN(cardNumber)
        XCTAssertEqual(bin, "123456")
    }
    
    func testIsAmex(){
        
        let amexCardNumber = "371180111111111"
        let amexPaymentMethod = MockBuilder.buildPaymentMethod("amex")
        self.cardFormManager = CardViewModelManager(amount: 10, paymentMethods: nil, paymentMethod: amexPaymentMethod, customerCard: nil, token: nil, paymentSettings: nil)
        var isAmex = self.cardFormManager!.isAmexCard(amexCardNumber)
        XCTAssertTrue(isAmex)
        
        let masterCardNumber = "503175111111111"
        let masterPaymentMethod = MockBuilder.buildPaymentMethod("master")
        self.cardFormManager = CardViewModelManager(amount: 10, paymentMethods: nil, paymentMethod: masterPaymentMethod, customerCard: nil, token: nil, paymentSettings: nil)
        isAmex = self.cardFormManager!.isAmexCard(masterCardNumber)
        XCTAssertFalse(isAmex)
        
        isAmex = self.cardFormManager!.isAmexCard("")
        XCTAssertFalse(isAmex)
    }
    
    func testMatchedPaymentMethod(){
        let defaultPaymentMethod = MockBuilder.buildPaymentMethod("master")
        self.cardFormManager = CardViewModelManager(amount: 10, paymentMethods: nil, paymentMethod: defaultPaymentMethod, customerCard: nil, token: nil, paymentSettings: nil)
        
        let paymentMethodFound = self.cardFormManager?.matchedPaymentMethod("XXXX")
        XCTAssertEqual(defaultPaymentMethod, paymentMethodFound)
        
        self.cardFormManager = CardViewModelManager(amount: 10, paymentMethods: nil, paymentMethod: nil, customerCard: nil, token: nil, paymentSettings: nil)
        let noPaymentMethodFound = self.cardFormManager?.matchedPaymentMethod("XXXX")
        XCTAssertNil(noPaymentMethodFound)

    }
    
    func testTokenHidratate(){
        self.cardFormManager = CardViewModelManager(amount: 10, paymentMethods: nil, paymentMethod: nil, customerCard: nil, token: nil, paymentSettings: nil)
        self.cardFormManager?.cvvEmpty = false
        self.cardFormManager?.cardholderNameEmpty = false
        self.cardFormManager?.tokenHidratate("cardNumber", expirationDate: "11/22", cvv: "123", cardholderName: "cardholdername")
        
        XCTAssertEqual(self.cardFormManager?.cardToken?.cardNumber, "cardNumber")
        XCTAssertEqual(self.cardFormManager?.cardToken?.expirationMonth, 11)
        XCTAssertEqual(self.cardFormManager?.cardToken?.expirationYear, 2022)
        XCTAssertEqual(self.cardFormManager?.cardToken?.securityCode, "123")
        XCTAssertEqual(self.cardFormManager?.cardToken?.cardholder?.name, "cardholdername")
    }
    
    func testBuildSavedCardToken(){
        let customerCard = MockBuilder.buildCard()
        self.cardFormManager = CardViewModelManager(amount: 10, paymentMethods: nil, paymentMethod: nil, customerCard: customerCard, token: nil, paymentSettings: nil)
        self.cardFormManager?.buildSavedCardToken("cvv")
        
        let savedCardToken = self.cardFormManager!.cardToken as! SavedCardToken
        let savedCardtokenCardId = savedCardToken.cardId
        //XCTAssertEqual(savedCardtokenCardId, customerCard.idCard)
        XCTAssertEqual(savedCardToken.securityCode, "cvv")
        XCTAssertEqual(savedCardToken.securityCodeRequired, customerCard.isSecurityCodeRequired())
    }
    
    func testIsValidInputCVV() {
        self.cardFormManager = CardViewModelManager(amount: 10, paymentMethods: nil, paymentMethod: nil, customerCard: nil, token: nil, paymentSettings: nil)
        //TODO : acá hay casos locos
        XCTAssertFalse(self.cardFormManager!.isValidInputCVV(""))
        XCTAssertTrue(self.cardFormManager!.isValidInputCVV("123"))
    }
    
    func testValidateCardNumber(){
        
    }
}
