//
//  PXResourceProvider.swift
//  MercadoPagoSDK
//
//  Created by AUGUSTO COLLERONE ALFONSO on 12/5/17.
//  Copyright © 2017 MercadoPago. All rights reserved.
//

import Foundation
import MercadoPagoServices

open class PXResourceProvider: NSObject {

    static var error_body_title_base = "error_body_title_"
    static var error_body_description_base = "error_body_description_"
    static var error_body_action_text_base = "error_body_action_text_"
    static var error_body_secondary_title_base = "error_body_secondary_title_"
    static var spanishId = "es"

    static open func getTitleForErrorBody() -> String {
        return getWord(key: error_body_title_base, statusDetail: "")
    }

    static open func getDescriptionForErrorBodyForPENDING_CONTINGENCY() -> String {
        return getWord(key: error_body_description_base, statusDetail: PXPayment.StatusDetails.PENDING_CONTINGENCY)
    }

    static open func getDescriptionForErrorBodyForPENDING_REVIEW_MANUAL() -> String {
        return getWord(key: error_body_description_base, statusDetail: PXPayment.StatusDetails.PENDING_REVIEW_MANUAL)
    }

    static open func getDescriptionForErrorBodyForREJECTED_CALL_FOR_AUTHORIZE() -> String {
        return getWord(key: error_body_description_base, statusDetail: PXPayment.StatusDetails.REJECTED_CALL_FOR_AUTHORIZE)
    }

    static open func getDescriptionForErrorBodyForREJECTED_CARD_DISABLED(_ paymentMethodName: String?) -> String {
        if let paymentMethodName = paymentMethodName {
            let string = getWord(key: error_body_description_base, statusDetail: PXPayment.StatusDetails.REJECTED_CARD_DISABLED)
            return string.replacingOccurrences(of: "%1$s", with: paymentMethodName)
        } else {
            return getWord(key: error_body_description_base, statusDetail: "")
        }
    }

    static open func getDescriptionForErrorBodyForREJECTED_INSUFFICIENT_AMOUNT() -> String {
        return getWord(key: error_body_description_base, statusDetail: PXPayment.StatusDetails.REJECTED_INSUFFICIENT_AMOUNT)
    }

    static open func getDescriptionForErrorBodyForREJECTED_OTHER_REASON() -> String {
        return getWord(key: error_body_description_base, statusDetail: PXPayment.StatusDetails.REJECTED_OTHER_REASON)
    }

    static open func getDescriptionForErrorBodyForREJECTED_BY_BANK() -> String {
        return getWord(key: error_body_description_base, statusDetail: PXPayment.StatusDetails.REJECTED_BY_BANK)
    }

    static open func getDescriptionForErrorBodyForREJECTED_INSUFFICIENT_DATA() -> String {
        return getWord(key: error_body_description_base, statusDetail: PXPayment.StatusDetails.REJECTED_INSUFFICIENT_DATA)
    }

    static open func getDescriptionForErrorBodyForREJECTED_DUPLICATED_PAYMENT() -> String {
        return getWord(key: error_body_description_base, statusDetail: PXPayment.StatusDetails.REJECTED_DUPLICATED_PAYMENT)
    }

    static open func getDescriptionForErrorBodyForREJECTED_MAX_ATTEMPTS() -> String {
        return getWord(key: error_body_description_base, statusDetail: PXPayment.StatusDetails.REJECTED_MAX_ATTEMPTS)
    }

    static open func getDescriptionForErrorBodyForREJECTED_HIGH_RISK() -> String {
        return getWord(key: error_body_description_base, statusDetail: PXPayment.StatusDetails.REJECTED_HIGH_RISK)
    }

    static open func getActionTextForErrorBodyForREJECTED_CALL_FOR_AUTHORIZE(_ paymentMethodName: String?) -> String {
        if let paymentMethodName = paymentMethodName {
            let string = getWord(key: error_body_action_text_base, statusDetail: PXPayment.StatusDetails.REJECTED_CALL_FOR_AUTHORIZE)
            return string.replacingOccurrences(of: "%1$s", with: paymentMethodName)
        } else {
            return getWord(key: error_body_action_text_base, statusDetail: "")
        }
    }

    static open func getSecondaryTitleForErrorBodyForREJECTED_CALL_FOR_AUTHORIZE() -> String {
        return getWord(key: error_body_secondary_title_base, statusDetail: "")
    }

    static open func getWord(key: String, statusDetail: String) -> String {
        let searchKey = key + statusDetail
        if let translation = getTranslation(for: searchKey), translation.isNotEmpty {
            return translation
        } else if let translation = getTranslation(for: key), translation.isNotEmpty {
            return translation
        } else {
            return getTranslation(for: key, languageId: spanishId)!
        }
    }

    static open func getTranslation(for key: String, languageId: String = MercadoPagoContext.getLanguage()) -> String? {
        let path = MercadoPago.getBundle()!.path(forResource: "PXTranslations", ofType: "plist")
        let dictionary = NSDictionary(contentsOfFile: path!)
        if let keyDict = dictionary?.value(forKey: key) as? NSDictionary {
            if let translation = keyDict.value(forKey: languageId) as? String {
                return translation
            } else {
                if languageId.contains(spanishId) {
                    if let translation = keyDict.value(forKey: spanishId) as? String {
                        return translation
                    }
                }
            }
        }
        return nil
    }
}
