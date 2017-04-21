//
//  MercadoPagoCheckout.swift
//  MercadoPagoSDK
//
//  Created by Demian Tejo on 1/23/17.
//  Copyright © 2017 MercadoPago. All rights reserved.
//

import UIKit

open class MercadoPagoCheckout: NSObject {
    

    var viewModel : MercadoPagoCheckoutViewModel
    var navigationController : UINavigationController!
    var viewControllerBase : UIViewController?
    
    var countLoadings: Int = 0
    
    private var currentLoadingView : UIViewController?
    
    internal static var firstViewControllerPushed = false
    private var rootViewController : UIViewController?
    
    public init(checkoutPreference : CheckoutPreference, paymentData : PaymentData? = nil, discount: DiscountCoupon? = nil, navigationController : UINavigationController, paymentResult: PaymentResult? = nil) {
        viewModel = MercadoPagoCheckoutViewModel(checkoutPreference : checkoutPreference, paymentData: paymentData, paymentResult: paymentResult, discount : discount)
        DecorationPreference.saveNavBarStyleFor(navigationController: navigationController)
        self.navigationController = navigationController
        
        if self.navigationController.viewControllers.count > 0 {
            let  newNavigationStack = self.navigationController.viewControllers.filter {!$0.isKind(of:MercadoPagoUIViewController.self) || $0.isKind(of:CheckoutViewController.self);
            }
            viewControllerBase = newNavigationStack.last
        }
    }
    
    public func start(){
        executeNextStep()
    }
    
    func executeNextStep(){
        switch self.viewModel.nextStep() {
        case .SEARCH_PREFERENCE :
            self.collectCheckoutPreference()
        case .VALIDATE_PREFERENCE :
            self.validatePreference()
        case .SEARCH_DIRECT_DISCOUNT:
            self.collectDirectDiscount()
        case .SEARCH_PAYMENT_METHODS :
            self.collectPaymentMethodSearch()
        case .PAYMENT_METHOD_SELECTION :
            self.collectPaymentMethods()
        case .CARD_FORM:
            self.collectCard()
        case .IDENTIFICATION :
            self.collectIdentification()
        case .CREDIT_DEBIT:
            self.collectCreditDebit()
        case .GET_ISSUERS:
            self.collectIssuers()
        case .ISSUERS_SCREEN:
            self.startIssuersScreen()
        case .CREATE_CARD_TOKEN :
            self.createCardToken()
        case .GET_PAYER_COSTS:
            self.collectPayerCosts()
        case .PAYER_COST_SCREEN:
            self.startPayerCostScreen()
        case .REVIEW_AND_CONFIRM :
            self.collectPaymentData()
        case .SECURITY_CODE_ONLY :
            self.collectSecurityCode()
        case .POST_PAYMENT :
            self.createPayment()
        case .CONGRATS :
            self.displayPaymentResult()
        case .FINISH:
            self.finish()
        case .ERROR:
            self.error()
        default: break
        }
    }
    
    func collectCheckoutPreference() {
        self.presentLoading()
        MPServicesBuilder.getPreference(self.viewModel.checkoutPreference._id, baseURL: MercadoPagoCheckoutViewModel.servicePreference.getDefaultBaseURL(), success: {(checkoutPreference : CheckoutPreference) -> Void in
            self.viewModel.checkoutPreference = checkoutPreference
            self.dismissLoading()
            self.executeNextStep()
            
        }, failure: {(error : NSError) -> Void in
            self.dismissLoading()
            self.viewModel.errorInputs(error: MPSDKError.convertFrom(error), errorCallback: { (Void) -> Void in
               self.collectCheckoutPreference()
            })
            self.executeNextStep()
        })
    }
    
    func validatePreference(){
        let errorMessage = self.viewModel.checkoutPreference.validate()
        if errorMessage != nil {
            self.viewModel.errorInputs(error: MPSDKError(message: "Hubo un error".localized, messageDetail: errorMessage!, retry: false), errorCallback : { (Void) -> Void in })
        }
        self.executeNextStep()
    }
    
