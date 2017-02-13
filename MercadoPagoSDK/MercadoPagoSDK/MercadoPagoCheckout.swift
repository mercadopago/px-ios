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
    
    private var currentLoadingView : UIViewController?
    
    public init(checkoutPreference : CheckoutPreference, navigationController : UINavigationController) {
        viewModel = MercadoPagoCheckoutViewModel(checkoutPreference: checkoutPreference)

        self.navigationController = navigationController
    
        if self.navigationController.viewControllers.count > 0 {
            viewControllerBase = self.navigationController.viewControllers[0]
        }
    }
    
    public init(checkoutPreference : CheckoutPreference, paymentData : PaymentData, navigationController : UINavigationController) {
        viewModel = MercadoPagoCheckoutViewModel(checkoutPreference : checkoutPreference, paymentData: paymentData)
        
        self.navigationController = navigationController
        
        if self.navigationController.viewControllers.count > 0 {
            viewControllerBase = self.navigationController.viewControllers[0]
        }
    }
    
    
    open static func addConfirmAdditionalCells(_ cells: [MPCustomCells]){
        MercadoPagoCheckoutViewModel.confirmAdditionalCustomCells = cells
    }
    
    open static func addConfirmItemCells(_ cells: [MPCustomCells]){
        MercadoPagoCheckoutViewModel.confirmItemsCells = cells
    }
    
    open static func setDecorationPreference(_ decorationPreference: DecorationPreference){
        MercadoPagoCheckoutViewModel.decorationPreference = decorationPreference
    }
    
    open static func setServicePreference(_ servicePreference: ServicePreference){
        MercadoPagoCheckoutViewModel.servicePreference = servicePreference
    }
    
    open static func setFlowPreference(_ flowPreference: FlowPreference){
        MercadoPagoCheckoutViewModel.flowPreference = flowPreference
    }
    
    open static func setPaymentDataCallback(paymentDataCallback : @escaping (_ paymentData : PaymentData) -> Void) {
        MercadoPagoCheckoutViewModel.paymentDataCallback = paymentDataCallback
    }
    
    public func start(){
        executeNextStep()
    }
    
    func executeNextStep(){
        switch self.viewModel.nextStep() {
        case .SEARCH_PREFENCE :
            self.collectCheckoutPreference()
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
        case .ISSUER:
            self.collectIssuer()
        case .CREATE_CARD_TOKEN :
            self.createCardToken()
        case .PAYER_COST:
            self.collectPayerCost()
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
        MPServicesBuilder.getPreference(self.viewModel.checkoutPreference._id, success: {(checkoutPreference : CheckoutPreference) -> Void in
            self.viewModel.checkoutPreference = checkoutPreference
            self.executeNextStep()
           // self.dismissLoading()
        }, failure: {(error : NSError) -> Void in
            self.viewModel.errorInputs(error: MPSDKError.convertFrom(error), errorCallback: { (Void) -> Void in
               self.collectCheckoutPreference()
            })
            self.executeNextStep()
        })
    }
    
    func collectPaymentMethodSearch() {
        self.presentLoading()
        MPServicesBuilder.searchPaymentMethods(self.viewModel.getAmount(), defaultPaymenMethodId: self.viewModel.getDefaultPaymentMethodId(), excludedPaymentTypeIds: self.viewModel.getExcludedPaymentTypesIds(), excludedPaymentMethodIds: self.viewModel.getExcludedPaymentMethodsIds(),
                success: { (paymentMethodSearchResponse: PaymentMethodSearch) -> Void in
                    self.viewModel.updateCheckoutModel(paymentMethodSearch: paymentMethodSearchResponse)
                    self.executeNextStep()
                    self.dismissLoading()
                    
            }, failure: { (error) -> Void in
                self.viewModel.errorInputs(error: MPSDKError.convertFrom(error), errorCallback: { (Void) -> Void in
                    self.collectPaymentMethodSearch()
                })
                self.executeNextStep()
            })
    }
    
    
    
    func collectPaymentMethods(){
        let paymentMethodSelectionStep = PaymentVaultViewController(viewModel: self.viewModel.paymentVaultViewModel(), callback : { (paymentOptionSelected : PaymentMethodOption) -> Void  in
            self.viewModel.updateCheckoutModel(paymentOptionSelected : paymentOptionSelected)
            self.viewModel.rootVC = false
            self.executeNextStep()
        })
        
        self.navigationController.pushViewController(paymentMethodSelectionStep, animated: true)
    }
    

    func collectCard(){
        
        let cardFormStep = CardFormViewController(cardFormManager: self.viewModel.cardFormManager(), callback: { (paymentMethods, cardToken) in
            self.viewModel.updateCheckoutModel(paymentMethods: paymentMethods, cardToken:cardToken)
            self.executeNextStep()
        })
        self.navigationController.pushViewController(cardFormStep, animated: true)
    }
    
    func collectIdentification() {
        let identificationStep = IdentificationViewController { (identification : Identification) in
            self.viewModel.updateCheckoutModel(identification : identification)
            self.executeNextStep()
        }
        identificationStep.callbackCancel = { self.navigationController.popViewController(animated: true)}
        self.navigationController.pushViewController(identificationStep, animated: true)
    }
    
    func collectCreditDebit(){
        let crediDebitStep = CardAdditionalViewController(viewModel: self.viewModel.debitCreditViewModel(), collectPaymentMethodCallback: { (paymentMethod) in
            self.viewModel.updateCheckoutModel(paymentMethod: paymentMethod)
            self.executeNextStep()
        })
        self.navigationController.pushViewController(crediDebitStep, animated: true)
    }
    
    func collectIssuer(){
        let issuerStep = CardAdditionalViewController(viewModel: self.viewModel.issuerViewModel(), collectIssuerCallback: { (issuer) in
            self.viewModel.updateCheckoutModel(issuer: issuer)
            self.executeNextStep()
        })
        self.navigationController.pushViewController(issuerStep, animated: true)
    }
    
    func createCardToken() {
        MPServicesBuilder.createNewCardToken(self.viewModel.cardToken!, success: { (token : Token?) -> Void in
            self.viewModel.updateCheckoutModel(token: token!)
            self.executeNextStep()
        }, failure : { (error) -> Void in
            self.viewModel.errorInputs(error: MPSDKError.convertFrom(error), errorCallback: { (Void) in
                self.createCardToken()
            })
            self.executeNextStep()
        })
    }

    func collectPayerCost(){
        let payerCostStep = CardAdditionalViewController(viewModel: self.viewModel.payerCostViewModel(), collectPayerCostCallback: { (payerCost) in
            self.viewModel.updateCheckoutModel(payerCost: payerCost)
            self.executeNextStep()
        })
        self.navigationController.pushViewController(payerCostStep, animated: true)
    }
    
    func collectPaymentData() {
        
        let checkoutVC = CheckoutViewController(viewModel: self.viewModel.checkoutViewModel(), callback: {(paymentData : PaymentData) -> Void in
            self.viewModel.updateCheckoutModel(paymentData: paymentData)
            if MercadoPagoCheckoutViewModel.paymentDataCallback != nil {
                MercadoPagoCheckoutViewModel.paymentDataCallback!(self.viewModel.paymentData)
            } else {
                self.executeNextStep()
            }
        }, callbackCancel : { Void -> Void in
            self.viewModel.setIsCheckoutComplete(isCheckoutComplete: true)
            self.executeNextStep()
        })
        
        
        self.presentLoading()
        self.navigationController.popToViewController(viewControllerBase!, animated: false)
        self.navigationController.pushViewController(checkoutVC, animated: false)
        self.dismissLoading(animated: false)
    }
    
    func collectSecurityCode(){
        let securityCodeVc = SecrurityCodeViewController(viewModel: self.viewModel.securityCodeViewModel(), collectSecurityCodeCallback : { (token: Token?) -> Void in
            self.viewModel.updateCheckoutModel(token: token!)
            self.executeNextStep()
        })
        self.navigationController.pushViewController(securityCodeVc, animated: true)
        
    }
    
    func createPayment() {
        
        var paymentBody : [String:Any]
        if MercadoPagoCheckoutViewModel.servicePreference.isUsingDeafaultPaymentSettings() {
            let mpPayment = MercadoPagoCheckoutViewModel.createMPPayment(self.viewModel.checkoutPreference.getPayer().email, preferenceId: self.viewModel.checkoutPreference._id, paymentData: self.viewModel.paymentData)
            paymentBody = mpPayment.toJSON()
        } else {
            paymentBody = self.viewModel.paymentData.toJSON()
        }
    
        MerchantServer.createPayment(paymentUrl : MercadoPagoCheckoutViewModel.servicePreference.getPaymentURL(), paymentUri : MercadoPagoCheckoutViewModel.servicePreference.getPaymentURI(), paymentBody : paymentBody as NSDictionary, success: {(payment : Payment) -> Void in
            self.viewModel.updateCheckoutModel(payment: payment)
            self.executeNextStep()
        }, failure: {(error : NSError) -> Void in
            self.viewModel.errorInputs(error: MPSDKError.convertFrom(error), errorCallback: { (Void) in
                self.createPayment()
            })
            self.executeNextStep()
        })
    }
    
    func displayPaymentResult() {
        // TODO : por que dos? esta bien? no hay view models, ver que onda
        let congratsViewController : UIViewController
        if (PaymentTypeId.isOfflineType(paymentTypeId: self.viewModel.payment!.paymentTypeId)) {
            congratsViewController = InstructionsRevampViewController(payment: self.viewModel.payment!, paymentTypeId: self.viewModel.paymentData.paymentMethod!.paymentTypeId, callback: { (payment : Payment, state :MPStepBuilder.CongratsState) in
                self.executeNextStep()
            })
        } else {
            congratsViewController = CongratsRevampViewController(payment: self.viewModel.payment!, paymentMethod: self.viewModel.paymentData.paymentMethod!, callback: { (payment : Payment, state : MPStepBuilder.CongratsState) in
                self.executeNextStep()
            })
        }
        self.viewModel.setIsCheckoutComplete(isCheckoutComplete: true)
        self.navigationController.pushViewController(congratsViewController, animated: true)
    }
    
    func error() {
        // Display error
        let errorStep = ErrorViewController(error: MercadoPagoCheckoutViewModel.error, callback: { (Void) -> Void in
            self.viewModel.errorCallback?()
        }, callbackCancel: {(Void) -> Void in
            // Aparte de default callbackCancel
        })
        // Limpiar error anterior
        MercadoPagoCheckoutViewModel.error = nil
        self.navigationController.present(errorStep, animated: true, completion: {})
        
    }
    
    func finish(){
        
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
    
    func presentLoading(animated : Bool = false) {
        if self.currentLoadingView == nil {
            let vcLoading = MercadoPagoUIViewController()
            vcLoading.view.backgroundColor = MercadoPagoCheckoutViewModel.decorationPreference.baseColor
            let loadingInstance = LoadingOverlay.shared.showOverlay(vcLoading.view, backgroundColor: MercadoPagoCheckoutViewModel.decorationPreference.baseColor)
            
            vcLoading.view.addSubview(loadingInstance)
            loadingInstance.bringSubview(toFront: vcLoading.view)
            
            self.currentLoadingView = vcLoading
            self.navigationController.present(vcLoading, animated: animated, completion: {})
        }
    }
    
    func dismissLoading(animated : Bool = false) {
        if self.currentLoadingView != nil {
            self.currentLoadingView!.dismiss(animated: animated, completion: {})
            self.currentLoadingView = nil
        }
    }
}
