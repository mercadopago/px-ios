//
//  PXHeaderComponentTest.swift
//  MercadoPagoSDKTests
//
//  Created by Eden Torres on 1/5/18.
//  Copyright © 2018 MercadoPago. All rights reserved.
//

import Foundation
import XCTest

class PXHeaderComponentTest: BaseTest {

    // MARK: APPROVED - CARD
    func testHeaderView_approvedCardPayment_render() {
        // Given:
        let resultViewModel = ResultMockComponentHelper.buildResultViewModel()

        // When:
        let headerView = ResultMockComponentHelper.buildHeaderView(resultViewModel: resultViewModel)

        // Then:
        XCTAssertEqual(headerView.circleImage?.image, MercadoPago.getImage("default_item_icon", bundle: MercadoPago.getBundle()!))
        XCTAssertEqual(headerView.badgeImage?.image, MercadoPago.getImage("ok_badge"))
        XCTAssertNil(headerView.statusLabel?.attributedText)
        XCTAssertEqual(headerView.messageLabel?.attributedText?.string, PXHeaderResutlConstants.APPROVED_HEADER_TITLE.localized)
        XCTAssertEqual(headerView.backgroundColor, ThemeManager.shared.successColor())
    }

    func testHeaderView_approvedCardPaymentPreference_render() {
        // Given:
        let resultViewModel = ResultMockComponentHelper.buildResultViewModelWithPreference()

        // When:
        let headerView = ResultMockComponentHelper.buildHeaderView(resultViewModel: resultViewModel)

        // Then:
        XCTAssertEqual(headerView.circleImage?.image, MercadoPago.getImage("default_item_icon", bundle: MercadoPago.getBundle()!))
        XCTAssertEqual(headerView.badgeImage?.image, MercadoPago.getImage("ok_badge"))
        XCTAssertEqual(headerView.statusLabel?.text, ResultMockComponentHelper.approvedLabelDummy)
        XCTAssertEqual(headerView.messageLabel?.attributedText?.string, ResultMockComponentHelper.approvedTitleDummy)
        XCTAssertEqual(headerView.backgroundColor, ThemeManager.shared.successColor())
    }

    // MARK: APPROVED - ACCOUNT MONEY
    func testHeaderView_approvedAccountMoney_render() {
        // Given:
        let resultViewModel = ResultMockComponentHelper.buildResultViewModel(paymentMethodId: "account_money", paymentTypeId: "account_money")

        // When:
        let headerView = ResultMockComponentHelper.buildHeaderView(resultViewModel: resultViewModel)

        // Then:
        XCTAssertEqual(headerView.circleImage?.image, MercadoPago.getImage("default_item_icon", bundle: MercadoPago.getBundle()!))
        XCTAssertEqual(headerView.badgeImage?.image, MercadoPago.getImage("ok_badge"))
        XCTAssertNil(headerView.statusLabel?.attributedText)
        XCTAssertEqual(headerView.messageLabel?.attributedText?.string, PXHeaderResutlConstants.APPROVED_HEADER_TITLE.localized)
        XCTAssertEqual(headerView.backgroundColor, ThemeManager.shared.successColor())
    }

    // MARK: REJECTED - CARD
    func testHeaderView_rejectedCardPayment_render() {
        // Given:
        let resultViewModel = ResultMockComponentHelper.buildResultViewModel(status: "rejected")

        // When:
        let headerView = ResultMockComponentHelper.buildHeaderView(resultViewModel: resultViewModel)

        // Then:
        XCTAssertEqual(headerView.backgroundColor, ThemeManager.shared.rejectedColor())
        XCTAssertEqual(headerView.circleImage?.image, MercadoPago.getImage("card_icon", bundle: MercadoPago.getBundle()!))
        XCTAssertEqual(headerView.badgeImage?.image, MercadoPago.getImage("error_badge"))
        XCTAssertEqual(headerView.statusLabel?.attributedText?.string, PXHeaderResutlConstants.REJECTED_ICON_SUBTEXT.localized)
    }

