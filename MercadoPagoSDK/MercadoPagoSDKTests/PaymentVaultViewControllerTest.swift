//
//  PaymentVaultViewControllerTest.swift
//  MercadoPagoSDK
//
//  Created by Maria cristina rodriguez on 22/1/16.
//  Copyright © 2016 MercadoPago. All rights reserved.
//

import XCTest

class PaymentVaultViewModelTest: BaseTest {

    var instance: PaymentVaultViewModel?

    let mockPmSearchitem = MockBuilder.buildPaymentMethodSearchItem("pmId")

    override func setUp() {

        instance = createPaymentVaulViewModelInstance(paymentMethodOptions: [mockPmSearchitem] as [PaymentMethodOption])
    }

    func createPaymentVaulViewModelInstance(paymentMethodOptions: [PaymentMethodOption], customerPaymentMethods: [CardInformation] = [], paymentMethodPlugins: [PXPaymentMethodPlugin] = []) -> PaymentVaultViewModel {
        return  PaymentVaultViewModel(amount: 1.0, paymentPrefence: nil, paymentMethodOptions: paymentMethodOptions, customerPaymentOptions: customerPaymentMethods, paymentMethodPlugins: paymentMethodPlugins, isRoot: true, email: "sarasa@hotmail.com", mercadoPagoServicesAdapter: MercadoPagoServicesAdapter())
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
        var paymentMethodOptions = [mockPaymentMethodSearchItem]
        instance = createPaymentVaulViewModelInstance(paymentMethodOptions: paymentMethodOptions)
        paymentMethodCount = instance!.getDisplayedPaymentMethodsCount()
        XCTAssertEqual(1, paymentMethodCount)

        // Payment methods not loaded
        paymentMethodOptions = [mockPaymentMethodSearchItem, mockPaymentMethodSearchItem, mockPaymentMethodSearchItem]
        instance = createPaymentVaulViewModelInstance(paymentMethodOptions: paymentMethodOptions)
        paymentMethodCount = instance!.getDisplayedPaymentMethodsCount()
        XCTAssertEqual(3, paymentMethodCount)

        // Display 3 payment methods from search and two cards
        let cardMock = MockBuilder.buildCard()
        var customerPaymentOptions = [cardMock, cardMock]
        instance = createPaymentVaulViewModelInstance(paymentMethodOptions: paymentMethodOptions, customerPaymentMethods: customerPaymentOptions)
        paymentMethodCount = instance!.getDisplayedPaymentMethodsCount()
        XCTAssertEqual(5, paymentMethodCount)

        // Display 3 payment methods from search and 3 cards (max available)
        customerPaymentOptions = [cardMock, cardMock, cardMock, cardMock]
       instance = createPaymentVaulViewModelInstance(paymentMethodOptions: paymentMethodOptions, customerPaymentMethods: customerPaymentOptions)
        paymentMethodCount = instance!.getDisplayedPaymentMethodsCount()
        XCTAssertEqual(6, paymentMethodCount)

        // Verify custom MaxSavedCardsToShow
        MercadoPagoCheckoutViewModel.flowPreference.maxSavedCardsToShow = 4
        instance = createPaymentVaulViewModelInstance(paymentMethodOptions: paymentMethodOptions, customerPaymentMethods: customerPaymentOptions)
        paymentMethodCount = instance!.getDisplayedPaymentMethodsCount()
        XCTAssertEqual(7, paymentMethodCount)
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

    /**
     *  getPaymentMethodOption() for groups payment methods
     */
    func testGetPaymentMethodOptionNoCustomerCard() {
        let mockPmSearchitem = MockBuilder.buildPaymentMethodSearchItem("pmId")
        let mockAnotherPmSearchitem = MockBuilder.buildPaymentMethodSearchItem("anotherPmId")
        let mockOneMorePmSearchitem = MockBuilder.buildPaymentMethodSearchItem("oneMorePmId")
        let mockOneLastPmSearchitem = MockBuilder.buildPaymentMethodSearchItem("oneLastPmId")
        instance = createPaymentVaulViewModelInstance(paymentMethodOptions: [mockPmSearchitem, mockAnotherPmSearchitem, mockOneMorePmSearchitem, mockOneLastPmSearchitem])

        var result = instance!.getPaymentMethodOption(row: 0)
        XCTAssertEqual("pmId", result!.getTitle())

        result = instance!.getPaymentMethodOption(row: 2)
        XCTAssertEqual("oneMorePmId", result!.getTitle())

        result = instance!.getPaymentMethodOption(row: 3)
        XCTAssertEqual("oneLastPmId", result!.getTitle())
    }

    /**
     *  getPaymentMethodOption() with customer cards
     */
    func testGetPaymentMethodOptionWithCustomerCards() {

        let mockCard = MockBuilder.buildCustomerPaymentMethod(paymentMethodId: "amex", paymentTypeId: "credit_card")
        let anotherMockCard = MockBuilder.buildCustomerPaymentMethod(paymentMethodId: "visa", paymentTypeId: "credit_card")

        let mockPmSearchitem = MockBuilder.buildPaymentMethodSearchItem("pmId")
        let mockAnotherPmSearchitem = MockBuilder.buildPaymentMethodSearchItem("anotherPmId")
        let mockOneMorePmSearchitem = MockBuilder.buildPaymentMethodSearchItem("oneMorePmId")
        let mockOneLastPmSearchitem = MockBuilder.buildPaymentMethodSearchItem("oneLastPmId")

        let customerPaymentOptions = [mockCard, anotherMockCard]
        let paymentMethodOptions = [mockPmSearchitem, mockAnotherPmSearchitem, mockOneMorePmSearchitem, mockOneLastPmSearchitem]

        instance = createPaymentVaulViewModelInstance(paymentMethodOptions: paymentMethodOptions, customerPaymentMethods: customerPaymentOptions)

        var result = instance!.getPaymentMethodOption(row: 3)
        XCTAssertEqual("anotherPmId", result!.getTitle())

        result = instance!.getPaymentMethodOption(row: 1)
        XCTAssertEqual("visa", result!.getTitle())

        result = instance!.getPaymentMethodOption(row: 5)
        XCTAssertEqual("oneLastPmId", result!.getTitle())
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

        let mockPmSearchitem = MockBuilder.buildPaymentMethodSearchItem("pmId")
        let mockAnotherPmSearchitem = MockBuilder.buildPaymentMethodSearchItem("anotherPmId")
        let mockOneMorePmSearchitem = MockBuilder.buildPaymentMethodSearchItem("oneMorePmId")
        let mockOneLastPmSearchitem = MockBuilder.buildPaymentMethodSearchItem("oneLastPmId")

        let paymentMethodOptions = [mockPmSearchitem, mockAnotherPmSearchitem, mockOneMorePmSearchitem, mockOneLastPmSearchitem]
        let customerPaymentMethods = [mockCard, anotherMockCard, oneMoreMockCard, oneLastMockCard, thisIsTheLastMockCardIPromise]
        instance = createPaymentVaulViewModelInstance(paymentMethodOptions: paymentMethodOptions, customerPaymentMethods: customerPaymentMethods)

        var result = instance!.getPaymentMethodOption(row: 3)
        XCTAssertEqual("pmId", result!.getTitle())

        result = instance!.getPaymentMethodOption(row: 1)
        XCTAssertEqual("visa", result!.getTitle())

        result = instance!.getPaymentMethodOption(row: 2)
        XCTAssertEqual("master", result!.getTitle())

        result = instance!.getPaymentMethodOption(row: 6)
        XCTAssertEqual("oneLastPmId", result!.getTitle())

        //Change MaxSavedCardsToShow
        MercadoPagoCheckoutViewModel.flowPreference.maxSavedCardsToShow = 5
        instance = createPaymentVaulViewModelInstance(paymentMethodOptions: paymentMethodOptions, customerPaymentMethods: customerPaymentMethods)

        result = instance!.getPaymentMethodOption(row: 3)
        XCTAssertEqual("elo", result!.getTitle())

        result = instance!.getPaymentMethodOption(row: 0)
        XCTAssertEqual("amex", result!.getTitle())

        result = instance!.getPaymentMethodOption(row: 4)
        XCTAssertEqual("hipercard", result!.getTitle())

        result = instance!.getPaymentMethodOption(row: 5)
        XCTAssertEqual("pmId", result!.getTitle())

        result = instance!.getPaymentMethodOption(row: 8)
        XCTAssertEqual("oneLastPmId", result!.getTitle())

        //Change MaxSavedCardsToShow
        MercadoPagoCheckoutViewModel.flowPreference.maxSavedCardsToShow = 2
        instance = createPaymentVaulViewModelInstance(paymentMethodOptions: paymentMethodOptions, customerPaymentMethods: customerPaymentMethods)

        result = instance!.getPaymentMethodOption(row: 2)
        XCTAssertEqual("pmId", result!.getTitle())

        result = instance!.getPaymentMethodOption(row: 1)
        XCTAssertEqual("visa", result!.getTitle())
    }

    // MARK: Test Get Payment Method Option with Payment Methods Plugins
    func testGetPaymentMethodOption_WithCustomerCardsPaymentMethodPlugin_Calculated() {

        let mockCard = MockBuilder.buildCustomerPaymentMethod(paymentMethodId: "amex", paymentTypeId: "credit_card")
        let anotherMockCard = MockBuilder.buildCustomerPaymentMethod(paymentMethodId: "visa", paymentTypeId: "credit_card")

        let mockPmSearchitem = MockBuilder.buildPaymentMethodSearchItem("pmId")
        let mockAnotherPmSearchitem = MockBuilder.buildPaymentMethodSearchItem("anotherPmId")
        let mockOneMorePmSearchitem = MockBuilder.buildPaymentMethodSearchItem("oneMorePmId")
        let mockOneLastPmSearchitem = MockBuilder.buildPaymentMethodSearchItem("oneLastPmId")

        // Plugins at top
        var mockPaymentMethodPlugin1 = MockBuilder.buildPaymentMethodPlugin(id: "plugin1", name: "Plugin 1", configPaymentMethodPlugin: nil)
        var mockPaymentMethodPlugin2 = MockBuilder.buildPaymentMethodPlugin(id: "plugin2", name: "Plugin 2", configPaymentMethodPlugin: nil)

        let customerPaymentOptions = [mockCard, anotherMockCard]
        let paymentMethodOptions = [mockPmSearchitem, mockAnotherPmSearchitem, mockOneMorePmSearchitem, mockOneLastPmSearchitem]
        var pluginPaymentMethod = [mockPaymentMethodPlugin1, mockPaymentMethodPlugin2]

        instance = createPaymentVaulViewModelInstance(paymentMethodOptions: paymentMethodOptions, customerPaymentMethods: customerPaymentOptions, paymentMethodPlugins: pluginPaymentMethod)

        var result = instance!.getPaymentMethodOption(row: 0)
        XCTAssertEqual("Plugin 1", result!.getTitle())

        result = instance!.getPaymentMethodOption(row: 1)
        XCTAssertEqual("Plugin 2", result!.getTitle())

        result = instance!.getPaymentMethodOption(row: 5)
        XCTAssertEqual("anotherPmId", result!.getTitle())

        result = instance!.getPaymentMethodOption(row: 3)
        XCTAssertEqual("visa", result!.getTitle())

        result = instance!.getPaymentMethodOption(row: 7)
        XCTAssertEqual("oneLastPmId", result!.getTitle())

        // Plugins at bottom
        mockPaymentMethodPlugin1 = MockBuilder.buildPaymentMethodPlugin(id: "plugin1", name: "Plugin 1", displayOrder: .BOTTOM, configPaymentMethodPlugin: nil)
        mockPaymentMethodPlugin2 = MockBuilder.buildPaymentMethodPlugin(id: "plugin2", name: "Plugin 2", displayOrder: .BOTTOM, configPaymentMethodPlugin: nil)

        pluginPaymentMethod = [mockPaymentMethodPlugin1, mockPaymentMethodPlugin2]

        instance = createPaymentVaulViewModelInstance(paymentMethodOptions: paymentMethodOptions, customerPaymentMethods: customerPaymentOptions, paymentMethodPlugins: pluginPaymentMethod)

        result = instance!.getPaymentMethodOption(row: 3)
        XCTAssertEqual("anotherPmId", result!.getTitle())

        result = instance!.getPaymentMethodOption(row: 1)
        XCTAssertEqual("visa", result!.getTitle())

        result = instance!.getPaymentMethodOption(row: 5)
        XCTAssertEqual("oneLastPmId", result!.getTitle())

        result = instance!.getPaymentMethodOption(row: 6)
        XCTAssertEqual("Plugin 1", result!.getTitle())

        result = instance!.getPaymentMethodOption(row: 7)
        XCTAssertEqual("Plugin 2", result!.getTitle())
    }

    func testGetPaymentMethodOption_NoCustomerCardAndPaymentMethodsPlugin_Calculated() {
        let mockPmSearchitem = MockBuilder.buildPaymentMethodSearchItem("pmId")
        let mockAnotherPmSearchitem = MockBuilder.buildPaymentMethodSearchItem("anotherPmId")
        let mockOneMorePmSearchitem = MockBuilder.buildPaymentMethodSearchItem("oneMorePmId")
        let mockOneLastPmSearchitem = MockBuilder.buildPaymentMethodSearchItem("oneLastPmId")

        // Plugins at top
        var mockPaymentMethodPlugin1 = MockBuilder.buildPaymentMethodPlugin(id: "plugin1", name: "Plugin 1", configPaymentMethodPlugin: nil)
        var mockPaymentMethodPlugin2 = MockBuilder.buildPaymentMethodPlugin(id: "plugin2", name: "Plugin 2", configPaymentMethodPlugin: nil)
        var pluginPaymentMethods = [mockPaymentMethodPlugin1, mockPaymentMethodPlugin2]

        instance = createPaymentVaulViewModelInstance(paymentMethodOptions: [mockPmSearchitem, mockAnotherPmSearchitem, mockOneMorePmSearchitem, mockOneLastPmSearchitem], paymentMethodPlugins: pluginPaymentMethods)

        var result = instance!.getPaymentMethodOption(row: 0)
        XCTAssertEqual("Plugin 1", result!.getTitle())

        result = instance!.getPaymentMethodOption(row: 1)
        XCTAssertEqual("Plugin 2", result!.getTitle())

        result = instance!.getPaymentMethodOption(row: 2)
        XCTAssertEqual("pmId", result!.getTitle())

        result = instance!.getPaymentMethodOption(row: 4)
        XCTAssertEqual("oneMorePmId", result!.getTitle())

        result = instance!.getPaymentMethodOption(row: 5)
        XCTAssertEqual("oneLastPmId", result!.getTitle())

        // Plugins at bottom
        mockPaymentMethodPlugin1 = MockBuilder.buildPaymentMethodPlugin(id: "plugin1", name: "Plugin 1", displayOrder: .BOTTOM, configPaymentMethodPlugin: nil)
        mockPaymentMethodPlugin2 = MockBuilder.buildPaymentMethodPlugin(id: "plugin2", name: "Plugin 2", displayOrder: .BOTTOM, configPaymentMethodPlugin: nil)

        pluginPaymentMethods = [mockPaymentMethodPlugin1, mockPaymentMethodPlugin2]

        instance = createPaymentVaulViewModelInstance(paymentMethodOptions: [mockPmSearchitem, mockAnotherPmSearchitem, mockOneMorePmSearchitem, mockOneLastPmSearchitem], paymentMethodPlugins: pluginPaymentMethods)

        result = instance!.getPaymentMethodOption(row: 0)
        XCTAssertEqual("pmId", result!.getTitle())

        result = instance!.getPaymentMethodOption(row: 2)
        XCTAssertEqual("oneMorePmId", result!.getTitle())

        result = instance!.getPaymentMethodOption(row: 3)
        XCTAssertEqual("oneLastPmId", result!.getTitle())

        result = instance!.getPaymentMethodOption(row: 4)
        XCTAssertEqual("Plugin 1", result!.getTitle())

        result = instance!.getPaymentMethodOption(row: 5)
        XCTAssertEqual("Plugin 2", result!.getTitle())
    }

    override func tearDown() {
        // Restore default value
        super.tearDown()
        MercadoPagoCheckoutViewModel.flowPreference.maxSavedCardsToShow = FlowPreference.DEFAULT_MAX_SAVED_CARDS_TO_SHOW
    }

}