    func collectDirectDiscount() {
        self.presentLoading()
        MerchantServer.getDirectDiscount(transactionAmount: self.viewModel.getFinalAmount(), payerEmail: self.viewModel.checkoutPreference.payer.email, addtionalInfo: MercadoPagoCheckoutViewModel.servicePreference.discountAdditionalInfo, success: { (discount) in
            self.viewModel.paymentData.discount = discount
            self.executeNextStep()
            self.dismissLoading()
        }) { (error: NSError) in
            self.dismissLoading()
            self.executeNextStep()
        }
    }
    
    func collectPaymentMethodSearch() {
        self.presentLoading()
        MPServicesBuilder.searchPaymentMethods(self.viewModel.getFinalAmount(), defaultPaymenMethodId: self.viewModel.getDefaultPaymentMethodId(), excludedPaymentTypeIds: self.viewModel.getExcludedPaymentTypesIds(), excludedPaymentMethodIds: self.viewModel.getExcludedPaymentMethodsIds(),
                                               baseURL: MercadoPagoCheckoutViewModel.servicePreference.getDefaultBaseURL(), success: { (paymentMethodSearchResponse: PaymentMethodSearch) -> Void in
                    self.viewModel.updateCheckoutModel(paymentMethodSearch: paymentMethodSearchResponse)
                    self.dismissLoading()
                                                self.executeNextStep()
                    
                    
            }, failure: { (error) -> Void in
                self.dismissLoading()
                self.viewModel.errorInputs(error: MPSDKError.convertFrom(error), errorCallback: { (Void) -> Void in
                    self.collectPaymentMethodSearch()
                })
                self.executeNextStep()
            })
    }
    
    
    
    func collectPaymentMethods(){
        // Se limpia paymentData antes de ofrecer selección de medio de pago

    
        self.viewModel.paymentData.clear()
        let paymentMethodSelectionStep = PaymentVaultViewController(viewModel: self.viewModel.paymentVaultViewModel(), callback : { (paymentOptionSelected : PaymentMethodOption) -> Void  in
            self.viewModel.updateCheckoutModel(paymentOptionSelected : paymentOptionSelected)
            self.viewModel.rootVC = false
            self.executeNextStep()
        })
        
        self.pushViewController(viewController : paymentMethodSelectionStep, animated: true)
      
    }
    

    func collectCard(){
        
        let cardFormStep = CardFormViewController(cardFormManager: self.viewModel.cardFormManager(), callback: { (paymentMethods, cardToken) in
            self.viewModel.updateCheckoutModel(paymentMethods: paymentMethods, cardToken:cardToken)
            self.executeNextStep()
        })
        self.pushViewController(viewController : cardFormStep, animated: true)
    }
    
    func collectIdentification() {
        let identificationStep = IdentificationViewController (callback: { (identification : Identification) in
            self.viewModel.updateCheckoutModel(identification : identification)
            self.executeNextStep()
        }, errorExitCallback: { [weak self] in
            
            guard let object = self else {
                return 
            }
            object.finish()
        })
        
        identificationStep.callbackCancel = {[weak self] in
            
            guard let object = self else {
                return
            }
            object.navigationController.popViewController(animated: true)
        }
        self.pushViewController(viewController : identificationStep, animated: true)
    }
    
    func collectCreditDebit(){
        let crediDebitStep = AdditionalStepViewController(viewModel: self.viewModel.debitCreditViewModel(), callback: { (paymentMethod) in
            self.viewModel.updateCheckoutModel(paymentMethod: paymentMethod as! PaymentMethod)
            self.executeNextStep()
        })
        self.pushViewController(viewController : crediDebitStep, animated: true)
    }
    
    func collectIssuers(){
        self.presentLoading()
        let bin = self.viewModel.cardToken?.getBin()
        MPServicesBuilder.getIssuers(self.viewModel.paymentData.paymentMethod, bin: bin, baseURL: MercadoPagoCheckoutViewModel.servicePreference.getDefaultBaseURL(), success: { (issuers) -> Void in
            
            self.viewModel.issuers = issuers
            
            if issuers.count == 1 {
                self.viewModel.updateCheckoutModel(issuer: issuers[0])
            }
            self.dismissLoading()
            self.executeNextStep()
            
        }) { (error) -> Void in
            self.dismissLoading()
            self.viewModel.errorInputs(error: MPSDKError.convertFrom(error), errorCallback: { (Void) in
                self.collectIssuers()
            })
            self.executeNextStep()
        }
        
    }
    
