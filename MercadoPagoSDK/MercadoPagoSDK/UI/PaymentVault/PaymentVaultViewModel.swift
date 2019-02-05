//
//  PaymentVaultViewModel.swift
//  MercadoPagoSDK
//
//  Created by Valeria Serber on 6/12/17.
//  Copyright © 2017 MercadoPago. All rights reserved.
//

import Foundation

class PaymentVaultViewModel: NSObject {

    internal var amountHelper: PXAmountHelper
    var groupName: String?
    var email: String
    var paymentMethodOptions: [PaymentMethodOption]
    var customerPaymentOptions: [PXCardInformation]?
    var paymentMethodPlugins = [PXPaymentMethodPlugin]()
    var paymentMethods: [PXPaymentMethod]!
    var defaultPaymentOption: PXPaymentMethodSearchItem?

    var displayItems = [PaymentOptionDrawable]()
    var currency: PXCurrency = SiteManager.shared.getCurrency()

    var customerId: String?

    var mercadoPagoServicesAdapter: MercadoPagoServicesAdapter!

    let advancedConfiguration: PXAdvancedConfiguration
    
    internal var isRoot = true

    init(amountHelper: PXAmountHelper, paymentMethodOptions: [PaymentMethodOption], customerPaymentOptions: [PXCardInformation]?, paymentMethodPlugins: [PXPaymentMethodPlugin], paymentMethods: [PXPaymentMethod], groupName: String? = nil, isRoot: Bool, email: String, mercadoPagoServicesAdapter: MercadoPagoServicesAdapter, callbackCancel: (() -> Void)? = nil, advancedConfiguration: PXAdvancedConfiguration) {
        self.amountHelper = amountHelper
        self.email = email
        self.groupName = groupName
        self.paymentMethodOptions = paymentMethodOptions
        self.customerPaymentOptions = customerPaymentOptions
        self.paymentMethodPlugins = paymentMethodPlugins
        self.paymentMethods = paymentMethods
        self.isRoot = isRoot
        self.mercadoPagoServicesAdapter = mercadoPagoServicesAdapter
        self.advancedConfiguration = advancedConfiguration
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
       return false
    }

    func hasAccountMoneyIn(customerOptions: [PXCardInformation]) -> Bool {
        for paymentOption: PXCardInformation in customerOptions {
            if paymentOption.getPaymentMethodId() == PXPaymentTypes.ACCOUNT_MONEY.rawValue {
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

    func getDiscountInfo(row: Int) -> String? {
        if let paymentOption = getPaymentMethodOption(row: row) {
            return amountHelper.paymentConfigurationService.getDiscountInfoForPaymentMethod(paymentOption.getId())
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
            guard let realCount = self.customerPaymentOptions?.count else {
                return 0
            }
            return realCount
        }
        return 0
    }
}
