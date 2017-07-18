//
//  PaymentResultViewModelTest.swift
//  MercadoPagoSDK
//
//  Created by Eden Torres on 4/25/17.
//  Copyright © 2017 MercadoPago. All rights reserved.
//

import XCTest
@testable import MercadoPagoSDK
class PaymentResultViewModelTest: BaseTest {

    //*********************
    // General
    //*********************

    var instance: PaymentResultViewModel!
    var paymentData: PaymentData!
    var paymentResult: PaymentResult!
    override func setUp() {
        super.setUp()

        self.paymentData = MockBuilder.buildPaymentData(paymentMethodId: "visa", installments: 1, installmentRate: 0)
        self.paymentResult = PaymentResult(status: "approved", statusDetail: "", paymentData: paymentData, payerEmail: "sarsa@sarasita.com", id: "123", statementDescription: "mercadopago")
        self.instance = PaymentResultViewModel(paymentResult: paymentResult, checkoutPreference: CheckoutPreference(), callback: { (_) in})
    }

    func testColor() {
        paymentResult.status = "lala"
        XCTAssertEqual(self.instance.getColor(), UIColor(red: 255, green: 89, blue: 89))

        let paymentPreference = PaymentResultScreenPreference()
        paymentPreference.setStatusBackgroundColor(color: UIColor.yellow)
        self.instance.paymentResultScreenPreference = paymentPreference
        XCTAssertEqual(self.instance.getColor(), UIColor.yellow)
    }

    func testNumberOfSections() {
        XCTAssertEqual(self.instance!.numberOfSections(), 6)
    }
}
class ApprovedPaymentResultViewModelTest: BaseTest {

    //*********************
    // APPROVED PAYMENTS
    //*********************

    var instance: PaymentResultViewModel!
    var paymentData: PaymentData!
    var paymentResult: PaymentResult!
    override func setUp() {
        super.setUp()

        self.paymentData = MockBuilder.buildPaymentData(paymentMethodId: "visa", installments: 1, installmentRate: 0)
        self.paymentResult = PaymentResult(status: "approved", statusDetail: "", paymentData: paymentData, payerEmail: "sarsa@sarasita.com", id: "123", statementDescription: "mercadopago")
        self.instance = PaymentResultViewModel(paymentResult: paymentResult, checkoutPreference: CheckoutPreference(), callback: { (_) in})
    }

    func testStatus() {
        XCTAssertTrue(self.instance.paymentResult.isApproved())
        XCTAssertFalse(self.instance.paymentResult.isPending())
        XCTAssertFalse(self.instance.paymentResult.isRejected())
        XCTAssertFalse(self.instance.paymentResult.isCallForAuth())
    }

    func testGetColor() {
        XCTAssertEqual(self.instance!.getColor(), UIColor.px_greenCongrats())
    }

    func testLayoutName() {
        XCTAssertEqual(self.instance.getLayoutName(), "approved")
    }

    func testRowsDefault() {
        /// HEADER
        /// APPROVED CELL
        /// EMAIL
        /// EXIT BUTTON

        // Header
        XCTAssertEqual(self.instance.numberOfRowsInSection(section: 0), 1)
        // SubHeader
        XCTAssertEqual(self.instance.numberOfRowsInSection(section: 1), 0)
        // Body
        XCTAssertEqual(self.instance.numberOfRowsInSection(section: 2), 2)
        // Additional Cells
        XCTAssertEqual(self.instance.numberOfRowsInSection(section: 3), 0)
        // Secondary Button
        XCTAssertEqual(self.instance.numberOfRowsInSection(section: 4), 0)
        // Exit Button
        XCTAssertEqual(self.instance.numberOfRowsInSection(section: 5), 1)

        XCTAssertEqual(self.instance.numberOfRowsInSection(section: 100), 0)

        // Header
        XCTAssertTrue(self.instance.isHeaderCellFor(indexPath: IndexPath(row: 0, section: 0)))
        XCTAssertEqual(self.instance.heightForRowAt(indexPath: IndexPath(row: 0, section: 0)), UITableViewAutomaticDimension)

        // SubHeader
        XCTAssertFalse(self.instance.isApprovedCustomSubHeaderCellFor(indexPath: IndexPath(row: 0, section: 1)))

        // Approved Body
        XCTAssertTrue(self.instance.isApprovedBodyCellFor(indexPath: IndexPath(row: 0, section: 2)))
        XCTAssertEqual(self.instance.heightForRowAt(indexPath: IndexPath(row: 0, section: 2)), UITableViewAutomaticDimension)

        // Email
        XCTAssertTrue(self.instance.isEmailCellFor(indexPath: IndexPath(row: 1, section: 2)))
        XCTAssertEqual(self.instance.heightForRowAt(indexPath: IndexPath(row: 1, section: 2)), UITableViewAutomaticDimension)

        // Additional Cells
        XCTAssertFalse(self.instance.isApprovedAdditionalCustomCellFor(indexPath: IndexPath(row: 0, section: 3)))

        // Secondary Button
        XCTAssertFalse(self.instance.isSecondaryExitButtonCellFor(indexPath: IndexPath(row: 0, section: 4)))
        XCTAssertFalse(self.instance.shouldShowSecondaryExitButton())

        //ExitButton
        XCTAssertTrue(self.instance.isFooterCellFor(indexPath: IndexPath(row: 0, section: 5)))
        XCTAssertEqual(self.instance.heightForRowAt(indexPath: IndexPath(row: 0, section: 5)), UITableViewAutomaticDimension)
    }

