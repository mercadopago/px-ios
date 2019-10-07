//
//  InitFlow+Services.swift
//  MercadoPagoSDK
//
//  Created by Juan sebastian Sanzone on 2/7/18.
//  Copyright © 2018 MercadoPago. All rights reserved.
//

import Foundation

extension InitFlow {
    func getCheckoutPreference() {
        model.getService().getCheckoutPreference(checkoutPreferenceId: model.properties.checkoutPreference.id, callback: { [weak self] (checkoutPreference) in
            guard let self = self else {
                return
            }
            self.model.properties.checkoutPreference = checkoutPreference
            self.model.properties.paymentData.payer = checkoutPreference.getPayer()
            self.executeNextStep()
            }, failure: { [weak self] (error) in
                guard let self = self else {
                    return
                }
                let customError = InitFlowError(errorStep: .SERVICE_GET_PREFERENCE, shouldRetry: true, requestOrigin: .GET_PREFERENCE, apiException: MPSDKError.getApiException(error))
                self.model.setError(error: customError)
                self.executeNextStep()
        })
    }

    func validatePreference() {
        let errorMessage = model.properties.checkoutPreference.validate(privateKey: model.properties.privateKey)
        if errorMessage != nil {
            let customError = InitFlowError(errorStep: .ACTION_VALIDATE_PREFERENCE, shouldRetry: false, requestOrigin: nil, apiException: nil)
            model.setError(error: customError)
        }
        executeNextStep()
    }

    func initPaymentMethodPlugins() {
        if !model.properties.paymentMethodPlugins.isEmpty {
            initPlugin(plugins: model.properties.paymentMethodPlugins, index: model.properties.paymentMethodPlugins.count - 1)
        } else {
            executeNextStep()
        }
    }

    func initPlugin(plugins: [PXPaymentMethodPlugin], index: Int) {
        if index < 0 {
            DispatchQueue.main.async {
                self.model.paymentMethodPluginDidLoaded()
                self.executeNextStep()
            }
        } else {
            model.populateCheckoutStore()
            let plugin = plugins[index]
            plugin.initPaymentMethodPlugin(PXCheckoutStore.sharedInstance, { [weak self] _ in
                self?.initPlugin(plugins: plugins, index: index - 1)
            })
        }
    }

    func getPaymentMethodSearch() {
        let paymentMethodPluginsToShow = model.properties.paymentMethodPlugins.filter { $0.mustShowPaymentMethodPlugin(PXCheckoutStore.sharedInstance) == true }
        var pluginIds = [String]()
        for plugin in paymentMethodPluginsToShow {
            pluginIds.append(plugin.getId())
        }

        let cardIdsWithEsc = model.getESCService()?.getSavedCardIds()
        let exclusions: MercadoPagoServicesAdapter.PaymentSearchExclusions = (model.getExcludedPaymentTypesIds(), model.getExcludedPaymentMethodsIds())
        let oneTapInfo: MercadoPagoServicesAdapter.PaymentSearchOneTapInfo = (cardIdsWithEsc, pluginIds)

        var differentialPricingString: String?
        if let diffPricing = model.properties.checkoutPreference.differentialPricing?.id {
            differentialPricingString = String(describing: diffPricing)
        }

        var defaultInstallments: String?
        let dInstallments = model.properties.checkoutPreference.getDefaultInstallments()
        if let dInstallments = dInstallments {
            defaultInstallments = String(dInstallments)
        }

        var maxInstallments: String?
        let mInstallments = model.properties.checkoutPreference.getMaxAcceptedInstallments()
        maxInstallments = String(mInstallments)

        let hasPaymentProcessor: Bool = model.properties.paymentPlugin != nil ? true : false
        let discountParamsConfiguration = model.properties.advancedConfig.discountParamsConfiguration
        let marketplace = model.amountHelper.preference.marketplace
        let splitEnabled: Bool = model.properties.paymentPlugin?.supportSplitPaymentMethodPayment(checkoutStore: PXCheckoutStore.sharedInstance) ?? false
        let serviceAdapter = model.getService()

        //payment method search service should be performed using the processing modes designated by the preference object
        let pref = model.properties.checkoutPreference
        serviceAdapter.update(processingModes: pref.processingModes, branchId: pref.branchId)
        serviceAdapter.getPaymentMethodSearch(amount: model.amountHelper.amountToPay, exclusions: exclusions, oneTapInfo: oneTapInfo, payer: model.properties.paymentData.payer ?? PXPayer(email: ""), site: SiteManager.shared.getSiteId(), extraParams: (defaultPaymentMethod: model.getDefaultPaymentMethodId(), differentialPricingId: differentialPricingString, defaultInstallments: defaultInstallments, expressEnabled: model.properties.advancedConfig.expressEnabled, hasPaymentProcessor: hasPaymentProcessor, splitEnabled: splitEnabled, maxInstallments: maxInstallments), discountParamsConfiguration: discountParamsConfiguration, marketplace: marketplace, charges: model.amountHelper.chargeRules, callback: { [weak self] (paymentMethodSearch) in

            guard let self = self else {
                return
            }

            self.model.updateInitModel(paymentMethodsResponse: paymentMethodSearch)
            self.executeNextStep()

            }, failure: { [weak self] (error) in
                guard let self = self else {
                    return
                }
                let customError = InitFlowError(errorStep: .SERVICE_GET_PAYMENT_METHODS, shouldRetry: true, requestOrigin: .PAYMENT_METHOD_SEARCH, apiException: MPSDKError.getApiException(error))
                self.model.setError(error: customError)
                self.executeNextStep()
        })
    }
}
