//
//  OneTapFlow.swift
//  MercadoPagoSDK
//
//  Created by Eden Torres on 09/05/2018.
//  Copyright © 2018 MercadoPago. All rights reserved.
//

import Foundation

final class OneTapFlow: NSObject, PXFlow {
    let model: OneTapFlowModel
    let pxNavigationHandler: PXNavigationHandler

    weak var resultHandler: PXOneTapResultHandlerProtocol?

    let advancedConfig: PXAdvancedConfiguration

    init(navigationController: PXNavigationHandler, paymentData: PaymentData, checkoutPreference: CheckoutPreference, search: PaymentMethodSearch, paymentOptionSelected: PaymentMethodOption, reviewScreenPreference: ReviewScreenPreference, chargeRules: [PXPaymentTypeChargeRule]?, oneTapResultHandler: PXOneTapResultHandlerProtocol, consumedDiscount: Bool, advancedConfiguration: PXAdvancedConfiguration) {
        pxNavigationHandler = navigationController
        resultHandler = oneTapResultHandler
        advancedConfig = advancedConfiguration
        model = OneTapFlowModel(paymentData: paymentData, checkoutPreference: checkoutPreference, search: search, paymentOptionSelected: paymentOptionSelected, reviewScreenPreference: reviewScreenPreference, chargeRules: chargeRules, consumedDiscount: consumedDiscount)
    }

    deinit {
        #if DEBUG
        print("DEINIT FLOW - \(self)")
        #endif
    }

    func setPaymentFlow(paymentFlow: PXPaymentFlow) {
        model.paymentFlow = paymentFlow
    }

    func start() {
        executeNextStep()
    }

    func executeNextStep() {
        switch self.model.nextStep() {
        case .screenReviewOneTap:
            self.showReviewAndConfirmScreenForOneTap()
        case .screenSecurityCode:
            self.showSecurityCodeScreen()
        case .serviceCreateESCCardToken:
            self.createCardToken()
        case .payment:
            self.startPaymentFlow()
        case .finish:
            self.finishFlow()
        }
    }

    // Cancel one tap and go to checkout
    func cancelFlow() {
        model.search.deleteCheckoutDefaultOption()
        resultHandler?.cancelOneTap()
    }

    // Finish one tap and continue with checkout
    func finishFlow() {
        model.search.deleteCheckoutDefaultOption()

        if let paymentResult = model.paymentResult {
            resultHandler?.finishOneTap(paymentResult: paymentResult, instructionsInfo: model.instructionsInfo)
        } else if let businessResult = model.businessResult {
            resultHandler?.finishOneTap(businessResult: businessResult)
        } else {
            resultHandler?.finishOneTap(paymentData: model.paymentData)
        }
    }

    // Exit checkout
    func exitCheckout() {
        resultHandler?.exitCheckout()
    }
}

extension OneTapFlow {
    /// Returns a auto selected payment option from a paymentMethodSearch object. If no option can be selected it returns nil
    ///
    /// - Parameters:
    ///   - search: payment method search item
    ///   - paymentMethodPlugins: payment Methods plugins that can be show
    /// - Returns: selected payment option if possible
    static func autoSelectOneTapOption(search: PaymentMethodSearch, paymentMethodPlugins: [PXPaymentMethodPlugin]) -> PaymentMethodOption? {

        var selectedPaymentOption: PaymentMethodOption?
        if search.hasCheckoutDefaultOption() {
            // Check if can autoselect plugin
            let paymentMethodPluginsFound = paymentMethodPlugins.filter { (paymentMethodPlugin: PXPaymentMethodPlugin) -> Bool in
                return paymentMethodPlugin.getId() == search.oneTap?.paymentMethodId
            }
            if let paymentMethodPlugin = paymentMethodPluginsFound.first {
                selectedPaymentOption = paymentMethodPlugin
            } else {
                // Check if can autoselect customer card
                guard let customerPaymentMethods = search.customerPaymentMethods else {
                    return nil
                }
                let customOptionsFound = customerPaymentMethods.filter { (cardInformation: CardInformation) -> Bool in
                    return cardInformation.getCardId() == search.oneTap?.oneTapCard?.cardId
                }
                if let customerPaymentMethod = customOptionsFound.first, let customerPaymentOption = customerPaymentMethod as? PaymentMethodOption {
                    // Check if one tap response has payer costs
                    if let oneTap = search.oneTap, oneTap.oneTapCard?.selectedPayerCost != nil {
                        // Check if card found has same paymentmethod as One tap response
                        if oneTap.paymentMethodId == customerPaymentMethod.getPaymentMethodId() && oneTap.paymentTypeId == customerPaymentMethod.getPaymentTypeId() {
                            selectedPaymentOption = customerPaymentOption
                        }
                    }
                }}
        }
        return selectedPaymentOption
    }
}