    func testRowsDefaultNoApprovedBody() {
        let paymentPreference = PaymentResultScreenPreference()
        paymentPreference.disableApprovedBodyCell()
        self.instance.paymentResultScreenPreference = paymentPreference

        /// HEADER
        /// Email
        /// EXIT BUTTON

        // Header
        XCTAssertEqual(self.instance.numberOfRowsInSection(section: 0), 1)
        // SubHeader
        XCTAssertEqual(self.instance.numberOfRowsInSection(section: 1), 0)
        // Body
        XCTAssertEqual(self.instance.numberOfRowsInSection(section: 2), 1)
        // Additional Cells
        XCTAssertEqual(self.instance.numberOfRowsInSection(section: 3), 0)
        // Secondary Button
        XCTAssertEqual(self.instance.numberOfRowsInSection(section: 4), 0)
        // Exit Button
        XCTAssertEqual(self.instance.numberOfRowsInSection(section: 5), 1)

        XCTAssertEqual(self.instance.numberOfRowsInSection(section: 100), 0)

        // Header
        XCTAssertTrue(self.instance.isHeaderCellFor(indexPath: IndexPath(row: 0, section: 0)))
        XCTAssertEqual(self.instance.heightForRowAt(indexPath: IndexPath(row: 0, section: 0)), UITableViewAutomaticDimension)

        // SubHeader
        XCTAssertFalse(self.instance.isApprovedCustomSubHeaderCellFor(indexPath: IndexPath(row: 0, section: 1)))

        // Approved Body
        XCTAssertFalse(self.instance.isApprovedBodyCellFor(indexPath: IndexPath(row: 0, section: 2)))

        // Email
        XCTAssertTrue(self.instance.isEmailCellFor(indexPath: IndexPath(row: 0, section: 2)))
        XCTAssertEqual(self.instance.heightForRowAt(indexPath: IndexPath(row: 0, section: 2)), UITableViewAutomaticDimension)

        // Additional Cells
        XCTAssertFalse(self.instance.isApprovedAdditionalCustomCellFor(indexPath: IndexPath(row: 0, section: 3)))

        // Secondary Button
        XCTAssertFalse(self.instance.isSecondaryExitButtonCellFor(indexPath: IndexPath(row: 0, section: 4)))
        XCTAssertFalse(self.instance.shouldShowSecondaryExitButton())

        //ExitButton
        XCTAssertTrue(self.instance.isFooterCellFor(indexPath: IndexPath(row: 0, section: 5)))
        XCTAssertEqual(self.instance.heightForRowAt(indexPath: IndexPath(row: 0, section: 5)), UITableViewAutomaticDimension)

    }

    func testRowsDefaultNoApprovedBodyAndEmail() {

        let paymentPreference = PaymentResultScreenPreference()
        paymentPreference.disableApprovedBodyCell()
        self.instance.paymentResultScreenPreference = paymentPreference
        self.instance.paymentResult.payerEmail = ""

        /// HEADER
        /// EXIT BUTTON

        // Header
        XCTAssertEqual(self.instance.numberOfRowsInSection(section: 0), 1)
        // SubHeader
        XCTAssertEqual(self.instance.numberOfRowsInSection(section: 1), 0)
        // Body
        XCTAssertEqual(self.instance.numberOfRowsInSection(section: 2), 0)
        // Additional Cells
        XCTAssertEqual(self.instance.numberOfRowsInSection(section: 3), 0)
        // Secondary Button
        XCTAssertEqual(self.instance.numberOfRowsInSection(section: 4), 0)
        // Exit Button
        XCTAssertEqual(self.instance.numberOfRowsInSection(section: 5), 1)

        XCTAssertEqual(self.instance.numberOfRowsInSection(section: 100), 0)

        // Header
        XCTAssertTrue(self.instance.isHeaderCellFor(indexPath: IndexPath(row: 0, section: 0)))
        XCTAssertEqual(self.instance.heightForRowAt(indexPath: IndexPath(row: 0, section: 0)), UITableViewAutomaticDimension)

        // SubHeader
        XCTAssertFalse(self.instance.isApprovedCustomSubHeaderCellFor(indexPath: IndexPath(row: 0, section: 1)))

        // Approved Body
        XCTAssertFalse(self.instance.isApprovedBodyCellFor(indexPath: IndexPath(row: 0, section: 2)))

        // Email
        XCTAssertFalse(self.instance.isEmailCellFor(indexPath: IndexPath(row: 0, section: 2)))

        // Additional Cells
        XCTAssertFalse(self.instance.isApprovedAdditionalCustomCellFor(indexPath: IndexPath(row: 0, section: 3)))

        // Secondary Button
        XCTAssertFalse(self.instance.isSecondaryExitButtonCellFor(indexPath: IndexPath(row: 0, section: 4)))
        XCTAssertFalse(self.instance.shouldShowSecondaryExitButton())

        //ExitButton
        XCTAssertTrue(self.instance.isFooterCellFor(indexPath: IndexPath(row: 0, section: 5)))
        XCTAssertEqual(self.instance.heightForRowAt(indexPath: IndexPath(row: 0, section: 5)), UITableViewAutomaticDimension)
    }

