//
//  PXReceiptViewModelHelper.swift
//  MercadoPagoSDK
//
//  Created by Eden Torres on 1/5/18.
//  Copyright © 2018 MercadoPago. All rights reserved.
//

import Foundation

extension PXResultViewModel {
    open func getReceiptComponentProps() -> PXReceiptProps {
        if hasReceiptComponent() {
            let date = Date()
            guard let paymentId = self.paymentResult.paymentId else {
                return PXReceiptProps()
            }
            return PXReceiptProps(dateLabelString: Utils.getFormatedStringDate(date), receiptDescriptionString: "Número de operación ".localized + paymentId)
        } else {
            return PXReceiptProps()
        }
    }

    open func hasReceiptComponent() -> Bool {
        if self.paymentResult.paymentId == nil {
            return false
        }
        if paymentResult.isApproved() {
            let isPaymentMethodPlugin = self.paymentResult.paymentData?.getPaymentMethod()?.paymentTypeId == PaymentTypeId.PAYMENT_METHOD_PLUGIN.rawValue

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
        let receiptProps = getReceiptComponentProps()
        return PXReceiptComponent(props: receiptProps)
    }
}
