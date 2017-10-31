//
//  InstructionsViewModelTest.swift
//  MercadoPagoSDKTests
//
//  Created by Eden Torres on 10/3/17.
//  Copyright © 2017 MercadoPago. All rights reserved.
//

import XCTest

class InstructionsViewModelTest: BaseTest {

    var viewModel: InstructionsViewModel!
    var instructionsInfo: InstructionsInfo!
    var paymentResult: PaymentResult!
    override func setUp() {
        super.setUp()
        paymentResult = MockBuilder.buildPaymentResult()
        paymentResult.paymentData?.issuer = nil
        let paymentMethod = MockBuilder.buildPaymentMethod("bolbradesco")
        instructionsInfo = MockBuilder.buildInstructionsInfo(paymentMethod: paymentMethod)
        let paymentResultScreenPreference = PaymentResultScreenPreference()
        viewModel = InstructionsViewModel(paymentResult: paymentResult, paymentResultScreenPreference: paymentResultScreenPreference, instructionsInfo: instructionsInfo)
    }

    func test_headerColor() {
        XCTAssertEqual(viewModel.getHeaderColor(), UIColor.instructionsHeaderColor())
    }

    func test_numberOfSections() {
        XCTAssertEqual(viewModel.numberOfSections(), 3)
    }

    func test_numberOfRowsInSections() {
        // Header
        // Given subtitle
        instructionsInfo.instructions[0].subtitle = "subtitle"
        XCTAssertEqual(viewModel.numberOfRowsInSection(InstructionsViewModel.Sections.header.rawValue), 2)

        // Given NO subtile
        instructionsInfo.instructions[0].subtitle = nil
        XCTAssertEqual(viewModel.numberOfRowsInSection(InstructionsViewModel.Sections.header.rawValue), 1)

        // Body
        XCTAssertEqual(viewModel.numberOfRowsInSection(InstructionsViewModel.Sections.body.rawValue), 1)

        // Footer
        // Given secondary info
        instructionsInfo.instructions[0].secondaryInfo = ["subtitle"]
        XCTAssertEqual(viewModel.numberOfRowsInSection(InstructionsViewModel.Sections.footer.rawValue), 2)

        // Given NO secondary info
        instructionsInfo.instructions[0].secondaryInfo = nil
        XCTAssertEqual(viewModel.numberOfRowsInSection(InstructionsViewModel.Sections.footer.rawValue), 1)

        //Given wrong section
        XCTAssertEqual(viewModel.numberOfRowsInSection(-10), 0)
    }

    func test_getInstruction() {
        XCTAssertEqual(viewModel.getInstruction(), instructionsInfo.instructions[0])
    }

    func test_shouldShowSecundaryInformation() {
        let servicePreference = ServicePreference()
        servicePreference.setAggregatorAsProcessingMode()
        MercadoPagoCheckout.setServicePreference(servicePreference)

        // Given Proccesing Mode Agregator and Secondary Info
        // Should show
        instructionsInfo.instructions[0].secondaryInfo = ["subtitle"]
        XCTAssert(viewModel.shouldShowSecundaryInformation())

        // Given Proccesing Mode Agregator
        // Should not show
        instructionsInfo.instructions[0].secondaryInfo = nil
        XCTAssertFalse(viewModel.shouldShowSecundaryInformation())

        // Given Secondary Info
        // Should not show
        servicePreference.setGatewayAsProcessingMode()
        instructionsInfo.instructions[0].secondaryInfo = ["subtitle"]
        XCTAssertFalse(viewModel.shouldShowSecundaryInformation())

        // Given nothing
        // Should not show
        servicePreference.setGatewayAsProcessingMode()
        instructionsInfo.instructions[0].secondaryInfo = nil
        XCTAssertFalse(viewModel.shouldShowSecundaryInformation())
    }

