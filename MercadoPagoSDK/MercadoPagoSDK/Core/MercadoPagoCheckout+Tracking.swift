//
//  MercadoPagoCheckout+Tracking.swift
//  MercadoPagoSDK
//
//  Created by Eden Torres on 13/12/2018.
//

import Foundation

// MARK: Tracking
extension MercadoPagoCheckout {

    internal func startTracking() {
        MPXTracker.sharedInstance.startNewSession()

        // Track init event
        var properties: [String: Any] = [:]
        if !String.isNullOrEmpty(viewModel.checkoutPreference.id) {
        properties["checkout_preference_id"] = viewModel.checkoutPreference.id
        } else {
        properties["checkout_preference"] = viewModel.checkoutPreference.getCheckoutPrefForTracking()
        }

        properties["esc_enabled"] = viewModel.getAdvancedConfiguration().isESCEnabled()
        properties["express_enabled"] = viewModel.getAdvancedConfiguration().expressEnabled

        viewModel.populateCheckoutStore()
        properties["split_enabled"] = viewModel.paymentPlugin?.supportSplitPaymentMethodPayment(checkoutStore: PXCheckoutStore.sharedInstance) ?? false

        MPXTracker.sharedInstance.trackEvent(path: TrackingPaths.Events.getInitPath(), properties: properties)
    }
    
    internal func trackInitFlowFriction(flowError: InitFlowError) {
        var properties: [String: Any] = [:]
        properties["path"] = TrackingPaths.Screens.PaymentVault.getPaymentVaultPath()
        properties["style"] = Tracking.Style.screen
        properties["id"] = Tracking.Error.Id.genericError
        properties["message"] = "Hubo un error"
        properties["attributable_to"] = Tracking.Error.Atrributable.user

        var extraDic: [String: Any] = [:]
        var errorDic: [String: Any] = [:]

        errorDic["url"] =  flowError.requestOrigin?.rawValue
        errorDic["retry_available"] = flowError.shouldRetry
        errorDic["status"] =  flowError.apiException?.status

        if let causes = flowError.apiException?.cause {
            var causesDic: [String: Any] = [:]
            for cause in causes where !String.isNullOrEmpty(cause.code) {
                causesDic["code"] = cause.code
                causesDic["description"] = cause.causeDescription
            }
            errorDic["causes"] = causesDic
        }
        extraDic["api_error"] = errorDic
        properties["extra_info"] = extraDic
        MPXTracker.sharedInstance.trackEvent(path: TrackingPaths.Events.getErrorPath(), properties: properties)
    }
    
    internal func trackInitFlowRefreshFriction(cardId: String) {
        var properties: [String: Any] = [:]
        properties["path"] = TrackingPaths.Screens.OneTap.getOneTapPath()
        properties["style"] = Tracking.Style.noScreen
        properties["id"] = Tracking.Error.Id.genericError
        properties["message"] = "No se pudo recuperar la tarjeta ingresada"
        properties["attributable_to"] = Tracking.Error.Atrributable.mercadopago
        var extraDic: [String: Any] = [:]
        extraDic["cardId"] =  cardId
        properties["extra_info"] = extraDic
        MPXTracker.sharedInstance.trackEvent(path: TrackingPaths.Events.getErrorPath(), properties: properties)
    }
}
