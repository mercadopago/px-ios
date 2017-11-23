//
//  MercadoPagoCheckout.swift
//  MercadoPagoSDK
//
//  Created by Demian Tejo on 1/23/17.
//  Copyright © 2017 MercadoPago. All rights reserved.
//

import UIKit
import MercadoPagoPXTracking

open class MercadoPagoCheckout: NSObject {

    static var currentCheckout: MercadoPagoCheckout?
    var viewModel: MercadoPagoCheckoutViewModel
    var navigationController: UINavigationController!
    var viewControllerBase: UIViewController?
    var countLoadings: Int = 0
    var mpAction: MPAction?

    private var currentLoadingView: UIViewController?

    internal static var firstViewControllerPushed = false
    private var rootViewController: UIViewController?

    var entro = false

    public init(publicKey: String, accessToken: String, checkoutPreference: CheckoutPreference, paymentData: PaymentData?, paymentResult: PaymentResult?, discount: DiscountCoupon? = nil, navigationController: UINavigationController) {

        MercadoPagoContext.setPublicKey(publicKey)
        MercadoPagoContext.setPayerAccessToken(accessToken)

        viewModel = MercadoPagoCheckoutViewModel(checkoutPreference : checkoutPreference, paymentData: paymentData, paymentResult: paymentResult, discount : discount)
        DecorationPreference.saveNavBarStyleFor(navigationController: navigationController)
        MercadoPagoCheckoutViewModel.flowPreference.disableESC()
        self.navigationController = navigationController

        if self.navigationController.viewControllers.count > 0 {
            let  newNavigationStack = self.navigationController.viewControllers.filter {!$0.isKind(of:MercadoPagoUIViewController.self) || $0.isKind(of:ReviewScreenViewController.self)
            }
            viewControllerBase = newNavigationStack.last
        }
    }

    func initMercadPagoPXTracking() {
        MPXTracker.setPublicKey(MercadoPagoContext.sharedInstance.publicKey())
        MPXTracker.setSdkVersion(MercadoPagoContext.sharedInstance.sdkVersion())
    }

    public func setBinaryMode(_ binaryMode: Bool) {
        self.viewModel.binaryMode = binaryMode
    }

    public func start() {
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

    public func resume() {
        MercadoPagoCheckout.currentCheckout = self
        executeNextStep()
    }

    func initialize() {
        initMercadPagoPXTracking()
        MPXTracker.trackScreen(screenId: TrackingUtil.SCREEN_ID_CHECKOUT, screenName: TrackingUtil.SCREEN_NAME_CHECKOUT)
        executeNextStep()
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
        case .SCREEN_HOOK_1:
            self.showHookScreen(hookStep: .STEP1)
        default: break
        }
    }
    
    func executePreviousStep(animated:Bool=true) {
        self.navigationController.popViewController(animated: animated)
    }

    func validatePreference() {
        let errorMessage = self.viewModel.checkoutPreference.validate()
        if errorMessage != nil {
            self.viewModel.errorInputs(error: MPSDKError(message: "Hubo un error".localized, errorDetail: errorMessage!, retry: false), errorCallback : { (_) -> Void in })
        }
        self.executeNextStep()
    }

    func cleanNavigationStack () {
        var  newNavigationStack = self.navigationController.viewControllers.filter {!$0.isKind(of:MercadoPagoUIViewController.self) || $0.isKind(of:ReviewScreenViewController.self)
        }
        self.navigationController.viewControllers = newNavigationStack
    }

    private func executePaymentDataCallback() {
        if MercadoPagoCheckoutViewModel.paymentDataCallback != nil {
            MercadoPagoCheckoutViewModel.paymentDataCallback!(self.viewModel.paymentData)
        }
    }

    public func updateReviewAndConfirm() {
        let currentViewController = self.navigationController.viewControllers
        if let checkoutVC = currentViewController.last as? ReviewScreenViewController {
            checkoutVC.showNavBar()
            checkoutVC.viewModel = viewModel.checkoutViewModel()
            checkoutVC.checkoutTable.reloadData()
        }
    }