    func testHeaderView_rejectedCardPaymentPreference_render() {
        // Given:
        let resultViewModel = ResultMockComponentHelper.buildResultViewModelWithPreference(status: "rejected")

        // When:
        let headerView = ResultMockComponentHelper.buildHeaderView(resultViewModel: resultViewModel)

        // Then:
        XCTAssertEqual(headerView.backgroundColor, ThemeManager.shared.rejectedColor())
        XCTAssertEqual(headerView.circleImage?.image, MercadoPago.getImage("card_icon", bundle: MercadoPago.getBundle()!))
        XCTAssertEqual(headerView.badgeImage?.image, MercadoPago.getImage("error_badge"))
        XCTAssertEqual(headerView.statusLabel?.attributedText?.string, PXHeaderResutlConstants.REJECTED_ICON_SUBTEXT.localized)
        XCTAssertEqual(headerView.messageLabel?.attributedText?.string, ResultMockComponentHelper.rejectedTitleDummy)
    }

    func testHeaderView_rejectedC4AuthCardPayment_render() {
        // Given:
        let resultViewModel = ResultMockComponentHelper.buildResultViewModel(status: "rejected", statusDetail: RejectedStatusDetail.CALL_FOR_AUTH)

        // When:
        let headerView = ResultMockComponentHelper.buildHeaderView(resultViewModel: resultViewModel)

        // Then:
        XCTAssertEqual(headerView.backgroundColor, ThemeManager.shared.warningColor())
        XCTAssertEqual(headerView.circleImage?.image, MercadoPago.getImage("card_icon", bundle: MercadoPago.getBundle()!))
        XCTAssertEqual(headerView.badgeImage?.image, MercadoPago.getImage("need_action_badge"))
        XCTAssertEqual(headerView.messageLabel?.attributedText?.string, resultViewModel.getTitleForCallForAuth(resultViewModel.paymentResult.paymentData!.paymentMethod!).string)
    }

    // MARK: PENDING - CARD
    func testHeaderView_pendingCardPayment_render() {
        // Given:
        let resultViewModel = ResultMockComponentHelper.buildResultViewModel(status: "in_process")

        // When:
        let headerView = ResultMockComponentHelper.buildHeaderView(resultViewModel: resultViewModel)

        // Then:
        XCTAssertEqual(headerView.backgroundColor, ThemeManager.shared.successColor())
        XCTAssertEqual(headerView.circleImage?.image, MercadoPago.getImage("card_icon", bundle: MercadoPago.getBundle()!))
        XCTAssertEqual(headerView.badgeImage?.image, MercadoPago.getImage("pending_badge"))
        XCTAssertNil(headerView.statusLabel?.attributedText)
        XCTAssertEqual(headerView.messageLabel?.attributedText?.string, PXHeaderResutlConstants.PENDING_HEADER_TITLE.localized.localized)
    }

    func testHeaderView_pendingCardPaymentPreference_render() {
        // Given:
        let resultViewModel = ResultMockComponentHelper.buildResultViewModelWithPreference(status: "in_process")

        // When:
        let headerView = ResultMockComponentHelper.buildHeaderView(resultViewModel: resultViewModel)

        // Then:
        XCTAssertEqual(headerView.backgroundColor, ThemeManager.shared.successColor())
        XCTAssertEqual(headerView.circleImage?.image, MercadoPago.getImage("card_icon", bundle: MercadoPago.getBundle()!))
        XCTAssertEqual(headerView.badgeImage?.image, MercadoPago.getImage("pending_badge"))
        XCTAssertNil(headerView.statusLabel?.attributedText)
        XCTAssertEqual(headerView.messageLabel?.attributedText?.string, PXHeaderResutlConstants.PENDING_HEADER_TITLE.localized.localized)
    }

    // MARK: Instructions
    func testHeaderView_instructionsPayment_render() {
        // Given:
        let resultViewModel = ResultMockComponentHelper.buildResultViewModelWithInstructionInfo()

        // When:
        let headerView = ResultMockComponentHelper.buildHeaderView(resultViewModel: resultViewModel)

        // Then:
        XCTAssertEqual(headerView.circleImage?.image, MercadoPago.getImage("card_icon", bundle: MercadoPago.getBundle()!))
        XCTAssertEqual(headerView.badgeImage?.image, MercadoPago.getImage("pending_badge"))
        XCTAssertNil(headerView.statusLabel?.attributedText)
        XCTAssertEqual(headerView.messageLabel?.attributedText?.string, resultViewModel.titleForInstructions().string)
        XCTAssertEqual(headerView.backgroundColor, ThemeManager.shared.successColor())
    }
}
