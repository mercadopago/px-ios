//
//  CheckoutViewModel.swift
//  MercadoPagoSDK
//
//  Created by Demian Tejo on 1/23/17.
//  Copyright © 2017 MercadoPago. All rights reserved.
//

import UIKit

public enum CheckoutStep: String {
    case SEARCH_PREFERENCE
    case SEARCH_DIRECT_DISCOUNT
    case VALIDATE_PREFERENCE
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
    case ENTITY_TYPE
    case GET_FINANCIAL_INSTITUTIONS
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
    var reviewScreenPreference = ReviewScreenPreference()
    var paymentResultScreenPreference = PaymentResultScreenPreference()
    internal static var paymentDataCallback: ((PaymentData) -> Void)?
    internal static var paymentDataConfirmCallback: ((PaymentData) -> Void)?
    internal static var paymentCallback: ((Payment) -> Void)?
    var callbackCancel: (() -> Void)?
    internal static var changePaymentMethodCallback: (() -> Void)?

    var checkoutPreference: CheckoutPreference!

    var paymentMethods: [PaymentMethod]?
    // card token previo a la tokenización y válido para pago
    var cardToken: CardToken?
//
    var customerId: String?

    //optionals?
    // Payment methods disponibles en selección de medio de pago
    var paymentMethodOptions: [PaymentMethodOption]?
    // Payment method seleccionado en selección de medio de pago
    var paymentOptionSelected: PaymentMethodOption?
    // Payment method disponibles correspondientes a las opciones que se muestran en selección de medio de pago
    var availablePaymentMethods: [PaymentMethod]?

    var rootPaymentMethodOptions: [PaymentMethodOption]?

    var customPaymentOptions: [CardInformation]?

    var rootVC = true

    var binaryMode: Bool = false
    var paymentData = PaymentData()
    var payment: Payment?
    var paymentResult: PaymentResult?

    //open var installment: Installment?
    open var payerCosts: [PayerCost]?
    open var issuers: [Issuer]?
    open var entityTypes: [EntityType]?
    open var financialInstitutions: [FinancialInstitution]?

    static var error: MPSDKError?

    internal var errorCallback: (() -> Void)?

    internal var needLoadPreference: Bool = false
    internal var preferenceValidated: Bool = false
    internal var readyToPay: Bool = false
    private var checkoutComplete = false
    internal var initWithPaymentData = false
    var directDiscountSearched = false

    static internal func clearEnviroment() {
        MercadoPagoCheckoutViewModel.servicePreference = ServicePreference()
        MercadoPagoCheckoutViewModel.decorationPreference = DecorationPreference()
        MercadoPagoCheckoutViewModel.flowPreference = FlowPreference()

        MercadoPagoCheckoutViewModel.paymentDataCallback = nil
        MercadoPagoCheckoutViewModel.paymentDataConfirmCallback = nil
        MercadoPagoCheckoutViewModel.paymentCallback = nil
        MercadoPagoCheckoutViewModel.changePaymentMethodCallback = nil

    }

    init(checkoutPreference: CheckoutPreference, paymentData: PaymentData?, paymentResult: PaymentResult?, discount: DiscountCoupon?) {
        self.checkoutPreference = checkoutPreference
        if let pm = paymentData {
            if pm.isComplete() {
                self.paymentData = pm
                self.directDiscountSearched = true
                if paymentResult == nil {
                    self.initWithPaymentData = true
                }
            }
        }
        if let discount = discount {
            if paymentData == nil {
                self.paymentData = PaymentData()
            }
            self.paymentData.discount = discount
        }
        self.paymentResult = paymentResult
        if !String.isNullOrEmpty(self.checkoutPreference._id) {
            // Cargar información de preferencia en caso que tenga id
            needLoadPreference = true
        } else {
            self.paymentData.payer = self.checkoutPreference.getPayer()
            MercadoPagoContext.setSiteID(self.checkoutPreference.getSiteId())
        }
    }

    func hasError() -> Bool {
        return MercadoPagoCheckoutViewModel.error != nil
    }

    public func getPaymentPreferences() -> PaymentPreference? {
        return self.checkoutPreference.paymentPreference
    }

