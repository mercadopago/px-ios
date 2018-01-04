//
//  PaymentVaultViewModel.swift
//  MercadoPagoSDK
//
//  Created by Valeria Serber on 6/12/17.
//  Copyright © 2017 MercadoPago. All rights reserved.
//

import Foundation

class PaymentVaultViewModel: NSObject {

    var groupName: String?

    var amount: Double
    var paymentPreference: PaymentPreference?
    var email: String

    var paymentMethodOptions: [PaymentMethodOption]
    var customerPaymentOptions: [CardInformation]?
    var paymentMethodPlugins = [PXPaymentMethodPlugin]()
    var paymentMethods: [PaymentMethod]!
    var defaultPaymentOption: PaymentMethodSearchItem?

    var displayItems = [PaymentOptionDrawable]()

    var discount: DiscountCoupon?

    var customerId: String?

    var couponCallback: ((DiscountCoupon) -> Void)?
    var mercadoPagoServicesAdapter: MercadoPagoServicesAdapter!

    internal var isRoot = true

    init(amount: Double, paymentPrefence: PaymentPreference?, paymentMethodOptions: [PaymentMethodOption], customerPaymentOptions: [CardInformation]?, paymentMethodPlugins: [PXPaymentMethodPlugin], groupName: String? = nil, isRoot: Bool, discount: DiscountCoupon? = nil, email: String, mercadoPagoServicesAdapter: MercadoPagoServicesAdapter, callbackCancel: (() -> Void)? = nil, couponCallback: ((DiscountCoupon) -> Void)? = nil) {
        self.amount = amount
        self.email = email
        self.groupName = groupName
        self.discount = discount
        self.paymentPreference = paymentPrefence
        self.paymentMethodOptions = paymentMethodOptions
        self.customerPaymentOptions = customerPaymentOptions
        self.paymentMethodPlugins = paymentMethodPlugins
        self.isRoot = isRoot
        self.couponCallback = couponCallback
        self.mercadoPagoServicesAdapter = mercadoPagoServicesAdapter

        super.init()
        self.populateDisplayItemsDrawable()
    }
}

// MARK: Logic
extension PaymentVaultViewModel {

    func hasPaymentMethodsPlugins() -> Bool {
        return isRoot && !paymentMethodPlugins.isEmpty
    }

    func shouldGetCustomerCardsInfo() -> Bool {
        return MercadoPagoCheckoutViewModel.servicePreference.isCustomerInfoAvailable() && self.isRoot
    }

    func hasAccountMoneyIn(customerOptions: [CardInformation]) -> Bool {
        for paymentOption: CardInformation in customerOptions {
            if paymentOption.getPaymentMethodId() == PaymentTypeId.ACCOUNT_MONEY.rawValue {
                return true
            }
        }
        return false
    }

    func hasOnlyGroupsPaymentMethodAvailable() -> Bool {
        return (self.paymentMethodOptions.count == 1 && Array.isNullOrEmpty(self.customerPaymentOptions))
    }

    func hasOnlyCustomerPaymentMethodAvailable() -> Bool {
        return Array.isNullOrEmpty(self.paymentMethodOptions) && !Array.isNullOrEmpty(self.customerPaymentOptions) && self.customerPaymentOptions?.count == 1
    }

    func getPaymentMethodOption(row: Int) -> PaymentOptionDrawable? {
        if displayItems.indices.contains(row) {
            return displayItems[row]
        }
        return nil
    }
}

// MARK: Drawable Builders
extension PaymentVaultViewModel {

    fileprivate func populateDisplayItemsDrawable() {

        var topPluginsDrawable = [PaymentOptionDrawable]()
        var bottomPluginsDrawable = [PaymentOptionDrawable]()
        var customerPaymentOptionsDrawable = [PaymentOptionDrawable]()
        var paymentOptionsDrawable = [PaymentOptionDrawable]()

        buildTopBottomPaymentPluginsAsDrawable(&topPluginsDrawable, &bottomPluginsDrawable)

        // Populate customer payment options.
        customerPaymentOptionsDrawable = buildCustomerPaymentOptionsAsDrawable()

        // Populate payment methods search items.
        paymentOptionsDrawable = buildPaymentMethodSearchItemsAsDrawable()

        // Fill displayItems
        displayItems.append(contentsOf: topPluginsDrawable)
        displayItems.append(contentsOf: customerPaymentOptionsDrawable)
        displayItems.append(contentsOf: paymentOptionsDrawable)
        displayItems.append(contentsOf: bottomPluginsDrawable)
    }

    fileprivate func buildTopBottomPaymentPluginsAsDrawable(_ topPluginsDrawable: inout [PaymentOptionDrawable], _ bottomPluginsDrawable: inout [PaymentOptionDrawable]) {
        // Populate payments methods plugins.
        if hasPaymentMethodsPlugins() {
            for plugin in paymentMethodPlugins {
                if plugin.displayOrder == .TOP {
                    topPluginsDrawable.append(plugin)
                } else {
                    bottomPluginsDrawable.append(plugin)
                }
            }
        }
    }

    fileprivate func buildCustomerPaymentOptionsAsDrawable() -> [PaymentOptionDrawable] {
        var returnDrawable = [PaymentOptionDrawable]()
        let customerPaymentMethodsCount = getCustomerPaymentMethodsToDisplayCount()
        if customerPaymentMethodsCount > 0 {
            for customerPaymentMethodIndex in 0...customerPaymentMethodsCount-1 {
                if let customerPaymentOptions = customerPaymentOptions, customerPaymentOptions.indices.contains(customerPaymentMethodIndex) {
                    let customerPaymentOption = customerPaymentOptions[customerPaymentMethodIndex]
                    returnDrawable.append(customerPaymentOption)
                }
            }
        }
        return returnDrawable
    }

    fileprivate func buildPaymentMethodSearchItemsAsDrawable() -> [PaymentOptionDrawable] {
        var returnDrawable = [PaymentOptionDrawable]()
        for targetPaymentMethodOption in paymentMethodOptions {
            if let targetPaymentOptionDrawable = targetPaymentMethodOption as? PaymentOptionDrawable {
                returnDrawable.append(targetPaymentOptionDrawable)
            }
        }
        return returnDrawable
    }
}

// MARK: Counters
extension PaymentVaultViewModel {

    func getPaymentMethodPluginCount() -> Int {
        if !Array.isNullOrEmpty(paymentMethodPlugins) && self.isRoot {
            return paymentMethodPlugins.count
        }
        return 0
    }

    func getDisplayedPaymentMethodsCount() -> Int {
        return displayItems.count
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
}
