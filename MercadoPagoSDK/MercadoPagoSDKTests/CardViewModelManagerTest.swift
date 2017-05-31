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
    
    /*
     *
     * cvvLenght() tests with default value, customer card and payment method setting
     *
     */
    func testCvvLengthDefaultValue() {
        self.cardFormManager = CardViewModelManager(amount: 10, paymentMethods: nil, paymentSettings: nil)
        
        let cvvLengthDefault = self.cardFormManager?.cvvLenght()
        XCTAssertEqual(cvvLengthDefault, 3)
    }
    
    func testCvvLengthCustomerCardLength () {
        let customerCard = MockBuilder.buildCard()
        let securityCode = SecurityCode()
        securityCode.length = 4
        customerCard.securityCode = securityCode
        
        self.cardFormManager = CardViewModelManager(amount: 10, paymentMethods: nil, paymentMethod: nil, customerCard: customerCard, token: nil, paymentSettings: nil)
        
        XCTAssertEqual(4, self.cardFormManager?.cvvLenght())
    }
    
    func testCvvLengthPaymentMethodSettingLength() {
        let paymentMethod = MockBuilder.buildPaymentMethod("amex")
        let setting = Setting()
        setting.securityCode = SecurityCode()
        setting.securityCode.length = 4
        setting.securityCode.cardLocation = "front"
        paymentMethod.settings = [setting]
        self.cardFormManager = CardViewModelManager(amount: 10, paymentMethods: nil, paymentMethod: [paymentMethod], customerCard: nil, token: nil, paymentSettings: nil)
        
        let cvvLengthFromPaymentMethodSetting = self.cardFormManager?.cvvLenght()
        XCTAssertEqual(cvvLengthFromPaymentMethodSetting, paymentMethod.secCodeLenght())
    }
    
    /*
     *
     * getLabelTextColor() tests for default value, paymentMethod and customerCard
     *
     */
    func testGetLabelTextColorDefaultColor() {
        self.cardFormManager = CardViewModelManager(amount: 10, paymentMethods: nil, paymentSettings: nil)
        
        let color = self.cardFormManager!.getLabelTextColor(cardNumber: nil)
        XCTAssertEqual(color, MPLabel.defaultColorText)
    }
    
    func testGetPMLabelColors() {
        let paymentMethod = MockBuilder.buildPaymentMethod("visa")
        let cardNumber = "4242424242424242"
        self.cardFormManager = CardViewModelManager(amount: 10, paymentMethods: nil, paymentMethod: [paymentMethod], paymentSettings: nil)
        
        let fontColor = self.cardFormManager!.getLabelTextColor(cardNumber: cardNumber)
        XCTAssertEqual(fontColor, paymentMethod.getFontColor(bin: "424242"))
        
        let editingFontColor = self.cardFormManager!.getEditingLabelColor(cardNumber: cardNumber)
        XCTAssertEqual(editingFontColor, paymentMethod.getEditingFontColor(bin: "424242"))
    }
    
    func testGetPMLabelColorsForMultipleSettings() {
        let paymentMethod = MockBuilder.buildPaymentMethod("maestro", name : "Maestro", paymentTypeId : "debit_card", multipleSettings: true)
        let firstSettingCardNumber = "501041456060594693"
        let secondSettingCardNumber = "5010811232093852985"
        self.cardFormManager = CardViewModelManager(amount: 10, paymentMethods: nil, paymentMethod: [paymentMethod], paymentSettings: nil)
        
        let firstBin = firstSettingCardNumber.substring(to: (firstSettingCardNumber.characters.index(firstSettingCardNumber.startIndex, offsetBy: 6)))
        let secondBin = secondSettingCardNumber.substring(to: (secondSettingCardNumber.characters.index(firstSettingCardNumber.startIndex, offsetBy: 6)))
        
        //First Setting Colors
        let firtsFontColor = self.cardFormManager!.getLabelTextColor(cardNumber: firstSettingCardNumber)
        XCTAssertEqual(firtsFontColor, paymentMethod.getFontColor(bin: firstBin))
        
        let firstEditingFontColor = self.cardFormManager!.getEditingLabelColor(cardNumber: firstSettingCardNumber)
        XCTAssertEqual(firstEditingFontColor, paymentMethod.getEditingFontColor(bin: firstBin))

        //Second Setting Colors
        let secondFontColor = self.cardFormManager!.getLabelTextColor(cardNumber: secondSettingCardNumber)
        XCTAssertEqual(secondFontColor, paymentMethod.getFontColor(bin: secondBin))
        
        let secondEditingFontColor = self.cardFormManager!.getEditingLabelColor(cardNumber: secondSettingCardNumber)
        XCTAssertEqual(secondEditingFontColor, paymentMethod.getEditingFontColor(bin: secondBin))
    }

    
    
