//
//  PaymentResultViewModel.swift
//  MercadoPagoSDK
//
//  Created by Eden Torres on 2/22/17.
//  Copyright © 2017 MercadoPago. All rights reserved.
//

import Foundation

class PaymentResultViewModel: NSObject {

    var paymentResult: PaymentResult!
    var callback: ( _ status: PaymentResult.CongratsState) -> Void
    var checkoutPreference: CheckoutPreference?

    var contentCell: PaymentResultContentView?

    var paymentResultScreenPreference = PaymentResultScreenPreference()

    init(paymentResult: PaymentResult, checkoutPreference: CheckoutPreference, callback : @escaping ( _ status: PaymentResult.CongratsState) -> Void, paymentResultScreenPreference: PaymentResultScreenPreference = PaymentResultScreenPreference()) {
        self.paymentResult = paymentResult
        self.callback = callback
        self.checkoutPreference = checkoutPreference
        self.paymentResultScreenPreference = paymentResultScreenPreference
    }

    open func getContentCell() -> PaymentResultContentView {
        if contentCell == nil {
            contentCell = PaymentResultContentView(paymentResult: self.paymentResult, paymentResultScreenPreference: self.paymentResultScreenPreference)
        }
        return contentCell!
    }

    func getColor() -> UIColor {
        if let color = paymentResultScreenPreference.statusBackgroundColor {
            return color
        } else if paymentResult.isApproved() {
            return UIColor.px_greenCongrats()
        } else if paymentResult.isPending() {
            return UIColor(red: 255, green: 161, blue: 90)
        } else if paymentResult.isCallForAuth() {
            return UIColor(red: 58, green: 184, blue: 239)
        } else if paymentResult.isRejected() {
            return UIColor.px_redCongrats()
        }
        return UIColor(red: 255, green: 89, blue: 89)
    }

    internal func getLayoutName() -> String! {

        if paymentResult.status == PaymentStatus.REJECTED {
            if paymentResult.statusDetail == "cc_rejected_call_for_authorize" {
                return "authorize" //C4A
            } else if paymentResult.statusDetail.contains("cc_rejected_bad_filled") {
                return "recovery" //bad fill something
            }
        }

        return paymentResult.status
    }

    func setCallbackWithTracker() -> (_ paymentResult: PaymentResult, _ status: PaymentResult.CongratsState) -> Void {
        let callbackWithTracker : (_ paymentResutl: PaymentResult, _ status: PaymentResult.CongratsState) -> Void = {(paymentResult, status) in
            self.callback(status)
        }
        return callbackWithTracker
    }

    func getPaymentAction() -> PaymentActions.RawValue {
        if self.paymentResult.statusDetail.contains("cc_rejected_bad_filled") {
            return PaymentActions.RECOVER_PAYMENT.rawValue
        } else if paymentResult.isCallForAuth() {
            return PaymentActions.RECOVER_TOKEN.rawValue
        } else if paymentResult.isRejected() {
            return PaymentActions.SELECTED_OTHER_PM.rawValue
        } else {
            return PaymentActions.RECOVER_PAYMENT.rawValue
        }
    }

    func numberOfSections() -> Int {
        return 6
    }

    func isHeaderCellFor(indexPath: IndexPath) -> Bool {
        return indexPath.section == Sections.header.rawValue
    }

    func isFooterCellFor(indexPath: IndexPath) -> Bool {
        return indexPath.section == Sections.exit.rawValue
    }

    func isApprovedBodyCellFor(indexPath: IndexPath) -> Bool {
        //approved case
        let precondition = indexPath.section == Sections.body.rawValue && paymentResult.isApproved()
        //if row at index 0 exists and approved body is not disabled, row 0 should display approved body
        let case1 = !paymentResultScreenPreference.isApprovedPaymentBodyDisableCell() && indexPath.row == 0
        return precondition && case1
    }

    func isEmailCellFor(indexPath: IndexPath) -> Bool {
        //approved case
        let precondition = indexPath.section == Sections.body.rawValue && paymentResult.isApproved() && !String.isNullOrEmpty(paymentResult.payerEmail)
        //if row at index 0 exists and approved body is disabled, row 0 should display email row
        let case1 = paymentResultScreenPreference.isApprovedPaymentBodyDisableCell() && indexPath.row == 0
        //if row at index 1 exists, row 1 should display email row
        let case2 = indexPath.row == 1
        return precondition && (case1 || case2)
    }

    func isCallForAuthFor(indexPath: IndexPath) -> Bool {
        //non approved case
        let precondition = indexPath.section == Sections.body.rawValue && !paymentResult.isApproved()
        //if row at index 0 exists and callForAuth is not disabled, row 0 should display callForAuth cell
        let case1 = paymentResult.isCallForAuth() && indexPath.row == 0
        return precondition && case1
    }

    func isContentCellFor(indexPath: IndexPath) -> Bool {
        //non approved case
        let precondition = indexPath.section == Sections.body.rawValue && !paymentResult.isApproved()
        //if row at index 0 exists and callForAuth is disabled, row 0 should display select another payment row
        let case1 = !paymentResult.isCallForAuth() && indexPath.row == 0
        //if row at index 1 exists, row 1 should display select another payment row
        let case2 = indexPath.row == 1
        return precondition && (case1 || case2) && !self.paymentResultScreenPreference.isContentCellDisable()
    }

    func isApprovedAdditionalCustomCellFor(indexPath: IndexPath) -> Bool {
        return indexPath.section == Sections.additionaCells.rawValue && paymentResult.isApproved() && numberOfCustomAdditionalCells() > indexPath.row
    }
    func isPendingAdditionalCustomCellFor(indexPath: IndexPath) -> Bool {
        return indexPath.section == Sections.additionaCells.rawValue && paymentResult.isPending() && numberOfCustomAdditionalCells() > indexPath.row
    }

