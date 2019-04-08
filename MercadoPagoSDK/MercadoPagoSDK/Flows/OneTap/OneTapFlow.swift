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

    init(navigationController: PXNavigationHandler, paymentData: PXPaymentData, checkoutPreference: PXCheckoutPreference, search: PXPaymentMethodSearch, paymentOptionSelected: PaymentMethodOption, reviewConfirmConfiguration: PXReviewConfirmConfiguration, chargeRules: [PXPaymentTypeChargeRule]?, oneTapResultHandler: PXOneTapResultHandlerProtocol, advancedConfiguration: PXAdvancedConfiguration, mercadoPagoServicesAdapter: MercadoPagoServicesAdapter, paymentConfigurationService: PXPaymentConfigurationServices, disabledOption: PXDisabledOption? = nil) {
        pxNavigationHandler = navigationController
        resultHandler = oneTapResultHandler
        advancedConfig = advancedConfiguration
        model = OneTapFlowModel(paymentData: paymentData, checkoutPreference: checkoutPreference, search: search, paymentOptionSelected: paymentOptionSelected, chargeRules: chargeRules, mercadoPagoServicesAdapter: mercadoPagoServicesAdapter, advancedConfiguration: advancedConfiguration, paymentConfigurationService: paymentConfigurationService, disabledOption: disabledOption)
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

    // Cancel one tap and go to checkout
    func cancelFlowForNewPaymentSelection() {
        model.search.deleteCheckoutDefaultOption()
        resultHandler?.cancelOneTapForNewPaymentMethodSelection()
    }

    // Finish one tap and continue with checkout
    func finishFlow() {
        if let paymentResult = model.paymentResult {
            resultHandler?.finishOneTap(paymentResult: paymentResult, instructionsInfo: model.instructionsInfo)
        } else if let businessResult = model.businessResult {
            resultHandler?.finishOneTap(businessResult: businessResult, paymentData: model.paymentData, splitAccountMoney: model.splitAccountMoney)
        } else {
            resultHandler?.finishOneTap(paymentData: model.paymentData, splitAccountMoney: model.splitAccountMoney)
        }
    }

    // Exit checkout
    func exitCheckout() {
        resultHandler?.exitCheckout()
    }

    func setCustomerPaymentMethods(_ customPaymentMethods: [CustomerPaymentMethod]?) {
        model.customerPaymentOptions = customPaymentMethods
    }

    func setPaymentMethodPlugins(_ plugins: [PXPaymentMethodPlugin]?) {
        model.paymentMethodPlugins = plugins
    }
}

extension OneTapFlow {
    /// Returns a auto selected payment option from a paymentMethodSearch object. If no option can be selected it returns nil
    ///
    /// - Parameters:
    ///   - search: payment method search item
    ///   - paymentMethodPlugins: payment Methods plugins that can be show
    /// - Returns: selected payment option if possible
    static func autoSelectOneTapOption(search: PXPaymentMethodSearch, customPaymentOptions: [CustomerPaymentMethod]?, paymentMethodPlugins: [PXPaymentMethodPlugin], amountHelper: PXAmountHelper) -> PaymentMethodOption? {
        var selectedPaymentOption: PaymentMethodOption?
        if search.hasCheckoutDefaultOption() {
            // Check if can autoselect plugin
            let paymentMethodPluginsFound = paymentMethodPlugins.filter { (paymentMethodPlugin: PXPaymentMethodPlugin) -> Bool in
                return paymentMethodPlugin.getId() == search.expressCho?.first?.paymentMethodId
            }
            if let paymentMethodPlugin = paymentMethodPluginsFound.first {
                selectedPaymentOption = paymentMethodPlugin
            } else {

                // Check if can autoselect customer card
                guard let customerPaymentMethods = customPaymentOptions else {
                    return nil
                }

                if let suggestedAccountMoney = search.expressCho?.first?.accountMoney {
                    selectedPaymentOption = suggestedAccountMoney
                } else if let firstPaymentMethodId = search.expressCho?.first?.paymentMethodId {
                    let customOptionsFound = customerPaymentMethods.filter { return $0.getPaymentMethodId() == firstPaymentMethodId }
                    if let customerPaymentMethod = customOptionsFound.first {
                        // Check if one tap response has payer costs
                        if let expressNode = search.getPaymentMethodInExpressCheckout(targetId: customerPaymentMethod.getId()).expressNode, let expressPaymentMethod = expressNode.oneTapCard, amountHelper.paymentConfigurationService.getSelectedPayerCostsForPaymentMethod(expressPaymentMethod.cardId) != nil {
                            if expressNode.paymentMethodId == customerPaymentMethod.getPaymentMethodId() && expressNode.paymentTypeId == customerPaymentMethod.getPaymentTypeId() {
                                selectedPaymentOption = customerPaymentMethod
                            }
                        }
                    }
                }
            }
        }
        return selectedPaymentOption
    }

    func getCustomerPaymentOption(forId: String) -> PaymentMethodOption? {
        guard let customerPaymentMethods = model.customerPaymentOptions else {
            return nil
        }
        let customOptionsFound = customerPaymentMethods.filter { return $0.card?.id == forId }
        return customOptionsFound.first
    }
}