    func testRowsCustomCells() {

        let paymentPreference = PaymentResultScreenPreference()
        paymentPreference.approvedAdditionalInfoCells = [MPCustomCell(cell: UITableViewCell())]
        paymentPreference.approvedSubHeaderCells = [MPCustomCell(cell: UITableViewCell())]
        self.instance.paymentResultScreenPreference = paymentPreference

        /// HEADER
        /// SUBHEHEADER
        /// APPROVED CELL
        /// EMAIL
        /// ADDITIONAL CELL
        /// EXIT BUTTON

        // Header
        XCTAssertEqual(self.instance.numberOfRowsInSection(section: 0), 1)
        // SubHeader
        XCTAssertEqual(self.instance.numberOfRowsInSection(section: 1), self.instance.numberOfCustomSubHeaderCells())
        // Body
        XCTAssertEqual(self.instance.numberOfRowsInSection(section: 2), 2)
        // Additional Cells
        XCTAssertEqual(self.instance.numberOfRowsInSection(section: 3), self.instance.numberOfCustomAdditionalCells())
        // Secondary Button
        XCTAssertEqual(self.instance.numberOfRowsInSection(section: 4), 0)
        // Exit Button
        XCTAssertEqual(self.instance.numberOfRowsInSection(section: 5), 1)

        XCTAssertEqual(self.instance.numberOfRowsInSection(section: 100), 0)

        // Header
        XCTAssertTrue(self.instance.isHeaderCellFor(indexPath: IndexPath(row: 0, section: 0)))
        XCTAssertEqual(self.instance.heightForRowAt(indexPath: IndexPath(row: 0, section: 0)), UITableViewAutomaticDimension)

        // SubHeader
        XCTAssertTrue(self.instance.isApprovedCustomSubHeaderCellFor(indexPath: IndexPath(row: 0, section: 1)))
        XCTAssertEqual(self.instance.heightForRowAt(indexPath: IndexPath(row: 0, section: 1)), 0)

        // Approved Body
        XCTAssertTrue(self.instance.isApprovedBodyCellFor(indexPath: IndexPath(row: 0, section: 2)))
        XCTAssertEqual(self.instance.heightForRowAt(indexPath: IndexPath(row: 0, section: 2)), UITableViewAutomaticDimension)

        // Email
        XCTAssertTrue(self.instance.isEmailCellFor(indexPath: IndexPath(row: 1, section: 2)))
        XCTAssertEqual(self.instance.heightForRowAt(indexPath: IndexPath(row: 1, section: 2)), UITableViewAutomaticDimension)

        // Additional Cells
        XCTAssertTrue(self.instance.isApprovedAdditionalCustomCellFor(indexPath: IndexPath(row: 0, section: 3)))
        XCTAssertEqual(self.instance.heightForRowAt(indexPath: IndexPath(row: 0, section: 3)), 0)

        // Secondary Button
        XCTAssertFalse(self.instance.isSecondaryExitButtonCellFor(indexPath: IndexPath(row: 0, section: 4)))
        XCTAssertFalse(self.instance.shouldShowSecondaryExitButton())

        //ExitButton
        XCTAssertTrue(self.instance.isFooterCellFor(indexPath: IndexPath(row: 0, section: 5)))
        XCTAssertEqual(self.instance.heightForRowAt(indexPath: IndexPath(row: 0, section: 5)), UITableViewAutomaticDimension)
    }

    func testRowsSecondaryButton() {

        let paymentPreference = PaymentResultScreenPreference()
        paymentPreference.setApprovedSecondaryExitButton(callback: { (_) in

        }, text: "sarsa")
        self.instance.paymentResultScreenPreference = paymentPreference

        /// HEADER
        /// APPROVED CELL
        /// EMAIL
        /// SECONDARY BUTTON
        /// EXIT BUTTON

        // Header
        XCTAssertEqual(self.instance.numberOfRowsInSection(section: 0), 1)
        // SubHeader
        XCTAssertEqual(self.instance.numberOfRowsInSection(section: 1), 0)
        // Body
        XCTAssertEqual(self.instance.numberOfRowsInSection(section: 2), 2)
        // Additional Cells
        XCTAssertEqual(self.instance.numberOfRowsInSection(section: 3), 0)
        // Secondary Button
        XCTAssertEqual(self.instance.numberOfRowsInSection(section: 4), 1)
        // Exit Button
        XCTAssertEqual(self.instance.numberOfRowsInSection(section: 5), 1)

        XCTAssertEqual(self.instance.numberOfRowsInSection(section: 100), 0)

        // Header
        XCTAssertTrue(self.instance.isHeaderCellFor(indexPath: IndexPath(row: 0, section: 0)))
        XCTAssertEqual(self.instance.heightForRowAt(indexPath: IndexPath(row: 0, section: 0)), UITableViewAutomaticDimension)

        // SubHeader
        XCTAssertFalse(self.instance.isApprovedCustomSubHeaderCellFor(indexPath: IndexPath(row: 0, section: 1)))

        // Approved Body
        XCTAssertTrue(self.instance.isApprovedBodyCellFor(indexPath: IndexPath(row: 0, section: 2)))
        XCTAssertEqual(self.instance.heightForRowAt(indexPath: IndexPath(row: 0, section: 2)), UITableViewAutomaticDimension)

        // Email
        XCTAssertTrue(self.instance.isEmailCellFor(indexPath: IndexPath(row: 1, section: 2)))
        XCTAssertEqual(self.instance.heightForRowAt(indexPath: IndexPath(row: 1, section: 2)), UITableViewAutomaticDimension)

        // Additional Cells
        XCTAssertFalse(self.instance.isApprovedAdditionalCustomCellFor(indexPath: IndexPath(row: 0, section: 3)))

        // Secondary Button
        XCTAssertTrue(self.instance.isSecondaryExitButtonCellFor(indexPath: IndexPath(row: 0, section: 4)))
        XCTAssertEqual(self.instance.heightForRowAt(indexPath: IndexPath(row: 0, section: 4)), UITableViewAutomaticDimension)
        XCTAssertTrue(self.instance.shouldShowSecondaryExitButton())

        //ExitButton
        XCTAssertTrue(self.instance.isFooterCellFor(indexPath: IndexPath(row: 0, section: 5)))
        XCTAssertEqual(self.instance.heightForRowAt(indexPath: IndexPath(row: 0, section: 5)), UITableViewAutomaticDimension)
    }
}

class PendingPaymentResultViewModelTest: BaseTest {

    //*********************
    // Pending PAYMENTS
    //*********************

    var instance: PaymentResultViewModel!
    var paymentData: PaymentData!
    var paymentResult: PaymentResult!
    override func setUp() {
        super.setUp()

        self.paymentData = MockBuilder.buildPaymentData(paymentMethodId: "visa", installments: 1, installmentRate: 0)
        self.paymentResult = PaymentResult(status: "in_process", statusDetail: "pending_contingency", paymentData: paymentData, payerEmail: "sarsa@sarasita.com", id: "123", statementDescription: nil)
        self.instance = PaymentResultViewModel(paymentResult: paymentResult, checkoutPreference: CheckoutPreference(), callback: { (_) in})
    }

    func testStatus() {
        XCTAssertFalse(self.instance.paymentResult.isApproved())
        XCTAssertTrue(self.instance.paymentResult.isPending())
        XCTAssertFalse(self.instance.paymentResult.isRejected())
        XCTAssertFalse(self.instance.paymentResult.isCallForAuth())
    }

    func testGetColor() {
        XCTAssertEqual(self.instance!.getColor(), UIColor(red: 255, green: 161, blue: 90))
    }

    func testLayoutName() {
        XCTAssertEqual(self.instance.getLayoutName(), "in_process")
    }

