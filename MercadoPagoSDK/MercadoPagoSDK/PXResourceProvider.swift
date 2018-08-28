//
//  PXResourceProvider.swift
//  MercadoPagoSDK
//
//  Created by AUGUSTO COLLERONE ALFONSO on 12/5/17.
//  Copyright © 2017 MercadoPago. All rights reserved.
//

import Foundation
import MercadoPagoServicesV4

@objcMembers
open class PXResourceProvider: NSObject {

    static var error_body_title_base = PXStrings.error_body_title_
    static var error_body_description_base = PXStrings.error_body_description_
    static var error_body_action_text_base = PXStrings.error_body_action_text_
    static var error_body_secondary_title_base = PXStrings.error_body_secondary_title_

    static open func getTitleForErrorBody() -> String {
        return error_body_title_base.PXLocalized
    }

    static open func getDescriptionForErrorBodyForPENDING_CONTINGENCY() -> String {
        let key = error_body_description_base + PXPayment.StatusDetails.PENDING_CONTINGENCY
        return key.PXLocalized
    }

    static open func getDescriptionForErrorBodyForPENDING_REVIEW_MANUAL() -> String {
        let key = error_body_description_base + PXPayment.StatusDetails.PENDING_REVIEW_MANUAL
        return key.PXLocalized
    }

    static open func getDescriptionForErrorBodyForREJECTED_CALL_FOR_AUTHORIZE() -> String {
        let key = error_body_description_base + PXPayment.StatusDetails.REJECTED_CALL_FOR_AUTHORIZE
        return key.PXLocalized
    }

    static open func getDescriptionForErrorBodyForREJECTED_CARD_DISABLED(_ paymentMethodName: String?) -> String {
        if let paymentMethodName = paymentMethodName {
            let key = error_body_description_base + PXPayment.StatusDetails.REJECTED_CARD_DISABLED
            return key.PXLocalized.replacingOccurrences(of: "%1$s", with: paymentMethodName)
        } else {
            return error_body_description_base.PXLocalized
        }
    }

    static open func getDescriptionForErrorBodyForREJECTED_INSUFFICIENT_AMOUNT() -> String {
        let key = error_body_description_base + PXPayment.StatusDetails.REJECTED_INSUFFICIENT_AMOUNT
        return key.PXLocalized
    }

    static open func getDescriptionForErrorBodyForREJECTED_OTHER_REASON() -> String {
        let key = error_body_description_base + PXPayment.StatusDetails.REJECTED_OTHER_REASON
        return key.PXLocalized
    }

    static open func getDescriptionForErrorBodyForREJECTED_BY_BANK() -> String {
        let key = error_body_description_base + PXPayment.StatusDetails.REJECTED_BY_BANK
        return key.PXLocalized
    }

    static open func getDescriptionForErrorBodyForREJECTED_INSUFFICIENT_DATA() -> String {
        let key = error_body_description_base + PXPayment.StatusDetails.REJECTED_INSUFFICIENT_DATA
        return key.PXLocalized
    }

    static open func getDescriptionForErrorBodyForREJECTED_DUPLICATED_PAYMENT() -> String {
        let key = error_body_description_base + PXPayment.StatusDetails.REJECTED_DUPLICATED_PAYMENT
        return key.PXLocalized
    }

    static open func getDescriptionForErrorBodyForREJECTED_MAX_ATTEMPTS() -> String {
        let key = error_body_description_base + PXPayment.StatusDetails.REJECTED_MAX_ATTEMPTS
        return key.PXLocalized
    }

    static open func getDescriptionForErrorBodyForREJECTED_HIGH_RISK() -> String {
        let key = error_body_description_base + PXPayment.StatusDetails.REJECTED_HIGH_RISK
        return key.PXLocalized
    }

    static open func getActionTextForErrorBodyForREJECTED_CALL_FOR_AUTHORIZE(_ paymentMethodName: String?) -> String {

        if let paymentMethodName = paymentMethodName {
            let key = error_body_action_text_base + PXPayment.StatusDetails.REJECTED_CALL_FOR_AUTHORIZE
            return key.PXLocalized.replacingOccurrences(of: "%1$s", with: paymentMethodName)
        } else {
            return error_body_action_text_base.PXLocalized
        }
    }

    static open func getSecondaryTitleForErrorBodyForREJECTED_CALL_FOR_AUTHORIZE() -> String {
        return error_body_secondary_title_base.PXLocalized
    }
}
