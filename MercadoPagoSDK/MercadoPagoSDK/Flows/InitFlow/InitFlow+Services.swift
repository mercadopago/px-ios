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
        let cardIdsWithEsc = PXConfiguratorManager.escProtocol.getSavedCardIds(config: PXConfiguratorManager.escConfig)

        let discountParamsConfiguration = initFlowModel.properties.advancedConfig.discountParamsConfiguration
        let flowName: String? = MPXTracker.sharedInstance.getFlowName() ?? nil
        let splitEnabled: Bool = initFlowModel.properties.paymentPlugin?.supportSplitPaymentMethodPayment(checkoutStore: PXCheckoutStore.sharedInstance) ?? false
        let serviceAdapter = initFlowModel.getService()

        //payment method search service should be performed using the processing modes designated by the preference object
        let pref = initFlowModel.properties.checkoutPreference
        serviceAdapter.update(processingModes: pref.processingModes, branchId: pref.branchId)

        let charges = self.initFlowModel.amountHelper.chargeRules ?? []

        //Add headers
        var headers: [String: String] = [:]
        if let prodId = initFlowModel.properties.productId {
            headers[MercadoPagoService.HeaderField.productId.rawValue] = prodId
        }

        if let prefId = pref.id, prefId.isNotEmpty {
            // CLOSED PREFERENCE
            serviceAdapter.getClosedPrefInitSearch(preferenceId: prefId, cardsWithEsc: cardIdsWithEsc, oneTapEnabled: true, splitEnabled: splitEnabled, discountParamsConfiguration: discountParamsConfiguration, flow: flowName, charges: charges, headers: headers, callback: callback(_:), failure: failure(_:))
        } else {
            // OPEN PREFERENCE
            serviceAdapter.getOpenPrefInitSearch(pref: pref, cardsWithEsc: cardIdsWithEsc, oneTapEnabled: true, splitEnabled: splitEnabled, discountParamsConfiguration: discountParamsConfiguration, flow: flowName, charges: charges, headers: headers, callback: callback(_:), failure: failure(_:))
        }
    }

    func callback(_ search: PXInitDTO) {
        /// Hack para corregir un issue cuando hay un descuento para un medio de pago particular
        /// El nodo coupons no trae el valor de generalCoupon y cuando usa MercadoPagoCheckoutViewModel.getPaymentOptionConfigurations
        /// se rompe todo al no encontrar el payer_costs correspondiente al coupon
        let generalCoupon = search.generalCoupon
        if !generalCoupon.isEmpty,
            !search.coupons.keys.contains(generalCoupon) {
            search.coupons[generalCoupon] = PXDiscountConfiguration(isAvailable: true)
        }
        if search.selectedDiscountConfiguration == nil,
            let selectedDiscountConfiguration = search.coupons[search.generalCoupon] {
            search.selectedDiscountConfiguration = selectedDiscountConfiguration
        }
        /// Fin del hack

        initFlowModel.updateInitModel(paymentMethodsResponse: search)

        //Tracking Experiments
        MPXTracker.sharedInstance.setExperiments(search.experiments)

        //Set site
        SiteManager.shared.setCurrency(currency: search.currency)
        SiteManager.shared.setSite(site: search.site)

        executeNextStep()
    }

    func failure(_ error: NSError) {
        let customError = InitFlowError(errorStep: .SERVICE_GET_INIT, shouldRetry: true, requestOrigin: .GET_INIT, apiException: MPSDKError.getApiException(error))
        initFlowModel.setError(error: customError)
        executeNextStep()
    }
}