    func testGetPaymentAction() {
        XCTAssertEqual(self.instance.getPaymentAction(), PaymentResultViewModel.PaymentActions.RECOVER_PAYMENT.rawValue)
    }

    func testRowsDefault() {
        /// HEADER
        /// CONTENT CELL
        /// SECONDARY BUTTON
        /// EXIT BUTTON

        // Header
        XCTAssertEqual(self.instance.numberOfRowsInSection(section: 0), 1)
        // SubHeader
        XCTAssertEqual(self.instance.numberOfRowsInSection(section: 1), 0)
        // Content cell
        XCTAssertEqual(self.instance.numberOfRowsInSection(section: 2), 1)
        // Additional Cells
        XCTAssertEqual(self.instance.numberOfRowsInSection(section: 3), 0)
        // Secondary Button
        XCTAssertEqual(self.instance.numberOfRowsInSection(section: 4), 1)
        // Exit Button
        XCTAssertEqual(self.instance.numberOfRowsInSection(section: 5), 1)

        XCTAssertEqual(self.instance.numberOfRowsInSection(section: 100), 0)

        // Header
        XCTAssertTrue(self.instance.isHeaderCellFor(indexPath: IndexPath(row: 0, section: 0)))
        XCTAssertEqual(self.instance.heightForRowAt(indexPath: IndexPath(row: 0, section: 0)), UITableViewAutomaticDimension)

        // SubHeader
        XCTAssertFalse(self.instance.isApprovedCustomSubHeaderCellFor(indexPath: IndexPath(row: 0, section: 1)))

        // ContentCell
        XCTAssertTrue(self.instance.isContentCellFor(indexPath: IndexPath(row: 0, section: 2)))
        XCTAssertEqual(self.instance.heightForRowAt(indexPath: IndexPath(row: 0, section: 2)), self.instance.getContentCell().frame.height)

        // Additional Cells
        XCTAssertFalse(self.instance.isPendingAdditionalCustomCellFor(indexPath: IndexPath(row: 0, section: 3)))

        // Secondary Button
        XCTAssertTrue(self.instance.isSecondaryExitButtonCellFor(indexPath: IndexPath(row: 0, section: 4)))
        XCTAssertEqual(self.instance.heightForRowAt(indexPath: IndexPath(row: 0, section: 4)), UITableViewAutomaticDimension)
        XCTAssertTrue(self.instance.shouldShowSecondaryExitButton())

        //ExitButton
        XCTAssertTrue(self.instance.isFooterCellFor(indexPath: IndexPath(row: 0, section: 5)))
        XCTAssertEqual(self.instance.heightForRowAt(indexPath: IndexPath(row: 0, section: 5)), UITableViewAutomaticDimension)
    }

    func testRowsNoContentCell() {

        let paymentPreference = PaymentResultScreenPreference()
        paymentPreference.disableContentCell()
        self.instance.paymentResultScreenPreference = paymentPreference

        /// HEADER
        /// SECONDARY BUTTON
        /// EXIT BUTTON

        // Header
        XCTAssertEqual(self.instance.numberOfRowsInSection(section: 0), 1)
        // SubHeader
        XCTAssertEqual(self.instance.numberOfRowsInSection(section: 1), 0)
        // Content cell
        XCTAssertEqual(self.instance.numberOfRowsInSection(section: 2), 0)
        // Additional Cells
        XCTAssertEqual(self.instance.numberOfRowsInSection(section: 3), 0)
        // Secondary Button
        XCTAssertEqual(self.instance.numberOfRowsInSection(section: 4), 1)
        // Exit Button
        XCTAssertEqual(self.instance.numberOfRowsInSection(section: 5), 1)

        XCTAssertEqual(self.instance.numberOfRowsInSection(section: 100), 0)

        // Header
        XCTAssertTrue(self.instance.isHeaderCellFor(indexPath: IndexPath(row: 0, section: 0)))
        XCTAssertEqual(self.instance.heightForRowAt(indexPath: IndexPath(row: 0, section: 0)), UITableViewAutomaticDimension)

        // SubHeader
        XCTAssertFalse(self.instance.isApprovedCustomSubHeaderCellFor(indexPath: IndexPath(row: 0, section: 1)))

        // ContentCell
        XCTAssertFalse(self.instance.isContentCellFor(indexPath: IndexPath(row: 0, section: 2)))

        // Additional Cells
        XCTAssertFalse(self.instance.isPendingAdditionalCustomCellFor(indexPath: IndexPath(row: 0, section: 3)))

        // Secondary Button
        XCTAssertTrue(self.instance.isSecondaryExitButtonCellFor(indexPath: IndexPath(row: 0, section: 4)))
        XCTAssertEqual(self.instance.heightForRowAt(indexPath: IndexPath(row: 0, section: 4)), UITableViewAutomaticDimension)
        XCTAssertTrue(self.instance.shouldShowSecondaryExitButton())

        //ExitButton
        XCTAssertTrue(self.instance.isFooterCellFor(indexPath: IndexPath(row: 0, section: 5)))
        XCTAssertEqual(self.instance.heightForRowAt(indexPath: IndexPath(row: 0, section: 5)), UITableViewAutomaticDimension)
    }

