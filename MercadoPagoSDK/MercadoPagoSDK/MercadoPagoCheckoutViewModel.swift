//
//  CheckoutViewModel.swift
//  MercadoPagoSDK
//
//  Created by Demian Tejo on 1/23/17.
//  Copyright © 2017 MercadoPago. All rights reserved.
//

import UIKit

public enum CheckoutStep : String {
    case SEARCH_PREFERENCE
    case SEARCH_PAYMENT_METHODS
    case SEARCH_CUSTOMER_PAYMENT_METHODS
    case PAYMENT_METHOD_SELECTION
    case PM_OFF
    case CARD_FORM
    case SECURITY_CODE_ONLY
    case CREDIT_DEBIT
    case GET_ISSUERS
    case ISSUERS_SCREEN
    case CREATE_CARD_TOKEN
    case IDENTIFICATION
    case GET_PAYER_COSTS
    case PAYER_COST_SCREEN
    case REVIEW_AND_CONFIRM
    case POST_PAYMENT
    case CONGRATS
    case FINISH
    case ERROR
}



open class MercadoPagoCheckoutViewModel: NSObject {
    
    internal static var servicePreference = ServicePreference()
    internal static var decorationPreference = DecorationPreference()
    internal static var flowPreference = FlowPreference()
    internal static var reviewScreenPreference = ReviewScreenPreference()
    internal static var paymentResultScreenPreference = PaymentResultScreenPreference()
    
    internal static var paymentDataCallback : ((PaymentData) -> Void)?
    internal static var paymentDataConfirmCallback : ((PaymentData) -> Void)?
    internal static var paymentCallback : ((Payment) -> Void)?
    internal static var callback: ((Void) -> Void)?
    internal static var changePaymentMethodCallback: ((Void) -> Void)?
    

    var checkoutPreference : CheckoutPreference!
    
    var paymentMethods : [PaymentMethod]?
    // card token previo a la tokenización y válido para pago
    var cardToken: CardToken?
//
    var customerId : String?
    
    //optionals?
    // Payment methods disponibles en selección de medio de pago
    var paymentMethodOptions : [PaymentMethodOption]?
    // Payment method seleccionado en selección de medio de pago
    var paymentOptionSelected : PaymentMethodOption?
    // Payment method disponibles correspondientes a las opciones que se muestran en selección de medio de pago
    var availablePaymentMethods : [PaymentMethod]?
    
    var rootPaymentMethodOptions : [PaymentMethodOption]?
    
    var customPaymentOptions : [CardInformation]?
    
    var rootVC = true
    
    var next : CheckoutStep = .SEARCH_PAYMENT_METHODS
    
    let cardViewRect = CGRect(x: 0, y: 0, width: 100, height: 30)

    var paymentData = PaymentData()
    var payment : Payment?
    var paymentResult: PaymentResult?
    
    open var installment: Installment?
    open var issuers: [Issuer]?
    
    static var error : MPSDKError?
    internal var errorCallback : ((Void) -> Void)?
    
    private var needLoadPreference : Bool = false
    private var readyToPay : Bool = false
    private var checkoutComplete = false
    internal var reviewAndConfirm = false
    internal var initWithPaymentData = false
    
    init(checkoutPreference : CheckoutPreference, paymentData : PaymentData?, paymentResult: PaymentResult?) {
        self.checkoutPreference = checkoutPreference
        if let pm = paymentData{
            if pm.isComplete() {
                self.paymentData = pm
                self.reviewAndConfirm = true
                self.initWithPaymentData = true
            }
        }
        self.paymentResult = paymentResult
    }
    init(checkoutPreferenceId : String, paymentData : PaymentData?, paymentResult: PaymentResult?) {
        self.checkoutPreference = CheckoutPreference()
        self.checkoutPreference._id = checkoutPreferenceId
        
        if let pm = paymentData{
            if pm.isComplete() {
                self.paymentData = pm
                self.reviewAndConfirm = true
                self.initWithPaymentData = true
            }
        }
        self.paymentResult = paymentResult
        if !String.isNullOrEmpty(self.checkoutPreference._id) {
            // Cargar información de preferencia en caso que tenga id
            needLoadPreference = true
        }
    }
    
    func hasError() -> Bool {
        return MercadoPagoCheckoutViewModel.error != nil
    }
    
    public func getPaymentPreferences() -> PaymentPreference? {
        return self.checkoutPreference.paymentPreference
    }
    
