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
        checkoutPref.items = [Item()]

        self.instance = CheckoutViewModel(checkoutPreference: checkoutPref, paymentData: PaymentData(), paymentOptionSelected: mockPaymentMethodSearchItem as PaymentMethodOption, shoppingPreference: ShoppingReviewPreference())

        paymentData = MockBuilder.buildPaymentData(paymentMethodId: "visa", paymentMethodName: "Visa", paymentMethodTypeId: "credit_card")
        paymentData.payerCost = MockBuilder.buildInstallment().payerCosts[1]
        paymentData.payerCost?.installments = 3
        paymentData.discount = MockBuilder.buildDiscount()
        paymentData.payer = MockBuilder.buildPayer("id")

        self.instanceWithCoupon = CheckoutViewModel(checkoutPreference: CheckoutPreference(), paymentData: paymentData, paymentOptionSelected: mockPaymentMethodSearchItem as PaymentMethodOption, shoppingPreference: ShoppingReviewPreference())

        let reviewScreenPreference = ReviewScreenPreference()
        reviewScreenPreference.setSummaryRows(summaryRows: [SummaryRow(customDescription: "lala", descriptionColor: nil, customAmount: 20.0, amountColor: nil)])

        self.instanceWithCustomSummaryRow = CheckoutViewModel(checkoutPreference: CheckoutPreference(), paymentData: paymentData, paymentOptionSelected: mockPaymentMethodSearchItem as PaymentMethodOption, reviewScreenPreference: reviewScreenPreference, shoppingPreference: ShoppingReviewPreference())
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
        XCTAssertEqual(self.instance!.numberOfRowsInSection(section: 1), self.instance!.numberOfRowsInMainSection())
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

    func testNumberOfRowsInMainSectionWithOfflinePaymentMethod() {
        let paymentMethodOff = MockBuilder.buildPaymentMethod("redlink", name: "redlink", paymentTypeId: PaymentTypeId.ATM.rawValue)
        self.instance!.paymentData.paymentMethod = paymentMethodOff

        let result = self.instance!.numberOfRowsInMainSection()
        XCTAssertEqual(1, result)
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

    /// Summary's tests

    func testSummaryAccountMoney() {

        /// SUMARY:
        ///
        /// Productos --- $30

        self.instance!.paymentData = MockBuilder.buildPaymentData(paymentMethodId: "account_money", paymentMethodName: "account_money", paymentMethodTypeId: "account_money")

        // Number of Rows
        XCTAssertEqual(self.instance!.numberOfRowsInMainSection(), 1)

        // Cells
        XCTAssertTrue(self.instance!.isProductlCellFor(indexPath: IndexPath(row: 0, section: 1)))
        XCTAssertEqual(self.instance!.heightForRow(IndexPath(row: 0, section: 1)), PurchaseSimpleDetailTableViewCell.PRODUCT_ONLY_ROW_HEIGHT)

        XCTAssertTrue(self.instance!.isPaymentMethodCellFor(indexPath: IndexPath(row: 0, section: 3)))
        XCTAssertEqual(self.instance!.heightForRow(IndexPath(row: 0, section: 3)), OfflinePaymentMethodCell.ROW_HEIGHT)

        // Extra checks
        XCTAssertFalse(self.instance!.shouldShowInstallmentSummary())
        XCTAssertFalse(self.instance!.shouldShowTotal())
        XCTAssertFalse(self.instance!.shouldDisplayNoRate())
        XCTAssertFalse(self.instance!.hasPayerCostAddionalInfo())
    }

    func testSummaryAccountMoneyWithCoupon() {

        /// SUMARY:
        ///
        /// Productos --- $30
        /// Descuento --- -$10
        /// Total --- $20

        self.instanceWithCoupon!.paymentData.paymentMethod = PaymentMethod(_id: "account_money", name : "account_money", paymentTypeId : "account_money")

        // Number of Rows
        XCTAssertEqual(self.instanceWithCoupon!.numberOfRowsInMainSection(), 3)

        // Cells
        XCTAssertTrue(self.instanceWithCoupon!.isProductlCellFor(indexPath: IndexPath(row: 0, section: 1)))
        XCTAssertEqual(self.instanceWithCoupon!.heightForRow(IndexPath(row: 0, section: 1)), PurchaseSimpleDetailTableViewCell.PRODUCT_ROW_HEIGHT)

        XCTAssertTrue(self.instanceWithCoupon!.isProductlCellFor(indexPath: IndexPath(row: 1, section: 1)))
        XCTAssertEqual(self.instanceWithCoupon!.heightForRow(IndexPath(row: 1, section: 1)), PurchaseSimpleDetailTableViewCell.PRODUCT_ROW_HEIGHT)

        XCTAssertTrue(self.instanceWithCoupon!.isTotalCellFor(indexPath: IndexPath(row: 2, section: 1)))
        XCTAssertEqual(self.instanceWithCoupon!.heightForRow(IndexPath(row: 2, section: 1)), PurchaseSimpleDetailTableViewCell.TOTAL_ROW_HEIGHT)

        XCTAssertTrue(self.instanceWithCoupon!.isPaymentMethodCellFor(indexPath: IndexPath(row: 0, section: 3)))
        XCTAssertEqual(self.instanceWithCoupon!.heightForRow(IndexPath(row: 0, section: 3)), OfflinePaymentMethodCell.ROW_HEIGHT)

        // Extra checks
        XCTAssertFalse(self.instanceWithCoupon!.shouldShowInstallmentSummary())
        XCTAssertTrue(self.instanceWithCoupon!.shouldShowTotal())
        XCTAssertFalse(self.instanceWithCoupon!.shouldDisplayNoRate())
        XCTAssertFalse(self.instanceWithCoupon!.hasPayerCostAddionalInfo())
    }

    func testSummaryAccountMoneyWithCustomSumaryRowAndCoupon() {

        /// SUMARY:
        ///
        /// Productos --- $30
        /// Comision --- -$10
        /// Descuento --- -$10
        /// Total --- $20

        self.instanceWithCustomSummaryRow!.paymentData.paymentMethod = PaymentMethod(_id: "account_money", name : "account_money", paymentTypeId : "account_money")

        // Number of Rows
        XCTAssertEqual(self.instanceWithCustomSummaryRow!.numberOfRowsInMainSection(), 4)

        // Cells
        XCTAssertTrue(self.instanceWithCustomSummaryRow!.isProductlCellFor(indexPath: IndexPath(row: 0, section: 1)))
        XCTAssertEqual(self.instanceWithCustomSummaryRow!.heightForRow(IndexPath(row: 0, section: 1)), PurchaseSimpleDetailTableViewCell.PRODUCT_ROW_HEIGHT)

        XCTAssertTrue(self.instanceWithCustomSummaryRow!.isProductlCellFor(indexPath: IndexPath(row: 1, section: 1)))
        XCTAssertEqual(self.instanceWithCustomSummaryRow!.heightForRow(IndexPath(row: 1, section: 1)), PurchaseSimpleDetailTableViewCell.PRODUCT_ROW_HEIGHT)

        XCTAssertTrue(self.instanceWithCustomSummaryRow!.isProductlCellFor(indexPath: IndexPath(row: 2, section: 1)))
        XCTAssertEqual(self.instanceWithCustomSummaryRow!.heightForRow(IndexPath(row: 2, section: 1)), PurchaseSimpleDetailTableViewCell.PRODUCT_ROW_HEIGHT)

        XCTAssertTrue(self.instanceWithCustomSummaryRow!.isTotalCellFor(indexPath: IndexPath(row: 3, section: 1)))
        XCTAssertEqual(self.instanceWithCustomSummaryRow!.heightForRow(IndexPath(row: 3, section: 1)), PurchaseSimpleDetailTableViewCell.TOTAL_ROW_HEIGHT)

        XCTAssertTrue(self.instanceWithCustomSummaryRow!.isPaymentMethodCellFor(indexPath: IndexPath(row: 0, section: 3)))
        XCTAssertEqual(self.instanceWithCustomSummaryRow!.heightForRow(IndexPath(row: 0, section: 3)), OfflinePaymentMethodCell.ROW_HEIGHT)

        // Extra checks
        XCTAssertFalse(self.instanceWithCustomSummaryRow!.shouldShowInstallmentSummary())
        XCTAssertTrue(self.instanceWithCustomSummaryRow!.shouldShowTotal())
        XCTAssertFalse(self.instanceWithCustomSummaryRow!.shouldDisplayNoRate())
        XCTAssertFalse(self.instanceWithCustomSummaryRow!.hasPayerCostAddionalInfo())
    }

    func testSummaryPaymentMethodOff() {

        /// SUMARY:
        ///
        /// Productos --- $30

        self.instance!.paymentData = MockBuilder.buildPaymentData(paymentMethodId: "oxxo", paymentMethodName: "Oxxo", paymentMethodTypeId: "ticket")

        // Number of Rows
        XCTAssertEqual(self.instance!.numberOfRowsInMainSection(), 1)

        // Cells
        XCTAssertTrue(self.instance!.isProductlCellFor(indexPath: IndexPath(row: 0, section: 1)))
        XCTAssertEqual(self.instance!.heightForRow(IndexPath(row: 0, section: 1)), PurchaseSimpleDetailTableViewCell.PRODUCT_ONLY_ROW_HEIGHT)

        XCTAssertTrue(self.instance!.isPaymentMethodCellFor(indexPath: IndexPath(row: 0, section: 3)))
        XCTAssertEqual(self.instance!.heightForRow(IndexPath(row: 0, section: 3)), OfflinePaymentMethodCell.ROW_HEIGHT)

        // Extra checks
        XCTAssertFalse(self.instance!.shouldShowInstallmentSummary())
        XCTAssertFalse(self.instance!.shouldShowTotal())
        XCTAssertFalse(self.instance!.shouldDisplayNoRate())
        XCTAssertFalse(self.instance!.hasPayerCostAddionalInfo())
    }

    func testSummaryCreditCardNoRateInstallments() {

        /// SUMARY:
        ///
        /// Productos --- $30

        self.instance!.paymentData = MockBuilder.buildPaymentData(paymentMethodId: "visa", paymentMethodName: "Visa", paymentMethodTypeId: "credit_card")
        self.instance!.paymentData.payerCost = MockBuilder.buildPayerCost()

        // Number of Rows
        XCTAssertEqual(self.instance!.numberOfRowsInMainSection(), 1)

        // Cells
        XCTAssertTrue(self.instance!.isProductlCellFor(indexPath: IndexPath(row: 0, section: 1)))
        XCTAssertEqual(self.instance!.heightForRow(IndexPath(row: 0, section: 1)), PurchaseSimpleDetailTableViewCell.PRODUCT_ONLY_ROW_HEIGHT)

        XCTAssertTrue(self.instance!.isPaymentMethodCellFor(indexPath: IndexPath(row: 0, section: 3)))
        XCTAssertEqual(self.instance!.heightForRow(IndexPath(row: 0, section: 3)), PaymentMethodSelectedTableViewCell.getCellHeight(payerCost : self.instance!.paymentData.payerCost, reviewScreenPreference: self.instance!.reviewScreenPreference))

        // Extra checks
        XCTAssertFalse(self.instance!.shouldShowInstallmentSummary())
        XCTAssertFalse(self.instance!.shouldShowTotal())
        XCTAssertFalse(self.instance!.shouldDisplayNoRate())
        XCTAssertFalse(self.instance!.hasPayerCostAddionalInfo())
    }
    func testSummaryCreditCardWithInstallments() {

        /// SUMARY:
        ///
        /// Productos --- $30
        /// Pagas --- 3X$10
        /// Total --- 30

        self.instance!.paymentData = MockBuilder.buildPaymentData(paymentMethodId: "visa", paymentMethodName: "Visa", paymentMethodTypeId: "credit_card")
        self.instance!.paymentData.payerCost = MockBuilder.buildPayerCost(installments: 3)

        // Number of Rows
        XCTAssertEqual(self.instance!.numberOfRowsInMainSection(), 3)

        // Cells
        XCTAssertTrue(self.instance!.isProductlCellFor(indexPath: IndexPath(row: 0, section: 1)))
        XCTAssertEqual(self.instance!.heightForRow(IndexPath(row: 0, section: 1)), PurchaseSimpleDetailTableViewCell.PRODUCT_ROW_HEIGHT)

        XCTAssertTrue(self.instance!.isInstallmentsCellFor(indexPath: IndexPath(row: 1, section: 1)))
        XCTAssertEqual(self.instance!.heightForRow(IndexPath(row: 1, section: 1)), PurchaseDetailTableViewCell.getCellHeight(payerCost : self.instance!.paymentData.payerCost))

        XCTAssertTrue(self.instance!.isTotalCellFor(indexPath: IndexPath(row: 2, section: 1)))
        XCTAssertEqual(self.instance!.heightForRow(IndexPath(row: 2, section: 1)), PurchaseSimpleDetailTableViewCell.TOTAL_ROW_HEIGHT)

        XCTAssertTrue(self.instance!.isPaymentMethodCellFor(indexPath: IndexPath(row: 0, section: 3)))
        XCTAssertEqual(self.instance!.heightForRow(IndexPath(row: 0, section: 3)), PaymentMethodSelectedTableViewCell.getCellHeight(payerCost : self.instance!.paymentData.payerCost, reviewScreenPreference: self.instance!.reviewScreenPreference))

        // Extra checks
        XCTAssertTrue(self.instance!.shouldShowInstallmentSummary())
        XCTAssertTrue(self.instance!.shouldShowTotal())
        XCTAssertFalse(self.instance!.hasPayerCostAddionalInfo())
    }
    func testSummaryDebitCard() {

        /// SUMARY:
        ///
        /// Productos --- $30

        self.instance!.paymentData = MockBuilder.buildPaymentData(paymentMethodId: "visa", paymentMethodName: "Visa", paymentMethodTypeId: "debit_card")

        // Number of Cells
        XCTAssertEqual(self.instance!.numberOfRowsInMainSection(), 1) // Productos

        // Cells
        XCTAssertTrue(self.instance!.isProductlCellFor(indexPath: IndexPath(row: 0, section: 1)))
        XCTAssertEqual(self.instance!.heightForRow(IndexPath(row: 0, section: 1)), PurchaseSimpleDetailTableViewCell.PRODUCT_ONLY_ROW_HEIGHT)

        XCTAssertTrue(self.instance!.isPaymentMethodCellFor(indexPath: IndexPath(row: 0, section: 3)))
        XCTAssertEqual(self.instance!.heightForRow(IndexPath(row: 0, section: 3)), PaymentMethodSelectedTableViewCell.getCellHeight(payerCost : self.instance!.paymentData.payerCost, reviewScreenPreference: self.instance!.reviewScreenPreference))

        // Extra checks
        XCTAssertFalse(self.instance!.shouldShowInstallmentSummary())
        XCTAssertFalse(self.instance!.shouldShowTotal())
        XCTAssertFalse(self.instance!.hasPayerCostAddionalInfo())
    }

    func testSummaryCreditCardWithInstallmentsWithCoupon() {

        /// SUMARY:
        ///
        /// Productos --- $30
        /// Descuento --- -$0
        /// Pagas --- 3X$10
        /// Total --- 30

        MercadoPagoCheckoutViewModel.flowPreference.enableDiscount()
        instanceWithCoupon!.summaryRows = []
        instanceWithCoupon!.setSummaryRows(shortTitle: ShoppingReviewPreference.DEFAULT_ONE_WORD_TITLE)

        // Number of cells
        XCTAssertEqual(self.instanceWithCoupon!.numberOfRowsInMainSection(), 4)

        // Cells
        XCTAssertTrue(self.instanceWithCoupon!.isProductlCellFor(indexPath: IndexPath(row: 0, section: 1)))
        XCTAssertEqual(self.instanceWithCoupon!.heightForRow(IndexPath(row: 0, section: 1)), PurchaseSimpleDetailTableViewCell.PRODUCT_ROW_HEIGHT)

        XCTAssertTrue(self.instanceWithCoupon!.isProductlCellFor(indexPath: IndexPath(row: 1, section: 1)))
        XCTAssertEqual(self.instanceWithCoupon!.heightForRow(IndexPath(row: 1, section: 1)), PurchaseSimpleDetailTableViewCell.PRODUCT_ROW_HEIGHT)

        XCTAssertTrue(self.instanceWithCoupon!.isInstallmentsCellFor(indexPath: IndexPath(row: 2, section: 1)))
        XCTAssertEqual(self.instanceWithCoupon!.heightForRow(IndexPath(row: 2, section: 1)), PurchaseDetailTableViewCell.getCellHeight(payerCost : self.instanceWithCoupon!.paymentData.payerCost))

        XCTAssertTrue(self.instanceWithCoupon!.isTotalCellFor(indexPath: IndexPath(row: 3, section: 1)))
        XCTAssertEqual(self.instanceWithCoupon!.heightForRow(IndexPath(row: 3, section: 1)), PurchaseSimpleDetailTableViewCell.TOTAL_ROW_HEIGHT)

        XCTAssertTrue(self.instanceWithCoupon!.isPaymentMethodCellFor(indexPath: IndexPath(row: 0, section: 3)))
        XCTAssertEqual(self.instanceWithCoupon!.heightForRow(IndexPath(row: 0, section: 3)), PaymentMethodSelectedTableViewCell.getCellHeight(payerCost : self.instanceWithCoupon!.paymentData.payerCost, reviewScreenPreference: self.instanceWithCoupon!.reviewScreenPreference))

        // Extra checks
        XCTAssertTrue(self.instanceWithCoupon!.shouldShowInstallmentSummary())
        XCTAssertTrue(self.instanceWithCoupon!.shouldShowTotal())
        XCTAssertFalse(self.instanceWithCoupon!.hasPayerCostAddionalInfo())
    }

    func testSummaryCreditCardWithInstallmentsWithCouponAndCFT() {

        /// SUMARY:
        ///
        /// Productos --- $30
        /// Descuento --- -$0
        /// Pagas --- 3X$10
        /// Total --- 30
        /// CFT Y TEA

        MercadoPagoCheckoutViewModel.flowPreference.enableDiscount()
        instanceWithCoupon!.summaryRows = []
        instanceWithCoupon!.setSummaryRows(shortTitle: ShoppingReviewPreference.DEFAULT_ONE_WORD_TITLE)

        self.instanceWithCoupon!.paymentData.payerCost = MockBuilder.buildPayerCost(installments: 3, hasCFT: true)

        // Number of cells
        XCTAssertEqual(self.instanceWithCoupon!.numberOfRowsInMainSection(), 5)

        // Cells
        XCTAssertTrue(self.instanceWithCoupon!.isProductlCellFor(indexPath: IndexPath(row: 0, section: 1)))
        XCTAssertEqual(self.instanceWithCoupon!.heightForRow(IndexPath(row: 0, section: 1)), PurchaseSimpleDetailTableViewCell.PRODUCT_ROW_HEIGHT)

        XCTAssertTrue(self.instanceWithCoupon!.isProductlCellFor(indexPath: IndexPath(row: 1, section: 1)))
        XCTAssertEqual(self.instanceWithCoupon!.heightForRow(IndexPath(row: 1, section: 1)), PurchaseSimpleDetailTableViewCell.PRODUCT_ROW_HEIGHT)

        XCTAssertTrue(self.instanceWithCoupon!.isInstallmentsCellFor(indexPath: IndexPath(row: 2, section: 1)))
        XCTAssertEqual(self.instanceWithCoupon!.heightForRow(IndexPath(row: 2, section: 1)), PurchaseDetailTableViewCell.getCellHeight(payerCost : self.instanceWithCoupon!.paymentData.payerCost))

        XCTAssertTrue(self.instanceWithCoupon!.isTotalCellFor(indexPath: IndexPath(row: 3, section: 1)))
        XCTAssertEqual(self.instanceWithCoupon!.heightForRow(IndexPath(row: 3, section: 1)), PurchaseSimpleDetailTableViewCell.TOTAL_ROW_HEIGHT)

        XCTAssertTrue(self.instanceWithCoupon!.isPayerCostAdditionalInfoFor(indexPath: IndexPath(row: 4, section: 1)))
        XCTAssertEqual(self.instanceWithCoupon!.heightForRow(IndexPath(row: 4, section: 1)), ConfirmAdditionalInfoTableViewCell.ROW_HEIGHT)

        XCTAssertTrue(self.instanceWithCoupon!.isPaymentMethodCellFor(indexPath: IndexPath(row: 0, section: 3)))
        XCTAssertEqual(self.instanceWithCoupon!.heightForRow(IndexPath(row: 0, section: 3)), PaymentMethodSelectedTableViewCell.getCellHeight(payerCost : self.instanceWithCoupon!.paymentData.payerCost, reviewScreenPreference: self.instanceWithCoupon!.reviewScreenPreference))

        XCTAssertTrue(self.instanceWithCoupon!.isPaymentMethodCellFor(indexPath: IndexPath(row: 0, section: 3)))
        XCTAssertEqual(self.instanceWithCoupon!.heightForRow(IndexPath(row: 0, section: 3)), PaymentMethodSelectedTableViewCell.getCellHeight(payerCost : self.instanceWithCoupon!.paymentData.payerCost, reviewScreenPreference: self.instanceWithCoupon!.reviewScreenPreference))

        // Extra checks
        XCTAssertTrue(self.instanceWithCoupon!.shouldShowInstallmentSummary())
        XCTAssertTrue(self.instanceWithCoupon!.shouldShowTotal())
        XCTAssertTrue(self.instanceWithCoupon!.hasPayerCostAddionalInfo())
    }

    func testSummaryCreditCardWithInstallmentsWithCFT() {

        /// SUMARY:
        ///
        /// Productos --- $30
        /// Pagas --- 3X$10
        /// Total --- 30
        /// CFT Y TEA

        self.instance!.paymentData = MockBuilder.buildPaymentData(paymentMethodId: "visa", paymentMethodName: "Visa", paymentMethodTypeId: "credit_card")
        self.instance!.paymentData.payerCost = MockBuilder.buildPayerCost(installments: 3, hasCFT: true)

        // Number of cells
        XCTAssertEqual(self.instance!.numberOfRowsInMainSection(), 4)

        // Cells
        XCTAssertTrue(self.instance!.isProductlCellFor(indexPath: IndexPath(row: 0, section: 1)))
        XCTAssertEqual(self.instance!.heightForRow(IndexPath(row: 0, section: 1)), PurchaseSimpleDetailTableViewCell.PRODUCT_ROW_HEIGHT)

        XCTAssertTrue(self.instance!.isInstallmentsCellFor(indexPath: IndexPath(row: 1, section: 1)))
        XCTAssertEqual(self.instance!.heightForRow(IndexPath(row: 1, section: 1)), PurchaseDetailTableViewCell.getCellHeight(payerCost : self.instance!.paymentData.payerCost))

        XCTAssertTrue(self.instance!.isTotalCellFor(indexPath: IndexPath(row: 2, section: 1)))
        XCTAssertEqual(self.instance!.heightForRow(IndexPath(row: 2, section: 1)), PurchaseSimpleDetailTableViewCell.TOTAL_ROW_HEIGHT)

        XCTAssertTrue(self.instance!.isPayerCostAdditionalInfoFor(indexPath: IndexPath(row: 3, section: 1)))
        XCTAssertEqual(self.instance!.heightForRow(IndexPath(row: 3, section: 1)), ConfirmAdditionalInfoTableViewCell.ROW_HEIGHT)

        XCTAssertTrue(self.instance!.isPaymentMethodCellFor(indexPath: IndexPath(row: 0, section: 3)))
        XCTAssertEqual(self.instance!.heightForRow(IndexPath(row: 0, section: 3)), PaymentMethodSelectedTableViewCell.getCellHeight(payerCost : self.instance!.paymentData.payerCost, reviewScreenPreference: self.instance!.reviewScreenPreference))

        // Extra checks
        XCTAssertTrue(self.instance!.shouldShowInstallmentSummary())
        XCTAssertTrue(self.instance!.shouldShowTotal())
        XCTAssertTrue(self.instance!.hasPayerCostAddionalInfo())
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
}
