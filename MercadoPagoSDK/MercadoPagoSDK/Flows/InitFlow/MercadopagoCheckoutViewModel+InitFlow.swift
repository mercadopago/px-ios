//
//  MercadopagoCheckoutViewModel+InitFlow.swift
//  MercadoPagoSDK
//
//  Created by Juan sebastian Sanzone on 4/7/18.
//  Copyright © 2018 MercadoPago. All rights reserved.
//

import Foundation

// MARK: Init Flow
extension MercadoPagoCheckoutViewModel {
    func createInitFlow() {
        // Create init flow props.
        let initFlowProperties: InitFlowProperties
        initFlowProperties.checkoutPreference = self.checkoutPreference
        initFlowProperties.paymentData = self.paymentData
        initFlowProperties.paymentMethodPlugins = self.paymentMethodPlugins
        initFlowProperties.paymentPlugin = self.paymentPlugin

        if let search = search {
            let initSearch = PXOpenPrefInitDTO(preference: search.preference, oneTap: search.expressCho, currency: search.currency, site: search.site, generalCoupon: search.defaultAmountConfiguration, coupons: search.discountConfigurations, groups: search.paymentMethodSearchItem, payerPaymentMethods: search.customOptionSearchItems, availablePaymentMethods: search.paymentMethods)
            initFlowProperties.paymentMethodSearchResult = initSearch
        } else {
            initFlowProperties.paymentMethodSearchResult = nil
        }
        initFlowProperties.chargeRules = self.chargeRules
        initFlowProperties.serviceAdapter = self.mercadoPagoServicesAdapter
        initFlowProperties.advancedConfig = self.getAdvancedConfiguration()
        initFlowProperties.paymentConfigurationService = self.paymentConfigurationService
        initFlowProperties.escManager = escManager
        initFlowProperties.privateKey = privateKey

        configureBiometricModule()

        // Create init flow.
        initFlow = InitFlow(flowProperties: initFlowProperties, finishCallback: { [weak self] (checkoutPreference, initSearch)  in
            self?.checkoutPreference = checkoutPreference

            let search = PXPaymentMethodSearch(preference: initSearch.preference ?? PXCheckoutPreference(preferenceId: ""), site: initSearch.site ?? PXSite(id: "MLA", currencyId: "ARS", termsAndConditionsUrl: "url", shouldWarnAboutBankInterests: false), currency: initSearch.currency, expressCho: initSearch.oneTap, defaultAmountConfiguration: initSearch.generalCoupon, discountConfigurations: initSearch.coupons, paymentMethodSearchItem: [], customOptionSearchItems: initSearch.payerPaymentMethods, paymentMethods: initSearch.availablePaymentMethods, cards: [], defaultOption: nil, oneTap: nil)

            self?.updateCheckoutModel(paymentMethodSearch: search)
            PXTrackingStore.sharedInstance.addData(forKey: PXTrackingStore.cardIdsESC, value: self?.getCardsIdsWithESC() ?? [])

            let selectedDiscountConfigurartion = search.selectedDiscountConfiguration
            self?.attemptToApplyDiscount(selectedDiscountConfigurartion)

            self?.initFlowProtocol?.didFinishInitFlow()
        }, errorCallback: { [weak self] initFlowError in
            self?.initFlowProtocol?.didFailInitFlow(flowError: initFlowError)
        })
    }

    func setInitFlowProtocol(flowInitProtocol: InitFlowProtocol) {
        initFlowProtocol = flowInitProtocol
    }

    func startInitFlow() {
        trackingConfig?.updateTracker()
        initFlow?.start()
    }

    func updateInitFlow() {
        initFlow?.updateModel(paymentPlugin: self.paymentPlugin, paymentMethodPlugins: self.paymentMethodPlugins, chargeRules: self.chargeRules)
    }

    func configureBiometricModule() {
        // We use productId as unique identifier
        PXConfiguratorManager.biometricConfig = PXBiometricConfig.createConfig(withFlowIdentifier: getAdvancedConfiguration().productId, andAmount: paymentData.getRawAmount())
    }
}