    func finish() {
        DecorationPreference.applyAppNavBarDecorationPreferencesTo(navigationController: self.navigationController)
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
        }

        goToRootViewController()
    }

    func cancel() {
        DecorationPreference.applyAppNavBarDecorationPreferencesTo(navigationController: self.navigationController)

        if let callback = viewModel.callbackCancel {
            callback()
            return
        }

        goToRootViewController()
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
            let when = DispatchTime.now() + 0.3
            DispatchQueue.main.asyncAfter(deadline: when) {
                if self.countLoadings > 0 && self.currentLoadingView == nil {
                    self.createCurrentLoading()
                    self.navigationController.present(self.currentLoadingView!, animated: animated, completion: completion)
                }
            }
        }
    }

    func dismissLoading(animated: Bool = false, completion: (() -> Swift.Void)? = nil) {
        self.countLoadings -= 1
        if self.currentLoadingView != nil && countLoadings == 0 {
            self.currentLoadingView!.dismiss(animated: animated, completion: completion)
            self.currentLoadingView?.view.alpha = 0
            self.currentLoadingView = nil
        }
    }

    internal func createCurrentLoading() {
        let vcLoading = MPXLoadingViewController()
        vcLoading.view.backgroundColor = MercadoPagoCheckoutViewModel.decorationPreference.baseColor
        let loadingInstance = LoadingOverlay.shared.showOverlay(vcLoading.view, backgroundColor: MercadoPagoCheckoutViewModel.decorationPreference.baseColor)

        vcLoading.view.addSubview(loadingInstance)
        loadingInstance.bringSubview(toFront: vcLoading.view)

        self.currentLoadingView = vcLoading
    }

    internal func pushViewController(viewController: MercadoPagoUIViewController,
                                    animated: Bool,
                                    completion : (() -> Swift.Void)? = nil) {

        viewController.hidesBottomBarWhenPushed = true
        let mercadoPagoViewControllers = self.navigationController.viewControllers.filter {$0.isKind(of:MercadoPagoUIViewController.self)}
        if mercadoPagoViewControllers.count == 0 {
            self.navigationController.navigationBar.isHidden = false
            viewController.callbackCancel = { self.cancel() }
        }
        self.navigationController.pushViewController(viewController, animated: animated)
    }

    internal func removeRootLoading() {
        let currentViewControllers = self.navigationController.viewControllers.filter { (vc: UIViewController) -> Bool in
            return vc != self.rootViewController
        }
        self.navigationController.viewControllers = currentViewControllers
    }

    public func popToWhenFinish(viewController: UIViewController) {
        if self.navigationController.viewControllers.contains(viewController) {
            self.viewControllerBase = viewController
        }
    }

}

@objc
public protocol Componetisable {
    func render() -> UIView
}

@objc
public protocol Hookeable: Componetisable {
    func getStep() -> HookStep
    func render() -> UIView
    func renderDidFinish()
    func didRecive(hookStore: HookStore)
    func titleForNavigationBar() -> String
    func shouldShowBackArrow() -> Bool
    func shouldShowNavigationBar() -> Bool
}

open class MPAction: NSObject {

    private var checkout: MercadoPagoCheckout?

    public init(withCheckout:MercadoPagoCheckout) {
        self.checkout = withCheckout
    }
    
    open func next() {
        checkout?.executeNextStep()
    }
    
    open func back() {
        checkout?.executePreviousStep()
    }
    
    open func cancel() {
        checkout?.cancel()
    }
}

open class HookStore: NSObject {

    static let sharedInstance = HookStore()
    private var data = [String : Any]()
    var paymentData = PaymentData()
    var paymentOptionSelected: PaymentMethodOption?

    public func addData(forKey: String, value: Any) {
        self.data[forKey] = value
    }
    public func remove(key: String) {
        data.removeValue(forKey: key)
    }

    public func removeAll() {
        data.removeAll()
    }

    public func getData(forKey: String) -> Any? {
        return self.data[forKey]
    }

    public func getPaymentData() -> PaymentData {
        return paymentData
    }

    public func getPaymentOptionSelected() -> PaymentMethodOption? {
        return paymentOptionSelected
    }

}
