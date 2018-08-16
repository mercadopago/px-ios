//
//  PaymentFlow.swift
//  MercadoPagoSDK
//
//  Created by Eden Torres on 26/06/2018.
//  Copyright © 2018 MercadoPago. All rights reserved.
//

import Foundation

internal final class PXPaymentFlow: NSObject, PXFlow {
    let model: PXPaymentFlowModel

    weak var resultHandler: PXPaymentResultHandlerProtocol?
    weak var paymentErrorHandler: PXPaymentErrorHandlerProtocol?

    var pxNavigationHandler: PXNavigationHandler

    init(paymentPlugin: PXPaymentPluginComponent?, paymentMethodPaymentPlugin: PXPaymentPluginComponent?, binaryMode: Bool, mercadoPagoServicesAdapter: MercadoPagoServicesAdapter, paymentErrorHandler: PXPaymentErrorHandlerProtocol, navigationHandler: PXNavigationHandler, paymentData: PaymentData?, checkoutPreference: CheckoutPreference?) {
        model = PXPaymentFlowModel(paymentPlugin: paymentPlugin, paymentMethodPaymentPlugin: paymentMethodPaymentPlugin, binaryMode: binaryMode, mercadoPagoServicesAdapter: mercadoPagoServicesAdapter)
        self.paymentErrorHandler = paymentErrorHandler
        self.pxNavigationHandler = navigationHandler
        self.model.paymentData = paymentData
        self.model.checkoutPreference = checkoutPreference
    }

    func setData(paymentData: PaymentData, checkoutPreference: CheckoutPreference, resultHandler: PXPaymentResultHandlerProtocol) {
        self.model.paymentData = paymentData
        self.model.checkoutPreference = checkoutPreference
        self.resultHandler = resultHandler
    }

    deinit {
        #if DEBUG
            print("DEINIT FLOW - \(self)")
        #endif
    }

    func start() {
        executeNextStep()
    }

    func executeNextStep() {
        switch self.model.nextStep() {
        case .createDefaultPayment:
            createPayment()
        case .createPaymentMethodPaymentPlugin:
            createPaymentWithPlugin(plugin: model.paymentMethodPaymentPlugin)
        case .createPaymentPlugin:
            createPaymentWithPlugin(plugin: model.paymentPlugin)
        case .createPaymentPluginScreen:
            showPaymentPluginComponent(paymentPluginComponent: model.paymentPlugin)
        case .createPaymentMethodPaymentPluginScreen:
            showPaymentPluginComponent(paymentPluginComponent: model.paymentMethodPaymentPlugin)
        case .getInstructions:
            getInstructions()
        case .finish:
            finishFlow()
        }
    }

    func getPaymentTimeOut() -> TimeInterval {
        let instructionTimeOut: TimeInterval = model.isOfflinePayment() ? 15 : 0
        if let paymentPluginTimeOut = model.paymentPlugin?.paymentTimeOut?() {
            return paymentPluginTimeOut + instructionTimeOut
        } else if let paymentMethodPluginTimeOut = model.paymentMethodPaymentPlugin?.paymentTimeOut?() {
            return paymentMethodPluginTimeOut + instructionTimeOut
        } else {
            return model.mercadoPagoServicesAdapter.getTimeOut() + instructionTimeOut
        }
    }

    func needToShowPaymentPluginScreen() -> Bool {
        return model.needToShowPaymentPluginScreenForPaymentPlugin() || model.needToShowPaymentPluginScreenForPaymentMethodPlugin()
    }

    func finishFlow() {
        if let paymentResult = model.paymentResult {
            self.resultHandler?.finishPaymentFlow(paymentResult: (paymentResult), instructionsInfo: model.instructionsInfo)
        } else if let businessResult = model.businessResult {
            self.resultHandler?.finishPaymentFlow(businessResult: businessResult)
        }
    }

    func cancelFlow() {}

    func exitCheckout() {}

    func cleanPayment() {
        model.cleanData()
    }
}

/** :nodoc: */
extension PXPaymentFlow: PXPaymentFlowHandlerProtocol {
    public func showError() {
        let error = MPSDKError(message: "Hubo un error".localized, errorDetail: "", retry: false)
        resultHandler?.finishPaymentFlow(error: error)
    }

    func showError(error: MPSDKError) {
        resultHandler?.finishPaymentFlow(error: error)
    }
}
