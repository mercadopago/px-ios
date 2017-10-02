//
//  CheckoutViewModelTest.swift
//  MercadoPagoSDK
//
//  Created by Eden Torres on 4/18/17.
//  Copyright © 2017 MercadoPago. All rights reserved.
//

import XCTest
@testable import MercadoPagoSDK
class CheckoutViewModelTest: BaseTest {

    var instance: CheckoutViewModel?
    var instanceWithCoupon: CheckoutViewModel?
    var instanceWithCustomSummaryRow: CheckoutViewModel?

    var paymentData: PaymentData = PaymentData()

    let mockPaymentMethodSearchItem = MockBuilder.buildPaymentMethodSearchItem("paymentMethodId")

    override func setUp() {
        let checkoutPref = CheckoutPreference()
        checkoutPref.items = [Item(_id: "12", title: "test", quantity: 1, unitPrice: 1000.0, description: "dummy", currencyId: "ARG")]

        self.instance = CheckoutViewModel(checkoutPreference: checkoutPref, paymentData: PaymentData(), paymentOptionSelected: mockPaymentMethodSearchItem as PaymentMethodOption)

        paymentData = MockBuilder.buildPaymentData(paymentMethodId: "visa", paymentMethodName: "Visa", paymentMethodTypeId: "credit_card")
        paymentData.payerCost = MockBuilder.buildInstallment().payerCosts[1]
        paymentData.payerCost?.installments = 3
        paymentData.discount = MockBuilder.buildDiscount()
        paymentData.payer = MockBuilder.buildPayer("id")

        self.instanceWithCoupon = CheckoutViewModel(checkoutPreference: CheckoutPreference(), paymentData: paymentData, paymentOptionSelected: mockPaymentMethodSearchItem as PaymentMethodOption)

        let reviewScreenPreference = ReviewScreenPreference()

        self.instanceWithCustomSummaryRow = CheckoutViewModel(checkoutPreference: CheckoutPreference(), paymentData: paymentData, paymentOptionSelected: mockPaymentMethodSearchItem as PaymentMethodOption, reviewScreenPreference: reviewScreenPreference)
    }

    func testCells() {
        XCTAssertTrue(self.instance!.isTitleCellFor(indexPath: IndexPath(row: 0, section: 0)))
        XCTAssertEqual(self.instance!.heightForRow(IndexPath(row: 0, section: 0)), 60)

        XCTAssertTrue(self.instance!.isPaymentMethodCellFor(indexPath: IndexPath(row: 0, section: 3)))

        XCTAssertTrue(self.instance!.isItemCellFor(indexPath: IndexPath(row: 1, section: 2)))
        XCTAssertEqual(self.instance!.heightForRow(IndexPath(row: 0, section: 2)), PurchaseItemDetailTableViewCell.getCellHeight(item: self.instance!.preference!.items[0]))

        MercadoPagoContext.setPayerAccessToken("")

        XCTAssertTrue(self.instance!.isTermsAndConditionsViewCellFor(indexPath: IndexPath(row: 0, section: 5)))
        XCTAssertEqual(self.instance!.heightForRow(IndexPath(row: 0, section: 5)), TermsAndConditionsViewCell.getCellHeight())

        XCTAssertTrue(self.instance!.isExitButtonTableViewCellFor(indexPath: IndexPath(row: 2, section: 5)))
        XCTAssertEqual(self.instance!.heightForRow(IndexPath(row: 2, section: 5)), ExitButtonTableViewCell.ROW_HEIGHT)

        MercadoPagoContext.setPayerAccessToken("sarasa")

        XCTAssertTrue(self.instance!.isExitButtonTableViewCellFor(indexPath: IndexPath(row: 1, section: 5)))
        XCTAssertEqual(self.instance!.heightForRow(IndexPath(row: 1, section: 5)), ExitButtonTableViewCell.ROW_HEIGHT)

        XCTAssertEqual(self.instance!.heightForRow(IndexPath(row: 2, section: 100)), 0)

    }

