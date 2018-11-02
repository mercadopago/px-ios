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
        private static let from = "#from="
        private static let refer = "#refer="

        // Review and Confirm Path
        static func getReviewAndConfirmPath() -> String {
            return TrackingPaths.pxTrack + "/review/traditional"
        }

        // Terms and condition review Path
        static func getTermsAndCondiontionReviewPath() -> String {
            return TrackingPaths.pxTrack + "/review/traditional/terms_and_conditions"
        }

        // Bank Deaks Path
        static func getBankDealsPath() -> String {
            return TrackingPaths.pxTrack + addPaymentMethod + "/promotions"
        }

        // Terms and Conditions deal Path
        static func getTermsAndConditionBankDealsPath() -> String {
            return TrackingPaths.pxTrack + addPaymentMethod + "/promotions/terms_and_conditions"
        }

        // Issuers Paths
        static func getIssuersPath() -> String {
            return TrackingPaths.pxTrack + payments + "/card_issuer"
        }

        // Installments Paths
        static func getInstallmentsPath() -> String {
            return TrackingPaths.pxTrack + payments + "/installments"
        }

        // Discount details path
        static func getDiscountDetailPath() -> String {
            return TrackingPaths.pxTrack + payments + selectMethod + "/applied_discount"
        }

        // Error path
        static func getErrorPath() -> String {
            return TrackingPaths.pxTrack + "/generic_error"
        }

        // Available payment methods paths
        static func getAvailablePaymentMethodsPath(paymentTypeId: String) -> String {
            return TrackingPaths.pxTrack + addPaymentMethod + "/" + paymentTypeId + "/number/error_more_info"
        }

        // Security Code Paths
        static func getSecurityCodePath(paymentTypeId: String) -> String {
            return pxTrack + payments + selectMethod + "/" + paymentTypeId + "/cvv"
        }
    }
}

// MARK: CardForm Flow Screen Paths
extension TrackingPaths.Screens {
    internal struct CardForm {
        private static let number = "/number"
        private static let name = "/name"
        private static let expirationDate = "/expiration_date"
        private static let cvv = "/cvv"
        private static let identification = "/document"

        static let cardForm = TrackingPaths.pxTrack + TrackingPaths.addPaymentMethod

        static func getCardNumberPath(paymentTypeId: String) -> String {
            return cardForm + "/" + paymentTypeId + number
        }

        static func getCardNamePath(paymentTypeId: String) -> String {
            return cardForm + "/" + paymentTypeId + name
        }

        static func getExpirationDatePath(paymentTypeId: String) -> String {
            return cardForm + "/" + paymentTypeId + expirationDate
        }

        static func getCvvPath(paymentTypeId: String) -> String {
            return cardForm + "/" + paymentTypeId + cvv
        }

        static func getIdentificationPath(paymentTypeId: String) -> String {
            return cardForm + "/" + paymentTypeId + identification
        }
    }
}

// MARK: Boleto Flow Screen Paths
extension TrackingPaths.Screens {
    internal struct Boleto {
        private static let cpf = "/cpf"
        private static let name = "/name"
        private static let lastName = "/lastname"

        private static let boleto = TrackingPaths.pxTrack + TrackingPaths.selectMethod + "/ticket"

        static func getCpfPath() -> String {
            return boleto + cpf
        }

        static func getNamePath() -> String {
            return boleto + name
        }

        static func getLastNamePath() -> String {
            return boleto + lastName
        }
    }
}

// MARK: Payment Result Screen Paths
extension TrackingPaths.Screens {
    internal struct PaymentResult {
        private static let success = "/success"
        private static let furtherAction = "/further_action_needed"
        private static let error = "/error"

        private static let result = TrackingPaths.pxTrack + "/result"

        static func getSuccessPath() -> String {
            return result + success
        }

        static func getFurtherActionPath() -> String {
            return result + furtherAction
        }

        static func getErrorPath() -> String {
            return result + error
        }
    }
}

// MARK: Payment Result Screen Paths
extension TrackingPaths.Screens {
    internal struct PaymentVault {
        private static let ticket = "/ticket"
        private static let cardType = "/select_card_type"

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
    }
}
