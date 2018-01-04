//
//  PXBodyComponent.swift
//  TestAutolayout
//
//  Created by Demian Tejo on 10/19/17.
//  Copyright © 2017 Demian Tejo. All rights reserved.
//

import UIKit
import MercadoPagoServices

open class PXBodyComponent: NSObject, PXComponentizable {

    let rejectedStatusDetailsWithBody = [PXPayment.StatusDetails.REJECTED_OTHER_REASON, PXPayment.StatusDetails.REJECTED_BY_BANK, PXPayment.StatusDetails.REJECTED_INSUFFICIENT_DATA, PXPayment.StatusDetails.REJECTED_DUPLICATED_PAYMENT, PXPayment.StatusDetails.REJECTED_MAX_ATTEMPTS, PXPayment.StatusDetails.REJECTED_HIGH_RISK, PXPayment.StatusDetails.REJECTED_CALL_FOR_AUTHORIZE, PXPayment.StatusDetails.REJECTED_CARD_DISABLED, PXPayment.StatusDetails.REJECTED_INSUFFICIENT_AMOUNT]

    let pendingStatusDetailsWithBody = [PXPayment.StatusDetails.PENDING_CONTINGENCY, PXPayment.StatusDetails.PENDING_REVIEW_MANUAL]

    var props: PXBodyProps

    init(props: PXBodyProps) {
        self.props = props
    }

    public func hasInstructions() -> Bool {
        return props.instruction != nil
    }

    public func getInstructionsComponent() -> PXInstructionsComponent? {
        if let instruction = props.instruction {
            let instructionsProps = PXInstructionsProps(instruction: instruction)
            let instructionsComponent = PXInstructionsComponent(props: instructionsProps)
            return instructionsComponent
        }
        return nil
    }

    fileprivate func getPaymentMethodIcon(paymentMethod: PaymentMethod) -> UIImage? {
        let defaultColor = paymentMethod.paymentTypeId == PaymentTypeId.ACCOUNT_MONEY.rawValue
        var paymentMethodImage: UIImage? =  MercadoPago.getImageForPaymentMethod(withDescription: paymentMethod._id, defaultColor: defaultColor)
        // Retrieve image for payment plugin or any external payment method.
        if paymentMethod.paymentTypeId == PaymentTypeId.PAYMENT_METHOD_PLUGIN.rawValue {
            paymentMethodImage = paymentMethod.getImageForExtenalPaymentMethod()
        }
        return paymentMethodImage
    }

    public func getPaymentMethodComponent() -> PXPaymentMethodComponent {
        let pm = self.props.paymentResult.paymentData!.paymentMethod!

        let image = getPaymentMethodIcon(paymentMethod: pm)
        let currency = MercadoPagoContext.getCurrency()
        var amountTitle = Utils.getAmountFormated(amount: self.props.amount, forCurrency: currency)
        var amountDetail: String?
        if let payerCost = self.props.paymentResult.paymentData?.payerCost {
            if payerCost.installments > 1 {
                amountTitle = String(payerCost.installments) + "x " + Utils.getAmountFormated(amount: payerCost.installmentAmount, forCurrency: currency)
                amountDetail = Utils.getAmountFormated(amount: payerCost.totalAmount, forCurrency: currency, addingParenthesis: true)
            }
        }
        var issuerName: String?
        var pmDescription: String = ""
        let paymentMethodName = pm.name ?? ""

        if pm.isCard {
            issuerName = self.props.paymentResult.paymentData?.issuer?.name
            if let lastFourDigits = (self.props.paymentResult.paymentData?.token?.lastFourDigits) {
                pmDescription = paymentMethodName + " " + "terminada en ".localized + lastFourDigits
            }
        } else {
            pmDescription = paymentMethodName
        }

        var disclaimerText: String? = nil
        if let statementDescription = self.props.paymentResult.statementDescription {
            disclaimerText =  ("En tu estado de cuenta verás el cargo como %0".localized as NSString).replacingOccurrences(of: "%0", with: "\(statementDescription)")
        }

        let bodyProps = PXPaymentMethodProps(paymentMethodIcon: image, amountTitle: amountTitle, amountDetail: amountDetail, paymentMethodDescription: pmDescription, paymentMethodDetail: issuerName, disclaimer: disclaimerText)

        return PXPaymentMethodComponent(props: bodyProps)
    }

    public func hasBodyError() -> Bool {
        return isPendingWithBody() || isRejectedWithBody()
    }

    public func getBodyErrorComponent() -> PXErrorComponent {
        let status = props.paymentResult.status
        let statusDetail = props.paymentResult.statusDetail
        let paymentMethodName = props.paymentResult.paymentData?.paymentMethod?.name
        let errorProps = PXErrorProps(status: status, statusDetail: statusDetail, paymentMethodName: paymentMethodName, action: getCallback())
        let errorComponent = PXErrorComponent(props: errorProps)
        return errorComponent
    }

    public func isPendingWithBody() -> Bool {
        let hasPendingStatus = props.paymentResult.status.elementsEqual(PXPayment.Status.PENDING) || props.paymentResult.status.elementsEqual(PXPayment.Status.IN_PROCESS)
        return hasPendingStatus && pendingStatusDetailsWithBody.contains(props.paymentResult.statusDetail)
    }

    public func isRejectedWithBody() -> Bool {
        return props.paymentResult.status.elementsEqual(PXPayment.Status.REJECTED) && rejectedStatusDetailsWithBody.contains(props.paymentResult.statusDetail)
    }

    func getCallback() -> (() -> Void) {
        return { self.executeCallback() }
    }

    func executeCallback() {
        self.props.callback()
    }

    public func render() -> UIView {
        return PXBodyRenderer().render(self)
    }

}

open class PXBodyProps: NSObject {
    var paymentResult: PaymentResult
    var instruction: Instruction?
    var amount: Double
    var callback : (() -> Void)
    init(paymentResult: PaymentResult, amount: Double, instruction: Instruction?, callback:  @escaping (() -> Void)) {
        self.paymentResult = paymentResult
        self.instruction = instruction
        self.amount = amount
        self.callback = callback
    }
}
