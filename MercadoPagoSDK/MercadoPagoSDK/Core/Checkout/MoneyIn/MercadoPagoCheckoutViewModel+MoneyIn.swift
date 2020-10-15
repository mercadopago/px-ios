//
//  MercadoPagoCheckoutViewModel+MoneyIn.swift
//  MercadoPagoSDK
//
//  Created by Juan sebastian Sanzone on 2/8/18.
//  Copyright © 2018 MercadoPago. All rights reserved.
//

import Foundation

// MARK: - MoneyIn "ChoExpress"
extension MercadoPagoCheckoutViewModel {
    internal func getPreferenceDefaultPaymentOption() -> PaymentMethodOption? {
        guard let cardId = amountHelper.preference.paymentPreference.cardId else {
            return nil
        }

        amountHelper.preference.clearCardId()

        if let options = self.paymentMethodOptions {
            let optionsFound = options.filter { (paymentMethodOption: PaymentMethodOption) -> Bool in
                return paymentMethodOption.getId() == cardId
            }
            if let paymentOption = optionsFound.first {
                return paymentOption
            }
        }

        if self.search != nil {
            guard let customerPaymentMethods = customPaymentOptions else {
                return nil
            }
            return customerPaymentMethods.first(where: { return $0.getCardId() == cardId })
        }

        return nil
    }
}
