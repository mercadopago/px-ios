//
//  ResourceManager.swift
//  MercadoPagoSDK
//
//  Created by Eden Torres on 17/08/2018.
//  Copyright © 2018 MercadoPago. All rights reserved.
//

import Foundation

internal class ResourceManager {

    static let shared = ResourceManager()

    let DEFAULT_FONT_NAME = ".SFUIDisplay-Regular"
    
    let allPaymentIDs: Set<String> = [PXPaymentTypes.DEBIT_CARD.rawValue, PXPaymentTypes.CREDIT_CARD.rawValue, PXPaymentTypes.ACCOUNT_MONEY.rawValue, PXPaymentTypes.TICKET.rawValue, PXPaymentTypes.BANK_TRANSFER.rawValue, PXPaymentTypes.ATM.rawValue, PXPaymentTypes.DIGITAL_CURRENCY.rawValue, PXPaymentTypes.PREPAID_CARD.rawValue, PXPaymentTypes.BOLBRADESCO.rawValue, PXPaymentTypes.PEC.rawValue]

    func getBundle() -> Bundle {
        return Bundle(for: ResourceManager.self)
    }

    func getImage(_ name: String?) -> UIImage? {
        guard let name = name else {
            return nil
        }
        return UIImage(named: name, in: MercadoPagoBundle.bundle(), compatibleWith: nil)
    }
}

// MARK: Payment Method Resources
extension ResourceManager {
    func getDictionaryForResource(named resource: String) -> NSDictionary? {
        guard let path = MercadoPagoBundle.bundle().path(forResource: resource, ofType: "plist") else {
            return nil
        }
        return NSDictionary(contentsOfFile: path)
    }

    func getImageFor(_ paymentMethod: PXPaymentMethod, forCell: Bool? = false) -> UIImage? {
        if forCell == true {
            return ResourceManager.shared.getImage(paymentMethod.id.lowercased())
        } else if let pmImage = ResourceManager.shared.getImage("icoTc_"+paymentMethod.id.lowercased()) {
            return pmImage
        } else {
            return ResourceManager.shared.getCardDefaultLogo()
        }
    }

    func getCardDefaultLogo() -> UIImage? {
        return ResourceManager.shared.getImage("icoTc_default")
    }

    func getColorFor(_ paymentMethod: PXPaymentMethod, settings: [PXSetting]?) -> UIColor {
        let dictPM = ResourceManager.shared.getDictionaryForResource(named: "PaymentMethod")

        if let pmConfig = dictPM?.value(forKey: paymentMethod.id) as? NSDictionary {
            if let stringColor = pmConfig.value(forKey: "first_color") as? String {
                return UIColor.fromHex(stringColor)
            } else {
                return UIColor.cardDefaultColor()
            }
        } else if let setting = settings?[0] {
            if let cardNumber = setting.cardNumber, let pmConfig = dictPM?.value(forKey: paymentMethod.id + "_" + String(cardNumber.length)) as? NSDictionary {
                if let stringColor = pmConfig.value(forKey: "first_color") as? String {
                    return UIColor.fromHex(stringColor)
                } else {
                    return UIColor.cardDefaultColor()
                }
            }
        }
        return UIColor.cardDefaultColor()

    }

    func getLabelMaskFor(_ paymentMethod: PXPaymentMethod, settings: [PXSetting]?, forCell: Bool? = false) -> String {
        let dictPM = ResourceManager.shared.getDictionaryForResource(named: "PaymentMethod")

        let defaultMask = "XXXX XXXX XXXX XXXX"

        if let pmConfig = dictPM?.value(forKey: paymentMethod.id) as? NSDictionary {
            let etMask = pmConfig.value(forKey: "label_mask") as? String
            return etMask ?? defaultMask
        } else if let setting = settings?[0] {
            if let cardNumber = setting.cardNumber, let pmConfig = dictPM?.value(forKey: paymentMethod.id + "_" + String(cardNumber.length)) as? NSDictionary {
                let etMask = pmConfig.value(forKey: "label_mask") as? String
                return etMask ?? defaultMask
            }
        }
        return defaultMask
    }

    func getEditTextMaskFor(_ paymentMethod: PXPaymentMethod, settings: [PXSetting]?, forCell: Bool? = false) -> String {
        let dictPM = ResourceManager.shared.getDictionaryForResource(named: "PaymentMethod")

        let defaultMask = "XXXX XXXX XXXX XXXX"

        if let pmConfig = dictPM?.value(forKey: paymentMethod.id) as? NSDictionary {
            let etMask = pmConfig.value(forKey: "editText_mask") as? String
            return etMask ?? defaultMask
        } else if let setting = settings?[0] {
            if let cardNumber = setting.cardNumber, let pmConfig = dictPM?.value(forKey: paymentMethod.id + "_" + String(cardNumber.length)) as? NSDictionary {
                let etMask = pmConfig.value(forKey: "editText_mask") as? String
                return etMask ?? defaultMask
            }
        }
        return defaultMask
    }

