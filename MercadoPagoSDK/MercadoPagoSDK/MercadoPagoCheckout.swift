//
//  MercadoPagoCheckout.swift
//  MercadoPagoSDK
//
//  Created by Demian Tejo on 1/23/17.
//  Copyright © 2017 MercadoPago. All rights reserved.
//

import UIKit
import MercadoPagoPXTrackingV4
import MercadoPagoServicesV4

@objcMembers
open class MercadoPagoCheckout: NSObject {
    internal enum InitMode {
        case normal
        case lazy
    }

    internal var initMode: InitMode = .normal
    internal var lifecycleProtocol: PXCheckoutLifecycleProtocol?
    internal static var currentCheckout: MercadoPagoCheckout?
    internal var viewModel: MercadoPagoCheckoutViewModel

    public init(builder: MercadoPagoCheckoutBuilder) {
        var choPref: CheckoutPreference

        if let preferenceId = builder.preferenceId {
            choPref = CheckoutPreference(preferenceId: preferenceId)
        } else if let preference = builder.checkoutPreference {
            choPref = preference
        } else {
            fatalError("CheckoutPreference or preferenceId must be mandatory.")
        }

        if let accessToken = builder.privateKey {
            MercadoPagoContext.setPayerAccessToken(accessToken)
        }

        MercadoPagoContext.setPublicKey(builder.publicKey)
        PXServicesURLConfigs.PX_SDK_VERSION = MercadoPagoContext.sharedInstance.sdkVersion() //TODO: This is temporary.

        viewModel = MercadoPagoCheckoutViewModel(checkoutPreference: choPref)

        // Set advanced config.
        if let advancedConfig = builder.advancedConfig {
            viewModel.setAdvancedConfiguration(advancedConfig: advancedConfig)
            if let theme = advancedConfig.theme {
                ThemeManager.shared.setTheme(theme: theme)
            } else if let defaultColor = builder.defaultUIColor {
                ThemeManager.shared.setDefaultColor(color: defaultColor)
            }
        }

        if let paymentConfiguration = builder.paymentConfig {
            let (discountConfig, chargeRules, paymentPlugin, paymentMethodPlugins) = paymentConfiguration.getPaymentConfiguration()

            // Set charge rules
            viewModel.chargeRules = chargeRules

            // Set discount/campaign
            if let dConfig = discountConfig {
                let discountConfiguration = dConfig.getDiscountConfiguration()
                if let campaign = discountConfiguration.campaign, let discount = discountConfiguration.discount {
                    viewModel.setDiscount(discount, withCampaign: campaign)
                }
                if discountConfiguration.isNotAvailable {
                    viewModel.clearDiscount()
                    viewModel.consumedDiscount = true
                }
            }

            // Payment method plugins.
            viewModel.paymentMethodPlugins = paymentMethodPlugins
            viewModel.paymentMethodPluginsToShow = paymentMethodPlugins

            // Payment plugin (paymentProcessor).
            viewModel.paymentPlugin = paymentPlugin
        }

        viewModel.updateInitFlow()
    }
}

// MARK: Publics
extension MercadoPagoCheckout {
    public func start(navigationController: UINavigationController) {
        commondInit()
        ThemeManager.shared.initialize()
        viewModel.setNavigationHandler(handler: PXNavigationHandler(navigationController: navigationController))
        ThemeManager.shared.saveNavBarStyleFor(navigationController: navigationController)
        if initMode == .lazy {
            if viewModel.initFlow?.getStatus() == .finished {
                executeNextStep()
            } else {
                if viewModel.initFlow?.getStatus() == .running {
                    return
                } else {
                    // Lazy with "ready" to run.
                    viewModel.pxNavigationHandler.presentInitLoading()
                    executeNextStep()
                }
            }
        } else {
            viewModel.pxNavigationHandler.presentInitLoading()
            executeNextStep()
        }
    }

    public func lazyStart(lifecycleDelegate: PXCheckoutLifecycleProtocol) {
        viewModel.initFlow?.restart()
        lifecycleProtocol = lifecycleDelegate
        initMode = .lazy
        commondInit()
        executeNextStep()
    }
}

// MARK: Internals
extension MercadoPagoCheckout {
    internal func setPaymentResult(paymentResult: PaymentResult) {
        self.viewModel.paymentResult = paymentResult
    }

    internal func setPaymentData(paymentData: PaymentData) {
        self.viewModel.paymentData = paymentData
    }

    internal func enableBetaServices() {
        URLConfigs.MP_SELECTED_ENV = URLConfigs.MP_TEST_ENV
        PXServicesSettings.enableBetaServices()
        PXTrackingSettings.enableBetaServices()
    }

    internal func setCheckoutPreference(checkoutPreference: CheckoutPreference) {
        self.viewModel.checkoutPreference = checkoutPreference
    }

