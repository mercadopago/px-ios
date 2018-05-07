//
//  MercadoPagoCheckout.swift
//  MercadoPagoSDK
//
//  Created by Demian Tejo on 1/23/17.
//  Copyright © 2017 MercadoPago. All rights reserved.
//

import UIKit
import MercadoPagoPXTracking

@objcMembers
open class MercadoPagoCheckout: NSObject {

    static var currentCheckout: MercadoPagoCheckout?
    var viewModel: MercadoPagoCheckoutViewModel
    var navigationController: UINavigationController!
    var viewControllerBase: UIViewController?
    var countLoadings: Int = 0

    private var currentLoadingView: UIViewController?

    internal static var firstViewControllerPushed = false
    private var rootViewController: UIViewController?

    var entro = false

    public init(publicKey: String, accessToken: String, checkoutPreference: CheckoutPreference, paymentData: PaymentData?, paymentResult: PaymentResult?, discount: DiscountCoupon? = nil, navigationController: UINavigationController) {

        MercadoPagoCheckoutViewModel.flowPreference.removeHooks()

        MercadoPagoContext.setPublicKey(publicKey)
        MercadoPagoContext.setPayerAccessToken(accessToken)

        ThemeManager.shared.initialize()

        viewModel = MercadoPagoCheckoutViewModel(checkoutPreference: checkoutPreference, paymentData: paymentData, paymentResult: paymentResult, discount: discount)

        ThemeManager.shared.saveNavBarStyleFor(navigationController: navigationController)

        MercadoPagoCheckoutViewModel.flowPreference.disableESC()

        self.navigationController = navigationController

        if self.navigationController.viewControllers.count > 0 {
            let  newNavigationStack = self.navigationController.viewControllers.filter {!$0.isKind(of: MercadoPagoUIViewController.self) || $0.isKind(of: PXReviewViewController.self)
            }
            viewControllerBase = newNavigationStack.last
        }
    }

    public func setTheme(_ theme: PXTheme) {
        ThemeManager.shared.setTheme(theme: theme)
    }

    public func setDefaultColor(_ color: UIColor) {
        ThemeManager.shared.setDefaultColor(color: color)
    }

    func initMercadPagoPXTracking() {
        MPXTracker.setPublicKey(MercadoPagoContext.sharedInstance.publicKey())
        MPXTracker.setSdkVersion(MercadoPagoContext.sharedInstance.sdkVersion())
        MPXTracker.sharedInstance.startNewFlow()
    }

    public func setBinaryMode(_ binaryMode: Bool) {
        self.viewModel.binaryMode = binaryMode
    }

    public func start() {
        presentInitLoading()
        MercadoPagoCheckout.currentCheckout = self
        executeNextStep()
    }

    public func setPaymentResult(paymentResult: PaymentResult) {
        self.viewModel.paymentResult = paymentResult
    }

    public func setCheckoutPreference(checkoutPreference: CheckoutPreference) {
        self.viewModel.checkoutPreference = checkoutPreference
    }

    public func setPaymentData(paymentData: PaymentData) {
        self.viewModel.paymentData = paymentData
    }

    public func setPaymentMethodPlugins(plugins: [PXPaymentMethodPlugin]) {
        self.viewModel.paymentMethodPlugins = plugins
        self.viewModel.paymentMethodPluginsToShow = plugins
    }

    public func getPXCheckoutStore() -> PXCheckoutStore {
        _ = self.viewModel.copyViewModelAndAssignToCheckoutStore()
        return PXCheckoutStore.sharedInstance
    }

    public func setPaymentPlugin(paymentPlugin: PXPaymentPluginComponent) {
        self.viewModel.paymentPlugin = paymentPlugin
    }

    public func resume() {
        MercadoPagoCheckout.currentCheckout = self
        executeNextStep()
    }

    func executePreviousStep(animated: Bool = true) {
        self.navigationController.popViewController(animated: animated)
    }