    func testRowsNoContentCellAndSecondaryButton() {

        let paymentPreference = PaymentResultScreenPreference()
        paymentPreference.disableContentCell()
        paymentPreference.disablePendingSecondaryExitButton()
        self.instance.paymentResultScreenPreference = paymentPreference

        /// HEADER
        /// EXIT BUTTON

        // Header
        XCTAssertEqual(self.instance.numberOfRowsInSection(section: 0), 1)
        // SubHeader
        XCTAssertEqual(self.instance.numberOfRowsInSection(section: 1), 0)
        // Content cell
        XCTAssertEqual(self.instance.numberOfRowsInSection(section: 2), 0)
        // Additional Cells
        XCTAssertEqual(self.instance.numberOfRowsInSection(section: 3), 0)
        // Secondary Button
        XCTAssertEqual(self.instance.numberOfRowsInSection(section: 4), 0)
        // Exit Button
        XCTAssertEqual(self.instance.numberOfRowsInSection(section: 5), 1)

        XCTAssertEqual(self.instance.numberOfRowsInSection(section: 100), 0)

        // Header
        XCTAssertTrue(self.instance.isHeaderCellFor(indexPath: IndexPath(row: 0, section: 0)))
        XCTAssertEqual(self.instance.heightForRowAt(indexPath: IndexPath(row: 0, section: 0)), UITableViewAutomaticDimension)

        // SubHeader
        XCTAssertFalse(self.instance.isApprovedCustomSubHeaderCellFor(indexPath: IndexPath(row: 0, section: 1)))

        // ContentCell
        XCTAssertFalse(self.instance.isContentCellFor(indexPath: IndexPath(row: 0, section: 2)))

        // Additional Cells
        XCTAssertFalse(self.instance.isPendingAdditionalCustomCellFor(indexPath: IndexPath(row: 0, section: 3)))

        // Secondary Button
        XCTAssertFalse(self.instance.isSecondaryExitButtonCellFor(indexPath: IndexPath(row: 0, section: 4)))
        XCTAssertFalse(self.instance.shouldShowSecondaryExitButton())

        //ExitButton
        XCTAssertTrue(self.instance.isFooterCellFor(indexPath: IndexPath(row: 0, section: 5)))
        XCTAssertEqual(self.instance.heightForRowAt(indexPath: IndexPath(row: 0, section: 5)), UITableViewAutomaticDimension)
    }

    func testRowsCustomCells() {

        let paymentPreference = PaymentResultScreenPreference()
        paymentPreference.pendingAdditionalInfoCells = [MPCustomCell(cell: UITableViewCell())]
        self.instance.paymentResultScreenPreference = paymentPreference

        /// HEADER
        /// CONTENT CELL
        /// ADDITIONAL CELLS
        /// SECONDARY BUTTON
        /// EXIT BUTTON

        // Header
        XCTAssertEqual(self.instance.numberOfRowsInSection(section: 0), 1)
        // SubHeader
        XCTAssertEqual(self.instance.numberOfRowsInSection(section: 1), 0)
        // Content cell
        XCTAssertEqual(self.instance.numberOfRowsInSection(section: 2), 1)
        // Additional Cells
        XCTAssertEqual(self.instance.numberOfRowsInSection(section: 3), self.instance.numberOfCustomAdditionalCells())
        // Secondary Button
        XCTAssertEqual(self.instance.numberOfRowsInSection(section: 4), 1)
        // Exit Button
        XCTAssertEqual(self.instance.numberOfRowsInSection(section: 5), 1)

        XCTAssertEqual(self.instance.numberOfRowsInSection(section: 100), 0)

        // Header
        XCTAssertTrue(self.instance.isHeaderCellFor(indexPath: IndexPath(row: 0, section: 0)))
        XCTAssertEqual(self.instance.heightForRowAt(indexPath: IndexPath(row: 0, section: 0)), UITableViewAutomaticDimension)

        // SubHeader
        XCTAssertFalse(self.instance.isApprovedCustomSubHeaderCellFor(indexPath: IndexPath(row: 0, section: 1)))

        // ContentCell
        XCTAssertTrue(self.instance.isContentCellFor(indexPath: IndexPath(row: 0, section: 2)))
        XCTAssertEqual(self.instance.heightForRowAt(indexPath: IndexPath(row: 0, section: 2)), self.instance.getContentCell().frame.height)

        // Additional Cells
        XCTAssertTrue(self.instance.isPendingAdditionalCustomCellFor(indexPath: IndexPath(row: 0, section: 3)))
        XCTAssertEqual(self.instance.heightForRowAt(indexPath: IndexPath(row: 0, section: 3)), 0)

        // Secondary Button
        XCTAssertTrue(self.instance.isSecondaryExitButtonCellFor(indexPath: IndexPath(row: 0, section: 4)))
        XCTAssertEqual(self.instance.heightForRowAt(indexPath: IndexPath(row: 0, section: 4)), UITableViewAutomaticDimension)
        XCTAssertTrue(self.instance.shouldShowSecondaryExitButton())

        //ExitButton
        XCTAssertTrue(self.instance.isFooterCellFor(indexPath: IndexPath(row: 0, section: 5)))
        XCTAssertEqual(self.instance.heightForRowAt(indexPath: IndexPath(row: 0, section: 5)), UITableViewAutomaticDimension)
    }
}

class CallForAuthPaymentResultViewModelTest: BaseTest {

    //*********************
    // C4A PAYMENTS
    //*********************

    var instance: PaymentResultViewModel!
    var paymentData: PaymentData!
    var paymentResult: PaymentResult!
    override func setUp() {
        super.setUp()

        self.paymentData = MockBuilder.buildPaymentData(paymentMethodId: "visa", installments: 1, installmentRate: 0)
        self.paymentResult = PaymentResult(status: "rejected", statusDetail: "cc_rejected_call_for_authorize", paymentData: paymentData, payerEmail: "sarsa@sarasita.com", id: "123", statementDescription: "mercadopago")
        self.instance = PaymentResultViewModel(paymentResult: paymentResult, checkoutPreference: CheckoutPreference(), callback: { (_) in})
    }

    func testStatus() {
        XCTAssertFalse(self.instance.paymentResult.isApproved())
        XCTAssertFalse(self.instance.paymentResult.isPending())
        XCTAssertTrue(self.instance.paymentResult.isCallForAuth())
        XCTAssertTrue(self.instance.paymentResult.isRejected())
    }

    func testGetColor() {
        XCTAssertEqual(self.instance!.getColor(), UIColor(red: 58, green: 184, blue: 239))
    }

    func testLayoutName() {
        XCTAssertEqual(self.instance.getLayoutName(), "authorize")
    }

    func testGetPaymentAction() {
        XCTAssertEqual(self.instance.getPaymentAction(), PaymentResultViewModel.PaymentActions.RECOVER_TOKEN.rawValue)
    }