    public func cardFormManager() -> CardViewModelManager{
        let paymentPreference = PaymentPreference()
        paymentPreference.defaultPaymentTypeId = self.paymentOptionSelected?.getId()
        return CardViewModelManager(amount : self.getAmount(), paymentMethods: search?.paymentMethods, paymentSettings : paymentPreference)
    }
    
    func paymentVaultViewModel() -> PaymentVaultViewModel {
        return PaymentVaultViewModel(amount: self.getAmount(), paymentPrefence: getPaymentPreferences(), paymentMethodOptions: self.paymentMethodOptions!, customerPaymentOptions: self.customPaymentOptions, isRoot : rootVC)
    }
    
    public func debitCreditViewModel() -> AdditionalStepViewModel{
        var pms : [PaymentMethod] = []
        if let _ = paymentMethods {
            pms = paymentMethods!
        }

        return CardTypeAdditionalStepViewModel(amount: self.getAmount(), token: self.cardToken, paymentMethods: pms, dataSource: pms)
    }
    
    public func issuerViewModel() -> AdditionalStepViewModel{
        var pms : [PaymentMethod] = []
        if let pm = self.paymentData.paymentMethod {
            pms = [pm]
        }

        return IssuerAdditionalStepViewModel(amount: self.getAmount(), token: self.cardToken, paymentMethods: pms, dataSource: self.issuers!)
    }
    
    public func payerCostViewModel() -> AdditionalStepViewModel{
        var pms : [PaymentMethod] = []
        if let pm = self.paymentData.paymentMethod {
            pms = [pm]
        }

        return PayerCostAdditionalStepViewModel(amount: self.getAmount(), token: self.cardToken, paymentMethods: pms, dataSource: (installment?.payerCosts)!)
    }
    
    public func savedCardSecurityCodeViewModel() -> SecurityCodeViewModel {
        let cardInformation = self.paymentOptionSelected as! CardInformation
        return SecurityCodeViewModel(paymentMethod: self.paymentData.paymentMethod!, cardInfo: cardInformation)
    }
    
    public func recoverTokenSecurityCodeViewModel() -> SecurityCodeViewModel {
        return SecurityCodeViewModel(paymentMethod: self.paymentData.paymentMethod!, cardInfo: paymentData.token!)
    }
    
    public func checkoutViewModel() -> CheckoutViewModel {
        let checkoutViewModel = CheckoutViewModel(checkoutPreference: self.checkoutPreference, paymentData : self.paymentData, paymentOptionSelected : self.paymentOptionSelected!)
        return checkoutViewModel
    }
    
    //SEARCH_PAYMENT_METHODS
    public func updateCheckoutModel(paymentMethods: [PaymentMethod], cardToken: CardToken?){
		self.paymentMethods = paymentMethods
        self.paymentData.paymentMethod = self.paymentMethods?[0] // Ver si son mas de uno
        self.cardToken = cardToken
    }
    
    
    //CREDIT_DEBIT
    public func updateCheckoutModel(paymentMethod: PaymentMethod?){
        self.paymentData.paymentMethod = paymentMethod
    }
    
    public func updateCheckoutModel(issuer: Issuer?){
        self.paymentData.issuer = issuer
    }
    
    public func updateCheckoutModel(identification : Identification) {
        self.cardToken!.cardholder!.identification = identification
    }
    
    public func updateCheckoutModel(payerCost: PayerCost?){
        self.paymentData.payerCost = payerCost
    }
    
    //PAYMENT_METHOD_SELECTION
    public func updateCheckoutModel(paymentOptionSelected : PaymentMethodOption){
        self.paymentOptionSelected = paymentOptionSelected
        if paymentOptionSelected.hasChildren() {
            self.paymentMethodOptions =  paymentOptionSelected.getChildren()
        } else if !self.initWithPaymentData {
            resetInformation()
        }
        
        if self.paymentOptionSelected!.isCustomerPaymentMethod() {
            self.findAndCompletePaymentMethodFor(paymentMethodId: paymentOptionSelected.getId())
            if self.paymentOptionSelected!.getId() == PaymentTypeId.ACCOUNT_MONEY.rawValue {
                self.reviewAndConfirm = MercadoPagoCheckoutViewModel.flowPreference.isReviewAndConfirmScreenEnable()
            }
        
        } else if !paymentOptionSelected.isCard() && !paymentOptionSelected.hasChildren() {
            self.paymentData.paymentMethod = Utils.findPaymentMethod(self.availablePaymentMethods!, paymentMethodId: paymentOptionSelected.getId())
            self.reviewAndConfirm = MercadoPagoCheckoutViewModel.flowPreference.isReviewAndConfirmScreenEnable()
        }
        
    }
    

