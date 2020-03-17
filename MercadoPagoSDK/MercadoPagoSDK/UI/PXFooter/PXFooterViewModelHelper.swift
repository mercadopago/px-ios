//
//  PXFooterViewModelHelper.swift
//  MercadoPagoSDK
//
//  Created by Demian Tejo on 11/15/17.
//  Copyright © 2017 MercadoPago. All rights reserved.
//

import UIKit

// MARK: Build Helpers
internal extension PXResultViewModel {

    func getActionButton() -> PXAction? {
        var actionButton: PXAction?
        if let label = getButtonLabel(), let action = getButtonAction() {
            actionButton = PXAction(label: label, action: action)
        }
        return actionButton
    }

    func getActionLink() -> PXAction? {
        guard let labelLink = self.getLinkLabel(), let actionOfLink = self.getLinkAction() else {
            return nil
        }
        return PXAction(label: labelLink, action: actionOfLink)
    }

    private func getButtonLabel() -> String? {
        if paymentResult.isAccepted() {
            return nil
        } else if paymentResult.isError() {
            return PXFooterResultConstants.GENERIC_ERROR_BUTTON_TEXT.localized
        } else if paymentResult.isWarning() {
            return getWarningButtonLabel()
        }
        return PXFooterResultConstants.DEFAULT_BUTTON_TEXT
    }

    private func getWarningButtonLabel() -> String? {
        if paymentResult.isCallForAuth() {
            return PXFooterResultConstants.C4AUTH_BUTTON_TEXT.localized
        } else if paymentResult.isBadFilled() {
            if paymentResult.statusDetail == PXPayment.StatusDetails.REJECTED_BAD_FILLED_SECURITY_CODE {
                return nil
                //return PXFooterResultConstants.BAD_FILLED_SECURITY_CODE_BUTTON_TEXT.localized
            } else {
                return PXFooterResultConstants.BAD_FILLED_BUTTON_TEXT.localized
            }
        } else if self.paymentResult.isDuplicatedPayment() {
            return PXFooterResultConstants.DUPLICATED_PAYMENT_BUTTON_TEXT.localized
        } else if self.paymentResult.isCardDisabled() {
            return PXFooterResultConstants.CARD_DISABLE_BUTTON_TEXT.localized
        } else if self.paymentResult.isFraudPayment() {
            return PXFooterResultConstants.FRAUD_BUTTON_TEXT.localized
        } else {
            return PXFooterResultConstants.GENERIC_ERROR_BUTTON_TEXT.localized
        }
    }

    private func getLinkLabel() -> String? {
        if paymentResult.hasSecondaryButton() {
            return PXFooterResultConstants.GENERIC_ERROR_BUTTON_TEXT.localized
        } else if paymentResult.isAccepted() {
            return PXFooterResultConstants.APPROVED_LINK_TEXT.localized
        }
        return nil
    }

    private func getButtonAction() -> (() -> Void)? {
        return { [weak self] in self?.pressButton() }
    }

    private func getLinkAction() -> (() -> Void)? {
        return { [weak self] in
            if let url = self?.getBackUrl() {
                self?.openURL(url: url, success: { [weak self] (_) in
                    self?.pressLink()
                })
            } else {
                self?.pressLink()
            }
        }
    }

    private func pressButton() {
        guard let callback = callback else { return }
        if paymentResult.isAccepted() {
             callback(PaymentResult.CongratsState.cancel_EXIT, nil)
        } else if paymentResult.isError() {
            callback(PaymentResult.CongratsState.cancel_SELECT_OTHER, nil)
        } else if self.paymentResult.isBadFilled() {
            callback(PaymentResult.CongratsState.cancel_SELECT_OTHER, nil)
        } else if paymentResult.isWarning() {
            switch self.paymentResult.statusDetail {
            case PXRejectedStatusDetail.CALL_FOR_AUTH.rawValue:
                callback(PaymentResult.CongratsState.call_FOR_AUTH, nil)
            case PXRejectedStatusDetail.CARD_DISABLE.rawValue:
                callback(PaymentResult.CongratsState.cancel_RETRY, nil)
            default:
                callback(PaymentResult.CongratsState.cancel_SELECT_OTHER, nil)
            }
        }
    }

    private func pressLink() {
        guard let callback = callback else { return }
        if paymentResult.isAccepted() {
            callback(PaymentResult.CongratsState.cancel_EXIT, nil)
        } else {
            switch self.paymentResult.statusDetail {
            case PXRejectedStatusDetail.REJECTED_FRAUD.rawValue:
                callback(PaymentResult.CongratsState.cancel_EXIT, nil)
            case PXRejectedStatusDetail.DUPLICATED_PAYMENT.rawValue:
                callback(PaymentResult.CongratsState.cancel_EXIT, nil)
            default:
                callback(PaymentResult.CongratsState.cancel_SELECT_OTHER, nil)
            }
        }
    }
}