    func startIssuersScreen() {
        let issuerStep = AdditionalStepViewController(viewModel: self.viewModel.issuerViewModel(), callback: { (issuer) in
            self.viewModel.updateCheckoutModel(issuer: issuer as! Issuer?)
            self.executeNextStep()
        })
        issuerStep.callbackCancel = {
            self.viewModel.issuers = nil
            self.viewModel.paymentData.issuer = nil
        }
        self.navigationController.pushViewController(issuerStep, animated: true)
    }

    
    func createCardToken(cardInformation: CardInformation? = nil, securityCode: String? = nil) {
        guard let cardInfo = cardInformation else {
            createNewCardToken()
            return
        }
        if cardInfo.canBeClone() {
            guard let token = cardInfo as? Token else {
                return // TODO Refactor : Tenemos unos lios barbaros con CardInformation y CardInformationForm, no entiendo porque hay uno y otr
            }
            cloneCardToken(token: token, securityCode: securityCode!)
        
        } else {
            createSavedCardToken(cardInformation: cardInfo, securityCode: securityCode!)
        }
    }
    
    func createNewCardToken() {
        self.presentLoading()
        
        MPServicesBuilder.createNewCardToken(self.viewModel.cardToken!, baseURL: MercadoPagoCheckoutViewModel.servicePreference.getGatewayURL(), success: { (token : Token?) -> Void in
            self.viewModel.updateCheckoutModel(token: token!)
            self.dismissLoading()
            self.executeNextStep()
        
        }, failure : { (error) -> Void in
            self.viewModel.errorInputs(error: MPSDKError.convertFrom(error), errorCallback: { (Void) in
                self.createNewCardToken()
            })
            self.dismissLoading()
            self.executeNextStep()
        })
    }
    
    func createSavedCardToken(cardInformation: CardInformation, securityCode: String) {
        self.presentLoading()
        
        let cardInformation = self.viewModel.paymentOptionSelected as! CardInformation
        let saveCardToken = SavedCardToken(card: cardInformation, securityCode: securityCode, securityCodeRequired: true)
        
        MPServicesBuilder.createToken(saveCardToken, baseURL: MercadoPagoCheckoutViewModel.servicePreference.getGatewayURL(), success: { (token) in
            if token.lastFourDigits.isEmpty {
                token.lastFourDigits = cardInformation.getCardLastForDigits()
            }
            self.viewModel.updateCheckoutModel(token: token)
            self.dismissLoading()
            self.executeNextStep()
            
        }, failure: { (error) in
            self.dismissLoading()
            self.viewModel.errorInputs(error: MPSDKError.convertFrom(error), errorCallback: { (Void) in
                self.createSavedCardToken(cardInformation: cardInformation, securityCode: securityCode)
            })
            self.executeNextStep()
        })
    }
    
    func cloneCardToken(token: Token, securityCode: String) {
        self.presentLoading()
        MPServicesBuilder.cloneToken(token,securityCode:securityCode, success: { (token) in
            self.viewModel.updateCheckoutModel(token: token)
            self.dismissLoading()
            self.executeNextStep()
            
        }, failure: { (error) in
            self.dismissLoading()
            self.viewModel.errorInputs(error: MPSDKError.convertFrom(error), errorCallback: { (Void) in
                self.cloneCardToken(token: token, securityCode: securityCode)
            })
            self.executeNextStep()
        })
    }

    func collectPayerCosts(updateCallback:((Void)->Void)? = nil) {
        self.presentLoading()
        let bin = self.viewModel.cardToken?.getBin()
        MPServicesBuilder.getInstallments(bin, amount: self.viewModel.getFinalAmount(), issuer: self.viewModel.paymentData.issuer, paymentMethodId: self.viewModel.paymentData.paymentMethod._id, baseURL: MercadoPagoCheckoutViewModel.servicePreference.getDefaultBaseURL(),success: { (installments) -> Void in
            self.viewModel.payerCosts = installments[0].payerCosts
            
            let defaultPayerCost = self.viewModel.checkoutPreference.paymentPreference?.autoSelectPayerCost(installments[0].payerCosts)
            if defaultPayerCost != nil {
                self.viewModel.updateCheckoutModel(payerCost: defaultPayerCost)
            }
            if let updateCallback = updateCallback {
                updateCallback()
                self.dismissLoading()
            } else {
                
                self.dismissLoading()
                self.executeNextStep()
            }

            
        }) { (error) -> Void in
            self.dismissLoading()
            self.viewModel.errorInputs(error: MPSDKError.convertFrom(error), errorCallback: { (Void) in
                self.collectPayerCosts()
            })
            self.executeNextStep()
        }
        
    }
    