    public func nextStep() -> CheckoutStep {

        if needLoadPreference {
            needLoadPreference = false
            return .SEARCH_PREFERENCE
        }
        
        
        if hasError() {
            return .ERROR
        }
        
        if shouldExitCheckout() {
            return .FINISH
        }
        
        if shouldShowCongrats() {
            return .CONGRATS
        }
        
        if needSearch() {
            return .SEARCH_PAYMENT_METHODS
        }
        
        if !isPaymentTypeSelected(){
            return .PAYMENT_METHOD_SELECTION
        }
        
        if reviewAndConfirm {
            return .REVIEW_AND_CONFIRM
        }
        
        if needCompleteCard() {
            return .CARD_FORM
        }
        if needGetIdentification() {
            return .IDENTIFICATION
        }
        
        if needSelectCreditDebit() {
            return .CREDIT_DEBIT
        }
        
        if needGetIssuers() {
            return .GET_ISSUERS
        }
        
        if needIssuerSelectionScreen() {
            return .ISSUERS_SCREEN
        }
        
        if needChosePayerCost() {
            return .GET_PAYER_COSTS
        }
        
        if needPayerCostSelectionScreen(){
            return .PAYER_COST_SCREEN
        }
        
        if needSecurityCode(){
            return .SECURITY_CODE_ONLY
        }
        
        if needCreateToken(){
            return .CREATE_CARD_TOKEN
        }
        
        if readyToPay {
            readyToPay = false
            return .POST_PAYMENT
        }
        
        return .REVIEW_AND_CONFIRM


    }
    
        
    var search : PaymentMethodSearch?
    
    public func updateCheckoutModel(paymentMethodSearch : PaymentMethodSearch) {
        self.search = paymentMethodSearch
        
        // La primera vez las opciones a mostrar van a ser el root de grupos
        self.rootPaymentMethodOptions = paymentMethodSearch.groups
        self.paymentMethodOptions = self.rootPaymentMethodOptions
        self.availablePaymentMethods = paymentMethodSearch.paymentMethods
        
        if search?.getPaymentOptionsCount() == 0 {
            self.errorInputs(error: MPSDKError(message: "Ha ocurrido un error".localized, messageDetail: "No se ha podido obtener los métodos de pago con esta preferencia".localized, retry: false), errorCallback: { (Void) in
                
            })
        }
        
        if !Array.isNullOrEmpty(paymentMethodSearch.customerPaymentMethods) {
            
            if !MercadoPagoContext.accountMoneyAvailable() {
                //Remover account_money como opción de pago
                self.customPaymentOptions =  paymentMethodSearch.customerPaymentMethods!.filter({ (element : CardInformation) -> Bool in
                    return element.getPaymentMethodId() != PaymentTypeId.ACCOUNT_MONEY.rawValue
                })
            } else {
                self.customPaymentOptions = paymentMethodSearch.customerPaymentMethods
            }
        }
        
        if self.search!.getPaymentOptionsCount() == 1 {
            if self.search!.groups.count == 1 {
                self.updateCheckoutModel(paymentOptionSelected: self.search!.groups[0])
            } else {
                let customOption = self.search!.customerPaymentMethods![0] as! PaymentMethodOption
                self.updateCheckoutModel(paymentOptionSelected: customOption)
            }
        }
        

    }
    
    
    public func updateCheckoutModel(token : Token) {
        self.paymentData.token = token
        self.reviewAndConfirm = MercadoPagoCheckoutViewModel.flowPreference.isReviewAndConfirmScreenEnable()
    }

    public class func createMPPayment(_ email : String, preferenceId : String, paymentData : PaymentData, customerId : String? = nil) -> MPPayment {
        
        var issuerId = ""
        if paymentData.issuer != nil {
            issuerId = String(paymentData.issuer!._id!.intValue)
        }
        var tokenId = ""
        if paymentData.token != nil {
            tokenId = paymentData.token!._id
        }
        
        var installments : Int = 0
        if paymentData.payerCost != nil {
            installments = paymentData.payerCost!.installments
        }
        let isBlacklabelPayment = paymentData.token != nil && paymentData.token!.cardId != nil && String.isNullOrEmpty(customerId)
        
