//
//  PXBodyComponent.swift
//  TestAutolayout
//
//  Created by Demian Tejo on 10/19/17.
//  Copyright © 2017 Demian Tejo. All rights reserved.
//

import UIKit

internal class PXBodyComponent: PXComponentizable {
    var props: PXBodyProps

    init(props: PXBodyProps) {
        self.props = props
    }

    func hasInstructions() -> Bool {
        return props.instruction != nil
    }

    func getInstructionsComponent() -> PXInstructionsComponent? {
        if let instruction = props.instruction {
            let instructionsProps = PXInstructionsProps(instruction: instruction)
            let instructionsComponent = PXInstructionsComponent(props: instructionsProps)
            return instructionsComponent
        }
        return nil
    }

    func hasBodyError() -> Bool {
        return isPendingWithBody() || isRejectedWithBody()
    }

    func getBodyErrorComponent() -> PXErrorComponent {
        let status = props.paymentResult.status
        let statusDetail = props.paymentResult.statusDetail
        let amount = props.paymentResult.paymentData?.payerCost?.totalAmount ?? props.amountHelper.amountToPay
        let paymentMethodName = props.paymentResult.paymentData?.paymentMethod?.name

        let title = getErrorTitle(status: status, statusDetail: statusDetail)
        let message = getErrorMessage(status: status,
                                      statusDetail: statusDetail,
                                      amount: amount,
                                      paymentMethodName: paymentMethodName)

        let errorProps = PXErrorProps(title: title.toAttributedString(), message: message?.toAttributedString(), secondaryTitle: nil, action: nil)
        let errorComponent = PXErrorComponent(props: errorProps)
        return errorComponent
    }

    func getErrorTitle(status: String, statusDetail: String) -> String {
        if status == PXPayment.Status.REJECTED &&
            statusDetail == PXPayment.StatusDetails.REJECTED_CALL_FOR_AUTHORIZE {
            return PXResourceProvider.getTitleForCallForAuth()
        }
        return PXResourceProvider.getTitleForErrorBody()
    }

    func getErrorMessage(status: String, statusDetail: String, amount: Double, paymentMethodName: String?) -> String? {
        if status == PXPayment.Status.PENDING || status == PXPayment.Status.IN_PROCESS {
            switch statusDetail {
            case PXPayment.StatusDetails.PENDING_CONTINGENCY:
                return PXResourceProvider.getDescriptionForErrorBodyForPENDING_CONTINGENCY()
            case PXPayment.StatusDetails.PENDING_REVIEW_MANUAL:
                return PXResourceProvider.getDescriptionForErrorBodyForPENDING_REVIEW_MANUAL()
            default:
                return nil
            }
        } else if status == PXPayment.Status.REJECTED {
            switch statusDetail {
            case PXPayment.StatusDetails.REJECTED_CALL_FOR_AUTHORIZE:
                return PXResourceProvider.getDescriptionForErrorBodyForREJECTED_CALL_FOR_AUTHORIZE(amount)
            case PXPayment.StatusDetails.REJECTED_CARD_DISABLED:
                return PXResourceProvider.getDescriptionForErrorBodyForREJECTED_CARD_DISABLED(paymentMethodName)
            case PXPayment.StatusDetails.REJECTED_INSUFFICIENT_AMOUNT:
                return PXResourceProvider.getDescriptionForErrorBodyForREJECTED_INSUFFICIENT_AMOUNT()
            case PXPayment.StatusDetails.REJECTED_OTHER_REASON:
                return PXResourceProvider.getDescriptionForErrorBodyForREJECTED_OTHER_REASON()
            case PXPayment.StatusDetails.REJECTED_BY_BANK:
                return PXResourceProvider.getDescriptionForErrorBodyForREJECTED_BY_BANK()
            case PXPayment.StatusDetails.REJECTED_INSUFFICIENT_DATA:
                return PXResourceProvider.getDescriptionForErrorBodyForREJECTED_INSUFFICIENT_DATA()
            case PXPayment.StatusDetails.REJECTED_DUPLICATED_PAYMENT:
                return PXResourceProvider.getDescriptionForErrorBodyForREJECTED_DUPLICATED_PAYMENT()
            case PXPayment.StatusDetails.REJECTED_MAX_ATTEMPTS:
                return PXResourceProvider.getDescriptionForErrorBodyForREJECTED_MAX_ATTEMPTS()
            case PXPayment.StatusDetails.REJECTED_HIGH_RISK:
                return PXResourceProvider.getDescriptionForErrorBodyForREJECTED_HIGH_RISK()
            case PXPayment.StatusDetails.REJECTED_CARD_HIGH_RISK:
                return PXResourceProvider.getDescriptionForErrorBodyForREJECTED_CARD_HIGH_RISK()
            case PXPayment.StatusDetails.REJECTED_BY_REGULATIONS:
                return PXResourceProvider.getDescriptionForErrorBodyForREJECTED_BY_REGULATIONS()
            case PXPayment.StatusDetails.REJECTED_INVALID_INSTALLMENTS:
                return PXResourceProvider.getDescriptionForErrorBodyForREJECTED_INVALID_INSTALLMENTS()
            default:
                return nil
            }
        }
        return nil
    }

    func isPendingWithBody() -> Bool {
        let hasPendingStatus = props.paymentResult.status == PXPayment.Status.PENDING || props.paymentResult.status == PXPayment.Status.IN_PROCESS
        let statusDetails = [PXPayment.StatusDetails.PENDING_CONTINGENCY,
                             PXPayment.StatusDetails.PENDING_REVIEW_MANUAL]

        return hasPendingStatus && statusDetails.contains(props.paymentResult.statusDetail)
    }

    func isRejectedWithBody() -> Bool {
        let statusDetails = [PXPayment.StatusDetails.REJECTED_CALL_FOR_AUTHORIZE,
                             PXPayment.StatusDetails.REJECTED_CARD_DISABLED,
                             PXPayment.StatusDetails.REJECTED_INVALID_INSTALLMENTS,
                             PXPayment.StatusDetails.REJECTED_DUPLICATED_PAYMENT,
                             PXPayment.StatusDetails.REJECTED_INSUFFICIENT_AMOUNT,
                             PXPayment.StatusDetails.REJECTED_MAX_ATTEMPTS,
                             PXPayment.StatusDetails.REJECTED_BY_REGULATIONS]

        return props.paymentResult.status == PXPayment.Status.REJECTED && statusDetails.contains(props.paymentResult.statusDetail)
    }

    func render() -> UIView {
        return PXBodyRenderer().render(self)
    }

}

internal class PXBodyProps {
    let paymentResult: PaymentResult
    let instruction: PXInstruction?
    let amountHelper: PXAmountHelper

    init(paymentResult: PaymentResult, amountHelper: PXAmountHelper, instruction: PXInstruction?) {
        self.paymentResult = paymentResult
        self.instruction = instruction
        self.amountHelper = amountHelper
    }
}
