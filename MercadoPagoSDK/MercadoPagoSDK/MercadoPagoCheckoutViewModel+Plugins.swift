//
//  MercadoPagoCheckoutViewModel+Plugins.swift
//  MercadoPagoSDK
//
//  Created by Eden Torres on 12/14/17.
//  Copyright © 2017 MercadoPago. All rights reserved.
//

import Foundation

/** :nodoc: */
extension MercadoPagoCheckoutViewModel {

    func needToShowPaymentMethodConfigPlugin() -> Bool {
        guard let paymentMethodPluginSelected = paymentOptionSelected as? PXPaymentMethodPlugin else {
            return false
        }

        populateCheckoutStore()

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
        paymentMethod.paymentMethodId = plugin.getId()
        paymentMethod.name = plugin.getTitle()
        paymentMethod.paymentTypeId = PXPaymentMethodPlugin.PAYMENT_METHOD_TYPE_ID
        paymentMethod.setExternalPaymentMethodImage(externalImage: plugin.getImage())
        paymentMethod.paymentMethodDescription = plugin.paymentMethodPluginDescription
        self.paymentData.paymentMethod = paymentMethod
    }
}

/** :nodoc: */
// MARK: Payment Plugin
extension MercadoPagoCheckoutViewModel {
    func needToCreatePaymentForPaymentPlugin() -> Bool {
        if paymentPlugin == nil {
            return false
        }

        populateCheckoutStore()

        if let shouldSkip = paymentPlugin?.support?(pluginStore: PXCheckoutStore.sharedInstance), !shouldSkip {
            return false
        }

        return needToCreatePayment()
    }
}
