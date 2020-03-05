//
//  PXRemedyComponent.swift
//  MercadoPagoSDK
//
//  Created by Eric Ertl on 05/03/2020.
//

import Foundation

internal class PXRemedyComponent: PXComponentizable {
var props: PXRemedyProps

    init(props: PXRemedyProps) {
        self.props = props
    }

    func hasRemedyError() -> Bool {
        return isRejectedWithBadFilledSecurityCode()
    }

    func getTextFieldRemedyComponent() -> PXTextFieldRemedyComponent {
        let status = props.paymentResult.status
        let statusDetail = props.paymentResult.statusDetail
        let amount = props.paymentResult.paymentData?.payerCost?.totalAmount ?? props.amountHelper.amountToPay
        let paymentMethodName = props.paymentResult.paymentData?.paymentMethod?.name

        let title = getErrorTitle(status: status, statusDetail: statusDetail)
        let message = getErrorMessage(status: status,
                                      statusDetail: statusDetail,
                                      amount: amount,
                                      paymentMethodName: paymentMethodName)

        let errorProps = PXTextFieldRemedyProps(title: title, message: message?.toAttributedString(), secondaryTitle: nil, action: nil)
        let errorComponent = PXTextFieldRemedyComponent(props: errorProps)
        return errorComponent
    }

    private func getErrorTitle(status: String, statusDetail: String) -> NSAttributedString? {
        var errorTitle: String?
        if status == PXPayment.Status.REJECTED {
            switch statusDetail {
            case PXPayment.StatusDetails.REJECTED_CALL_FOR_AUTHORIZE:
                errorTitle = PXResourceProvider.getTitleForCallForAuth()
            case PXPayment.StatusDetails.REJECTED_BAD_FILLED_SECURITY_CODE:
                break
            default:
                errorTitle = PXResourceProvider.getTitleForErrorBody()
            }
        }
        return errorTitle?.toAttributedString()
    }

    private func getErrorMessage(status: String, statusDetail: String, amount: Double, paymentMethodName: String?) -> String? {
        if status == PXPayment.Status.REJECTED {
            switch statusDetail {
            case PXPayment.StatusDetails.REJECTED_CALL_FOR_AUTHORIZE:
                return PXResourceProvider.getDescriptionForErrorBodyForREJECTED_CALL_FOR_AUTHORIZE(amount)
            case PXPayment.StatusDetails.REJECTED_BAD_FILLED_SECURITY_CODE:
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

    func isRejectedWithBadFilledSecurityCode() -> Bool {
        let statusDetails = [PXPayment.StatusDetails.REJECTED_BAD_FILLED_SECURITY_CODE]

        return props.paymentResult.status == PXPayment.Status.REJECTED && statusDetails.contains(props.paymentResult.statusDetail)
    }

    func render() -> UIView {
        return PXRemedyRenderer().render(self)
    }
}

internal class PXRemedyProps {
    let paymentResult: PaymentResult
    let amountHelper: PXAmountHelper

    init(paymentResult: PaymentResult, amountHelper: PXAmountHelper) {
        self.paymentResult = paymentResult
        self.amountHelper = amountHelper
    }
}