    func getFontColorFor(_ paymentMethod: PXPaymentMethod, settings: [PXSetting]?) -> UIColor {
        let dictPM = ResourceManager.shared.getDictionaryForResource(named: "PaymentMethod")
        let defaultColor = MPLabel.defaultColorText

        if let pmConfig = dictPM?.value(forKey: paymentMethod.id) as? NSDictionary {
            if let stringColor = pmConfig.value(forKey: "font_color") as? String {
                return UIColor.fromHex(stringColor)
            } else {
                return defaultColor
            }
        } else if let setting = settings?[0] {
            if let cardNumber = setting.cardNumber, let pmConfig = dictPM?.value(forKey: paymentMethod.id + "_" + String(cardNumber.length)) as? NSDictionary {
                if let stringColor = pmConfig.value(forKey: "font_color") as? String {
                    return UIColor.fromHex(stringColor)
                } else {
                    return defaultColor
                }            }
        }
        return defaultColor

    }

    func getEditingFontColorFor(_ paymentMethod: PXPaymentMethod, settings: [PXSetting]?) -> UIColor {
        let dictPM = ResourceManager.shared.getDictionaryForResource(named: "PaymentMethod")
        let defaultColor = MPLabel.highlightedColorText

        if let pmConfig = dictPM?.value(forKey: paymentMethod.id) as? NSDictionary {
            if let stringColor = pmConfig.value(forKey: "editing_font_color") as? String {
                return UIColor.fromHex(stringColor)
            } else {
                return defaultColor
            }
        } else if let setting = settings?[0] {
            if let cardNumber = setting.cardNumber, let pmConfig = dictPM?.value(forKey: paymentMethod.id + "_" + String(cardNumber.length)) as? NSDictionary {
                if let stringColor = pmConfig.value(forKey: "editing_font_color") as? String {
                    return UIColor.fromHex(stringColor)
                } else {
                    return defaultColor
                }
            }
        }
        return defaultColor

    }
}

// MARK: Payment Result Resources
extension ResourceManager {
    func getResultColorWith(status: String, statusDetail: String? = nil) -> UIColor {
        if let statusDetail = statusDetail {
            //Payment Result Logic
            let paymentResult = PaymentResult(status: status, statusDetail: statusDetail, paymentData: PXPaymentData(), splitAccountMoney: nil, payerEmail: nil, paymentId: nil, statementDescription: nil)
            if paymentResult.isApproved() || paymentResult.isWaitingForPayment() {
                return ThemeManager.shared.successColor()
            }
            if paymentResult.isRejectedWithRemedy() {
                return ThemeManager.shared.remedyWarningColor()
            }
            if paymentResult.isContingency() || paymentResult.isReviewManual() || paymentResult.isWarning() {
                return ThemeManager.shared.warningColor()
            }
            if paymentResult.isError() {
                if paymentResult.isHighRisk() {
                    return ThemeManager.shared.warningColor()
                } else {
                    return ThemeManager.shared.rejectedColor()
                }
            }
        }
        switch status.uppercased() {
        case PXBusinessResultStatus.APPROVED.getDescription():
            return ThemeManager.shared.successColor()
        case PXBusinessResultStatus.REJECTED.getDescription():
            return ThemeManager.shared.rejectedColor()
        case PXBusinessResultStatus.PENDING.getDescription(), PXBusinessResultStatus.IN_PROGRESS.getDescription():
            return ThemeManager.shared.warningColor()
        default:
            return ThemeManager.shared.rejectedColor()
        }
    }

    func getBadgeImageWith(status: String, statusDetail: String? = nil, clearBackground: Bool = false) -> UIImage? {

        if let statusDetail = statusDetail {
            //Payment Result Logic
            let paymentResult = PaymentResult(status: status, statusDetail: statusDetail, paymentData: PXPaymentData(), splitAccountMoney: nil, payerEmail: nil, paymentId: nil, statementDescription: nil)
            if paymentResult.isAccepted() {
                if paymentResult.isApproved() {
                    return getBadgeImage(name: "ok_badge", clearBackground: clearBackground)
                } else if paymentResult.isReviewManual() || paymentResult.isContingency() {
                    return getBadgeImage(name: "orange_pending_badge", clearBackground: clearBackground)
                } else {
                    return getBadgeImage(name: "pending_badge", clearBackground: clearBackground)
                }
            }
            if paymentResult.isWarning() {
                return getBadgeImage(name: "need_action_badge", clearBackground: clearBackground)
            }
            if paymentResult.isError() {
                if paymentResult.isHighRisk() {
                    return getBadgeImage(name: "need_action_badge", clearBackground: clearBackground)
                } else {
                    return getBadgeImage(name: "error_badge", clearBackground: clearBackground)
                }
            }
        } else {
            //Business Result Logic
            if status == PXBusinessResultStatus.APPROVED.getDescription() {
                return getBadgeImage(name: "ok_badge", clearBackground: clearBackground)
            } else if status == PXBusinessResultStatus.REJECTED.getDescription() {
                return getBadgeImage(name: "error_badge", clearBackground: clearBackground)
            } else if status == PXBusinessResultStatus.PENDING.getDescription() {
                return getBadgeImage(name: "orange_pending_badge", clearBackground: clearBackground)
            } else if status == PXBusinessResultStatus.IN_PROGRESS.getDescription() {
                return getBadgeImage(name: "orange_pending_badge", clearBackground: clearBackground)
            }
        }
        return nil
    }

    private func getBadgeImage(name: String, clearBackground: Bool) -> UIImage? {
        var imageName = clearBackground ? "clear_" : ""
        imageName += name
        return getImage(imageName)
    }
}
