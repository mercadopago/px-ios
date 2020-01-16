//
//  PXReceiptViewModelHelper.swift
//  MercadoPagoSDK
//
//  Created by Eden Torres on 1/5/18.
//  Copyright © 2018 MercadoPago. All rights reserved.
//

import Foundation

internal extension PXResultViewModel {
    func getReceiptComponentProps() -> PXReceiptProps? {
        if hasReceiptComponent() {
            let date = Date()
            guard let paymentId = self.paymentResult.paymentId else {
                return PXReceiptProps()
            }
            return PXReceiptProps(dateLabelString: Utils.getFormatedStringDate(date), receiptDescriptionString: String(format: "Operación #{0}".localized, paymentId).replacingOccurrences(of: "{0}", with: paymentId))
        } else {
            return nil
        }
    }

    func hasReceiptComponent() -> Bool {
        if self.paymentResult.paymentId == nil {
            return false
        }
        if paymentResult.isApproved() {
            let isPaymentMethodPlugin = self.paymentResult.paymentData?.getPaymentMethod()?.paymentTypeId == PXPaymentTypes.PAYMENT_METHOD_PLUGIN.rawValue

            if isPaymentMethodPlugin {
                let hasReceiptId = !String.isNullOrEmpty(self.paymentResult.paymentId)
                if hasReceiptId {
                    return true
                }
            } else if !self.preference.isPaymentIdDisable() {
                return true
            }
        }
        return false
    }

    func buildReceiptComponent() -> PXReceiptComponent? {
        guard let receiptProps = getReceiptComponentProps() else {
            return nil
        }
        return PXReceiptComponent(props: receiptProps)
    }
}