    func startPayerCostScreen() {
        
        let payerCostViewModel = self.viewModel.payerCostViewModel()
        
        let payerCostStep = AdditionalStepViewController(viewModel: payerCostViewModel, callback: { (payerCost) in
            self.viewModel.updateCheckoutModel(payerCost: payerCost as! PayerCost?)
            self.executeNextStep()
        })
        payerCostStep.callbackCancel = {
            self.viewModel.payerCosts = nil
            self.viewModel.paymentData.payerCost = nil
        }
        payerCostStep.viewModel.couponCallback = {[weak self] (discount) in
            guard let strongSelf = self else {
                return
            }
            strongSelf.viewModel.paymentData.discount = discount
            payerCostStep.viewModel.discount = discount
            
            strongSelf.collectPayerCosts(updateCallback: {
                payerCostStep.updateDataSource(dataSource: (strongSelf.viewModel.payerCosts)!)
            })
            
        }
        self.pushViewController(viewController : payerCostStep, animated: true)
    }

    
    func collectPaymentData() {
            let checkoutVC = CheckoutViewController(viewModel: self.viewModel.checkoutViewModel(), callbackPaymentData: {(paymentData : PaymentData) -> Void in
                self.viewModel.updateCheckoutModel(paymentData: paymentData)
                if paymentData.paymentMethod == nil && MercadoPagoCheckoutViewModel.changePaymentMethodCallback != nil {
                    MercadoPagoCheckoutViewModel.changePaymentMethodCallback!()
                }
                self.executeNextStep()
            }, callbackCancel : { Void -> Void in
                self.viewModel.setIsCheckoutComplete(isCheckoutComplete: true)
                self.executeNextStep()
            }, callbackConfirm : {(paymentData : PaymentData) -> Void in
                self.viewModel.updateCheckoutModel(paymentData: paymentData)
                if MercadoPagoCheckoutViewModel.paymentDataConfirmCallback != nil {
                    MercadoPagoCheckoutViewModel.paymentDataConfirmCallback!(self.viewModel.paymentData)
                } else {
                    self.executeNextStep()
                }
            })
        
        self.pushViewController(viewController: checkoutVC, animated: true, completion: {
            self.cleanNavigationStack()
        })
    }
	
	func cleanNavigationStack () {
		
		// TODO WALLET
        var  newNavigationStack = self.navigationController.viewControllers.filter {!$0.isKind(of:MercadoPagoUIViewController.self) || $0.isKind(of:CheckoutViewController.self);
        }
        self.navigationController.viewControllers = newNavigationStack;
        
	}
	
    private func executePaymentDataCallback() {
        if MercadoPagoCheckoutViewModel.paymentDataCallback != nil {
            MercadoPagoCheckoutViewModel.paymentDataCallback!(self.viewModel.paymentData)
        }
	}
    
    func collectSecurityCode(){
        let securityCodeVc = SecurityCodeViewController(viewModel: self.viewModel.savedCardSecurityCodeViewModel(), collectSecurityCodeCallback : { (cardInformation: CardInformationForm, securityCode: String) -> Void in
            self.createCardToken(cardInformation: cardInformation as! CardInformation, securityCode: securityCode)

        })
        self.pushViewController(viewController : securityCodeVc, animated: true)
        
    }
    
    func collectSecurityCodeForRetry(){
        let securityCodeVc = SecurityCodeViewController(viewModel: self.viewModel.cloneTokenSecurityCodeViewModel(), collectSecurityCodeCallback: { (cardInformation: CardInformationForm, securityCode: String) -> Void in
            self.cloneCardToken(token: cardInformation as! Token, securityCode: securityCode)
            
        })
        self.pushViewController(viewController : securityCodeVc, animated: true)
        
    }
    
