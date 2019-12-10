//
//  InitFlow.swift
//  MercadoPagoSDK
//
//  Created by Juan sebastian Sanzone on 26/6/18.
//  Copyright © 2018 MercadoPago. All rights reserved.
//

import Foundation

final class InitFlow: PXFlow {
    var pxNavigationHandler: PXNavigationHandler
    let model: InitFlowModel

    private var status: PXFlowStatus = .ready
    private let finishInitCallback: ((PXCheckoutPreference, PXInitDTO) -> Void)
    private let errorInitCallback: ((InitFlowError) -> Void)

    init(flowProperties: InitFlowProperties, finishCallback: @escaping ((PXCheckoutPreference, PXInitDTO) -> Void), errorCallback: @escaping ((InitFlowError) -> Void)) {
        pxNavigationHandler = PXNavigationHandler.getDefault()
        finishInitCallback = finishCallback
        errorInitCallback = errorCallback
        model = InitFlowModel(flowProperties: flowProperties)
        PXTrackingStore.sharedInstance.cleanChoType()
    }

    func updateModel(paymentPlugin: PXSplitPaymentProcessor?, paymentMethodPlugins: [PXPaymentMethodPlugin]?, chargeRules: [PXPaymentTypeChargeRule]?) {
        var pmPlugins: [PXPaymentMethodPlugin] = [PXPaymentMethodPlugin]()
        if let targetPlugins = paymentMethodPlugins {
            pmPlugins = targetPlugins
        }
        model.update(paymentPlugin: paymentPlugin, paymentMethodPlugins: pmPlugins, chargeRules: chargeRules)
    }

    deinit {
        #if DEBUG
            print("DEINIT FLOW - \(self)")
        #endif
    }

    func start() {
        if status != .running {
            status = .running
            executeNextStep()
        }
    }

    func executeNextStep() {
        let nextStep = model.nextStep()
        switch nextStep {
        case .SERVICE_GET_INIT:
            getInitSearch()
        case .FINISH:
            finishFlow()
        case .ERROR:
            cancelFlow()
        }
    }

    func finishFlow() {
        status = .finished
        if let paymentMethodsSearch = model.getPaymentMethodSearch() {
            setCheckoutTypeForTracking()

            //Return the preference we retrieved or the one the integrator created
            let preference = paymentMethodsSearch.preference ?? model.properties.checkoutPreference
            finishInitCallback(preference, paymentMethodsSearch)
        } else {
            cancelFlow()
        }
    }

    func cancelFlow() {
        status = .finished
        errorInitCallback(model.getError())
        model.resetError()
    }

    func exitCheckout() {}
}

// MARK: - Getters
extension InitFlow {
    func setFlowRetry(step: InitFlowModel.Steps) {
        status = .ready
        model.setPendingRetry(forStep: step)
    }

    func disposePendingRetry() {
        model.removePendingRetry()
    }

    func getStatus() -> PXFlowStatus {
        return status
    }

    func restart() {
        if status != .running {
            status = .ready
        }
    }
}

// MARK: - Privates
extension InitFlow {
    private func setCheckoutTypeForTracking() {
        if let paymentMethodsSearch = model.getPaymentMethodSearch() {
            PXTrackingStore.sharedInstance.setChoType(paymentMethodsSearch.oneTap != nil ? .one_tap : .traditional)
        }
    }
}
