//
//  PXPayment.swift
//  MercadoPagoSDK
//
//  Created by Eden Torres on 10/20/17.
//  Copyright © 2017 MercadoPago. All rights reserved.
//

import Foundation
open class PXPayment: NSObject {
    open var binaryMode: Bool!
    open var callForAuthorizeId: String!
    open var captured: Bool!
    open var card: PXCard!
    open var collectorId: String!
    open var couponAmount: Double!
    open var currencyId: String!
    open var dateApproved: Date!
    open var dateCreated: Date!
    open var dateLastUpdated: Date!
    open var _description: String!
    open var differentialPricingId: Int64!
    open var externalReference: String!
    open var feeDetails: [PXFeeDetail]!
    open var id: String!
    open var installments: Int!
    open var issuerId: Int!
    open var liveMode: Bool!
    open var metadata: NSDictionary!
    open var moneyReleaseDate: Date!
    open var notificationUrl: String!
    open var operationType: String!
    open var order: PXOrder!
    open var payer: PXPayer!
    open var paymentMethodId: String!
    open var paymentTypeId: String!
    open var refunds: [PXRefund]!
    open var statementDescriptor: String!
    open var status: String!
    open var statusDetail: String!
    open var transactionAmount: Double!
    open var transactionAmountRefunded: Double!
    open var transactionDetails: PXTransactionDetails!
    open var TokenId: String!

    open class Status: NSObject {
        public static let APPROVED = "approved"
        public static let IN_PROCESS = "in_process"
        public static let REJECTED = "rejected"
        public static let PENDING = "pending"
        public static let RECOVERY = "recovery"
    }

    open class StatusDetails: NSObject {
        public static let INVALID_ESC = "invalid_esc"
        public static let ACCREDITED = "accredited"
        public static let REJECTED_CALL_FOR_AUTHORIZE = "cc_rejected_call_for_authorize"
        public static let PENDING_CONTINGENCY = "pending_contingency"
        public static let PENDING_REVIEW_MANUAL = "pending_review_manual"
        public static let PENDING_WAITING_PAYMENT = "pending_waiting_payment"
        public static let REJECTED_OTHER_REASON = "cc_rejected_other_reason"
        public static let REJECTED_BAD_FILLED_OTHER = "cc_rejected_bad_filled_other"
        public static let REJECTED_BAD_FILLED_CARD_NUMBER = "cc_rejected_bad_filled_card_number"
        public static let REJECTED_BAD_FILLED_SECURITY_CODE = "cc_rejected_bad_filled_security_code"
        public static let REJECTED_BAD_FILLED_DATE = "cc_rejected_bad_filled_date"
        public static let REJECTED_HIGH_RISK = "rejected_high_risk"
        public static let REJECTED_INSUFFICIENT_AMOUNT = "cc_rejected_insufficient_amount"
        public static let REJECTED_MAX_ATTEMPTS = "cc_rejected_max_attempts"
        public static let REJECTED_DUPLICATED_PAYMENT = "cc_rejected_duplicated_payment"
        public static let REJECTED_CARD_DISABLED = "cc_rejected_card_disabled"
        public static let REJECTED_INSUFFICIENT_DATA = "rejected_insufficient_data"
    }
    
    open class func fromJSON(_ json: NSDictionary) -> PXPayment {
        let pxPayment: PXPayment = PXPayment()
        return pxPayment
    }
}
