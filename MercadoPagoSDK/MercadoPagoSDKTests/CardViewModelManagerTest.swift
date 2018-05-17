//
//  CardViewModelManagerTest.swift
//  MercadoPagoSDK
//
//  Created by Maria cristina rodriguez on 9/8/16.
//  Copyright © 2016 MercadoPago. All rights reserved.
//

import XCTest

class CardViewModelManagerTest: BaseTest {

    var cardFormManager: CardFormViewModel?

    override func setUp() {
        super.setUp()
        // Retomar valor default
        CardFormViewController.showBankDeals = true
        self.cardFormManager = CardFormViewModel(paymentMethods: [], mercadoPagoServicesAdapter: MercadoPagoServicesAdapter())
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
        let cvvLengthDefault = self.cardFormManager?.cvvLenght()
        XCTAssertEqual(cvvLengthDefault, 3)
    }

    func testCvvLengthCustomerCardLength () {
        let customerCard = MockBuilder.buildCard()
        let securityCode = SecurityCode()
        securityCode.length = 4
        customerCard.securityCode = securityCode

        self.cardFormManager?.customerCard = customerCard

        XCTAssertEqual(4, self.cardFormManager?.cvvLenght())
    }

    func testCvvLengthPaymentMethodSettingLength() {
        let paymentMethod = MockBuilder.buildPaymentMethod("amex")
        let setting = Setting()
        setting.securityCode = SecurityCode()
        setting.securityCode.length = 4
        setting.securityCode.cardLocation = "front"
        paymentMethod.settings = [setting]
        self.cardFormManager?.guessedPMS = [paymentMethod]

        let cvvLengthFromPaymentMethodSetting = self.cardFormManager?.cvvLenght()
        XCTAssertEqual(cvvLengthFromPaymentMethodSetting, paymentMethod.secCodeLenght())
    }

    /*
     *
     * getLabelTextColor() tests for default value, paymentMethod and customerCard
     *
     */
    func testGetLabelTextColorDefaultColor() {
        let color = self.cardFormManager!.getLabelTextColor(cardNumber: nil)
        XCTAssertEqual(color, MPLabel.defaultColorText)
    }

    func testGetPMLabelColors() {
        let paymentMethod = MockBuilder.buildPaymentMethod("visa")
        let cardNumber = "4242424242424242"
        self.cardFormManager?.guessedPMS = [paymentMethod]

        let fontColor = self.cardFormManager!.getLabelTextColor(cardNumber: cardNumber)
        XCTAssertEqual(fontColor, paymentMethod.getFontColor(bin: "424242"))

        let editingFontColor = self.cardFormManager!.getEditingLabelColor(cardNumber: cardNumber)
        XCTAssertEqual(editingFontColor, paymentMethod.getEditingFontColor(bin: "424242"))
    }

