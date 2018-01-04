//
//  PaymentStatus.swift
//  MercadoPagoSDK
//
//  Created by Eden Torres on 2/22/17.
//  Copyright © 2017 MercadoPago. All rights reserved.
//

import Foundation

struct PaymentStatus {
    static let APPROVED = "approved"
    static let REJECTED = "rejected"
    static let RECOVERY = "recovery"
    static let IN_PROCESS = "in_process"
    static let PENDING = "pending"
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
    static let INSUFFICIENT_DATA = "rejected_insufficient_data"
    static let REJECTED_BY_BANK = "rejected_by_bank"
    static let INVALID_ESC = "invalid_esc"
    static let REJECTED_PLUGIN_PM = "cc_rejected_plugin_pm"
}

struct PendingStatusDetail {
    static let CONTINGENCY = "pending_contingency"
    static let REVIEW_MANUAL = "pending_review_manual"
    static let WAITING_PAYMENT = "pending_waiting_payment"

}