    func testRowsDefault() {
        /// HEADER
        /// CALL FOR AUTH CELL
        /// CONTENT CELL
        /// SECONDARY BUTTON
        /// EXIT BUTTON

        // Header
        XCTAssertEqual(self.instance.numberOfRowsInSection(section: 0), 1)
        // SubHeader
        XCTAssertEqual(self.instance.numberOfRowsInSection(section: 1), 0)
        // Body
        XCTAssertEqual(self.instance.numberOfRowsInSection(section: 2), 2)
        // Additional Cells
        XCTAssertEqual(self.instance.numberOfRowsInSection(section: 3), 0)
        // Secondary Button
        XCTAssertEqual(self.instance.numberOfRowsInSection(section: 4), 1)
        // Exit Button
        XCTAssertEqual(self.instance.numberOfRowsInSection(section: 5), 1)

        XCTAssertEqual(self.instance.numberOfRowsInSection(section: 100), 0)

        // Header
        XCTAssertTrue(self.instance.isHeaderCellFor(indexPath: IndexPath(row: 0, section: 0)))
        XCTAssertEqual(self.instance.heightForRowAt(indexPath: IndexPath(row: 0, section: 0)), UITableViewAutomaticDimension)

        // SubHeader
        XCTAssertFalse(self.instance.isApprovedCustomSubHeaderCellFor(indexPath: IndexPath(row: 0, section: 1)))

        // Call For Auth
        XCTAssertTrue(self.instance.isCallForAuthFor(indexPath: IndexPath(row: 0, section: 2)))
        XCTAssertEqual(self.instance.heightForRowAt(indexPath: IndexPath(row: 0, section: 2)), UITableViewAutomaticDimension)

        // ContentCell
        XCTAssertTrue(self.instance.isContentCellFor(indexPath: IndexPath(row: 1, section: 2)))
        XCTAssertEqual(self.instance.heightForRowAt(indexPath: IndexPath(row: 1, section: 2)), self.instance.getContentCell().frame.height)

        // Additional Cells
        XCTAssertFalse(self.instance.isPendingAdditionalCustomCellFor(indexPath: IndexPath(row: 0, section: 3)))

        // Secondary Button
        XCTAssertTrue(self.instance.isSecondaryExitButtonCellFor(indexPath: IndexPath(row: 0, section: 4)))
        XCTAssertEqual(self.instance.heightForRowAt(indexPath: IndexPath(row: 0, section: 4)), UITableViewAutomaticDimension)
        XCTAssertTrue(self.instance.shouldShowSecondaryExitButton())

        //ExitButton
        XCTAssertTrue(self.instance.isFooterCellFor(indexPath: IndexPath(row: 0, section: 5)))
        XCTAssertEqual(self.instance.heightForRowAt(indexPath: IndexPath(row: 0, section: 5)), UITableViewAutomaticDimension)
    }

    func testRowsNoContentCell() {
        let paymentPreference = PaymentResultScreenPreference()
        paymentPreference.disableContentCell()
        self.instance.paymentResultScreenPreference = paymentPreference

        /// HEADER
        /// CALL FOR AUTH CELL
        /// SECONDARY BUTTON
        /// EXIT BUTTON

        // Header
        XCTAssertEqual(self.instance.numberOfRowsInSection(section: 0), 1)
        // SubHeader
        XCTAssertEqual(self.instance.numberOfRowsInSection(section: 1), 0)
        // Body
        XCTAssertEqual(self.instance.numberOfRowsInSection(section: 2), 1)
        // Additional Cells
        XCTAssertEqual(self.instance.numberOfRowsInSection(section: 3), 0)
        // Secondary Button
        XCTAssertEqual(self.instance.numberOfRowsInSection(section: 4), 1)
        // Exit Button
        XCTAssertEqual(self.instance.numberOfRowsInSection(section: 5), 1)

        XCTAssertEqual(self.instance.numberOfRowsInSection(section: 100), 0)

        // Header
        XCTAssertTrue(self.instance.isHeaderCellFor(indexPath: IndexPath(row: 0, section: 0)))
        XCTAssertEqual(self.instance.heightForRowAt(indexPath: IndexPath(row: 0, section: 0)), UITableViewAutomaticDimension)

        // SubHeader
        XCTAssertFalse(self.instance.isApprovedCustomSubHeaderCellFor(indexPath: IndexPath(row: 0, section: 1)))

        // Call For Auth
        XCTAssertTrue(self.instance.isCallForAuthFor(indexPath: IndexPath(row: 0, section: 2)))
        XCTAssertEqual(self.instance.heightForRowAt(indexPath: IndexPath(row: 0, section: 2)), UITableViewAutomaticDimension)

        // ContentCell
        XCTAssertFalse(self.instance.isContentCellFor(indexPath: IndexPath(row: 1, section: 2)))

        // Additional Cells
        XCTAssertFalse(self.instance.isPendingAdditionalCustomCellFor(indexPath: IndexPath(row: 0, section: 3)))

        // Secondary Button
        XCTAssertTrue(self.instance.isSecondaryExitButtonCellFor(indexPath: IndexPath(row: 0, section: 4)))
        XCTAssertEqual(self.instance.heightForRowAt(indexPath: IndexPath(row: 0, section: 4)), UITableViewAutomaticDimension)
        XCTAssertTrue(self.instance.shouldShowSecondaryExitButton())

        //ExitButton
        XCTAssertTrue(self.instance.isFooterCellFor(indexPath: IndexPath(row: 0, section: 5)))
        XCTAssertEqual(self.instance.heightForRowAt(indexPath: IndexPath(row: 0, section: 5)), UITableViewAutomaticDimension)
    }