        let mpPayment = MPPaymentFactory.createMPPayment(email: email, preferenceId: preferenceId, publicKey: MercadoPagoContext.publicKey(), paymentMethodId: paymentData.paymentMethod!._id, installments: installments, issuerId: issuerId, tokenId: tokenId, customerId: customerId, isBlacklabelPayment: isBlacklabelPayment)
        return mpPayment
    }
    
    
    public func updateCheckoutModel(paymentMethodOptions : [PaymentMethodOption]) {
        if self.rootPaymentMethodOptions != nil {
            self.rootPaymentMethodOptions!.insert(contentsOf: paymentMethodOptions, at: 0)
        } else {
            self.rootPaymentMethodOptions = paymentMethodOptions
        }
        self.paymentMethodOptions = self.rootPaymentMethodOptions
        self.next = .PAYMENT_METHOD_SELECTION
    }
    
    func updateCheckoutModel(paymentData: PaymentData){
        self.paymentData = paymentData
        if paymentData.paymentMethod == nil {
            // Vuelvo a root para iniciar la selección de medios de pago
            self.paymentOptionSelected = nil
            self.paymentMethodOptions = self.rootPaymentMethodOptions
            self.search = nil
            self.rootVC = true
            self.cardToken = nil
            self.issuers = nil
            self.installment = nil
            self.initWithPaymentData = false
        } else {
            self.readyToPay = true
        }
        self.reviewAndConfirm = false
    }
    
    public func updateCheckoutModel(payment : Payment) {
        self.payment = payment
    }

    
    internal func getAmount() -> Double {
        return self.checkoutPreference.getAmount()
    }
    
    public func isCheckoutComplete() -> Bool {
        return checkoutComplete
    }
    
    public func setIsCheckoutComplete(isCheckoutComplete : Bool) {
        self.checkoutComplete = isCheckoutComplete
    }
    
    internal func findAndCompletePaymentMethodFor(paymentMethodId : String){
        if paymentMethodId == PaymentTypeId.ACCOUNT_MONEY.rawValue {
            self.paymentData.paymentMethod = Utils.findPaymentMethod(self.availablePaymentMethods!, paymentMethodId: paymentMethodId)
        }else{
            let cardInformation = (self.paymentOptionSelected as! CardInformation)
            let paymentMethod = Utils.findPaymentMethod(self.availablePaymentMethods!, paymentMethodId:cardInformation.getPaymentMethodId())
            cardInformation.setupPaymentMethodSettings(paymentMethod.settings)
            cardInformation.setupPaymentMethod(paymentMethod)
            self.paymentData.paymentMethod = cardInformation.getPaymentMethod()
            self.paymentData.issuer = cardInformation.getIssuer()
        }
        
    }
    
    func hasCustomPaymentOptions() -> Bool {
        return !Array.isNullOrEmpty(self.customPaymentOptions)
    }
    
    internal func handleCustomerPaymentMethod(){
        if self.paymentOptionSelected!.getId() == PaymentTypeId.ACCOUNT_MONEY.rawValue {
            self.paymentData.paymentMethod = Utils.findPaymentMethod(self.availablePaymentMethods!, paymentMethodId: paymentOptionSelected!.getId())
        } else {
            // Se necesita completar información faltante de settings y pm para custom payment options
            let cardInformation = (self.paymentOptionSelected as! CardInformation)
            let paymentMethod = Utils.findPaymentMethod(self.availablePaymentMethods!, paymentMethodId: cardInformation.getPaymentMethodId())
            cardInformation.setupPaymentMethodSettings(paymentMethod.settings)
            cardInformation.setupPaymentMethod(paymentMethod)
            self.paymentData.paymentMethod = cardInformation.getPaymentMethod()
        }
    }
    
    func getDefaultPaymentMethodId() -> String? {
        return self.checkoutPreference.getDefaultPaymentMethodId()
    }
    
    func getExcludedPaymentTypesIds() -> Set<String>? {
        return self.checkoutPreference.getExcludedPaymentTypesIds()
    }
    
    func getExcludedPaymentMethodsIds() -> Set<String>? {
        return self.checkoutPreference.getExcludedPaymentMethodsIds()
    }
    
    func errorInputs(error : MPSDKError, errorCallback : ((Void) -> Void)?) {
        MercadoPagoCheckoutViewModel.error = error
        self.errorCallback = errorCallback
    }
    
    func resetInformation() {
        self.paymentData.clear()
        self.cardToken = nil
        self.issuers = nil
        self.installment = nil
    }
    

}