    public func updateReviewAndConfirm(){
        let currentViewController = self.navigationController.viewControllers
        if let checkoutVC = currentViewController.last as? CheckoutViewController {
            checkoutVC.showNavBar()
            checkoutVC.checkoutTable.reloadData()
        }
    }
    
    func createPayment() {
        self.presentLoading()
        
        var paymentBody : [String:Any]
        if MercadoPagoCheckoutViewModel.servicePreference.isUsingDeafaultPaymentSettings() {
            let mpPayment = MercadoPagoCheckoutViewModel.createMPPayment(self.viewModel.checkoutPreference.getPayer().email, preferenceId: self.viewModel.checkoutPreference._id, paymentData: self.viewModel.paymentData)
            paymentBody = mpPayment.toJSON()
        } else {
            paymentBody = self.viewModel.paymentData.toJSON()
        }
    
        MerchantServer.createPayment(paymentUrl : MercadoPagoCheckoutViewModel.servicePreference.getPaymentURL(), paymentUri : MercadoPagoCheckoutViewModel.servicePreference.getPaymentURI(), paymentBody : paymentBody as NSDictionary, success: {(payment : Payment) -> Void in
            self.viewModel.updateCheckoutModel(payment: payment)
            self.dismissLoading()
            self.executeNextStep()
            
        }, failure: {(error : NSError) -> Void in
            self.dismissLoading()
            self.viewModel.errorInputs(error: MPSDKError.convertFrom(error), errorCallback: { (Void) in
                self.createPayment()
            })
            self.executeNextStep()
        })
    }
    
    func displayPaymentResult() {
        // TODO : por que dos? esta bien? no hay view models, ver que onda
        if self.viewModel.paymentResult == nil {
            self.viewModel.paymentResult = PaymentResult(payment: self.viewModel.payment!, paymentData: self.viewModel.paymentData)            
        }

        let congratsViewController : UIViewController
        if (PaymentTypeId.isOnlineType(paymentTypeId: self.viewModel.paymentData.paymentMethod.paymentTypeId)) {
            congratsViewController = PaymentResultViewController(paymentResult: self.viewModel.paymentResult!, checkoutPreference: self.viewModel.checkoutPreference, paymentResultScreenPreference: self.viewModel.paymentResultScreenPreference, callback: { (state : PaymentResult.CongratsState) in
                if state == PaymentResult.CongratsState.call_FOR_AUTH {
                    self.navigationController.setNavigationBarHidden(false, animated: false)
                    self.viewModel.prepareForClone()
                    self.collectSecurityCodeForRetry()
                } else if state == PaymentResult.CongratsState.cancel_RETRY || state == PaymentResult.CongratsState.cancel_SELECT_OTHER {
                    self.navigationController.setNavigationBarHidden(false, animated: false)
                    self.viewModel.prepareForNewSelection()
                    self.executeNextStep()
                    
                }else{
                    self.finish()
                }
                
            })
        } else {
            congratsViewController = InstructionsViewController(paymentResult: self.viewModel.paymentResult!,  callback: { (state :PaymentResult.CongratsState) in
                self.finish()
            }, paymentResultScreenPreference: self.viewModel.paymentResultScreenPreference)
        }
        self.pushViewController(viewController : congratsViewController, animated: true)
    }
    
    func error() {
        // Display error
        let errorStep = ErrorViewController(error: MercadoPagoCheckoutViewModel.error, callback: nil, callbackCancel: {[weak self] in
            
            guard let object = self else {
                return
            }
            object.finish()
            
        })
        // Limpiar error anterior
        MercadoPagoCheckoutViewModel.error = nil
        
        errorStep.callback = {
            self.navigationController.dismiss(animated: true, completion: {
                self.viewModel.errorCallback?()
            })
        }
        self.navigationController.present(errorStep, animated: true, completion: {})
    }
    
    func finish(){
        DecorationPreference.applyAppNavBarDecorationPreferencesTo(navigationController: self.navigationController)
        
        removeRootLoading()
        
        if self.viewModel.paymentData.isComplete() && !MercadoPagoCheckoutViewModel.flowPreference.isReviewAndConfirmScreenEnable() && MercadoPagoCheckoutViewModel.paymentDataCallback != nil {
            MercadoPagoCheckoutViewModel.paymentDataCallback!(self.viewModel.paymentData)
            return
        } else if let payment = self.viewModel.payment, let paymentCallback = MercadoPagoCheckoutViewModel.paymentCallback {
            paymentCallback(payment)
        } else if let callback = MercadoPagoCheckoutViewModel.callback {
            callback()
            return
        }
        
        goToRootViewController()
    }
    