    public func cardFormManager() -> CardViewModelManager {
        let paymentPreference = PaymentPreference()
        paymentPreference.defaultPaymentTypeId = self.paymentOptionSelected?.getId()
        // TODO : está bien que la paymentPreference se cree desde cero? puede que vengan exclusiones de entrada ya?
        return CardViewModelManager(amount : self.getAmount(), paymentMethods: search?.paymentMethods, paymentSettings : paymentPreference)
    }

    func paymentVaultViewModel() -> PaymentVaultViewModel {
        return PaymentVaultViewModel(amount: self.getAmount(), paymentPrefence: getPaymentPreferences(), paymentMethodOptions: self.paymentMethodOptions!, customerPaymentOptions: self.customPaymentOptions, isRoot : rootVC, discount: self.paymentData.discount, email: self.checkoutPreference.payer.email, couponCallback: {[weak self] (discount) in
            guard let object = self else {
                return
            }
            object.paymentData.discount = discount
        })
    }

    public func entityTypeViewModel() -> AdditionalStepViewModel {

        return EntityTypeAdditionalStepViewModel(amount: self.getAmount(), token: self.cardToken, paymentMethod: self.paymentData.paymentMethod, dataSource: self.entityTypes!)
    }

    public func financialInstitutionViewModel() -> AdditionalStepViewModel {

        return FinancialInstitutionAdditionalStepViewModel(amount: self.getAmount(), token: self.cardToken, paymentMethod: self.paymentData.paymentMethod, dataSource: self.financialInstitutions!)
    }

    public func debitCreditViewModel() -> AdditionalStepViewModel {
        var pms: [PaymentMethod] = []
        if let _ = paymentMethods {
            pms = paymentMethods!
        }
        return CardTypeAdditionalStepViewModel(amount: self.getAmount(), token: self.cardToken, paymentMethods: pms, dataSource: pms)

    }

    public func issuerViewModel() -> AdditionalStepViewModel {
        var paymentMethod: PaymentMethod = PaymentMethod()
        if let pm = self.paymentData.paymentMethod {
            paymentMethod = pm
        }

        return IssuerAdditionalStepViewModel(amount: self.getAmount(), token: self.cardToken, paymentMethod: paymentMethod, dataSource: self.issuers!)
    }

    public func payerCostViewModel() -> AdditionalStepViewModel {
        var paymentMethod: PaymentMethod = PaymentMethod()
        if let pm = self.paymentData.paymentMethod {
            paymentMethod = pm
        }
        var cardInformation: CardInformationForm? = self.cardToken
        if cardInformation == nil {
            if let token = paymentOptionSelected as? CardInformationForm {
                cardInformation = token
            }
        }

        return PayerCostAdditionalStepViewModel(amount: self.getAmount(), token: cardInformation, paymentMethod: paymentMethod, dataSource: payerCosts!, discount: self.paymentData.discount, email: self.checkoutPreference.payer.email)
    }

    public func savedCardSecurityCodeViewModel() -> SecurityCodeViewModel {
        let cardInformation = self.paymentOptionSelected as! CardInformation
        return SecurityCodeViewModel(paymentMethod: self.paymentData.paymentMethod!, cardInfo: cardInformation)
    }

    public func cloneTokenSecurityCodeViewModel() -> SecurityCodeViewModel {
        let cardInformation = self.paymentData.token
        return SecurityCodeViewModel(paymentMethod: self.paymentData.paymentMethod!, cardInfo: cardInformation!)
    }

    public func checkoutViewModel() -> CheckoutViewModel {
        let checkoutViewModel = CheckoutViewModel(checkoutPreference: self.checkoutPreference, paymentData : self.paymentData, paymentOptionSelected : self.paymentOptionSelected!, discount: paymentData.discount, reviewScreenPreference: reviewScreenPreference)
        return checkoutViewModel
    }

    //SEARCH_PAYMENT_METHODS
    public func updateCheckoutModel(paymentMethods: [PaymentMethod], cardToken: CardToken?) {
        self.cleanToken()
        self.paymentMethods = paymentMethods
        self.paymentData.paymentMethod = self.paymentMethods?[0] // Ver si son mas de uno
        self.cardToken = cardToken
    }

    //CREDIT_DEBIT
    public func updateCheckoutModel(paymentMethod: PaymentMethod?) {
        self.paymentData.paymentMethod = paymentMethod
    }

