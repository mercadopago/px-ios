//
//  PXFooterViewModelHelper.swift
//  MercadoPagoSDK
//
//  Created by Demian Tejo on 11/15/17.
//  Copyright © 2017 MercadoPago. All rights reserved.
//

import UIKit

extension PXResultViewModel {

    func getFooterComponentProps() -> PXFooterProps {
        return PXFooterProps(buttonAction: getActionButton(), linkAction: getActionLink())
    }

    func buildFooterComponent() -> PXFooterComponent {
        let footerProps = getFooterComponentProps()
        return PXFooterComponent(props: footerProps)
    }
}

// MARK: Build Helpers
extension PXResultViewModel {

    func getActionButton() -> PXComponentAction? {
         var actionButton: PXComponentAction?
        if let label = self.getButtonLabel(), let action = self.getButtonAction() {
            actionButton = PXComponentAction(label: label, action: action)
        }
        return actionButton
    }

    func getActionLink() -> PXComponentAction? {
        var actionLink: PXComponentAction?
        if let labelLink = self.getLinkLabel(), let actionOfLink = self.getLinkAction() {
            actionLink = PXComponentAction(label: labelLink, action: actionOfLink)
        }
        return actionLink
    }

    func getButtonLabel() -> String? {
        if paymentResult.isAccepted() {
            if self.paymentResult.isWaitingForPayment() {
                if preference.getPendingSecondaryButtonText() != nil {
                    return preference.getPendingSecondaryButtonText()!
                } else {
                    return PXFooterResultConstants.DEFAULT_BUTTON_TEXT
                }
            } else if !preference.getApprovedSecondaryButtonText().isEmpty {
                return preference.getApprovedSecondaryButtonText()
            } else {
                return PXFooterResultConstants.DEFAULT_BUTTON_TEXT
            }
        } else if paymentResult.isError() {
            if let labelError = preference.getRejectedSecondaryButtonText() {
                return labelError
            } else {
                return PXFooterResultConstants.ERROR_BUTTON_TEXT.localized
            }
        } else if paymentResult.isWarning() {
            if let labelWarning = preference.getPendingSecondaryButtonText() {
                return labelWarning
            } else if self.paymentResult.statusDetail == RejectedStatusDetail.CALL_FOR_AUTH || self.paymentResult.statusDetail == RejectedStatusDetail.INSUFFICIENT_AMOUNT {
                return PXFooterResultConstants.C4AUTH_BUTTON_TEXT.localized
            } else if self.paymentResult.statusDetail == RejectedStatusDetail.CARD_DISABLE {
                return PXFooterResultConstants.CARD_DISABLE_BUTTON_TEXT.localized
            } else {
                return PXFooterResultConstants.WARNING_BUTTON_TEXT.localized
            }
        }
        return PXFooterResultConstants.DEFAULT_BUTTON_TEXT
    }

    func getLinkLabel() -> String? {
        if let label = preference.getExitButtonTitle() {
            return label
        }
        if paymentResult.isAccepted() {
           return PXFooterResultConstants.APPROVED_LINK_TEXT.PXLocalized
        } else if paymentResult.isError() {
            return PXFooterResultConstants.ERROR_LINK_TEXT.localized
        } else if paymentResult.isWarning() {
            if self.paymentResult.statusDetail == RejectedStatusDetail.CALL_FOR_AUTH || self.paymentResult.statusDetail == RejectedStatusDetail.INSUFFICIENT_AMOUNT {
                return PXFooterResultConstants.ERROR_LINK_TEXT.localized
            } else {
                return PXFooterResultConstants.WARNING_LINK_TEXT.localized
            }
        }
        return PXFooterResultConstants.DEFAULT_LINK_TEXT.localized
    }

    func getButtonAction() -> (() -> Void)? {
        if paymentResult.isAccepted() {
            if self.paymentResult.isWaitingForPayment() {
                if preference.getPendingSecondaryButtonCallback() != nil {
                    return { self.preference.getPendingSecondaryButtonCallback()!(self.paymentResult) }
                } else {
                    return nil
                }
            } else if preference.getApprovedSecondaryButtonCallback() != nil {
                return { self.preference.getApprovedSecondaryButtonCallback()!(self.paymentResult) }
            } else {
                return nil
            }
        }
        if (paymentResult.isWarning() || paymentResult.isError()) && preference.getRejectedSecondaryButtonCallback()  != nil {
            return { self.preference.getRejectedSecondaryButtonCallback()!(self.paymentResult)  }
        }
        return { self.pressButton() }
    }
    func getLinkAction() -> (() -> Void)? {
        return { self.pressLink() }
    }

    func pressButton() {
        if paymentResult.isAccepted() {
             self.callback(PaymentResult.CongratsState.approved)
        } else if paymentResult.isError() {
             self.callback(PaymentResult.CongratsState.cancel_SELECT_OTHER)
        } else if paymentResult.isWarning() {
            if self.paymentResult.statusDetail == RejectedStatusDetail.CALL_FOR_AUTH || self.paymentResult.statusDetail == RejectedStatusDetail.INSUFFICIENT_AMOUNT {
                self.callback(PaymentResult.CongratsState.cancel_SELECT_OTHER)
            } else {
                self.callback(PaymentResult.CongratsState.cancel_RETRY)
            }
        }
    }

    func pressLink() {
        if paymentResult.isAccepted() {
            self.callback(PaymentResult.CongratsState.approved)
        } else if paymentResult.isError() {
            self.callback(PaymentResult.CongratsState.approved) //
        } else if paymentResult.isWarning() {
            if self.paymentResult.statusDetail == RejectedStatusDetail.CALL_FOR_AUTH || self.paymentResult.statusDetail == RejectedStatusDetail.INSUFFICIENT_AMOUNT {
                self.callback(PaymentResult.CongratsState.approved)
            } else {
                self.callback(PaymentResult.CongratsState.cancel_SELECT_OTHER)
            }
        }
    }
}
