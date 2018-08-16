//
//  InitFlowModel.swift
//  MercadoPagoSDK
//
//  Created by Juan sebastian Sanzone on 27/6/18.
//  Copyright © 2018 MercadoPago. All rights reserved.
//

import Foundation
import MercadoPagoServicesV4

internal typealias InitFlowProperties = (paymentData: PaymentData, checkoutPreference: CheckoutPreference, paymentPlugin: PXPaymentPluginComponent?, paymentMethodPlugins: [PXPaymentMethodPlugin], paymentMethodSearchResult: PaymentMethodSearch?, chargeRules: [PXPaymentTypeChargeRule]?, campaigns: [PXCampaign]?, discount: PXDiscount?, consumedDiscount: Bool)

internal typealias InitFlowError = (errorStep: InitFlowModel.Steps, shouldRetry: Bool, requestOrigin: ApiUtil.RequestOrigin?)

internal protocol InitFlowProtocol: NSObjectProtocol {
    func didFinishInitFlow()
    func didFailInitFlow(flowError: InitFlowError)
}

final class InitFlowModel: NSObject, PXFlowModel {
    enum Steps: String {
        case ERROR = "Error"
        case SERVICE_GET_PREFERENCE = "Obtener datos de preferencia"
        case ACTION_VALIDATE_PREFERENCE = "Validación de preferencia"
        case SERVICE_GET_CAMPAIGNS = "Obtener campañas"
        case SERVICE_GET_DIRECT_DISCOUNT = "Obtener descuento"
        case SERVICE_GET_PAYMENT_METHODS = "Obtener medios de pago"
        case SERVICE_PAYMENT_METHOD_PLUGIN_INIT = "Iniciando plugin de pago"
        case FINISH = "Finish step"
    }

    private let serviceAdapter = MercadoPagoServicesAdapter(servicePreference: MercadoPagoCheckoutViewModel.servicePreference)
    private let mpESCManager: MercadoPagoESC = MercadoPagoESCImplementation()

    private var preferenceValidated: Bool = false
    private var needPaymentMethodPluginInit = true
    private var loadPreferenceStatus: Bool
    private var directDiscountSearchStatus: Bool
    private var flowError: InitFlowError?
    private var pendingRetryStep: Steps?


    var properties: InitFlowProperties

    var amountHelper: PXAmountHelper {
        get {
            return PXAmountHelper(preference: self.properties.checkoutPreference, paymentData: self.properties.paymentData, discount: self.properties.paymentData.discount, campaign: self.properties.paymentData.campaign, chargeRules: self.properties.chargeRules, consumedDiscount: self.properties.consumedDiscount)
        }
    }

    init(flowProperties: InitFlowProperties) {
        self.properties = flowProperties
        self.loadPreferenceStatus = !String.isNullOrEmpty(flowProperties.checkoutPreference.preferenceId)
        self.directDiscountSearchStatus = flowProperties.paymentData.isComplete()
        super.init()
    }

    func update(paymentPlugin: PXPaymentPluginComponent?, paymentMethodPlugins: [PXPaymentMethodPlugin]) {
        properties.paymentPlugin = paymentPlugin
        properties.paymentMethodPlugins = paymentMethodPlugins
    }
}

// MARK: Public methods
extension InitFlowModel {
    func getService() -> MercadoPagoServicesAdapter {
        return serviceAdapter
    }

    func getESCService() -> MercadoPagoESC {
        return mpESCManager
    }

    func getError() -> InitFlowError {
        if let error = flowError {
            return error
        }
        return InitFlowError(errorStep: .ERROR, shouldRetry: false, requestOrigin: nil)
    }

    func setError(error: InitFlowError) {
        if error.errorStep != .SERVICE_GET_CAMPAIGNS && error.errorStep != .SERVICE_GET_DIRECT_DISCOUNT && error.errorStep != .SERVICE_PAYMENT_METHOD_PLUGIN_INIT {
            flowError = error
        }
    }

    func resetError() {
        flowError = nil
    }

    func setPendingRetry(forStep: Steps) {
        pendingRetryStep = forStep
    }

    func removePendingRetry() {
        pendingRetryStep = nil
    }

