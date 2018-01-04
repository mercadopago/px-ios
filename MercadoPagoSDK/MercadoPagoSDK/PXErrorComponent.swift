//
//  PXErrorComponent.swift
//  MercadoPagoSDK
//
//  Created by AUGUSTO COLLERONE ALFONSO on 12/4/17.
//  Copyright © 2017 MercadoPago. All rights reserved.
//

import UIKit
import MercadoPagoServices

public class PXErrorComponent: NSObject, PXComponentizable {
    var props: PXErrorProps

    init(props: PXErrorProps) {
        self.props = props
    }
    public func render() -> UIView {
        return PXErrorRenderer().render(component: self)
    }

    public func getTitle() -> String {
        return PXResourceProvider.getTitleForErrorBody()
    }

    public func getDescription() -> String {
        if self.props.status.elementsEqual(PXPayment.Status.PENDING) || self.props.status.elementsEqual(PXPayment.Status.IN_PROCESS) {
            if self.props.statusDetail.elementsEqual(PXPayment.StatusDetails.PENDING_CONTINGENCY) {
                return PXResourceProvider.getDescriptionForErrorBodyForPENDING_CONTINGENCY()
            } else if self.props.statusDetail.elementsEqual(PXPayment.StatusDetails.PENDING_REVIEW_MANUAL) {
                return PXResourceProvider.getDescriptionForErrorBodyForPENDING_REVIEW_MANUAL()
            }
        } else if self.props.status.elementsEqual(PXPayment.Status.REJECTED) {
            if self.props.statusDetail.elementsEqual(PXPayment.StatusDetails.REJECTED_CALL_FOR_AUTHORIZE) {
                return PXResourceProvider.getDescriptionForErrorBodyForREJECTED_CALL_FOR_AUTHORIZE()
            } else if self.props.statusDetail.elementsEqual(PXPayment.StatusDetails.REJECTED_CARD_DISABLED) {
                return PXResourceProvider.getDescriptionForErrorBodyForREJECTED_CARD_DISABLED(self.props.paymentMethodName)
            } else if self.props.statusDetail.elementsEqual(PXPayment.StatusDetails.REJECTED_INSUFFICIENT_AMOUNT) {
                return PXResourceProvider.getDescriptionForErrorBodyForREJECTED_INSUFFICIENT_AMOUNT()
            } else if self.props.statusDetail.elementsEqual(PXPayment.StatusDetails.REJECTED_OTHER_REASON) {
                return PXResourceProvider.getDescriptionForErrorBodyForREJECTED_OTHER_REASON()
            } else if self.props.statusDetail.elementsEqual(PXPayment.StatusDetails.REJECTED_BY_BANK) {
                return PXResourceProvider.getDescriptionForErrorBodyForREJECTED_BY_BANK()
            } else if self.props.statusDetail.elementsEqual(PXPayment.StatusDetails.REJECTED_INSUFFICIENT_DATA) {
                return PXResourceProvider.getDescriptionForErrorBodyForREJECTED_INSUFFICIENT_DATA()
            } else if self.props.statusDetail.elementsEqual(PXPayment.StatusDetails.REJECTED_DUPLICATED_PAYMENT) {
                return PXResourceProvider.getDescriptionForErrorBodyForREJECTED_DUPLICATED_PAYMENT()
            } else if self.props.statusDetail.elementsEqual(PXPayment.StatusDetails.REJECTED_MAX_ATTEMPTS) {
                return PXResourceProvider.getDescriptionForErrorBodyForREJECTED_MAX_ATTEMPTS()
            } else if self.props.statusDetail.elementsEqual(PXPayment.StatusDetails.REJECTED_HIGH_RISK) {
                return PXResourceProvider.getDescriptionForErrorBodyForREJECTED_HIGH_RISK()
            }
        }
        return ""
    }

    public func getActionText() -> String {
        return PXResourceProvider.getActionTextForErrorBodyForREJECTED_CALL_FOR_AUTHORIZE(self.props.paymentMethodName)
    }

    public func getSecondaryTitleForCallForAuth() -> String {
        return PXResourceProvider.getSecondaryTitleForErrorBodyForREJECTED_CALL_FOR_AUTHORIZE()
    }

    public func isCallForAuthorize() -> Bool {
        return props.status.elementsEqual(PXPayment.Status.REJECTED) && props.statusDetail.elementsEqual(PXPayment.StatusDetails.REJECTED_CALL_FOR_AUTHORIZE)
    }

    public func hasTitle() -> Bool {
        return !self.props.statusDetail.elementsEqual(PXPayment.StatusDetails.REJECTED_DUPLICATED_PAYMENT)
    }

    public func hasActionForCallForAuth() -> Bool {
        return isCallForAuthorize() && !String.isNullOrEmpty(props.paymentMethodName)
    }

    public func recoverPayment() {
        self.props.action()
    }
}

class PXErrorProps: NSObject {
    var status: String
    var statusDetail: String
    var paymentMethodName: String?
    var action : (() -> Void)

    init(status: String, statusDetail: String, paymentMethodName: String?, action:  @escaping (() -> Void)) {
        self.status = status
        self.statusDetail = statusDetail
        self.paymentMethodName = paymentMethodName
        self.action = action
    }
}