    func testNumberOfRowsInSection() {
        XCTAssertEqual(self.instance!.numberOfRowsInSection(section: 0), 1)
        XCTAssertEqual(self.instance!.numberOfRowsInSection(section: 2), self.instance!.preference!.items.count)
        XCTAssertEqual(self.instance!.numberOfRowsInSection(section: 3), 1)
        XCTAssertEqual(self.instance!.numberOfRowsInSection(section: 4), self.instance!.numberOfCustomAdditionalCells())

        MercadoPagoContext.setPayerAccessToken("")
        XCTAssertEqual(self.instance!.numberOfRowsInSection(section: 5), 3)

        MercadoPagoContext.setPayerAccessToken("sarasa")
        XCTAssertEqual(self.instance!.numberOfRowsInSection(section: 5), 2)

        XCTAssertEqual(self.instance!.numberOfRowsInSection(section: 100), 0)
    }

    func testIsLogged() {
        MercadoPagoContext.setPayerAccessToken("")
        XCTAssertFalse(self.instance!.isUserLogged())

        MercadoPagoContext.setPayerAccessToken("sarasa")
        XCTAssertTrue(self.instance!.isUserLogged())
    }

    func testIsPaymentMethodSelectedCard() {

        XCTAssertFalse(self.instance!.isPaymentMethodSelectedCard())

        self.instance!.paymentData.paymentMethod = MockBuilder.buildPaymentMethod("rapipago", name: "rapipago", paymentTypeId: PaymentTypeId.TICKET.rawValue)
        XCTAssertFalse(self.instance!.isPaymentMethodSelectedCard())

        self.instance!.paymentData.paymentMethod = MockBuilder.buildPaymentMethod("visa", name: "visa", paymentTypeId: PaymentTypeId.CREDIT_CARD.rawValue)
        XCTAssertTrue(self.instance!.isPaymentMethodSelectedCard())

        self.instance!.paymentData.paymentMethod = MockBuilder.buildPaymentMethod("debmaster", name: "master", paymentTypeId: PaymentTypeId.DEBIT_CARD.rawValue)
        XCTAssertTrue(self.instance!.isPaymentMethodSelectedCard())
    }

    func testNumberOfSections() {
        let preference = MockBuilder.buildCheckoutPreference()
        self.instance!.preference = preference

        XCTAssertEqual(6, self.instance!.numberOfSections())

    }

    func testIsPaymentMethodSelected() {

        self.instance!.paymentData.paymentMethod = MockBuilder.buildPaymentMethod("rapipago", name: "rapipago", paymentTypeId: PaymentTypeId.TICKET.rawValue)

        XCTAssertTrue(self.instance!.isPaymentMethodSelected())

        self.instance!.paymentData.paymentMethod = nil

        XCTAssertFalse(self.instance!.isPaymentMethodSelected())

    }

    func testIsPreferenceLoaded() {
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

        //Amount with discount
        self.instanceWithCoupon?.paymentData.payerCost = nil
        XCTAssertEqual(self.instanceWithCoupon?.getTotalAmount(), paymentData.discount?.newAmount())
    }

