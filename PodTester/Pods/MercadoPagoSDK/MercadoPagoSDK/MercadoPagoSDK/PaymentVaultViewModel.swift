//
//  PaymentVaultViewModel.swift
//  MercadoPagoSDK
//
//  Created by Valeria Serber on 6/12/17.
//  Copyright © 2017 MercadoPago. All rights reserved.
//

import Foundation
class PaymentVaultViewModel: NSObject {

    var amount: Double
    var paymentPreference: PaymentPreference?
    var email: String

    var paymentMethodOptions: [PaymentMethodOption]
    var customerPaymentOptions: [CardInformation]?
    var paymentMethods: [PaymentMethod]!
    var defaultPaymentOption: PaymentMethodSearchItem?
    // var cards : [Card]?

    var discount: DiscountCoupon?

    weak var controller: PaymentVaultViewController?

    var customerId: String?

    var callback : ((_ paymentMethod: PaymentMethod, _ token: Token?, _ issuer: Issuer?, _ payerCost: PayerCost?) -> Void)!
    var callbackCancel: (() -> Void)?
    var couponCallback: ((DiscountCoupon) -> Void)?

    internal var isRoot = true

    init(amount: Double, paymentPrefence: PaymentPreference?, paymentMethodOptions: [PaymentMethodOption], customerPaymentOptions: [CardInformation]?, isRoot: Bool, discount: DiscountCoupon? = nil, email: String, callbackCancel: (() -> Void)? = nil, couponCallback: ((DiscountCoupon) -> Void)? = nil) {
        self.amount = amount
        self.email = email
        self.discount = discount
        self.paymentPreference = paymentPrefence
        self.paymentMethodOptions = paymentMethodOptions
        self.customerPaymentOptions = customerPaymentOptions
        self.isRoot = isRoot
        self.couponCallback = couponCallback
    }

    func shouldGetCustomerCardsInfo() -> Bool {
        return MercadoPagoCheckoutViewModel.servicePreference.isCustomerInfoAvailable() && self.isRoot
    }

    func getCustomerPaymentMethodsToDisplayCount() -> Int {
        if !Array.isNullOrEmpty(customerPaymentOptions) && self.isRoot {
            let realCount = self.customerPaymentOptions!.count

            if MercadoPagoCheckoutViewModel.flowPreference.isShowAllSavedCardsEnabled() {
                return realCount
            } else {
                var maxChosenCount = MercadoPagoCheckoutViewModel.flowPreference.getMaxSavedCardsToShow()
                let hasAccountMoney = hasAccountMoneyIn(customerOptions: self.customerPaymentOptions!)
                if hasAccountMoney {
                    maxChosenCount += 1
                }
                return (realCount <= maxChosenCount ? realCount : maxChosenCount)
            }
        }
        return 0
    }

    func hasAccountMoneyIn(customerOptions: [CardInformation]) -> Bool {
        for paymentOption: CardInformation in customerOptions {
            if paymentOption.getPaymentMethodId() == PaymentTypeId.ACCOUNT_MONEY.rawValue {
                return true
            }
        }
        return false
    }

    func getPaymentMethodOption(row: Int) -> PaymentOptionDrawable {
        if self.getCustomerPaymentMethodsToDisplayCount() > row {
            return self.customerPaymentOptions![row]
        }
        let indexInPaymentMethods = Array.isNullOrEmpty(self.customerPaymentOptions) ? row : (row - self.getCustomerPaymentMethodsToDisplayCount())
        return self.paymentMethodOptions[indexInPaymentMethods] as! PaymentOptionDrawable
    }

    func getDisplayedPaymentMethodsCount() -> Int {
        let currentPaymentMethodSearchCount = self.paymentMethodOptions.count
        return self.getCustomerPaymentMethodsToDisplayCount() + currentPaymentMethodSearchCount
    }

    //    func getCustomerCardRowHeight() -> CGFloat {
    //        return self.getCustomerPaymentMethodsToDisplayCount() > 0 ? CustomerPaymentMethodCell.ROW_HEIGHT : 0
    //    }

    func getExcludedPaymentTypeIds() -> Set<String>? {
        return (self.paymentPreference != nil) ? self.paymentPreference!.excludedPaymentTypeIds : nil
    }

    func getExcludedPaymentMethodIds() -> Set<String>? {
        return (self.paymentPreference != nil) ? self.paymentPreference!.excludedPaymentMethodIds : nil
    }

    func getPaymentPreferenceDefaultPaymentMethodId() -> String? {
        return (self.paymentPreference != nil) ? self.paymentPreference!.defaultPaymentMethodId : nil
    }

    func isCustomerPaymentMethodOptionSelected(_ row: Int) -> Bool {
        if Array.isNullOrEmpty(self.customerPaymentOptions) {
            return false
        }
        return (row < self.getCustomerPaymentMethodsToDisplayCount())
    }

    func hasOnlyGroupsPaymentMethodAvailable() -> Bool {
        return (self.paymentMethodOptions.count == 1 && Array.isNullOrEmpty(self.customerPaymentOptions))
    }

    func hasOnlyCustomerPaymentMethodAvailable() -> Bool {
        return Array.isNullOrEmpty(self.paymentMethodOptions) && !Array.isNullOrEmpty(self.customerPaymentOptions) && self.customerPaymentOptions?.count == 1
    }

}