    internal func executePreviousStep(animated: Bool = true) {
        viewModel.pxNavigationHandler.navigationController.popViewController(animated: animated)
    }

    internal func executeNextStep() {
        switch self.viewModel.nextStep() {
        case .START :
            self.initialize()
        case .SCREEN_PAYMENT_METHOD_SELECTION:
            self.showPaymentMethodsScreen()
        case .SCREEN_CARD_FORM:
            self.showCardForm()
        case .SCREEN_IDENTIFICATION:
            self.showIdentificationScreen()
        case .SCREEN_PAYER_INFO_FLOW:
            self.showPayerInfoFlow()
        case .SCREEN_ENTITY_TYPE:
            self.showEntityTypesScreen()
        case .SCREEN_FINANCIAL_INSTITUTIONS:
            self.showFinancialInstitutionsScreen()
        case .SERVICE_GET_ISSUERS:
            self.getIssuers()
        case .SCREEN_ISSUERS:
            self.showIssuersScreen()
        case .SERVICE_CREATE_CARD_TOKEN:
            self.createCardToken()
        case .SERVICE_GET_IDENTIFICATION_TYPES:
            self.getIdentificationTypes()
        case .SERVICE_GET_PAYER_COSTS:
            self.getPayerCosts()
        case .SCREEN_PAYER_COST:
            self.showPayerCostScreen()
        case .SCREEN_REVIEW_AND_CONFIRM:
            self.showReviewAndConfirmScreen()
        case .SCREEN_SECURITY_CODE:
            self.showSecurityCodeScreen()
        case .SERVICE_POST_PAYMENT:
            self.createPayment()
        case .SCREEN_PAYMENT_RESULT:
            self.showPaymentResultScreen()
        case .ACTION_FINISH:
            self.finish()
        case .SCREEN_ERROR:
            self.showErrorScreen()
        case .SCREEN_HOOK_BEFORE_PAYMENT_METHOD_CONFIG:
            self.showHookScreen(hookStep: .BEFORE_PAYMENT_METHOD_CONFIG)
        case .SCREEN_HOOK_AFTER_PAYMENT_METHOD_CONFIG:
            self.showHookScreen(hookStep: .AFTER_PAYMENT_METHOD_CONFIG)
        case .SCREEN_HOOK_BEFORE_PAYMENT:
            self.showHookScreen(hookStep: .BEFORE_PAYMENT)
        case .SCREEN_PAYMENT_METHOD_PLUGIN_PAYMENT:
            self.showPaymentMethodPluginPaymentScreen()
        case .SCREEN_PAYMENT_METHOD_PLUGIN_CONFIG:
            self.showPaymentMethodPluginConfigScreen()
        case .SCREEN_PAYMENT_PLUGIN_PAYMENT: //PROCESADORA
            self.showPaymentPluginScreen()
        case .FLOW_ONE_TAP:
            self.startOneTapFlow()
        default: break
        }
    }

    internal func finish() {
        viewModel.pxNavigationHandler.removeRootLoading()
        if let payment = self.viewModel.payment, let paymentCallback = MercadoPagoCheckoutViewModel.paymentCallback {
            paymentCallback(payment)
            return

        } else if let finishFlowCallback = MercadoPagoCheckoutViewModel.finishFlowCallback {
            finishFlowCallback(self.viewModel.payment)
            return
        }
        viewModel.pxNavigationHandler.goToRootViewController()
    }

    internal func cancel() {
        if let callback = viewModel.callbackCancel {
            callback()
            return
        }
        viewModel.pxNavigationHandler.goToRootViewController()
    }

    @objc internal func closeCheckout() {
        PXNotificationManager.UnsuscribeTo.attemptToClose(self)
        cancel()
    }
}

// MARK: Privates
extension MercadoPagoCheckout {
    private func initialize() {
        startTracking()
        MercadoPagoCheckout.currentCheckout = self
        viewModel.pxNavigationHandler.suscribeToNavigationFlow()
        if let currentCheckout = MercadoPagoCheckout.currentCheckout {
            PXNotificationManager.SuscribeTo.attemptToClose(currentCheckout, selector: #selector(closeCheckout))
        }
        viewModel.startInitFlow()
    }

    private func startTracking() {
        MPXTracker.setPublicKey(MercadoPagoContext.sharedInstance.publicKey())
        MPXTracker.setSdkVersion(MercadoPagoContext.sharedInstance.sdkVersion())
        MPXTracker.sharedInstance.startNewFlow()
    }

    private func commondInit() {
        viewModel.setInitFlowProtocol(flowInitProtocol: self)
        if !shouldApplyDiscount() {
            viewModel.clearDiscount()
        }
    }

    private func shouldApplyDiscount() -> Bool {
        if viewModel.paymentPlugin != nil {
            return !viewModel.consumedDiscount
        }
        return false
    }

    private func removeDiscount() {
        self.viewModel.clearDiscount()
    }
}