//    func testGetLabelTextColorCustomerCard() {
//        let customerCard = MockBuilder.buildCard(paymentMethodId: "master")
//        self.cardFormManager = CardViewModelManager(amount: 10, paymentMethods: nil, paymentMethod: nil, customerCard : customerCard, paymentSettings: nil)
//        
//        let expectedPaymentMethod = MockBuilder.buildPaymentMethod("master")
//        XCTAssertEqual(MercadoPago.getFontColorFor(expectedPaymentMethod), self.cardFormManager!.getLabelTextColor())
//    }
   
    /*
     *
     * showBankDeals() tests for no promos loaded, promos loaded and custom setting in CardFormVC
     *
     */
    func testShowBankDeals_noPromosLoaded(){
        self.cardFormManager = CardViewModelManager(amount: 10, paymentMethods: nil, paymentSettings: nil)
        let result = self.cardFormManager!.showBankDeals()
        XCTAssertNil(self.cardFormManager!.promos)
        XCTAssertFalse(result)
    }
    
    func testShowBankDeals_promosLoaded(){
        self.cardFormManager = CardViewModelManager(amount: 10, paymentMethods: nil, paymentSettings: nil)
        self.cardFormManager!.promos = [MockBuilder.buildPromo()]
        let result = self.cardFormManager!.showBankDeals()
        XCTAssertTrue(result)
    }
    
    func testShowBankDeals_promosLoadedIsEmpty(){
        self.cardFormManager = CardViewModelManager(amount: 10, paymentMethods: nil, paymentSettings: nil)
        self.cardFormManager!.promos = []
        let result = self.cardFormManager!.showBankDeals()
        XCTAssertFalse(result)
    }
    
    func testShowBankDeals_promosLoadedHidePromosByUser(){
        self.cardFormManager = CardViewModelManager(amount: 10, paymentMethods: nil, paymentSettings: nil)
        self.cardFormManager!.promos = [MockBuilder.buildPromo()]
        CardFormViewController.showBankDeals = false
        let result = self.cardFormManager!.showBankDeals()
        XCTAssertFalse(result)
    }
    
    func testGetEditingLabelColorDefaultColor() {
        self.cardFormManager = CardViewModelManager(amount: 10, paymentMethods: nil, paymentMethod: nil, customerCard: nil, token: nil, paymentSettings: nil)
        
     //   let color = self.cardFormManager?.getLabelTextColor()
     //   XCTAssertEqual(color, MPLabel.highlightedColorText)
    }
    
    func testGetEditingLabelColorPaymentMethodColor() {
        let paymentMethod = MockBuilder.buildPaymentMethod("master")
        self.cardFormManager = CardViewModelManager(amount: 10, paymentMethods: nil, paymentMethod: [paymentMethod], customerCard: nil, token: nil, paymentSettings: nil)
        
       // let color = self.cardFormManager?.getLabelTextColor()
       // let expectedColor = MercadoPago.getEditingFontColorFor(paymentMethod)
       // XCTAssertEqual(color, expectedColor)
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
        self.cardFormManager = CardViewModelManager(amount: 10, paymentMethods: nil, paymentMethod: [amexPaymentMethod], customerCard: nil, token: nil, paymentSettings: nil)
        var isAmex = self.cardFormManager!.isAmexCard(amexCardNumber)
        XCTAssertTrue(isAmex)
        
        let masterCardNumber = "503175111111111"
        let masterPaymentMethod = MockBuilder.buildPaymentMethod("master")
        self.cardFormManager = CardViewModelManager(amount: 10, paymentMethods: nil, paymentMethod: [masterPaymentMethod], customerCard: nil, token: nil, paymentSettings: nil)
        isAmex = self.cardFormManager!.isAmexCard(masterCardNumber)
        XCTAssertFalse(isAmex)
        
        isAmex = self.cardFormManager!.isAmexCard("")
        XCTAssertFalse(isAmex)
    }
    
    func testMatchedPaymentMethod(){
        let defaultPaymentMethod = MockBuilder.buildPaymentMethod("master")
        self.cardFormManager = CardViewModelManager(amount: 10, paymentMethods: nil, paymentMethod: [defaultPaymentMethod], customerCard: nil, token: nil, paymentSettings: nil)
        
        let paymentMethodFound = self.cardFormManager?.matchedPaymentMethod("XXXX")
        //XCTAssertEqual(defaultPaymentMethod, paymentMethodFound!)
        
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
     /*   self.cardFormManager = CardViewModelManager(amount: 10, paymentMethods: nil, paymentMethod: nil, customerCard: customerCard, token: nil, paymentSettings: nil)
        self.cardFormManager?.buildSavedCardToken("cvv")
        
        let savedCardToken = self.cardFormManager!.cardToken as! SavedCardToken
        let savedCardtokenCardId = savedCardToken.cardId
        //XCTAssertEqual(savedCardtokenCardId, customerCard.idCard)
        XCTAssertEqual(savedCardToken.securityCode, "cvv")
        XCTAssertEqual(savedCardToken.securityCodeRequired, customerCard.isSecurityCodeRequired())*/
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
