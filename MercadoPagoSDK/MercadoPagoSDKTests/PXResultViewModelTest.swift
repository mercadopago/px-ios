//
//  PXResultViewModelTest.swift
//  MercadoPagoSDKTests
//
//  Created by Demian Tejo on 31/10/17.
//  Copyright © 2017 MercadoPago. All rights reserved.
//

import XCTest

class PXResultViewModelTest: BaseTest {

    func testPaymentResultStatus_isAccepted() {
        var resultViewModel = ResultMockComponentHelper.buildResultViewModel(status: PaymentStatus.APPROVED)
        XCTAssertTrue(resultViewModel.isAccepted())
        resultViewModel = ResultMockComponentHelper.buildResultViewModel(status: PaymentStatus.IN_PROCESS)
        XCTAssertTrue(resultViewModel.isAccepted())
        resultViewModel = ResultMockComponentHelper.buildResultViewModel(status: PaymentStatus.PENDING)
        XCTAssertTrue(resultViewModel.isAccepted())
    }

    func testPaymentResultStatus_isWarning() {
        var resultViewModel = ResultMockComponentHelper.buildResultViewModel(status: PaymentStatus.REJECTED, statusDetail: RejectedStatusDetail.INVALID_ESC)
        XCTAssertTrue(resultViewModel.isWarning())
        resultViewModel = ResultMockComponentHelper.buildResultViewModel(status: PaymentStatus.REJECTED, statusDetail: RejectedStatusDetail.CALL_FOR_AUTH)
        XCTAssertTrue(resultViewModel.isWarning())
        resultViewModel = ResultMockComponentHelper.buildResultViewModel(status: PaymentStatus.REJECTED, statusDetail: RejectedStatusDetail.BAD_FILLED_CARD_NUMBER)
        XCTAssertTrue(resultViewModel.isWarning())
        resultViewModel = ResultMockComponentHelper.buildResultViewModel(status: PaymentStatus.REJECTED, statusDetail: RejectedStatusDetail.CARD_DISABLE)
        XCTAssertTrue(resultViewModel.isWarning())
        resultViewModel = ResultMockComponentHelper.buildResultViewModel(status: PaymentStatus.REJECTED, statusDetail: RejectedStatusDetail.INSUFFICIENT_AMOUNT)
        XCTAssertTrue(resultViewModel.isWarning())
        resultViewModel = ResultMockComponentHelper.buildResultViewModel(status: PaymentStatus.REJECTED, statusDetail: RejectedStatusDetail.BAD_FILLED_DATE)
        XCTAssertTrue(resultViewModel.isWarning())
        resultViewModel = ResultMockComponentHelper.buildResultViewModel(status: PaymentStatus.REJECTED, statusDetail: RejectedStatusDetail.BAD_FILLED_SECURITY_CODE)
        XCTAssertTrue(resultViewModel.isWarning())
        resultViewModel = ResultMockComponentHelper.buildResultViewModel(status: PaymentStatus.REJECTED, statusDetail: RejectedStatusDetail.BAD_FILLED_OTHER)
        XCTAssertTrue(resultViewModel.isWarning())
    }

    func testPaymentResultStatus_isError() {
        var resultViewModel = ResultMockComponentHelper.buildResultViewModel(status: PaymentStatus.REJECTED, statusDetail: RejectedStatusDetail.HIGH_RISK)
        XCTAssertTrue(resultViewModel.isError())
        resultViewModel = ResultMockComponentHelper.buildResultViewModel(status: PaymentStatus.REJECTED, statusDetail: RejectedStatusDetail.OTHER_REASON)
        XCTAssertTrue(resultViewModel.isError())
        resultViewModel = ResultMockComponentHelper.buildResultViewModel(status: PaymentStatus.REJECTED, statusDetail: RejectedStatusDetail.MAX_ATTEMPTS)
        XCTAssertTrue(resultViewModel.isError())
        resultViewModel = ResultMockComponentHelper.buildResultViewModel(status: PaymentStatus.REJECTED, statusDetail: RejectedStatusDetail.DUPLICATED_PAYMENT)
        XCTAssertTrue(resultViewModel.isError())
        resultViewModel = ResultMockComponentHelper.buildResultViewModel(status: PaymentStatus.REJECTED, statusDetail: RejectedStatusDetail.INSUFFICIENT_DATA)
        XCTAssertTrue(resultViewModel.isError())
        resultViewModel = ResultMockComponentHelper.buildResultViewModel(status: PaymentStatus.REJECTED, statusDetail: RejectedStatusDetail.REJECTED_BY_BANK)
        XCTAssertTrue(resultViewModel.isError())
        resultViewModel = ResultMockComponentHelper.buildResultViewModel(status: PaymentStatus.REJECTED, statusDetail: RejectedStatusDetail.REJECTED_PLUGIN_PM)
        XCTAssertTrue(resultViewModel.isError())
    }

    func testExpandedHeader() {
        let paymentResult = MockBuilder.buildPaymentResult("rejected", paymentMethodId: "Mastercard")
        paymentResult.statusDetail = RejectedStatusDetail.BAD_FILLED_SECURITY_CODE
        let resultViewModel = PXResultViewModel(paymentResult: paymentResult, amount:1000.0, instructionsInfo: nil)
        let resultViewController = PXResultViewController(viewModel: resultViewModel) { (congratsState) in

        }
        resultViewController.renderViews()
        let scrollView = resultViewController.scrollView
        let headerView = resultViewController.headerView
        let bodyView = resultViewController.bodyView
        let footerView = resultViewController.footerView
        let expectedHeaderHeight = scrollView!.frame.height - footerView!.frame.height
        XCTAssertEqual(headerView?.frame.height, expectedHeaderHeight)
        XCTAssertEqual(bodyView?.frame.height, 0)
        XCTAssertEqual(scrollView?.frame.height, resultViewController.contentView.frame.height)
    }

    func testExpandedBody() {
        MercadoPagoContext.setLanguage(language: Languages._PORTUGUESE)
        let paymentResult = MockBuilder.buildPaymentResult("rejected", paymentMethodId: "Mastercard")
        paymentResult.statusDetail = RejectedStatusDetail.OTHER_REASON
        let resultViewModel = PXResultViewModel(paymentResult: paymentResult, amount:1000.0, instructionsInfo: nil)
        let resultViewController = PXResultViewController(viewModel: resultViewModel) { (congratsState) in

        }
        resultViewController.renderViews()
        let scrollView = resultViewController.scrollView
        let headerView = resultViewController.headerView
        let bodyView = resultViewController.bodyView
        let footerView = resultViewController.footerView
        let expectedHeaderHeight = resultViewController.totalContentViewHeigth() - footerView!.frame.height - bodyView!.frame.height
        let expectedBodyHeight = resultViewController.totalContentViewHeigth() - footerView!.frame.height - headerView!.frame.height
        XCTAssertEqual(headerView?.frame.height, expectedHeaderHeight)
        XCTAssertEqual(bodyView?.frame.height, expectedBodyHeight)
        XCTAssertEqual(scrollView?.frame.height, resultViewController.contentView.frame.height)
    }
}