    public func updateCheckoutModel(financialInstitution: FinancialInstitution) {
        if let TDs = self.paymentData.transactionDetails {
            TDs.financialInstitution = financialInstitution
        } else {
            let TD = TransactionDetails(financialInstitution: financialInstitution)
            self.paymentData.transactionDetails = TD
        }
    }

    public func updateCheckoutModel(issuer: Issuer) {
        self.paymentData.issuer = issuer
    }

    public func updateCheckoutModel(identification: Identification) {
        self.cleanToken()
        if paymentData.paymentMethod.isCard() {
            self.cardToken!.cardholder!.identification = identification
        } else {
            paymentData.payer.identification = identification
        }
    }

    public func updateCheckoutModel(payerCost: PayerCost) {
        self.paymentData.payerCost = payerCost
    }

    public func updateCheckoutModel(entityType: EntityType) {
        self.paymentData.payer.entityType = entityType
    }

    //PAYMENT_METHOD_SELECTION
    public func updateCheckoutModel(paymentOptionSelected: PaymentMethodOption) {
        if !self.initWithPaymentData {
            resetInformation()
        }

        self.paymentOptionSelected = paymentOptionSelected
        if paymentOptionSelected.hasChildren() {
            self.paymentMethodOptions =  paymentOptionSelected.getChildren()
        }

        if self.paymentOptionSelected!.isCustomerPaymentMethod() {
            self.findAndCompletePaymentMethodFor(paymentMethodId: paymentOptionSelected.getId())
        } else if !paymentOptionSelected.isCard() && !paymentOptionSelected.hasChildren() {
            self.paymentData.paymentMethod = Utils.findPaymentMethod(self.availablePaymentMethods!, paymentMethodId: paymentOptionSelected.getId())
        }

    }
    public func nextStep() -> CheckoutStep {
        if hasError() {
            return .ERROR
        }
        
        if needLoadPreference {
            needLoadPreference = false
            return .SEARCH_PREFERENCE
        }
        if needToSearchDirectDiscount() {
            self.directDiscountSearched = true
            return .SEARCH_DIRECT_DISCOUNT
        }

        if shouldExitCheckout() {
            return .FINISH
        }

        if shouldShowCongrats() {
            return .CONGRATS
        }

        if needValidatePreference() {
            preferenceValidated = true
            return .VALIDATE_PREFERENCE
        }

        if needSearch() {
            return .SEARCH_PAYMENT_METHODS
        }

        if !isPaymentTypeSelected() {
            return .PAYMENT_METHOD_SELECTION
        }

        if readyToPay {
            readyToPay = false
            return .POST_PAYMENT
        }

        if needReviewAndConfirm() {
            return .REVIEW_AND_CONFIRM
        }

        if needCompleteCard() {
            return .CARD_FORM
        }

        if needGetIdentification() {
            return .IDENTIFICATION
        }

        if needSecurityCode() {
            return .SECURITY_CODE_ONLY
        }

        if needCreateToken() {
            return .CREATE_CARD_TOKEN
        }

        if needGetEntityTypes() {
            return .ENTITY_TYPE
        }

        if needSelectCreditDebit() {
            return .CREDIT_DEBIT
        }

        if needGetFinancialInstitutions() {
            return .GET_FINANCIAL_INSTITUTIONS
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

        if needPayerCostSelectionScreen() {
            return .PAYER_COST_SCREEN
        }

        return .FINISH

    }

    var search: PaymentMethodSearch?

    public func updateCheckoutModel(paymentMethodSearch: PaymentMethodSearch) {
        self.search = paymentMethodSearch

        // La primera vez las opciones a mostrar van a ser el root de grupos
        self.rootPaymentMethodOptions = paymentMethodSearch.groups
        self.paymentMethodOptions = self.rootPaymentMethodOptions
        self.availablePaymentMethods = paymentMethodSearch.paymentMethods

        if search?.getPaymentOptionsCount() == 0 {
            self.errorInputs(error: MPSDKError(message: "Ha ocurrido un error".localized, messageDetail: "No se ha podido obtener los métodos de pago con esta preferencia".localized, retry: false), errorCallback: { (_) in

            })
        }

        if !Array.isNullOrEmpty(paymentMethodSearch.customerPaymentMethods) {

            if !MercadoPagoContext.accountMoneyAvailable() {
                //Remover account_money como opción de pago
                self.customPaymentOptions =  paymentMethodSearch.customerPaymentMethods!.filter({ (element: CardInformation) -> Bool in
                    return element.getPaymentMethodId() != PaymentTypeId.ACCOUNT_MONEY.rawValue
                })
            } else {
                self.customPaymentOptions = paymentMethodSearch.customerPaymentMethods
            }
        }

        if self.search!.getPaymentOptionsCount() == 1 {
            if !Array.isNullOrEmpty(self.search!.groups) && self.search!.groups.count == 1 {
                self.updateCheckoutModel(paymentOptionSelected: self.search!.groups[0])
            } else {
                let customOption = self.search!.customerPaymentMethods![0] as! PaymentMethodOption
                self.updateCheckoutModel(paymentOptionSelected: customOption)
            }
        }

    }

    public func updateCheckoutModel(token: Token) {

        self.paymentData.token = token
        let lastFourDigits = self.paymentData.token!.lastFourDigits
        if lastFourDigits != nil {
           self.paymentData.token?.lastFourDigits = lastFourDigits
        }
    }

    public class func createMPPayment(preferenceId: String, paymentData: PaymentData, customerId: String? = nil, binaryMode: Bool) -> MPPayment {

        var issuerId = ""
        if paymentData.issuer != nil {
            issuerId = paymentData.issuer!._id!
        }
        var tokenId = ""
        if paymentData.token != nil {
            tokenId = paymentData.token!._id
        }

        var installments: Int = 0
        if paymentData.payerCost != nil {
            installments = paymentData.payerCost!.installments
        }

        var transactionDetails = TransactionDetails()
        if paymentData.transactionDetails != nil {
            transactionDetails = paymentData.transactionDetails!
        }

        var payer = Payer()
        if paymentData.payer != nil {
            payer = paymentData.payer
        }

        let isBlacklabelPayment = paymentData.token != nil && paymentData.token!.cardId != nil && String.isNullOrEmpty(customerId)

        let mpPayment = MPPaymentFactory.createMPPayment(preferenceId: preferenceId, publicKey: MercadoPagoContext.publicKey(), paymentMethodId: paymentData.paymentMethod!._id, installments: installments, issuerId: issuerId, tokenId: tokenId, customerId: customerId, isBlacklabelPayment: isBlacklabelPayment, transactionDetails: transactionDetails, payer: payer, binaryMode: binaryMode)
        return mpPayment
    }

    public func updateCheckoutModel(paymentMethodOptions: [PaymentMethodOption]) {
        if self.rootPaymentMethodOptions != nil {
            self.rootPaymentMethodOptions!.insert(contentsOf: paymentMethodOptions, at: 0)
        } else {
            self.rootPaymentMethodOptions = paymentMethodOptions
        }
        self.paymentMethodOptions = self.rootPaymentMethodOptions
    }

    func updateCheckoutModel(paymentData: PaymentData) {
        self.paymentData = paymentData
        if paymentData.paymentMethod == nil {
            // Vuelvo a root para iniciar la selección de medios de pago
            self.paymentOptionSelected = nil
            self.paymentMethodOptions = self.rootPaymentMethodOptions
            self.search = nil
            self.rootVC = true
            self.cardToken = nil
            self.issuers = nil
            self.entityTypes = nil
            self.financialInstitutions = nil
            self.payerCosts = nil
            self.initWithPaymentData = false
        } else {
            self.readyToPay = true
        }

    }

    public func updateCheckoutModel(payment: Payment) {
        self.payment = payment
    }

    internal func getAmount() -> Double {
        return self.checkoutPreference.getAmount()
    }

    internal func getFinalAmount() -> Double {
        if MercadoPagoCheckoutViewModel.flowPreference.isDiscountEnable(), let discount = paymentData.discount {
            return discount.newAmount()
        } else {
            return self.checkoutPreference.getAmount()
        }
    }

    public func isCheckoutComplete() -> Bool {
        return checkoutComplete
    }

    public func setIsCheckoutComplete(isCheckoutComplete: Bool) {
        self.checkoutComplete = isCheckoutComplete
    }

    internal func findAndCompletePaymentMethodFor(paymentMethodId: String) {
        if paymentMethodId == PaymentTypeId.ACCOUNT_MONEY.rawValue {
            self.paymentData.paymentMethod = Utils.findPaymentMethod(self.availablePaymentMethods!, paymentMethodId: paymentMethodId)
        } else {
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

    internal func handleCustomerPaymentMethod() {
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
        if self.checkoutPreference.siteId == "MLC" || self.checkoutPreference.siteId == "MCO" || self.checkoutPreference.siteId == "MLV" {
            self.checkoutPreference.addExcludedPaymentType("atm")
            self.checkoutPreference.addExcludedPaymentType("bank_transfer")
            self.checkoutPreference.addExcludedPaymentType("ticket")
        }
        return self.checkoutPreference.getExcludedPaymentTypesIds()
    }

    func getExcludedPaymentMethodsIds() -> Set<String>? {
        return self.checkoutPreference.getExcludedPaymentMethodsIds()
    }

    func entityTypesFinder(inDict: NSDictionary, forKey: String) -> [EntityType]? {

        if let siteETsDictionary = inDict.value(forKey: forKey) as? NSDictionary {
            let entityTypesKeys = siteETsDictionary.allKeys
            var entityTypes = [EntityType]()

            for ET in entityTypesKeys {
                let entityType = EntityType()
                entityType._id = ET as! String
                entityType.name = (siteETsDictionary.value(forKey: ET as! String) as! String!).localized

                entityTypes.append(entityType)
            }

            return entityTypes
        }

        return nil
    }

    func getEntityTypes() -> [EntityType] {
        let path = MercadoPago.getBundle()!.path(forResource: "EntityTypes", ofType: "plist")
        let dictET = NSDictionary(contentsOfFile: path!)
        let site = MercadoPagoContext.getSite()

        if let siteETs = entityTypesFinder(inDict: dictET!, forKey: site) {
            return siteETs
        } else {
            let siteETs = entityTypesFinder(inDict: dictET!, forKey: "default")
            return siteETs!
        }
    }

    func errorInputs(error: MPSDKError, errorCallback: (() -> Void)?) {
        MercadoPagoCheckoutViewModel.error = error
        self.errorCallback = errorCallback
    }

    func shouldDisplayPaymentResult() -> Bool {
        if !MercadoPagoCheckoutViewModel.flowPreference.isPaymentResultScreenEnable() {
            return false
        } else if !MercadoPagoCheckoutViewModel.flowPreference.isPaymentApprovedScreenEnable() && self.paymentResult?.status == PaymentStatus.APPROVED.rawValue {
            return false
        } else if !MercadoPagoCheckoutViewModel.flowPreference.isPaymentPendingScreenEnable() && self.paymentResult?.status == PaymentStatus.IN_PROCESS.rawValue {
            return false
        } else if !MercadoPagoCheckoutViewModel.flowPreference.isPaymentRejectedScreenEnable() && self.paymentResult?.status == PaymentStatus.REJECTED.rawValue {
            return false
        }
        return true
    }

}

extension MercadoPagoCheckoutViewModel {
    func resetGroupSelection() {
        self.paymentOptionSelected = nil
        guard let search = self.search else {
            return
        }
        self.updateCheckoutModel(paymentMethodSearch: search)
    }

    func resetInformation() {
        self.paymentData.clearCollectedData()
        self.cardToken = nil
        self.issuers = nil
        self.entityTypes = nil
        self.financialInstitutions = nil
        self.payerCosts = nil
    }

    func cleanPaymentResult() {
        self.payment = nil
        self.paymentResult = nil
        self.readyToPay = false
        self.setIsCheckoutComplete(isCheckoutComplete: false)
    }

    func prepareForClone() {
        self.setIsCheckoutComplete(isCheckoutComplete: false)
        self.cleanPaymentResult()
    }

    func prepareForNewSelection() {
           self.setIsCheckoutComplete(isCheckoutComplete: false)
        self.cleanPaymentResult()
        self.resetInformation()
        self.resetGroupSelection()
    }

    func cleanToken() {
        self.paymentData.token = nil
    }

}
