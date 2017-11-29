//
//  FlowPreferenceTest.swift
//  MercadoPagoSDK
//
//  Created by Eden Torres on 1/24/17.
//  Copyright © 2017 MercadoPago. All rights reserved.
//

import XCTest

class FlowPreferenceTest: BaseTest {

    let flowPreference = FlowPreference()

    override func setUp() {
        super.setUp()

        let firstHook = MockedHookViewController(hookStep: PXHookStep.AFTER_PAYMENT_TYPE_SELECTED)
        let secondHook = MockedHookViewController(hookStep: PXHookStep.AFTER_PAYMENT_METHOD_SELECTED)
        let thirdHook = MockedHookViewController(hookStep: PXHookStep.BEFORE_PAYMENT)

        let hooks: [PXHookComponent] = [firstHook, secondHook, thirdHook]
        flowPreference.setHook(hooks: hooks)
    }

    func testDefaultState() {
        XCTAssertFalse(flowPreference.isESCEnable())
        XCTAssert(flowPreference.isReviewAndConfirmScreenEnable())
        XCTAssert(flowPreference.isPaymentResultScreenEnable())
        XCTAssert(flowPreference.isPaymentApprovedScreenEnable())
        XCTAssert(flowPreference.isPaymentRejectedScreenEnable())
        XCTAssert(flowPreference.isPaymentPendingScreenEnable())
        XCTAssert(flowPreference.isPaymentSearchScreenEnable())
        XCTAssert(CardFormViewController.showBankDeals)
    }

    func testDisableReviewAndConfirmScreen() {
        flowPreference.disableReviewAndConfirmScreen()
        XCTAssertFalse(flowPreference.isReviewAndConfirmScreenEnable())
    }

    func testDisablePaymentResultScreen() {
        flowPreference.disablePaymentResultScreen()
        XCTAssertFalse(flowPreference.isPaymentResultScreenEnable())
    }

    func testDisablePaymentApprovedScreen() {
        flowPreference.disablePaymentApprovedScreen()
        XCTAssertFalse(flowPreference.isPaymentApprovedScreenEnable())
    }

    func testDisablePaymentRejectedScreen() {
        flowPreference.disablePaymentRejectedScreen()
        XCTAssertFalse(flowPreference.isPaymentRejectedScreenEnable())
    }
    func testDisableDefaultSelection() {
        flowPreference.disableDefaultSelection()
        XCTAssertFalse(flowPreference.isPaymentSearchScreenEnable())
    }

    func testDisableBankDeals() {
        flowPreference.disableBankDeals()
        XCTAssertFalse(CardFormViewController.showBankDeals)
    }

    func testDisableESC() {
        XCTAssertFalse(flowPreference.isESCEnable())
        flowPreference.saveESC = true
        flowPreference.disableESC()
        XCTAssertFalse(flowPreference.saveESC)
    }

    func testEnablePaymentPendingScreen() {
        flowPreference.disablePaymentPendingScreen()
        XCTAssertFalse(flowPreference.isPaymentPendingScreenEnable())
    }
    func testEnableReviewAndConfirmScreen() {
        XCTAssert(flowPreference.isReviewAndConfirmScreenEnable())
        flowPreference.disableReviewAndConfirmScreen()
        flowPreference.enableReviewAndConfirmScreen()
        XCTAssert(flowPreference.isReviewAndConfirmScreenEnable())
    }

    func testEnablePaymentResultScreen() {
        XCTAssert(flowPreference.isPaymentResultScreenEnable())
        flowPreference.disablePaymentResultScreen()
        flowPreference.enablePaymentResultScreen()
        XCTAssert(flowPreference.isPaymentResultScreenEnable())
    }

    func testEnablePaymentApprovedScreen() {
        XCTAssert(flowPreference.isPaymentApprovedScreenEnable())
        flowPreference.disablePaymentApprovedScreen()
        flowPreference.enablePaymentApprovedScreen()
        XCTAssert(flowPreference.isPaymentApprovedScreenEnable())
    }

    func testEnablePaymentRejectedScreen() {
        XCTAssert(flowPreference.isPaymentRejectedScreenEnable())
        flowPreference.disablePaymentRejectedScreen()
        flowPreference.enablePaymentRejectedScreen()
        XCTAssert(flowPreference.isPaymentRejectedScreenEnable())
    }

    func testEnablePaymentPendingdScreen() {
        XCTAssert(flowPreference.isPaymentPendingScreenEnable())
        flowPreference.disablePaymentPendingScreen()
        flowPreference.enablePaymentPendingScreen()
        XCTAssert(flowPreference.isPaymentPendingScreenEnable())
    }

    func testEnableDefaultSelection() {
        XCTAssert(flowPreference.isPaymentSearchScreenEnable())
        flowPreference.disableDefaultSelection()
        flowPreference.enableDefaultSelection()
        XCTAssert(flowPreference.isPaymentSearchScreenEnable())
    }

    func testEnableBankDeals() {
        flowPreference.enableBankDeals()
        XCTAssert(CardFormViewController.showBankDeals)
    }

    func testEnableESC() {
        flowPreference.disablePaymentApprovedScreen()
        flowPreference.enableESC()
        XCTAssert(flowPreference.saveESC)
    }

    func testDefaultMaxSavedCards() {
        XCTAssertEqual(3, flowPreference.getMaxSavedCardsToShow())
        XCTAssertFalse(flowPreference.isShowAllSavedCardsEnabled())
    }