    func paymentMethodPluginDidLoaded() {
        needPaymentMethodPluginInit = false
    }

    func getExcludedPaymentTypesIds() -> Set<String>? {
        if properties.checkoutPreference.siteId == "MLC" || properties.checkoutPreference.siteId == "MCO" ||
            properties.checkoutPreference.siteId == "MLV" {
            properties.checkoutPreference.addExcludedPaymentType("atm")
            properties.checkoutPreference.addExcludedPaymentType("bank_transfer")
            properties.checkoutPreference.addExcludedPaymentType("ticket")
        }
        return properties.checkoutPreference.getExcludedPaymentTypesIds()
    }

    func getDefaultPaymentMethodId() -> String? {
        return properties.checkoutPreference.getDefaultPaymentMethodId()
    }

    func getExcludedPaymentMethodsIds() -> Set<String>? {
        return properties.checkoutPreference.getExcludedPaymentMethodsIds()
    }

    func updateInitModel(paymentMethodsResponse: PaymentMethodSearch?) {
        properties.paymentMethodSearchResult = paymentMethodsResponse
    }

    func getPaymentMethodSearch() -> PaymentMethodSearch? {
        return properties.paymentMethodSearchResult
    }

    func populateCheckoutStore() {
        PXCheckoutStore.sharedInstance.paymentData = self.properties.paymentData
        PXCheckoutStore.sharedInstance.checkoutPreference = self.properties.checkoutPreference
    }
}

// MARK: nextStep - State machine
extension InitFlowModel {
    func nextStep() -> Steps {
        if let retryStep = pendingRetryStep {
            pendingRetryStep = nil
            return retryStep
        }

        if hasError() {
            return .ERROR
        }

        if needLoadPreference() {
            loadPreferenceStatus = false
            return .SERVICE_GET_PREFERENCE
        }

        if needValidatePreference() {
            preferenceValidated = true
            return .ACTION_VALIDATE_PREFERENCE
        }

        if needToSearchCampaign() {
            return .SERVICE_GET_CAMPAIGNS
        }

        if needToInitPaymentMethodPlugins() {
            return .SERVICE_PAYMENT_METHOD_PLUGIN_INIT
        }

        if needSearch() {
            return .SERVICE_GET_PAYMENT_METHODS
        }

        if needToSearchDirectDiscount() {
            directDiscountSearchStatus = true
            return .SERVICE_GET_DIRECT_DISCOUNT
        }

        return .FINISH
    }
}

// MARK: Needs methods
extension InitFlowModel {
    private func needLoadPreference() -> Bool {
        return loadPreferenceStatus
    }

    private func needToSearchDirectDiscount() -> Bool {
        return filterCampaignsByCodeType(campaigns: properties.campaigns, "none") != nil && !directDiscountSearchStatus && properties.paymentData.discount == nil && !properties.paymentData.isComplete() && (properties.paymentMethodPlugins.isEmpty && properties.paymentPlugin == nil) && !Array.isNullOrEmpty(properties.campaigns)
    }

    func needToSearchCampaign() -> Bool {
        return !directDiscountSearchStatus && !properties.paymentData.isComplete() && (properties.paymentMethodPlugins.isEmpty && properties.paymentPlugin == nil) && properties.campaigns == nil
    }

    private func needValidatePreference() -> Bool {
        return !loadPreferenceStatus && !preferenceValidated
    }

    private func needToInitPaymentMethodPlugins() -> Bool {
        if properties.paymentMethodPlugins.isEmpty {
            return false
        }
        return needPaymentMethodPluginInit
    }

    private func needSearch() -> Bool {
        return properties.paymentMethodSearchResult == nil
    }

    private func hasError() -> Bool {
        return flowError != nil
    }

    private func filterCampaignsByCodeType(campaigns: [PXCampaign]?, _ codeType: String) -> [PXCampaign]? {
        if let campaigns = campaigns {
            let filteredCampaigns = campaigns.filter { (campaign: PXCampaign) -> Bool in
                return campaign.codeType == codeType
            }
            if filteredCampaigns.isEmpty {
                return nil
            }
            return filteredCampaigns
        }
        return nil
    }
}
