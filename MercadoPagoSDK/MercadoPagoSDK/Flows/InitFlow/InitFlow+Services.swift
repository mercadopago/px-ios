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
            guard let strongSelf = self else {
                return
            }

            strongSelf.model.properties.checkoutPreference = checkoutPreference
            strongSelf.model.properties.paymentData.payer = checkoutPreference.getPayer()
            strongSelf.executeNextStep()

            }, failure: { [weak self] (error) in
                guard let strongSelf = self else {
                    return
                }
                let customError = InitFlowError(errorStep: .SERVICE_GET_PREFERENCE, shouldRetry: true, requestOrigin: .GET_PREFERENCE)
                strongSelf.model.setError(error: customError)
                strongSelf.executeNextStep()
        })
    }

    func validatePreference() {
        let errorMessage = model.properties.checkoutPreference.validate()
        if errorMessage != nil {
            let customError = InitFlowError(errorStep: .ACTION_VALIDATE_PREFERENCE, shouldRetry: false, requestOrigin: nil)
            model.setError(error: customError)
        }
        executeNextStep()
    }

    func getDirectDiscount() {
        model.getService().getDirectDiscount(amount: model.amountHelper.amountToPay, payerEmail: model.properties.checkoutPreference.payer.email, callback: { [weak self] (discount) in
            guard let strongSelf = self else {
                return
            }

            strongSelf.model.properties.discount = discount
            strongSelf.executeNextStep()

            }, failure: { [weak self] _ in
                guard let strongSelf = self else {
                    return
                }
                let customError = InitFlowError(errorStep: .SERVICE_GET_DIRECT_DISCOUNT, shouldRetry: true, requestOrigin: .GET_DIRECT_DISCOUNT)
                strongSelf.model.setError(error: customError)
                strongSelf.executeNextStep()
        })
    }

    func getCampaigns() {
        let payerEmail = model.properties.checkoutPreference.getPayer().email
        model.getService().getCampaigns(payerEmail: payerEmail, callback: { [weak self] (pxCampaigns) in
            guard let strongSelf = self else {
                return
            }

            strongSelf.model.properties.campaigns = pxCampaigns
            strongSelf.executeNextStep()

            }, failure: { [weak self] _ in
                guard let strongSelf = self else {
                    return
                }
                let customError = InitFlowError(errorStep: .SERVICE_GET_CAMPAIGNS, shouldRetry: true, requestOrigin: .GET_CAMPAIGNS)
                strongSelf.model.setError(error: customError)
                strongSelf.executeNextStep()
        })
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
        let paymentMethodPluginsToShow = model.properties.paymentMethodPlugins.filter {$0.mustShowPaymentMethodPlugin(PXCheckoutStore.sharedInstance) == true}
        var pluginIds = [String]()
        for plugin in paymentMethodPluginsToShow {
            pluginIds.append(plugin.getId())
        }

        let cardIdsWithEsc = model.getESCService().getSavedCardIds()
        let exclusions: MercadoPagoServicesAdapter.PaymentSearchExclusions = (model.getExcludedPaymentTypesIds(), model.getExcludedPaymentMethodsIds())
        let oneTapInfo: MercadoPagoServicesAdapter.PaymentSearchOneTapInfo = (cardIdsWithEsc, pluginIds)

        var differentialPricingString: String? = nil
        if let diffPricing = model.properties.checkoutPreference.differentialPricing?.id {
            differentialPricingString = String(describing: diffPricing)
        }

        var defaultInstallments: String?
        let dInstallments = model.properties.checkoutPreference.getDefaultInstallments()
        if dInstallments > 0 {
            defaultInstallments = String(dInstallments)
        }

        model.getService().getPaymentMethodSearch(amount: model.amountHelper.amountToPay, exclusions: exclusions, oneTapInfo: oneTapInfo, payer: model.properties.paymentData.payer ?? PXPayer(email: ""), site: SiteManager.shared.getSiteId(), extraParams: (defaultPaymentMethod: model.getDefaultPaymentMethodId(), differentialPricingId: differentialPricingString, defaultInstallments: defaultInstallments), callback: { [weak self] (paymentMethodSearch) in

            guard let strongSelf = self else {
                return
            }

            strongSelf.model.updateInitModel(paymentMethodsResponse: paymentMethodSearch)
            strongSelf.executeNextStep()

            }, failure: { [weak self] (error) in
                guard let strongSelf = self else {
                    return
                }
                let customError = InitFlowError(errorStep: .SERVICE_GET_PAYMENT_METHODS, shouldRetry: true, requestOrigin: .PAYMENT_METHOD_SEARCH)
                strongSelf.model.setError(error: customError)
                strongSelf.executeNextStep()
        })
    }
}
