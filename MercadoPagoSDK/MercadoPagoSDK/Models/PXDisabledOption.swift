//
//  PXDisabledOption.swift
//  MercadoPagoSDKV4
//
//  Created by Eden Torres on 27/08/2018.
//

import Foundation

internal struct PXDisabledOption {

    private var disabledCardId: String?
    private var disabledAccountMoney: Bool = false

    init(paymentResult: PaymentResult?) {
        if let paymentResult = paymentResult {
            if let cardId = paymentResult.cardId,
                paymentResult.statusDetail == PXPayment.StatusDetails.REJECTED_CARD_HIGH_RISK ||
                    paymentResult.statusDetail == PXPayment.StatusDetails.REJECTED_BLACKLIST {
                disabledCardId = cardId
            }

            if paymentResult.paymentData?.getPaymentMethod()?.isAccountMoney ?? false,
                paymentResult.statusDetail == PXPayment.StatusDetails.REJECTED_HIGH_RISK {
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
