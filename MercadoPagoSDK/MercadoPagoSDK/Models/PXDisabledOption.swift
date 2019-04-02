//
//  PXActionTag.swift
//  MercadoPagoSDKV4
//
//  Created by Eden Torres on 27/08/2018.
//

import Foundation

class PXDisabledOption {

    var disabledCardId: String? = nil
    var disabledAccountMoney: Bool = false

    init(paymentResult: PaymentResult?) {
        if let paymentResult = paymentResult {
            if let cardId = paymentResult.cardId {
                disabledCardId = cardId
            }

            if paymentResult.paymentData?.getPaymentMethod()?.getId() == PXPaymentTypes.ACCOUNT_MONEY.rawValue {
                disabledAccountMoney = true
            }
        }
    }

    public func getDisabledCardId() -> String? {
        return disabledCardId
    }

    public func isAccountMoneyDisabled() -> Bool {
        return disabledAccountMoney
    }
}