    func testRowsNoContentCellNoSecondaryButton() {
        let paymentPreference = PaymentResultScreenPreference()
        paymentPreference.disableContentCell()
        paymentPreference.disableRejectdSecondaryExitButton()
        self.instance.paymentResultScreenPreference = paymentPreference

        /// HEADER
        /// CALL FOR AUTH CELL
        /// SECONDARY BUTTON
        /// EXIT BUTTON

        // Header
        XCTAssertEqual(self.instance.numberOfRowsInSection(section: 0), 1)
        // SubHeader
        XCTAssertEqual(self.instance.numberOfRowsInSection(section: 1), 0)
        // Body
        XCTAssertEqual(self.instance.numberOfRowsInSection(section: 2), 1)
        // Additional Cells
        XCTAssertEqual(self.instance.numberOfRowsInSection(section: 3), 0)
        // Secondary Button
        XCTAssertEqual(self.instance.numberOfRowsInSection(section: 4), 0)
        // Exit Button
        XCTAssertEqual(self.instance.numberOfRowsInSection(section: 5), 1)

        XCTAssertEqual(self.instance.numberOfRowsInSection(section: 100), 0)

        // Header
        XCTAssertTrue(self.instance.isHeaderCellFor(indexPath: IndexPath(row: 0, section: 0)))
        XCTAssertEqual(self.instance.heightForRowAt(indexPath: IndexPath(row: 0, section: 0)), UITableViewAutomaticDimension)

        // SubHeader
        XCTAssertFalse(self.instance.isApprovedCustomSubHeaderCellFor(indexPath: IndexPath(row: 0, section: 1)))

        // Call For Auth
        XCTAssertTrue(self.instance.isCallForAuthFor(indexPath: IndexPath(row: 0, section: 2)))
        XCTAssertEqual(self.instance.heightForRowAt(indexPath: IndexPath(row: 0, section: 2)), UITableViewAutomaticDimension)

        // ContentCell
        XCTAssertFalse(self.instance.isContentCellFor(indexPath: IndexPath(row: 1, section: 2)))

        // Additional Cells
        XCTAssertFalse(self.instance.isPendingAdditionalCustomCellFor(indexPath: IndexPath(row: 0, section: 3)))

        // Secondary Button
        XCTAssertFalse(self.instance.isSecondaryExitButtonCellFor(indexPath: IndexPath(row: 0, section: 4)))
        XCTAssertFalse(self.instance.shouldShowSecondaryExitButton())

        //ExitButton
        XCTAssertTrue(self.instance.isFooterCellFor(indexPath: IndexPath(row: 0, section: 5)))
        XCTAssertEqual(self.instance.heightForRowAt(indexPath: IndexPath(row: 0, section: 5)), UITableViewAutomaticDimension)
    }
}
class RejectedPaymentResultViewModelTest: BaseTest {

    //*********************
    // REJECTED PAYMENTS
    //*********************

    var instance: PaymentResultViewModel!
    var paymentData: PaymentData!
    var paymentResult: PaymentResult!
    override func setUp() {
        super.setUp()

        self.paymentData = MockBuilder.buildPaymentData(paymentMethodId: "visa", installments: 1, installmentRate: 0)
        self.paymentResult = PaymentResult(status: "rejected", statusDetail: "lala", paymentData: paymentData, payerEmail: "sarsa@sarasita.com", id: "123", statementDescription: "mercadopago")

        self.instance = PaymentResultViewModel(paymentResult: paymentResult, checkoutPreference: CheckoutPreference(), callback: { (_) in})
    }

    func testStatus() {
        XCTAssertFalse(self.instance.paymentResult.isApproved())
        XCTAssertFalse(self.instance.paymentResult.isPending())
        XCTAssertFalse(self.instance.paymentResult.isCallForAuth())
        XCTAssertTrue(self.instance.paymentResult.isRejected())
    }

    func testGetColor() {
        XCTAssertEqual(self.instance!.getColor(), UIColor.px_redCongrats())
    }

    func testLayoutName() {
        XCTAssertEqual(self.instance.getLayoutName(), "rejected")
    }

    func testGetPaymentAction() {
        XCTAssertEqual(self.instance.getPaymentAction(), PaymentResultViewModel.PaymentActions.SELECTED_OTHER_PM.rawValue)
    }

    func testRowsDefault() {
        /// HEADER
        /// CONTENT CELL
        /// SECONDARY BUTTON
        /// EXIT BUTTON

        // Header
        XCTAssertEqual(self.instance.numberOfRowsInSection(section: 0), 1)
        // SubHeader
        XCTAssertEqual(self.instance.numberOfRowsInSection(section: 1), 0)
        // Body
        XCTAssertEqual(self.instance.numberOfRowsInSection(section: 2), 1)
        // Additional Cells
        XCTAssertEqual(self.instance.numberOfRowsInSection(section: 3), 0)
        // Secondary Button
        XCTAssertEqual(self.instance.numberOfRowsInSection(section: 4), 1)
        // Exit Button
        XCTAssertEqual(self.instance.numberOfRowsInSection(section: 5), 1)

        XCTAssertEqual(self.instance.numberOfRowsInSection(section: 100), 0)

        // Header
        XCTAssertTrue(self.instance.isHeaderCellFor(indexPath: IndexPath(row: 0, section: 0)))
        XCTAssertEqual(self.instance.heightForRowAt(indexPath: IndexPath(row: 0, section: 0)), UITableViewAutomaticDimension)

        // SubHeader
        XCTAssertFalse(self.instance.isApprovedCustomSubHeaderCellFor(indexPath: IndexPath(row: 0, section: 1)))

        // ContentCell
        XCTAssertTrue(self.instance.isContentCellFor(indexPath: IndexPath(row: 0, section: 2)))
        XCTAssertEqual(self.instance.heightForRowAt(indexPath: IndexPath(row: 0, section: 2)), self.instance.getContentCell().frame.height)

        // Additional Cells
        XCTAssertFalse(self.instance.isPendingAdditionalCustomCellFor(indexPath: IndexPath(row: 0, section: 3)))

        // Secondary Button
        XCTAssertTrue(self.instance.isSecondaryExitButtonCellFor(indexPath: IndexPath(row: 0, section: 4)))
        XCTAssertEqual(self.instance.heightForRowAt(indexPath: IndexPath(row: 0, section: 4)), UITableViewAutomaticDimension)
        XCTAssertTrue(self.instance.shouldShowSecondaryExitButton())

        //ExitButton
        XCTAssertTrue(self.instance.isFooterCellFor(indexPath: IndexPath(row: 0, section: 5)))
        XCTAssertEqual(self.instance.heightForRowAt(indexPath: IndexPath(row: 0, section: 5)), UITableViewAutomaticDimension)
    }