    func testShouldDisplayNoRate() {

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

    func testAddtitionalCustomCells() {
        XCTAssertEqual(self.instance!.numberOfCustomAdditionalCells(), 0)

        let reviewScreenPreference = ReviewScreenPreference()
        reviewScreenPreference.setAddionalInfoCells(customCells: [MPCustomCell(cell: UITableViewCell())])
        self.instance!.reviewScreenPreference = reviewScreenPreference

        XCTAssertEqual(self.instance!.numberOfCustomAdditionalCells(), 1)
        XCTAssertTrue(self.instance!.isAddtionalCustomCellsFor(indexPath: IndexPath(row: 0, section: 4)))
        XCTAssertEqual(self.instance!.heightForRow(IndexPath(row: 0, section: 4)), reviewScreenPreference.additionalInfoCells[0].getHeight())
    }

    func testItemCustomCells() {
        XCTAssertEqual(self.instance!.numberOfCustomItemCells(), 0)

        let reviewScreenPreference = ReviewScreenPreference()
        reviewScreenPreference.setCustomItemCell(customCell: [MPCustomCell(cell: UITableViewCell())])
        self.instance!.reviewScreenPreference = reviewScreenPreference

        XCTAssertEqual(self.instance!.numberOfCustomItemCells(), 1)
        XCTAssertEqual(self.instance!.numberOfRowsInSection(section: 2), 1)
        XCTAssertTrue(self.instance!.isItemCellFor(indexPath: IndexPath(row: 0, section: 2)))
        XCTAssertEqual(self.instance!.heightForRow(IndexPath(row: 0, section: 2)), reviewScreenPreference.customItemCells[0].getHeight())
    }

    func testCleanPaymentData() {
        XCTAssertEqual(self.instanceWithCoupon!.paymentData.paymentMethod!._id, "visa")
        XCTAssertEqual(self.instanceWithCoupon!.paymentData.payerCost!.installments, 3)
        XCTAssertEqual(self.instanceWithCoupon!.paymentData.payer.email, "thisisanem@il.com")
        XCTAssertEqual(self.instanceWithCoupon!.paymentData.discount!._id, "id")
        let newPaymentData = self.instanceWithCoupon!.getClearPaymentData()

        XCTAssertNil(newPaymentData.paymentMethod)
        XCTAssertNil(newPaymentData.payerCost)
        XCTAssertEqual(newPaymentData.payer.email, "thisisanem@il.com")
        XCTAssertEqual(newPaymentData.discount!._id, "id")
    }

    func getInvalidSummary() -> Summary {
        var preference = ReviewScreenPreference()
        preference.addSummaryProductDetail(amount: 1000)
        preference.addSummaryProductDetail(amount: 20)
        preference.addSummaryTaxesDetail(amount: 190)
        preference.addSummaryShippingDetail(amount: 100)
        return Summary(details: preference.details)
    }
    func getValidSummary() -> Summary {
        var preference = ReviewScreenPreference()
        preference.addSummaryProductDetail(amount: 500)
        preference.addSummaryProductDetail(amount: 200)
        preference.addSummaryTaxesDetail(amount: 200)
        preference.addSummaryShippingDetail(amount: 100)
        return Summary(details: preference.details)
    }
    func getValidSummaryWithoutProductDetail() -> Summary {
        var preference = ReviewScreenPreference()
        preference.addSummaryTaxesDetail(amount: 900)
        preference.addSummaryShippingDetail(amount: 100)
        return Summary(details: preference.details)
    }
    func testInvalidSummary() {
        instance?.reviewScreenPreference.details = getInvalidSummary().details
        var summary = instance?.getValidSummary(amount: 1000.0)
        var summaryComponent = SummaryComponent(frame: CGRect(x: 0, y: 0, width: 320.0, height: 0), summary: summary!, paymentData: PaymentData(), totalAmount: 1000)
        XCTAssertEqual(summaryComponent.requiredHeight, 73.5)
    }
    func testValidSummary() {
        instance?.reviewScreenPreference.details = getValidSummary().details
        var summary = instance?.getValidSummary(amount: 1000.0)
        var summaryComponent = SummaryComponent(frame: CGRect(x: 0, y: 0, width: 320.0, height: 0), summary: summary!, paymentData: PaymentData(), totalAmount: 1000)
        XCTAssertEqual(summaryComponent.requiredHeight, 179.0)
    }
    func testValidSummaryWithoutProductDetail() {
        instance?.reviewScreenPreference.details = getValidSummaryWithoutProductDetail().details
        var summary = instance?.getValidSummary(amount: 1000.0)
        var summaryComponent = SummaryComponent(frame: CGRect(x: 0, y: 0, width: 320.0, height: 0), summary: summary!, paymentData: PaymentData(), totalAmount: 1000)
        XCTAssertEqual(summaryComponent.requiredHeight, 73.5)
    }
}
