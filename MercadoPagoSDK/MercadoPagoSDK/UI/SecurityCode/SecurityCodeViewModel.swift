//
//  SecurityCodeViewModel.swift
//  MercadoPagoSDK
//
//  Created by AUGUSTO COLLERONE ALFONSO on 7/17/17.
//  Copyright © 2017 MercadoPago. All rights reserved.
//

import Foundation

internal class SecurityCodeViewModel {
    var paymentMethod: PXPaymentMethod
    var cardInfo: PXCardInformationForm
    var reason: Reason

    var callback: ((_ cardInformation: PXCardInformationForm, _ securityCode: String) -> Void)?

    public init(paymentMethod: PXPaymentMethod, cardInfo: PXCardInformationForm, reason: Reason) {
        self.paymentMethod = paymentMethod
        self.cardInfo = cardInfo
        self.reason = reason
    }

    func secCodeInBack() -> Bool {
        return paymentMethod.secCodeInBack()
    }
    func secCodeLenght() -> Int {
        return paymentMethod.secCodeLenght(cardInfo.getCardBin())
    }

    func executeCallback(secCode: String!) {
        callback!(cardInfo, secCode)
    }

    func getPaymentMethodColor() -> UIColor {
        return self.paymentMethod.getColor(bin: self.cardInfo.getCardBin())
    }

    func getPaymentMethodFontColor() -> UIColor {
        return self.paymentMethod.getFontColor(bin: self.cardInfo.getCardBin())
    }

    func getCardHeight() -> CGFloat {
        return getCardWidth() / 12 * 7
    }

    func getCardWidth() -> CGFloat {
        return (UIScreen.main.bounds.width - 100)
    }
    func getCardX() -> CGFloat {
        return ((UIScreen.main.bounds.width - getCardWidth()) / 2)
    }

    func getCardY() -> CGFloat {
        let cardSeparation: CGFloat = 510
        let yPos = (UIScreen.main.bounds.height - getCardHeight() - cardSeparation) / 2
        return yPos > 10 ? yPos : 10
    }

    func getCardBounds() -> CGRect {
        return CGRect(x: getCardX(), y: getCardY(), width: getCardWidth(), height: getCardHeight())
    }

    internal enum Reason: String {
        case SAVED_CARD = "saved_card"
        case INVALID_ESC = "invalid_esc"
        case INVALID_FINGERPRINT = "invalid_fingerprint"
        case UNEXPECTED_TOKENIZATION_ERROR = "unexpected_tokenization_error"
        case ESC_DISABLED = "esc_disabled"
        case ESC_CAP = "esc_cap"
        case CALL_FOR_AUTH = "call_for_auth"
        case NO_REASON = "no_reason"
    }
}

// MARK: Static methods
extension SecurityCodeViewModel {
    static func getSecurityCodeReason(invalidESCReason: PXESCDeleteReason?, isCallForAuth: Bool = false, escEnabled: Bool = true) -> SecurityCodeViewModel.Reason {
        if isCallForAuth {
            return .CALL_FOR_AUTH
        }

        if !escEnabled {
            return .ESC_DISABLED
        }

        guard let invalidESCReason = invalidESCReason else {
            return .SAVED_CARD
        }

        switch invalidESCReason {
        case .INVALID_ESC:
            return .INVALID_ESC
        case .INVALID_FINGERPRINT:
            return .INVALID_FINGERPRINT
        case .UNEXPECTED_TOKENIZATION_ERROR:
            return .UNEXPECTED_TOKENIZATION_ERROR
        case .ESC_CAP:
            return .ESC_CAP
        default:
            return .NO_REASON
        }
    }
}

// MARK: Tracking
extension SecurityCodeViewModel {
    func getScreenProperties() -> [String: Any] {
        var properties: [String: Any] = [:]
        properties["payment_method_id"] = paymentMethod.getPaymentIdForTracking()
        if let token = cardInfo as? PXCardInformation {
            properties["card_id"] =  token.getCardId()
        }
        properties["reason"] = reason.rawValue
        return properties
    }

    func getInvalidUserInputErrorProperties(message: String) -> [String: Any] {
        var properties: [String: Any] = [:]
        properties["path"] = TrackingPaths.Screens.getSecurityCodePath(paymentTypeId: paymentMethod.paymentTypeId)
        properties["style"] = Tracking.Style.customComponent
        properties["id"] = Tracking.Error.Id.invalidCVV
        properties["message"] = message
        properties["attributable_to"] = Tracking.Error.Atrributable.user
        var extraDic: [String: Any] = [:]
        extraDic["payment_method_type"] = paymentMethod.getPaymentTypeForTracking()
        extraDic["payment_method_id"] = paymentMethod.getPaymentIdForTracking()
        properties["extra_info"] = extraDic
        return properties
    }
}