    public func goToRootViewController(){
        if let rootViewController = viewControllerBase {
            self.navigationController.popToViewController(rootViewController, animated: true)
            self.navigationController.setNavigationBarHidden(false, animated: false)
        } else {
            self.navigationController.dismiss(animated: true, completion: {
                // --- Nothing
                self.navigationController.setNavigationBarHidden(false, animated: false)
            })
        }
    }
    
    
    func presentLoading(animated : Bool = false, completion: (() -> Swift.Void)? = nil) {
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
    
    func dismissLoading(animated : Bool = false, completion: (() -> Swift.Void)? = nil) {
        self.countLoadings -= 1
        if self.currentLoadingView != nil && countLoadings == 0 {
            self.currentLoadingView!.dismiss(animated: animated, completion: completion)
            self.currentLoadingView?.view.alpha = 0
            self.currentLoadingView = nil
        }
    }
    
    private func createCurrentLoading() {
        let vcLoading = MPXLoadingViewController()
        vcLoading.view.backgroundColor = MercadoPagoCheckoutViewModel.decorationPreference.baseColor
        let loadingInstance = LoadingOverlay.shared.showOverlay(vcLoading.view, backgroundColor: MercadoPagoCheckoutViewModel.decorationPreference.baseColor)
        
        vcLoading.view.addSubview(loadingInstance)
        loadingInstance.bringSubview(toFront: vcLoading.view)
        
        self.currentLoadingView = vcLoading
    }
    
    private func pushViewController(viewController: UIViewController,
                                    animated: Bool,
                                    completion : (() -> Swift.Void)? = nil) {
        
        viewController.hidesBottomBarWhenPushed = true
        self.navigationController.pushViewController(viewController, animated: animated)
    }
    
    internal func removeRootLoading() {
        let currentViewControllers = self.navigationController.viewControllers.filter { (vc : UIViewController) -> Bool in
            return vc != self.rootViewController
        }
        self.navigationController.viewControllers = currentViewControllers
    }
    

}

extension MercadoPagoCheckout {
    
    open static func setDecorationPreference(_ decorationPreference: DecorationPreference){
        MercadoPagoCheckoutViewModel.decorationPreference = decorationPreference
    }
    
    open static func setServicePreference(_ servicePreference: ServicePreference){
        MercadoPagoCheckoutViewModel.servicePreference = servicePreference
    }
    
    open static func setFlowPreference(_ flowPreference: FlowPreference){
        MercadoPagoCheckoutViewModel.flowPreference = flowPreference
    }
    
    open func setPaymentResultScreenPreference(_ paymentResultScreenPreference: PaymentResultScreenPreference){
        self.viewModel.paymentResultScreenPreference = paymentResultScreenPreference
    }
    
    open func setReviewScreenPreference(_ reviewScreenPreference: ReviewScreenPreference){
        self.viewModel.reviewScreenPreference = reviewScreenPreference
    }
    
    open static func setPaymentDataCallback(paymentDataCallback : @escaping (_ paymentData : PaymentData) -> Void) {
        MercadoPagoCheckoutViewModel.paymentDataCallback = paymentDataCallback
    }
    
    open static func setChangePaymentMethodCallback(changePaymentMethodCallback : @escaping (Void) -> Void) {
        MercadoPagoCheckoutViewModel.changePaymentMethodCallback = changePaymentMethodCallback
    }
    
    open static func setPaymentCallback(paymentCallback : @escaping (_ payment : Payment) -> Void) {
        MercadoPagoCheckoutViewModel.paymentCallback = paymentCallback
    }
    
    open static func setPaymentDataConfirmCallback(paymentDataConfirmCallback : @escaping (_ paymentData : PaymentData) -> Void) {
        MercadoPagoCheckoutViewModel.paymentDataConfirmCallback = paymentDataConfirmCallback
    }
    
    open static func setCallback(callback : @escaping (Void) -> Void) {
        MercadoPagoCheckoutViewModel.callback = callback
    }

}