    func testRowsNoContentCell() {

        let paymentPreference = PaymentResultScreenPreference()
        paymentPreference.disableContentCell()
        self.instance.paymentResultScreenPreference = paymentPreference

        /// HEADER
        /// SECONDARY BUTTON
        /// EXIT BUTTON

        // Header
        XCTAssertEqual(self.instance.numberOfRowsInSection(section: 0), 1)
        // SubHeader
        XCTAssertEqual(self.instance.numberOfRowsInSection(section: 1), 0)
        // Content cell
        XCTAssertEqual(self.instance.numberOfRowsInSection(section: 2), 0)
        // Additional Cells
        XCTAssertEqual(self.instance.numberOfRowsInSection(section: 3), 0)
        // Secondary Button
        XCTAssertEqual(self.instance.numberOfRowsInSection(section: 4), 1)
        // Exit Button
        XCTAssertEqual(self.instance.numberOfRowsInSection(section: 5), 1)

        XCTAssertEqual(self.instance.numberOfRowsInSection(section: 100), 0)

        // Header
        XCTAssertTrue(self.instance.isHeaderCellFor(indexPath: IndexPath(row: 0, section: 0)))
        XCTAssertEqual(self.instance.heightForRowAt(indexPath: IndexPath(row: 0, section: 0)), UITableViewAutomaticDimension)

        // SubHeader
        XCTAssertFalse(self.instance.isApprovedCustomSubHeaderCellFor(indexPath: IndexPath(row: 0, section: 1)))

        // ContentCell
        XCTAssertFalse(self.instance.isContentCellFor(indexPath: IndexPath(row: 0, section: 2)))

        // Additional Cells
        XCTAssertFalse(self.instance.isPendingAdditionalCustomCellFor(indexPath: IndexPath(row: 0, section: 3)))

        // Secondary Button
        XCTAssertTrue(self.instance.isSecondaryExitButtonCellFor(indexPath: IndexPath(row: 0, section: 4)))
        XCTAssertEqual(self.instance.heightForRowAt(indexPath: IndexPath(row: 0, section: 4)), UITableViewAutomaticDimension)
        XCTAssertTrue(self.instance.shouldShowSecondaryExitButton())

        //ExitButton
        XCTAssertTrue(self.instance.isFooterCellFor(indexPath: IndexPath(row: 0, section: 5)))
        XCTAssertEqual(self.instance.heightForRowAt(indexPath: IndexPath(row: 0, section: 5)), UITableViewAutomaticDimension)
    }

    func testRowsNoContentCellAndSecondaryButton() {

        let paymentPreference = PaymentResultScreenPreference()
        paymentPreference.disableContentCell()
        paymentPreference.disableRejectdSecondaryExitButton()
        self.instance.paymentResultScreenPreference = paymentPreference

        /// HEADER
        /// EXIT BUTTON

        // Header
        XCTAssertEqual(self.instance.numberOfRowsInSection(section: 0), 1)
        // SubHeader
        XCTAssertEqual(self.instance.numberOfRowsInSection(section: 1), 0)
        // Content cell
        XCTAssertEqual(self.instance.numberOfRowsInSection(section: 2), 0)
        // Additional Cells
        XCTAssertEqual(self.instance.numberOfRowsInSection(section: 3), 0)
        // Secondary Button
        XCTAssertEqual(self.instance.numberOfRowsInSection(section: 4), 0)
        // Exit Button
        XCTAssertEqual(self.instance.numberOfRowsInSection(section: 5), 1)

        XCTAssertEqual(self.instance.numberOfRowsInSection(section: 100), 0)

        // Header
        XCTAssertTrue(self.instance.isHeaderCellFor(indexPath: IndexPath(row: 0, section: 0)))
        XCTAssertEqual(self.instance.heightForRowAt(indexPath: IndexPath(row: 0, section: 0)), UITableViewAutomaticDimension)

        // SubHeader
        XCTAssertFalse(self.instance.isApprovedCustomSubHeaderCellFor(indexPath: IndexPath(row: 0, section: 1)))

        // ContentCell
        XCTAssertFalse(self.instance.isContentCellFor(indexPath: IndexPath(row: 0, section: 2)))

        // Additional Cells
        XCTAssertFalse(self.instance.isPendingAdditionalCustomCellFor(indexPath: IndexPath(row: 0, section: 3)))

        // Secondary Button
        XCTAssertFalse(self.instance.isSecondaryExitButtonCellFor(indexPath: IndexPath(row: 0, section: 4)))
        XCTAssertFalse(self.instance.shouldShowSecondaryExitButton())

        //ExitButton
        XCTAssertTrue(self.instance.isFooterCellFor(indexPath: IndexPath(row: 0, section: 5)))
        XCTAssertEqual(self.instance.heightForRowAt(indexPath: IndexPath(row: 0, section: 5)), UITableViewAutomaticDimension)
    }
}
class RecoveryPaymentResultViewModelTest: BaseTest {

    //*********************
    // RECOVERY PAYMENTS
    //*********************

    var instance: PaymentResultViewModel!
    var paymentData: PaymentData!
    var paymentResult: PaymentResult!
    override func setUp() {
        super.setUp()

        self.paymentData = MockBuilder.buildPaymentData(paymentMethodId: "visa", installments: 1, installmentRate: 0)
        self.paymentResult = PaymentResult(status: "rejected", statusDetail: "cc_rejected_bad_filled", paymentData: paymentData, payerEmail: "sarsa@sarasita.com", id: "123", statementDescription: "mercadopago")
        self.instance = PaymentResultViewModel(paymentResult: paymentResult, checkoutPreference: CheckoutPreference(), callback: { (_) in})
    }

    func testStatus() {
        XCTAssertFalse(self.instance.paymentResult.isApproved())
        XCTAssertFalse(self.instance.paymentResult.isPending())
        XCTAssertFalse(self.instance.paymentResult.isCallForAuth())
        XCTAssertTrue(self.instance.paymentResult.isRejected())
    }

    func testGetColor() {
        XCTAssertEqual(self.instance!.getColor(), UIColor.px_redCongrats())
    }

    func testLayoutName() {
        XCTAssertEqual(self.instance.getLayoutName(), "recovery")
    }

    func testGetPaymentAction() {
        XCTAssertEqual(self.instance.getPaymentAction(), PaymentResultViewModel.PaymentActions.RECOVER_PAYMENT.rawValue)
    }
}
