//
//  MercadoPagoCheckoutViewModel+Plugins.swift
//  MercadoPagoSDK
//
//  Created by Eden Torres on 12/14/17.
//  Copyright © 2017 MercadoPago. All rights reserved.
//

import Foundation
extension MercadoPagoCheckoutViewModel {

    func needToShowPaymentMethodConfigPlugin() -> Bool {
        guard let paymentMethodPluginSelected = paymentOptionSelected as? PXPaymentMethodPlugin else {
            return false
        }

        _ = copyViewModelAndAssignToCheckoutStore()

        if let shouldSkip = paymentMethodPluginSelected.paymentMethodConfigPlugin?.shouldSkip?(pluginStore: PXCheckoutStore.sharedInstance), shouldSkip {
            willShowPaymentMethodConfigPlugin()
            return false
        }

        if  wasPaymentMethodConfigPluginShowed() {
            return false
        }

        return paymentMethodPluginSelected.paymentMethodConfigPlugin != nil
    }

    func needToCreatePaymentForPaymentMethodPlugin() -> Bool {
        return needToCreatePayment() && self.paymentOptionSelected is PXPaymentMethodPlugin
    }

    func wasPaymentMethodConfigPluginShowed() -> Bool {
        return paymentMethodConfigPluginShowed
    }

    func willShowPaymentMethodConfigPlugin() {
        paymentMethodConfigPluginShowed = true
    }

    func resetPaymentMethodConfigPlugin() {
        paymentMethodConfigPluginShowed = false
    }

    public func paymentMethodPluginToPaymentMethod(plugin: PXPaymentMethodPlugin) {
        let paymentMethod = PaymentMethod()
        paymentMethod._id = plugin.getId()
        paymentMethod.name = plugin.getTitle()
        paymentMethod.paymentTypeId = PXPaymentMethodPlugin.PAYMENT_METHOD_TYPE_ID
        paymentMethod.setExternalPaymentMethodImage(externalImage: plugin.getImage())
        self.paymentData.paymentMethod = paymentMethod
    }
}

// MARK: Payment Plugin
extension MercadoPagoCheckoutViewModel {
    func needToCreatePaymentForPaymentPlugin() -> Bool {
        guard let _ = paymentPlugin else {
            return false
        }

        _ = copyViewModelAndAssignToCheckoutStore()

        if let shouldSkip = paymentPlugin?.support?(pluginStore: PXCheckoutStore.sharedInstance), !shouldSkip {
            return false
        }

        return needToCreatePayment()
    }

    func needToInitPaymentMethodPlugins() -> Bool {
        if paymentMethodPlugins.isEmpty {
            return false
        }
        return needPaymentMethodPluginInit
    }
}
