//
//  TrackingPaths+Screens.swift
//  MercadoPagoSDK
//
//  Created by Eden Torres on 29/10/2018.
//

import Foundation

// MARK: Screens
extension TrackingPaths {

    internal struct Screens {
        // Terms and condition Path
        static func getTermsAndCondiontionPath() -> String {
            return TrackingPaths.pxTrack + payments + "/terms_and_conditions"
        }

        // Discount details path
        static func getDiscountDetailPath() -> String {
            return TrackingPaths.pxTrack + payments + "/applied_discount"
        }

        // Error path
        static func getErrorPath() -> String {
            return TrackingPaths.pxTrack + "/generic_error"
        }

        // Security Code Paths
        static func getSecurityCodePath(paymentTypeId: String) -> String {
            return pxTrack + "/security_code"
        }
    }
}

// MARK: Payment Result Screen Paths
extension TrackingPaths.Screens {
    internal struct PaymentResult {
        private static let success = "/success"
        private static let furtherAction = "/further_action_needed"
        private static let error = "/error"
        private static let abort = "/abort"
        private static let _continue = "/continue"
        private static let primaryAction = "/primary_action"
        private static let secondaryAction = "/secondary_action"
        private static let changePaymentMethod = "/change_payment_method"
        private static let remedy = "/remedy"

        private static let result = "/result"

        static func getSuccessPath(basePath: String = TrackingPaths.pxTrack) -> String {
            return basePath + result + success
        }

        static func getSuccessAbortPath() -> String {
            return getSuccessPath() + abort
        }

        static func getSuccessContinuePath() -> String {
            return getSuccessPath() + _continue
        }

        static func getSuccessPrimaryActionPath() -> String {
            return getSuccessPath() + primaryAction
        }

        static func getSuccessSecondaryActionPath() -> String {
            return getSuccessPath() + secondaryAction
        }

        static func getFurtherActionPath(basePath: String = TrackingPaths.pxTrack) -> String {
            return basePath + result + furtherAction
        }

        static func getFurtherActionAbortPath() -> String {
            return getFurtherActionPath() + abort
        }

        static func getFurtherActionContinuePath() -> String {
            return getFurtherActionPath() + _continue
        }

        static func getFurtherActionPrimaryActionPath() -> String {
            return getFurtherActionPath() + primaryAction
        }

        static func getFurtherActionSecondaryActionPath() -> String {
            return getFurtherActionPath() + secondaryAction
        }

        static func getErrorPath(basePath: String = TrackingPaths.pxTrack) -> String {
            return basePath + result + error
        }

        static func getErrorAbortPath() -> String {
            return getErrorPath() + abort
        }

        static func getErrorChangePaymentMethodPath() -> String {
            return getErrorPath() + changePaymentMethod
        }

        static func getErrorRemedyPath() -> String {
            return getErrorPath() + remedy
        }

        static func getErrorPrimaryActionPath() -> String {
            return getErrorPath() + primaryAction
        }

        static func getErrorSecondaryActionPath() -> String {
            return getErrorPath() + secondaryAction
        }
    }
}

// MARK: Payment Result Screen Paths
extension TrackingPaths.Screens {
    internal struct PaymentVault {
        private static let ticket = "/ticket"
        private static let cardType = "/cards"

        static func getPaymentVaultPath() -> String {
            return TrackingPaths.pxTrack + TrackingPaths.payments + TrackingPaths.selectMethod
        }

        static func getTicketPath() -> String {
            return getPaymentVaultPath() + ticket
        }

        static func getCardTypePath() -> String {
            return getPaymentVaultPath() + cardType
        }
    }
}
// MARK: OneTap Screen Paths
extension TrackingPaths.Screens {
    internal struct OneTap {

        static func getOneTapPath() -> String {
            return TrackingPaths.pxTrack + "/review/one_tap"
        }

        static func getOneTapInstallmentsPath() -> String {
            return TrackingPaths.pxTrack + "/review/one_tap/installments"
        }

        static func getOneTapDisabledModalPath() -> String {
            return TrackingPaths.pxTrack + "/review/one_tap/disabled_payment_method_detail"
        }

        static func getOfflineMethodsPath() -> String {
            return getOneTapPath() + "/offline_methods"
        }
    }
}
