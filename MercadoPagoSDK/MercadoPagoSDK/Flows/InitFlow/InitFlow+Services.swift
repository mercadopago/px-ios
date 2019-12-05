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
        let cardIdsWithEsc = model.getESCService()?.getSavedCardIds() ?? []
        let exclusions: MercadoPagoServicesAdapter.PaymentSearchExclusions = (model.getExcludedPaymentTypesIds(), model.getExcludedPaymentMethodsIds())

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

        let extraParams = (defaultPaymentMethod: model.getDefaultPaymentMethodId(), differentialPricingId: differentialPricingString, defaultInstallments: defaultInstallments, expressEnabled: model.properties.advancedConfig.expressEnabled, hasPaymentProcessor: hasPaymentProcessor, splitEnabled: splitEnabled, maxInstallments: maxInstallments)

        let charges = self.model.amountHelper.chargeRules ?? []

        //Add headers
        var headers: [String: String] = [:]
        if let prodId = model.properties.productId {
            headers[MercadoPagoService.HeaderField.productId.rawValue] = prodId
        }

        if let prefId = pref.id, prefId.isNotEmpty {
            // CLOSED PREFERENCE
            serviceAdapter.getClosedPrefInitSearch(preferenceId: prefId, cardIdsWithEsc: cardIdsWithEsc, extraParams: extraParams, discountParamsConfiguration: discountParamsConfiguration, marketplace: marketplace, charges: charges, headers: headers, callback: callback(_:), failure: failure(_:))
        } else {
            // OPEN PREFERENCE
            serviceAdapter.getOpenPrefInitSearch(preference: pref, cardIdsWithEsc: cardIdsWithEsc, extraParams: extraParams, discountParamsConfiguration: discountParamsConfiguration, marketplace: marketplace, charges: charges, headers: headers, callback: callback(_:), failure: failure(_:))
        }
    }

    func callback(_ search: PXInitDTO) {
        self.model.updateInitModel(paymentMethodsResponse: search)

        //Tracking Experiments
        MPXTracker.sharedInstance.setExperiments(search.experiments)

        //Set site
        SiteManager.shared.setCurrency(currency: search.currency)
        SiteManager.shared.setSite(site: search.site)

        self.executeNextStep()
    }

    func failure(_ error: NSError) {
        let customError = InitFlowError(errorStep: .SERVICE_GET_INIT, shouldRetry: true, requestOrigin: .GET_INIT, apiException: MPSDKError.getApiException(error))
        self.model.setError(error: customError)
        self.executeNextStep()
    }
}