    func test_RowsGivenNormalInstruction() {
        // HEADER TITLE
        // HEADER SUBTITLE
        // BODY
        // EMAIL
        // CANCEL

        instructionsInfo.instructions[0].subtitle = "subtitle"
        instructionsInfo.instructions[0].secondaryInfo = ["subtitle"]

        XCTAssert(viewModel.isHeaderTitleCellFor(indexPath: IndexPath(row: 0, section: InstructionsViewModel.Sections.header.rawValue)))
        XCTAssert(viewModel.isHeaderSubtitleCellFor(indexPath: IndexPath(row: 1, section: InstructionsViewModel.Sections.header.rawValue)))
        XCTAssertEqual(viewModel.numberOfRowsInSection(InstructionsViewModel.Sections.header.rawValue), 2)

        XCTAssert(viewModel.isBodyCellFor(indexPath: IndexPath(row: 0, section: InstructionsViewModel.Sections.body.rawValue)))
        XCTAssertEqual(viewModel.numberOfRowsInSection(InstructionsViewModel.Sections.body.rawValue), 1)

        XCTAssert(viewModel.isSecondaryInfoCellFor(indexPath: IndexPath(row: 0, section: InstructionsViewModel.Sections.footer.rawValue)))
        XCTAssert(viewModel.isFooterCellFor(indexPath: IndexPath(row: 1, section: InstructionsViewModel.Sections.footer.rawValue)))
        XCTAssertEqual(viewModel.numberOfRowsInSection(InstructionsViewModel.Sections.footer.rawValue), 2)
    }

    func test_RowsGivenNoSubtitle() {
        // HEADER TITLE
        // BODY
        // EMAIL
        // CANCEL

        instructionsInfo.instructions[0].subtitle = nil
        instructionsInfo.instructions[0].secondaryInfo = ["subtitle"]

        XCTAssert(viewModel.isHeaderTitleCellFor(indexPath: IndexPath(row: 0, section: InstructionsViewModel.Sections.header.rawValue)))
        XCTAssertFalse(viewModel.isHeaderSubtitleCellFor(indexPath: IndexPath(row: 1, section: InstructionsViewModel.Sections.header.rawValue)))
        XCTAssertEqual(viewModel.numberOfRowsInSection(InstructionsViewModel.Sections.header.rawValue), 1)

        XCTAssert(viewModel.isBodyCellFor(indexPath: IndexPath(row: 0, section: InstructionsViewModel.Sections.body.rawValue)))
        XCTAssertEqual(viewModel.numberOfRowsInSection(InstructionsViewModel.Sections.body.rawValue), 1)

        XCTAssert(viewModel.isSecondaryInfoCellFor(indexPath: IndexPath(row: 0, section: InstructionsViewModel.Sections.footer.rawValue)))
        XCTAssert(viewModel.isFooterCellFor(indexPath: IndexPath(row: 1, section: InstructionsViewModel.Sections.footer.rawValue)))
        XCTAssertEqual(viewModel.numberOfRowsInSection(InstructionsViewModel.Sections.footer.rawValue), 2)
    }

    func test_RowsGivenNoEmail() {
        // HEADER TITLE
        // HEADER SUBTITLE
        // BODY
        // CANCEL

        instructionsInfo.instructions[0].subtitle = "subtitle"
        instructionsInfo.instructions[0].secondaryInfo = nil

        XCTAssert(viewModel.isHeaderTitleCellFor(indexPath: IndexPath(row: 0, section: InstructionsViewModel.Sections.header.rawValue)))
        XCTAssert(viewModel.isHeaderSubtitleCellFor(indexPath: IndexPath(row: 1, section: InstructionsViewModel.Sections.header.rawValue)))
        XCTAssertEqual(viewModel.numberOfRowsInSection(InstructionsViewModel.Sections.header.rawValue), 2)

        XCTAssert(viewModel.isBodyCellFor(indexPath: IndexPath(row: 0, section: InstructionsViewModel.Sections.body.rawValue)))
        XCTAssertEqual(viewModel.numberOfRowsInSection(InstructionsViewModel.Sections.body.rawValue), 1)

        XCTAssertFalse(viewModel.isSecondaryInfoCellFor(indexPath: IndexPath(row: 0, section: InstructionsViewModel.Sections.footer.rawValue)))
        XCTAssert(viewModel.isFooterCellFor(indexPath: IndexPath(row: 0, section: InstructionsViewModel.Sections.footer.rawValue)))
        XCTAssertEqual(viewModel.numberOfRowsInSection(InstructionsViewModel.Sections.footer.rawValue), 1)
    }

}
