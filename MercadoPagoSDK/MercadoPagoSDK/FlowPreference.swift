//
//  FlowPreference.swift
//  MercadoPagoSDK
//
//  Created by Eden Torres on 1/23/17.
//  Copyright © 2017 MercadoPago. All rights reserved.
//

import Foundation

open class FlowPreference: NSObject {

    static let DEFAULT_MAX_SAVED_CARDS_TO_SHOW = 3
    static let SHOW_ALL_SAVED_CARDS_CODE = "all"

    var showReviewAndConfirmScreen = true
    var showPaymentResultScreen = true
    var showPaymentApprovedScreen = true
    var showPaymentRejectedScreen = true
    var showPaymentPendingScreen = true
    var showPaymentSearchScreen = true
    var showDiscount = true
    var showAllSavedCards = false
    var showInstallmentsReviewScreen = true
    var maxSavedCardsToShow = FlowPreference.DEFAULT_MAX_SAVED_CARDS_TO_SHOW
    var saveESC = false

    public func disableReviewAndConfirmScreen() {
        showReviewAndConfirmScreen = false
    }

    public func disablePaymentResultScreen() {
        showPaymentResultScreen = false
    }

    public func disablePaymentApprovedScreen() {
        showPaymentApprovedScreen = false
    }

    public func disablePaymentRejectedScreen() {
        showPaymentRejectedScreen = false
    }

    public func disablePaymentPendingScreen() {
        showPaymentPendingScreen = false
    }

    public func disableDefaultSelection() {
        showPaymentSearchScreen = false
    }

    public func disableDiscount() {
        showDiscount = false
    }

    public func disableBankDeals() {
        CardFormViewController.showBankDeals = false
    }

    public func disableInstallmentsReviewScreen() {
        showInstallmentsReviewScreen = false
    }

    /*public func setCongratsDisplayTime(){
    
     }*/

    public func disableESC() {
        saveESC = false
    }

    public func enableReviewAndConfirmScreen() {
        showReviewAndConfirmScreen = true
    }

    public func enablePaymentResultScreen() {
        showPaymentResultScreen = true
    }

    public func enablePaymentApprovedScreen() {
        showPaymentApprovedScreen = true
    }

    public func enablePaymentRejectedScreen() {
        showPaymentRejectedScreen = true
    }

    public func enablePaymentPendingScreen() {
        showPaymentPendingScreen = true
    }

    public func enableDefaultSelection() {
        showPaymentSearchScreen = true
    }

    public func enableDiscount() {
        showDiscount = true
    }

    public func enableBankDeals() {
        CardFormViewController.showBankDeals = true
    }

    public func enableInstallmentsReviewScreen() {
        showInstallmentsReviewScreen = true
    }

    public func enableESC() {
        saveESC = true
    }

    public func setMaxSavedCardsToShow(fromInt: Int) {
        if fromInt > 0 {
            maxSavedCardsToShow = fromInt
        } else {
            maxSavedCardsToShow = FlowPreference.DEFAULT_MAX_SAVED_CARDS_TO_SHOW
        }
    }

    public func setMaxSavedCardsToShow(fromString: String) {
        if fromString == FlowPreference.SHOW_ALL_SAVED_CARDS_CODE {
            showAllSavedCards = true
        } else {
            showAllSavedCards = false
            maxSavedCardsToShow = FlowPreference.DEFAULT_MAX_SAVED_CARDS_TO_SHOW
        }
    }

    public func isReviewAndConfirmScreenEnable() -> Bool {
        return showReviewAndConfirmScreen
    }

    public func isPaymentResultScreenEnable() -> Bool {
        return showPaymentResultScreen
    }

    public func isPaymentApprovedScreenEnable() -> Bool {
        return showPaymentApprovedScreen
    }

    public func isPaymentRejectedScreenEnable() -> Bool {
        return showPaymentRejectedScreen
    }

    public func isPaymentPendingScreenEnable() -> Bool {
        return showPaymentPendingScreen
    }

    public func isPaymentSearchScreenEnable() -> Bool {
        return showPaymentSearchScreen
    }

    public func isDiscountEnable() -> Bool {
        return showDiscount
    }

    public func isShowAllSavedCardsEnabled() -> Bool {
        return showAllSavedCards
    }

    public func isInstallmentsReviewScreenEnable() -> Bool {
        return showInstallmentsReviewScreen
    }

    public func getMaxSavedCardsToShow() -> Int {
        return maxSavedCardsToShow
    }

    public func isESCEnable() -> Bool {
        return saveESC
    }

    open class func fromJSON(_ json: NSDictionary) -> FlowPreference {
        let flowPreference = FlowPreference()
        flowPreference.showReviewAndConfirmScreen = json["review_and_confirm_screen_enabled"] as? Bool ?? true
        flowPreference.showPaymentResultScreen = json["payment_result_screen_enabled"] as? Bool ?? true
        flowPreference.showPaymentApprovedScreen = json["payment_approved_screen_enabled"] as? Bool ?? true
        flowPreference.showPaymentRejectedScreen = json["payment_rejected_screen_enabled"] as? Bool ?? true
        flowPreference.showPaymentPendingScreen = json["payment_pending_screen_enabled"] as? Bool ?? true
        flowPreference.showPaymentSearchScreen = json["payment_search_screen_enabled"] as? Bool ?? true
        flowPreference.showDiscount = json["discount_enabled"] as? Bool ?? true
        flowPreference.showAllSavedCards = json["show_all_saved_cards_enabled"] as? Bool ?? false
        flowPreference.showInstallmentsReviewScreen = json["installments_review_screen_enabled"] as? Bool ?? true
        flowPreference.maxSavedCardsToShow = json["max_saved_cards_to_show"] as? Int ?? FlowPreference.DEFAULT_MAX_SAVED_CARDS_TO_SHOW

        return flowPreference
    }

}