    func testGetPMLabelColorsForMultipleSettings() {
        let paymentMethod = MockBuilder.buildPaymentMethod("maestro", name: "Maestro", paymentTypeId: "debit_card", multipleSettings: true)
        let firstSettingCardNumber = "501041456060594693"
        let secondSettingCardNumber = "5010811232093852985"
        self.cardFormManager?.guessedPMS = [paymentMethod]

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

    func testShowBankDeals_noPromosLoaded() {
        let result = self.cardFormManager!.showBankDeals()
        XCTAssertNil(self.cardFormManager!.promos)
        XCTAssertFalse(result)
    }

    func testShowBankDeals_promosLoaded() {
        self.cardFormManager!.promos = [MockBuilder.buildPXBankDeal()]
        let result = self.cardFormManager!.showBankDeals()

        XCTAssertTrue(result)
    }

    func testShowBankDeals_promosLoadedIsEmpty() {
        self.cardFormManager!.promos = []
        let result = self.cardFormManager!.showBankDeals()
        XCTAssertFalse(result)
    }

    func testShowBankDeals_promosLoadedHidePromosByUser() {
        self.cardFormManager!.promos = [MockBuilder.buildPXBankDeal()]
        CardFormViewController.showBankDeals = false
        let result = self.cardFormManager!.showBankDeals()
        XCTAssertFalse(result)
    }

    func testGetExpirationDateFromLabel() {
        let label = MPLabel()
        label.text = "11/22"

        let year = self.cardFormManager?.getExpirationYearFromLabel(label)
        XCTAssertEqual(year, 22)

        let month = self.cardFormManager?.getExpirationMonthFromLabel(label)
        XCTAssertEqual(month, 11)

    }

    func testGetBIN() {
        let cardNumber = "12345677777777"

        let bin = self.cardFormManager?.getBIN(cardNumber)
        XCTAssertEqual(bin, "123456")
    }

    func testIsAmex() {

        let amexCardNumber = "371180111111111"
        let amexPaymentMethod = MockBuilder.buildPaymentMethod("amex")
        self.cardFormManager?.guessedPMS = [amexPaymentMethod]
        var isAmex = self.cardFormManager!.isAmexCard(amexCardNumber)
        XCTAssertTrue(isAmex)

        let masterCardNumber = "503175111111111"
        let masterPaymentMethod = MockBuilder.buildPaymentMethod("master")
        self.cardFormManager?.guessedPMS = [masterPaymentMethod]
        isAmex = self.cardFormManager!.isAmexCard(masterCardNumber)
        XCTAssertFalse(isAmex)

        isAmex = self.cardFormManager!.isAmexCard("")
        XCTAssertFalse(isAmex)
    }

    func testTokenHidratate() {
        self.cardFormManager?.cvvEmpty = false
        self.cardFormManager?.cardholderNameEmpty = false
        self.cardFormManager?.tokenHidratate("cardNumber", expirationDate: "11/22", cvv: "123", cardholderName: "cardholdername")

        XCTAssertEqual(self.cardFormManager?.cardToken?.cardNumber, "cardNumber")
        XCTAssertEqual(self.cardFormManager?.cardToken?.expirationMonth, 11)
        XCTAssertEqual(self.cardFormManager?.cardToken?.expirationYear, 2022)
        XCTAssertEqual(self.cardFormManager?.cardToken?.securityCode, "123")
        XCTAssertEqual(self.cardFormManager?.cardToken?.cardholder?.name, "cardholdername")
    }

    func testBuildSavedCardToken() {
        let customerCard = MockBuilder.buildCard()
        self.cardFormManager?.customerCard = customerCard
        self.cardFormManager!.buildSavedCardToken("cvv")

        let savedCardToken = self.cardFormManager!.cardToken as! SavedCardToken
        let savedCardtokenCardId = savedCardToken.cardId
        XCTAssertEqual(savedCardtokenCardId, customerCard.getCardId())
        XCTAssertEqual(savedCardToken.securityCode, "cvv")
        XCTAssertEqual(savedCardToken.securityCodeRequired, customerCard.isSecurityCodeRequired())
    }

    func testIsValidInputCVV() {
        //TODO : acá hay casos locos
        XCTAssertFalse(self.cardFormManager!.isValidInputCVV(""))
        XCTAssertTrue(self.cardFormManager!.isValidInputCVV("123"))
    }

    /**
     *
     Test "cardType"
     **/
    func testCardTypeCredit() {
        let amex = MockBuilder.buildPaymentMethod("amex", paymentTypeId: "credit_card")
        let visa = MockBuilder.buildPaymentMethod("visa", paymentTypeId: "credit_card")
        let master = MockBuilder.buildPaymentMethod("master")
        let cardViewModel = CardFormViewModel(paymentMethods: [amex, visa, master], mercadoPagoServicesAdapter: MercadoPagoServicesAdapter())
        XCTAssertEqual(cardViewModel.getPaymentMethodTypeId(), "credit_card")
    }

    func testCardTypeDebit() {
        let debVisa = MockBuilder.buildPaymentMethod("debvisa", paymentTypeId: "debit_card")
        let debMaster = MockBuilder.buildPaymentMethod("debmaster", paymentTypeId: "debit_card")
        let cardViewModel = CardFormViewModel(paymentMethods: [debVisa, debMaster], mercadoPagoServicesAdapter: MercadoPagoServicesAdapter())
        XCTAssertEqual(cardViewModel.getPaymentMethodTypeId(), "debit_card")

    }

    func testNoCardType() {
        let debVisa = MockBuilder.buildPaymentMethod("amex", paymentTypeId: "credit_card")
        let debMaster = MockBuilder.buildPaymentMethod("debmaster", paymentTypeId: "debit_card")
        let cardViewModel = CardFormViewModel(paymentMethods: [debVisa, debMaster], mercadoPagoServicesAdapter: MercadoPagoServicesAdapter())
        XCTAssertNil(cardViewModel.getPaymentMethodTypeId())
    }

    func testShouldShowOnlyOneCardMessage() {
        let paymentMethods = MockBuilder.getMockPaymentMethods()
        cardFormManager?.paymentMethods = paymentMethods
        XCTAssertFalse(cardFormManager!.shoudShowOnlyOneCardMessage())
        let paymentMethod = paymentMethods[0]
        cardFormManager?.paymentMethods = [paymentMethod]
        XCTAssertTrue(cardFormManager!.shoudShowOnlyOneCardMessage())
    }

    func testGetNotAvailableCardMessage() {
        let defaultMessage = "Método de pago no soportado".localized
        let message = "Solo puedes pagar con ".localized
        let paymentMethods = MockBuilder.getMockPaymentMethods()
        paymentMethods[0].name = "Visa"
        cardFormManager?.paymentMethods = paymentMethods
        XCTAssertEqual(cardFormManager!.getOnlyOneCardAvailableMessage(), message + "Visa")
        paymentMethods[0].name = ""
        XCTAssertEqual(cardFormManager!.getOnlyOneCardAvailableMessage(), defaultMessage)
        let emptyPaymentMethods = [PaymentMethod]()
        cardFormManager?.paymentMethods = emptyPaymentMethods
         XCTAssertEqual(cardFormManager!.getOnlyOneCardAvailableMessage(), defaultMessage)
    }
}