    func testSetMaxSavedCards() {
        flowPreference.setMaxSavedCardsToShow(fromInt: 5)
        XCTAssertEqual(5, flowPreference.getMaxSavedCardsToShow())
        XCTAssertFalse(flowPreference.isShowAllSavedCardsEnabled())
    }

    func testSetMaxSavedCardsWithInvalidInt() {
        flowPreference.setMaxSavedCardsToShow(fromInt: 0)
        XCTAssertEqual(3, flowPreference.getMaxSavedCardsToShow())
        XCTAssertFalse(flowPreference.isShowAllSavedCardsEnabled())
    }

    func testSetMaxSavedCardsWithNegativeInt() {
        flowPreference.setMaxSavedCardsToShow(fromInt: -1)
        XCTAssertEqual(3, flowPreference.getMaxSavedCardsToShow())
        XCTAssertFalse(flowPreference.isShowAllSavedCardsEnabled())
    }

    func testSetMaxSavedCardsWithEmptyString() {
        flowPreference.setMaxSavedCardsToShow(fromString: "")
        XCTAssertEqual(3, flowPreference.getMaxSavedCardsToShow())
        XCTAssertFalse(flowPreference.isShowAllSavedCardsEnabled())
    }

    func testSetMaxSavedCardsWithInvalidString() {
        flowPreference.setMaxSavedCardsToShow(fromString: "invalid")
        XCTAssertEqual(3, flowPreference.getMaxSavedCardsToShow())
        XCTAssertFalse(flowPreference.isShowAllSavedCardsEnabled())
    }

    func testSetMaxSavedCardsToShowAll() {
        flowPreference.setMaxSavedCardsToShow(fromString: FlowPreference.SHOW_ALL_SAVED_CARDS_CODE)
        XCTAssertTrue(flowPreference.isShowAllSavedCardsEnabled())
    }

    func testDisableInstallmentsReviewScreen() {
        flowPreference.disableInstallmentsReviewScreen()
        XCTAssertFalse(flowPreference.isInstallmentsReviewScreenEnable())
    }

    func testEnableInstallmentsReviewScreen() {
        XCTAssert(flowPreference.isInstallmentsReviewScreenEnable())
        flowPreference.disableInstallmentsReviewScreen()
        flowPreference.enableInstallmentsReviewScreen()
        XCTAssert(flowPreference.isInstallmentsReviewScreenEnable())
    }

    func test_GetHookForHookStep() {
        var hook = flowPreference.getHookForStep(hookStep: .AFTER_PAYMENT_METHOD_SELECTED)
        XCTAssertEqual(hook!.hookForStep(), .AFTER_PAYMENT_METHOD_SELECTED)

        hook = flowPreference.getHookForStep(hookStep: .BEFORE_PAYMENT)
        XCTAssertEqual(hook!.hookForStep(), .BEFORE_PAYMENT)

        flowPreference.removeHookFromHooksToShow(hookStep: .AFTER_PAYMENT_METHOD_SELECTED)
        hook = flowPreference.getHookForStep(hookStep: .AFTER_PAYMENT_METHOD_SELECTED)
        XCTAssertNil(hook)
    }

    func test_removeHookFromHookToShow() {
        // Check if a hook step exits
        var hook = flowPreference.getHookForStep(hookStep: .AFTER_PAYMENT_METHOD_SELECTED)
        XCTAssertEqual(hook!.hookForStep(), .AFTER_PAYMENT_METHOD_SELECTED)

        // Remove that step
        flowPreference.removeHookFromHooksToShow(hookStep: .AFTER_PAYMENT_METHOD_SELECTED)
        hook = flowPreference.getHookForStep(hookStep: .AFTER_PAYMENT_METHOD_SELECTED)
        XCTAssertNil(hook)
    }

    func test_addHookFromHookToShow() {
        // Check if a hook step exits
        var hook = flowPreference.getHookForStep(hookStep: .AFTER_PAYMENT_METHOD_SELECTED)
        XCTAssertEqual(hook!.hookForStep(), .AFTER_PAYMENT_METHOD_SELECTED)

        // Remove that step
        flowPreference.removeHookFromHooksToShow(hookStep: .AFTER_PAYMENT_METHOD_SELECTED)
        hook = flowPreference.getHookForStep(hookStep: .AFTER_PAYMENT_METHOD_SELECTED)
        XCTAssertNil(hook)

        // Re add that step and check
        flowPreference.addHookToHooksToShow(hookStep: .AFTER_PAYMENT_METHOD_SELECTED)
        hook = flowPreference.getHookForStep(hookStep: .AFTER_PAYMENT_METHOD_SELECTED)
        XCTAssertEqual(hook!.hookForStep(), .AFTER_PAYMENT_METHOD_SELECTED)
    }

    func test_resetHookToShow() {
        // Check if a hook step exits
        var hook = flowPreference.getHookForStep(hookStep: .AFTER_PAYMENT_METHOD_SELECTED)
        XCTAssertEqual(hook!.hookForStep(), .AFTER_PAYMENT_METHOD_SELECTED)

        // Remove that step
        flowPreference.removeHookFromHooksToShow(hookStep: .AFTER_PAYMENT_METHOD_SELECTED)
        hook = flowPreference.getHookForStep(hookStep: .AFTER_PAYMENT_METHOD_SELECTED)
        XCTAssertNil(hook)

        // Reset HookToShow and check that has previous step
        flowPreference.resetHooksToShow()
        hook = flowPreference.getHookForStep(hookStep: .AFTER_PAYMENT_METHOD_SELECTED)
        XCTAssertEqual(hook!.hookForStep(), .AFTER_PAYMENT_METHOD_SELECTED)
    }

}
