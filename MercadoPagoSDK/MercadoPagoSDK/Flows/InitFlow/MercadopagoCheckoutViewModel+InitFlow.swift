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
        initFlowProperties.paymentMethodSearchResult = self.search
        initFlowProperties.chargeRules = self.chargeRules
        initFlowProperties.campaigns = self.campaigns
        initFlowProperties.consumedDiscount = self.consumedDiscount
        initFlowProperties.discount = self.paymentData.discount
        initFlowProperties.serviceAdapter = self.mercadoPagoServicesAdapter
        initFlowProperties.advancedConfig = self.getAdvancedConfiguration()

        // Create init flow.
        initFlow = InitFlow(flowProperties: initFlowProperties, finishCallback: { [weak self] (checkoutPreference, paymentMethodSearchResponse, pxCampaigns, pxDiscount)  in
            self?.updateCheckoutModel(paymentMethodSearch: paymentMethodSearchResponse)
            PXTrackingStore.sharedInstance.addData(forKey: PXTrackingStore.cardIdsESC, value: self?.getCardsIdsWithESC() ?? [])
            self?.campaigns = pxCampaigns
            self?.checkoutPreference = checkoutPreference
            self?.attemptToApplyDiscount(discount: pxDiscount)

            self?.initFlowProtocol?.didFinishInitFlow()
        }, errorCallback: { [weak self] initFlowError in
            self?.initFlowProtocol?.didFailInitFlow(flowError: initFlowError)
        })
    }

    func setInitFlowProtocol(flowInitProtocol: InitFlowProtocol) {
        initFlowProtocol = flowInitProtocol
    }

    func startInitFlow() {
        initFlow?.start()
    }

    func updateInitFlow() {
        initFlow?.updateModel(paymentPlugin: self.paymentPlugin, paymentMethodPlugins: self.paymentMethodPlugins)
    }

    func attemptToApplyDiscount(discount: PXDiscount?) {
        if let discount = discount, let campaigns = self.campaigns {
            let filteredCampaigns = campaigns.filter { (campaign: PXCampaign) -> Bool in
                return campaign.id.stringValue == discount.id
            }
            if let firstFilteredCampaign = filteredCampaigns.first {
                self.setDiscount(discount, withCampaign: firstFilteredCampaign)
            }
        }
    }
}
