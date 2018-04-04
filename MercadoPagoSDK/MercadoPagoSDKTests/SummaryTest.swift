//
//  SummaryTest.swift
//  MercadoPagoSDK
//
//  Created by Demian Tejo on 9/15/17.
//  Copyright © 2017 MercadoPago. All rights reserved.
//

import XCTest

class SummaryTest: BaseTest {

    let TITLE_VALUE_HEIGHT: CGFloat = 25.5
    let SMALL_MARGIN_HEIGHT: CGFloat = 8.0
    let LINE_HEIGHT: CGFloat = 1.0
    let LARGE_MARIN: CGFloat = 28.0
    let MEDIUM_MARGIN: CGFloat = 12.0
    let DISCLAIMER_HEIGHT: CGFloat = 18.5
    let PAYER_COST_HEIGHT: CGFloat = 33

    func getSummaryMultipleProductTaxesShipping() -> Summary {
        let preference = ReviewScreenPreference()
        preference.addSummaryProductDetail(amount: 1000)
        preference.addSummaryProductDetail(amount: 20)
        preference.addSummaryTaxesDetail(amount: 190)
        preference.addSummaryShippingDetail(amount: 100)
        return Summary(details: preference.details)
    }

    func getSummaryProductTaxesShipping() -> Summary {
        let preference = ReviewScreenPreference()
        preference.addSummaryProductDetail(amount: 2000)
        preference.addSummaryTaxesDetail(amount: 190)
        preference.addSummaryShippingDetail(amount: 100)
        return Summary(details: preference.details)
    }

    func getSummaryJustProduct() -> Summary {
        let preference = ReviewScreenPreference()
        preference.addSummaryProductDetail(amount: 1000)
        return Summary(details: preference.details)
    }

    func getSummaryProductTaxesCharge() -> Summary {
        let preference = ReviewScreenPreference()
        preference.addSummaryProductDetail(amount: 2000)
        preference.addSummaryTaxesDetail(amount: 190)
        preference.addSummaryChargeDetail(amount: 1000)
        return Summary(details: preference.details)
    }

    func getSummaryProductTaxesShippingChargeDisclaimer() -> Summary {
        let preference = ReviewScreenPreference()
        preference.addSummaryProductDetail(amount: 2000)
        preference.addSummaryTaxesDetail(amount: 190)
        preference.addSummaryShippingDetail(amount: 100)
        preference.addSummaryChargeDetail(amount: 1000)
        let summary = Summary(details: preference.details)
        summary.disclaimer = "disclaimer test"
        return summary
    }

    func titleValueRequieredHeight() -> CGFloat {
        return TITLE_VALUE_HEIGHT
    }

    func lineRequieredHeight() -> CGFloat {
        return LINE_HEIGHT + SMALL_MARGIN_HEIGHT
    }

    func totalRequieredHeight() -> CGFloat {
        return TITLE_VALUE_HEIGHT + MEDIUM_MARGIN + lineRequieredHeight() + MEDIUM_MARGIN + LARGE_MARIN
    }

    func heightFor3summaryDetails() -> CGFloat {
        return  titleValueRequieredHeight() * 3 + 2 * SMALL_MARGIN_HEIGHT + totalRequieredHeight()
    }

    func heightFor1summaryDetails() -> CGFloat {
        return  titleValueRequieredHeight()  + SMALL_MARGIN_HEIGHT + MEDIUM_MARGIN + LARGE_MARIN
    }

    func heightFor4summaryDetailsPayerCostAndDisclaimer() -> CGFloat {
        return  titleValueRequieredHeight() * 4 + 3 * SMALL_MARGIN_HEIGHT + totalRequieredHeight() + LARGE_MARIN + DISCLAIMER_HEIGHT + PAYER_COST_HEIGHT
    }

    func heightFor4summaryDetailsAndDisclaimer() -> CGFloat {
        return  titleValueRequieredHeight() * 4 + 3 * SMALL_MARGIN_HEIGHT + totalRequieredHeight() + LARGE_MARIN + DISCLAIMER_HEIGHT
    }

    func testSummaryMultipleProductTaxesShipping() {
        let summary = getSummaryMultipleProductTaxesShipping()
        XCTAssertEqual(summary.details[SummaryType.PRODUCT]?.getTotalAmount(), 1020)
        XCTAssertEqual(summary.details[SummaryType.TAXES]?.getTotalAmount(), 190)
        XCTAssertEqual(summary.details[SummaryType.SHIPPING]?.getTotalAmount(), 100)
    }

    func testSummaryComponentMultipleProductTaxesShipping() {
        let summary = getSummaryMultipleProductTaxesShipping()
        let summaryComponent = PXSummaryFullComponentView(width: 320, summaryViewModel: summary, paymentData: PaymentData(), totalAmount: 1000, backgroundColor: .white, customSummaryTitle: "Productos")
        XCTAssertTrue(summaryComponent.shouldAddTotal())
    }

    func testSummaryComponentProductTaxesShipping() {
        let summary = getSummaryProductTaxesShipping()
        let summaryComponent = PXSummaryFullComponentView(width: 320, summaryViewModel: summary, paymentData: PaymentData(), totalAmount: 1000, backgroundColor: .white, customSummaryTitle: "Productos")
        XCTAssertTrue(summaryComponent.shouldAddTotal())
    }

    func testSummaryComponentJustProduct() {
        let summary = getSummaryJustProduct()
        let summaryComponent = PXSummaryFullComponentView(width: 320, summaryViewModel: summary, paymentData: PaymentData(), totalAmount: 1000, backgroundColor: .white, customSummaryTitle: "Productos")
        XCTAssertFalse(summaryComponent.shouldAddTotal())
    }

    func testSummaryComponentSummaryProductTaxesShippingCharge() {
        let summary = getSummaryProductTaxesCharge()
        let summaryComponent = PXSummaryFullComponentView(width: 320, summaryViewModel: summary, paymentData: PaymentData(), totalAmount: 1000, backgroundColor: .white, customSummaryTitle: "Productos")
        XCTAssertTrue(summaryComponent.shouldAddTotal())
    }

    func testSummaryComponentSummaryProductTaxesShippingChargeDisclaimer() {
        let summary = getSummaryProductTaxesShippingChargeDisclaimer()
        let summaryComponent = PXSummaryFullComponentView(width: 320, summaryViewModel: summary, paymentData: PaymentData(), totalAmount: 1000, backgroundColor: .white, customSummaryTitle: "Productos")
        XCTAssertTrue(summaryComponent.shouldAddTotal())
    }

    func testSummaryComponentSummaryProductTaxesShippingChargeDisclaimerPayerCost() {
        let summary = getSummaryProductTaxesShippingChargeDisclaimer()
        let summaryComponent = PXSummaryFullComponentView(width: 320, summaryViewModel: summary, paymentData: PaymentData(), totalAmount: 1000, backgroundColor: .white, customSummaryTitle: "Productos")
        summaryComponent.addPayerCost(payerCost: PayerCost(installments: 3, installmentRate: 1.0, labels: [], minAllowedAmount: 12, maxAllowedAmount: 123, recommendedMessage: "testes", installmentAmount: 123.0, totalAmount: 234.0))
        XCTAssertTrue(summaryComponent.shouldAddTotal())
    }
}
