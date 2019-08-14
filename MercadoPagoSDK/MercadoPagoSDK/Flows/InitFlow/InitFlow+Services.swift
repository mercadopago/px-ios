//
//  InitFlow+Services.swift
//  MercadoPagoSDK
//
//  Created by Juan sebastian Sanzone on 2/7/18.
//  Copyright © 2018 MercadoPago. All rights reserved.
//

import Foundation

extension InitFlow {

    func getInitSearch() {
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
        serviceAdapter.getInitSearch(pref: pref, amount: model.amountHelper.amountToPay, exclusions: exclusions, oneTapInfo: oneTapInfo, payer: model.properties.paymentData.payer ?? PXPayer(email: ""), site: SiteManager.shared.getSiteId(), extraParams: (defaultPaymentMethod: model.getDefaultPaymentMethodId(), differentialPricingId: differentialPricingString, defaultInstallments: defaultInstallments, expressEnabled: model.properties.advancedConfig.expressEnabled, hasPaymentProcessor: hasPaymentProcessor, splitEnabled: splitEnabled, maxInstallments: maxInstallments), discountParamsConfiguration: discountParamsConfiguration, marketplace: marketplace, charges: self.model.amountHelper.chargeRules, callback: { [weak self] (paymentMethodSearch) in

            guard let strongSelf = self else {
                return
            }

            strongSelf.model.updateInitModel(paymentMethodsResponse: paymentMethodSearch)
            strongSelf.model.properties.checkoutPreference = paymentMethodSearch.preference
            strongSelf.model.properties.paymentData.payer = paymentMethodSearch.preference.getPayer()
            SiteManager.shared.setSite(site: paymentMethodSearch.site)
            SiteManager.shared.setCurrency(currency: paymentMethodSearch.currency)
            strongSelf.executeNextStep()

            }, failure: { [weak self] (error) in
                guard let strongSelf = self else {
                    return
                }
                let customError = InitFlowError(errorStep: .SERVICE_GET_INIT, shouldRetry: true, requestOrigin: .GET_INIT, apiException: MPSDKError.getApiException(error))
                strongSelf.model.setError(error: customError)
                strongSelf.executeNextStep()
        })
    }
}