    func initialize() {
        initMercadPagoPXTracking()
        // Disable init:trackScreen for v4.0
        // TODO-v4.1: Change trackScreen by trackEvent, in order to get convertion insights
        // MPXTracker.trackScreen(screenId: TrackingUtil.SCREEN_ID_CHECKOUT, screenName: TrackingUtil.SCREEN_NAME_CHECKOUT)
        executeNextStep()
        suscribeToNavigationFlow()
        PXNotificationManager.SuscribeTo.attemptToClose(MercadoPagoCheckout.currentCheckout, selector: #selector(closeCheckout))
    }

    func executeNextStep() {

        switch self.viewModel.nextStep() {
        case .START :
            self.initialize()
        case .SERVICE_GET_PREFERENCE:
            self.getCheckoutPreference()
        case .ACTION_VALIDATE_PREFERENCE:
            self.validatePreference()
        case .SERVICE_GET_DIRECT_DISCOUNT:
            self.getDirectDiscount()
        case .SERVICE_GET_PAYMENT_METHODS:
            self.getPaymentMethodSearch()
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
        case .SERVICE_GET_INSTRUCTIONS:
            self.getInstructions()
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
        case .SERVICE_PAYMENT_METHOD_PLUGIN_INIT:
            self.initPaymentMethodPlugins()
        default: break
        }
    }

    func validatePreference() {
        let errorMessage = self.viewModel.checkoutPreference.validate()
        if errorMessage != nil {
            self.viewModel.errorInputs(error: MPSDKError(message: "Hubo un error".localized, errorDetail: errorMessage!, retry: false), errorCallback: { () -> Void in })
        }
        self.executeNextStep()
    }

    func cleanCompletedCheckoutsFromNavigationStack() {
        let  pxResultViewControllers = self.navigationController.viewControllers.filter {$0.isKind(of: PXResultViewController.self)}
        if let lastResultViewController = pxResultViewControllers.last {
            let index = self.navigationController.viewControllers.index(of: lastResultViewController)
            let  validViewControllers = self.navigationController.viewControllers.filter {!$0.isKind(of: MercadoPagoUIViewController.self) || self.navigationController.viewControllers.index(of: $0)! > index! || $0 == self.navigationController.viewControllers.last }
            self.navigationController.viewControllers = validViewControllers
        }
    }

    private func executePaymentDataCallback() {
        if MercadoPagoCheckoutViewModel.paymentDataCallback != nil {
            MercadoPagoCheckoutViewModel.paymentDataCallback!(self.viewModel.paymentData)
        }
    }

    public func updateReviewAndConfirm() {
        let currentViewController = self.navigationController.viewControllers
        if let checkoutVC = currentViewController.last as? PXReviewViewController {
            checkoutVC.update(viewModel: self.viewModel.reviewConfirmViewModel())
        }
    }

    func finish() {

        removeRootLoading()

        if self.viewModel.paymentData.isComplete() && !MercadoPagoCheckoutViewModel.flowPreference.isReviewAndConfirmScreenEnable() && MercadoPagoCheckoutViewModel.paymentDataCallback != nil && !self.viewModel.isCheckoutComplete() {
            MercadoPagoCheckoutViewModel.paymentDataCallback!(self.viewModel.paymentData)
            return

        } else if self.viewModel.paymentData.isComplete() && MercadoPagoCheckoutViewModel.flowPreference.isReviewAndConfirmScreenEnable() && MercadoPagoCheckoutViewModel.paymentDataConfirmCallback != nil && !self.viewModel.isCheckoutComplete() {
            MercadoPagoCheckoutViewModel.paymentDataConfirmCallback!(self.viewModel.paymentData)
            return

        } else if let payment = self.viewModel.payment, let paymentCallback = MercadoPagoCheckoutViewModel.paymentCallback {
            paymentCallback(payment)
            return

        } else if let finishFlowCallback = MercadoPagoCheckoutViewModel.finishFlowCallback {
            finishFlowCallback(self.viewModel.payment)
            return
        }

        goToRootViewController()
    }

    func cancel() {

        if let callback = viewModel.callbackCancel {
            callback()
            return
        }

        goToRootViewController()
    }
    @objc
    func closeCheckout(){
        PXNotificationManager.UnsuscribeTo.attemptToClose(self)
        cancel()
    }

    public func goToRootViewController() {
        if let rootViewController = viewControllerBase {
            self.navigationController.popToViewController(rootViewController, animated: true)
            self.navigationController.setNavigationBarHidden(false, animated: false)
        } else {
            self.navigationController.dismiss(animated: true, completion: {
                self.navigationController.setNavigationBarHidden(false, animated: false)
            })
        }
    }

    func presentLoading(animated: Bool = false, completion: (() -> Swift.Void)? = nil) {
        self.countLoadings += 1
        if self.countLoadings == 1 {
            let when = DispatchTime.now() //+ 0.3
            DispatchQueue.main.asyncAfter(deadline: when) {
                if self.countLoadings > 0 && self.currentLoadingView == nil {
                    self.createCurrentLoading()
                    self.currentLoadingView?.modalTransitionStyle = .crossDissolve
                    self.navigationController.present(self.currentLoadingView!, animated: true, completion: completion)
                }
            }
        }
    }

    func presentInitLoading() {
        self.createCurrentLoading()
        self.currentLoadingView?.modalTransitionStyle = .crossDissolve
        self.navigationController.present(self.currentLoadingView!, animated: false, completion: nil)
    }

    func dismissLoading(animated: Bool = true, finishCallback:(()-> Void)? = nil) {
        self.countLoadings = 0
        if self.currentLoadingView != nil {
            self.currentLoadingView?.modalTransitionStyle = .crossDissolve
            self.currentLoadingView!.dismiss(animated: animated, completion: {
                self.currentLoadingView = nil
                if let callback = finishCallback {
                    callback()
                }
            })
        }
    }

    internal func createCurrentLoading() {
        let vcLoading = MPXLoadingViewController()
        vcLoading.view.backgroundColor = ThemeManager.shared.getTheme().loadingComponent().backgroundColor
        let loadingInstance = LoadingOverlay.shared.showOverlay(vcLoading.view, backgroundColor: ThemeManager.shared.getTheme().loadingComponent().backgroundColor, indicatorColor: ThemeManager.shared.getTheme().loadingComponent().tintColor)
        vcLoading.view.addSubview(loadingInstance)
        loadingInstance.bringSubview(toFront: vcLoading.view)
        self.currentLoadingView = vcLoading
    }

    internal func pushViewController(viewController: MercadoPagoUIViewController,
                                     animated: Bool, backToChechoutRoot: Bool = false) {

        viewController.hidesBottomBarWhenPushed = true
        // let mercadoPagoViewControllers = self.navigationController.viewControllers.filter {$0.isKind(of:MercadoPagoUIViewController.self)}
        // Se remueve el comportamiento custom para el back. Ahora el back respeta el stack de navegacion, no hace popToX view controller
        if backToChechoutRoot {
            self.navigationController.navigationBar.isHidden = false
            viewController.callbackCancel = { [weak self] in self?.backToCheckouitRoot() }
        }

        self.navigationController.pushViewController(viewController, animated: animated)
        self.cleanCompletedCheckoutsFromNavigationStack()
        self.dismissLoading()
    }

    func backToCheckouitRoot() {
        let mercadoPagoViewControllers = self.navigationController.viewControllers.filter {$0.isKind(of: MercadoPagoUIViewController.self)}
        if !mercadoPagoViewControllers.isEmpty {
            self.navigationController.popToViewController(mercadoPagoViewControllers[0], animated: true)
        }

    }
    internal func removeRootLoading() {
        let currentViewControllers = self.navigationController.viewControllers.filter { (viewController: UIViewController) -> Bool in
            return viewController != self.rootViewController
        }
        self.navigationController.viewControllers = currentViewControllers
    }

    public func popToWhenFinish(viewController: UIViewController) {
        if self.navigationController.viewControllers.contains(viewController) {
            self.viewControllerBase = viewController
        }
    }

}

extension MercadoPagoCheckout: UINavigationControllerDelegate {

    fileprivate func suscribeToNavigationFlow() {
        navigationController.delegate = self
    }

    public func navigationController(_ navigationController: UINavigationController, willShow viewController: UIViewController, animated: Bool) {
        if !(viewController is MercadoPagoUIViewController) {
            ThemeManager.shared.applyAppNavBarStyle(navigationController: navigationController)
            PXCheckoutStore.sharedInstance.clean()
        }
    }
}