    func isSecondaryExitButtonCellFor(indexPath: IndexPath) -> Bool {
        return indexPath.section == Sections.secondaryExit.rawValue && shouldShowSecondaryExitButton()
    }

    func isApprovedCustomSubHeaderCellFor(indexPath: IndexPath) -> Bool {
        return indexPath.section == Sections.subHedader.rawValue && paymentResult.isApproved() && numberOfCustomSubHeaderCells() > indexPath.row
    }

    func numberOfRowsInSection(section: Int) -> Int {
        switch section {
        case Sections.header.rawValue:
            return 1
        case Sections.subHedader.rawValue:
            return numberOfCustomSubHeaderCells()
        case Sections.body.rawValue:
            return numberOfCellInBody()
        case Sections.additionaCells.rawValue:
            return numberOfCustomAdditionalCells()
        case Sections.secondaryExit.rawValue:
            return shouldShowSecondaryExitButton() ? 1 : 0
        case Sections.exit.rawValue:
            return 1
        default:
            return 0
        }
    }

    func shouldShowSecondaryExitButton() -> Bool {
        if paymentResult.isApproved() && paymentResultScreenPreference.approvedSecondaryExitButtonCallback != nil {
            return true
        } else if paymentResult.isPending() && !paymentResultScreenPreference.isPendingSecondaryExitButtonDisable() {
            return true
        } else if paymentResult.isRejected() && !paymentResultScreenPreference.isRejectedSecondaryExitButtonDisable() {
            return true
        }
        return false
    }

    func numberOfCellInBody() -> Int {
        if paymentResult.isApproved() {
            let approvedBodyAdd = !paymentResultScreenPreference.isApprovedPaymentBodyDisableCell() ? 1 : 0
            let emailCellAdd = !String.isNullOrEmpty(paymentResult.payerEmail) ? 1 : 0
            return approvedBodyAdd + emailCellAdd

        }
        let callForAuthAdd = paymentResult.isCallForAuth() ? 1 : 0
        let selectAnotherCellAdd = !paymentResultScreenPreference.isContentCellDisable() ? 1 : 0
        return callForAuthAdd + selectAnotherCellAdd
    }

    func numberOfCustomAdditionalCells() -> Int {
        if !Array.isNullOrEmpty(paymentResultScreenPreference.pendingAdditionalInfoCells) && paymentResult.isPending() {
            return paymentResultScreenPreference.pendingAdditionalInfoCells.count
        } else if !Array.isNullOrEmpty(paymentResultScreenPreference.approvedAdditionalInfoCells) && paymentResult.isApproved() {
            return paymentResultScreenPreference.approvedAdditionalInfoCells.count
        }
        return 0
    }

    func numberOfCustomSubHeaderCells() -> Int {
        if !Array.isNullOrEmpty(paymentResultScreenPreference.approvedSubHeaderCells) && paymentResult.isApproved() {
            return paymentResultScreenPreference.approvedSubHeaderCells.count
        }
        return 0
    }

    func heightForRowAt(indexPath: IndexPath) -> CGFloat {
        if self.isContentCellFor(indexPath: indexPath) {
            return self.getContentCell().viewModel.getHeight()
        } else if self.isApprovedAdditionalCustomCellFor(indexPath: indexPath) {
            return paymentResultScreenPreference.approvedAdditionalInfoCells[indexPath.row].getHeight()
        } else if self.isPendingAdditionalCustomCellFor(indexPath: indexPath) {
            return paymentResultScreenPreference.pendingAdditionalInfoCells[indexPath.row].getHeight()
        } else if isApprovedCustomSubHeaderCellFor(indexPath: indexPath) {
            return paymentResultScreenPreference.approvedSubHeaderCells[indexPath.row].getHeight()
        }
        return UITableViewAutomaticDimension
    }

    enum PaymentActions: String {
        case RECOVER_PAYMENT = "RECOVER_PAYMENT"
        case RECOVER_TOKEN = "RECOVER_TOKEN"
        case SELECTED_OTHER_PM = "SELECT_OTHER_PAYMENT_METHOD"
    }

    public enum Sections: Int {
        case header = 0
        case subHedader = 1
        case body = 2
        case additionaCells = 3
        case secondaryExit = 4
        case exit = 5
    }
}

struct PaymentStatus {
    static let APPROVED = "approved"
    static let REJECTED = "rejected"
    static let RECOVERY = "recovery"
    static let IN_PROCESS = "in_process"
}

struct RejectedStatusDetail {
    static let HIGH_RISK = "rejected_high_risk"
    static let OTHER_REASON = "cc_rejected_other_reason"
    static let MAX_ATTEMPTS = "cc_rejected_max_attempts"
    static let CARD_DISABLE = "cc_rejected_card_disabled"
    static let BAD_FILLED_OTHER = "cc_rejected_bad_filled_other"
    static let BAD_FILLED_CARD_NUMBER = "cc_rejected_bad_filled_card_number"
    static let BAD_FILLED_SECURITY_CODE = "cc_rejected_bad_filled_security_code"
    static let BAD_FILLED_DATE = "cc_rejected_bad_filled_date"
    static let CALL_FOR_AUTH = "cc_rejected_call_for_authorize"
    static let DUPLICATED_PAYMENT = "cc_rejected_duplicated_payment"
    static let INSUFFICIENT_AMOUNT = "cc_rejected_insufficient_amount"
    static let INVALID_ESC = "invalid_esc"
}

struct PendingStatusDetail {
    static let CONTINGENCY = "pending_contingency"
    static let REVIEW_MANUAL = "pending_review_manual"

}
