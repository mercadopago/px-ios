//
//  PXSecurityCodeViewModel.swift
//  MercadoPagoSDK
//
//  Created by Esteban Adrian Boffa on 02/09/2020.
//

import Foundation
import MLCardDrawer
import AndesUI

final class PXSecurityCodeViewModel {

    enum Reason: String {
        case SAVED_CARD = "saved_card"
        case INVALID_ESC = "invalid_esc"
        case INVALID_FINGERPRINT = "invalid_fingerprint"
        case UNEXPECTED_TOKENIZATION_ERROR = "unexpected_tokenization_error"
        case ESC_DISABLED = "esc_disabled"
        case ESC_CAP = "esc_cap"
        case CALL_FOR_AUTH = "call_for_auth"
        case NO_REASON = "no_reason"
    }

    let paymentMethod: PXPaymentMethod
    let cardInfo: PXCardInformationForm
    let reason: Reason
    let cardUI: CardUI
    let cardData: CardData

    // MARK: Protocols
    weak var internetProtocol: InternetConnectionProtocol?

    public init(paymentMethod: PXPaymentMethod, cardInfo: PXCardInformationForm, reason: Reason, cardUI: CardUI, cardData: CardData, internetProtocol: InternetConnectionProtocol) {
        self.paymentMethod = paymentMethod
        self.cardInfo = cardInfo
        self.reason = reason
        self.cardUI = cardUI
        self.cardData = cardData
        self.internetProtocol = internetProtocol
    }
}

// MARK: Publics
extension PXSecurityCodeViewModel {
    func shouldShowCard() -> Bool {
        return !UIDevice.isSmallDevice() && !isVirtualCard()
    }

    func isVirtualCard() -> Bool {
        paymentMethod.creditsDisplayInfo?.cvvInfo != nil
    }

    func getTitle() -> String? {
        return isVirtualCard() ? paymentMethod.creditsDisplayInfo?.cvvInfo?.title : "px_security_code_screen_title".localized
    }

    func getSubtitle() -> String? {
        if isVirtualCard() {
            return paymentMethod.creditsDisplayInfo?.cvvInfo?.message
        } else {
            let text = cardUI.securityCodeLocation == .back ? "px_security_code_subtitle_back".localized : "px_security_code_subtitle_front".localized
            return text.replacingOccurrences(of: "{0}", with: "\(getSecurityCodeLength())")
        }
    }

    func getSecurityCodeLength() -> Int {
        return paymentMethod.secCodeLenght(cardInfo.getCardBin())
    }

    func getAndesTextFieldCodeLabel() -> String {
        return isVirtualCard() ? "px_dynamic_security_code".localized : "security_code".localized
    }

    func getAndesTextFieldCodeStyle() -> AndesTextFieldCodeStyle {
        let andesTextFieldCodeStyle: AndesTextFieldCodeStyle
        switch getSecurityCodeLength() {
        case 4:
            andesTextFieldCodeStyle = .FOURSOME
        case 6:
            andesTextFieldCodeStyle = .THREE_BY_THREE
        default:
            andesTextFieldCodeStyle = .THREESOME
        }
        return andesTextFieldCodeStyle
    }
}

// MARK: Static methods
extension PXSecurityCodeViewModel {
    static func getSecurityCodeReason(invalidESCReason: PXESCDeleteReason?, isCallForAuth: Bool = false) -> PXSecurityCodeViewModel.Reason {
        if isCallForAuth {
            return .CALL_FOR_AUTH
        }

        if !PXConfiguratorManager.escProtocol.hasESCEnable() {
            return .ESC_DISABLED
        }

        guard let invalidESCReason = invalidESCReason else { return .SAVED_CARD }

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
extension PXSecurityCodeViewModel {
    func getScreenProperties() -> [String: Any] {
        var properties: [String: Any] = [:]
        properties["payment_method_id"] = paymentMethod.getPaymentIdForTracking()
        properties["payment_method_type"] = paymentMethod.getPaymentTypeForTracking()
        if let cardInfo = cardInfo as? PXCardInformation {
            properties["card_id"] =  cardInfo.getCardId()
            properties["issuer_id"] = cardInfo.getIssuer()?.id
        }
        properties["bin"] = cardInfo.getCardBin()
        properties["reason"] = reason.rawValue
        return properties
    }

    func getNoConnectionProperties() -> [String: Any] {
        var properties: [String: Any] = [:]
        properties["path"] = "/px_checkout/no_connection"
        properties["style"] = "snackbar"
        properties["id"] = "no_connection"
        return properties
    }

    func getFrictionProperties(path: String, id: String) -> [String: Any] {
        var properties: [String: Any] = [:]
        properties["path"] = path
        properties["style"] = "snackbar"
        properties["id"] = id
        var extraInfo: [String: Any] = [:]
        extraInfo["payment_method_type"] = paymentMethod.getPaymentTypeForTracking()
        extraInfo["payment_method_id"] = paymentMethod.getPaymentIdForTracking()
        if let cardInfo = cardInfo as? PXCardInformation {
            extraInfo["card_id"] = cardInfo.getCardId()
            extraInfo["issuer_id"] = cardInfo.getIssuer()?.id
        }
        properties["extra_info"] = extraInfo
        return properties
    }
}
