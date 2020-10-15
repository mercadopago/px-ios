//
//  CheckoutViewModel.swift
//  MercadoPagoSDK
//
//  Created by Demian Tejo on 1/23/17.
//  Copyright © 2017 MercadoPago. All rights reserved.
//

import UIKit

internal enum CheckoutStep: String {
    case START
    case ACTION_FINISH
    case SERVICE_GET_IDENTIFICATION_TYPES
    case SCREEN_PAYMENT_METHOD_SELECTION
    case SCREEN_CARD_FORM
    case SCREEN_SECURITY_CODE
    case SERVICE_GET_ISSUERS
    case SCREEN_ISSUERS
    case SERVICE_CREATE_CARD_TOKEN
    case SCREEN_IDENTIFICATION
    case SCREEN_ENTITY_TYPE
    case SCREEN_FINANCIAL_INSTITUTIONS
    case SERVICE_GET_PAYER_COSTS
    case SCREEN_PAYER_INFO_FLOW
    case SCREEN_PAYER_COST
    case SCREEN_REVIEW_AND_CONFIRM
    case SERVICE_POST_PAYMENT
    case SERVICE_GET_REMEDY
    case SCREEN_PAYMENT_RESULT
    case SCREEN_ERROR
    case SCREEN_HOOK_BEFORE_PAYMENT_METHOD_CONFIG
    case SCREEN_HOOK_AFTER_PAYMENT_METHOD_CONFIG
    case SCREEN_HOOK_BEFORE_PAYMENT
    case SCREEN_PAYMENT_METHOD_PLUGIN_CONFIG
    case FLOW_ONE_TAP
}

internal class MercadoPagoCheckoutViewModel: NSObject, NSCopying {
    var hookService: HookService = HookService()

    private var advancedConfig: PXAdvancedConfiguration = PXAdvancedConfiguration()
    internal var trackingConfig: PXTrackingConfiguration?

    internal var publicKey: String
    internal var privateKey: String?

    var lifecycleProtocol: PXLifeCycleProtocol?

    // In order to ensure data updated create new instance for every usage
    var amountHelper: PXAmountHelper {
        guard let paymentData = paymentData.copy() as? PXPaymentData else {
            fatalError("Cannot find payment data")
        }
        return PXAmountHelper(preference: checkoutPreference, paymentData: paymentData, chargeRules: chargeRules, paymentConfigurationService: paymentConfigurationService, splitAccountMoney: splitAccountMoney)
    }

    var checkoutPreference: PXCheckoutPreference!
    let mercadoPagoServices: MercadoPagoServices

    //    var paymentMethods: [PaymentMethod]?
    var cardToken: PXCardToken?
    var customerId: String?

    // Payment methods disponibles en selección de medio de pago
    var paymentMethodOptions: [PaymentMethodOption]?
    var paymentOptionSelected: PaymentMethodOption?
    // Payment method disponibles correspondientes a las opciones que se muestran en selección de medio de pago
    var availablePaymentMethods: [PXPaymentMethod]?

    var rootPaymentMethodOptions: [PaymentMethodOption]?
    var customPaymentOptions: [CustomerPaymentMethod]?
    var identificationTypes: [PXIdentificationType]?
    var remedy: PXRemedy?

    var search: PXInitDTO?

    var rootVC = true

    internal var paymentData = PXPaymentData()
    internal var splitAccountMoney: PXPaymentData?
    var payment: PXPayment?
    internal var paymentResult: PaymentResult?
    var disabledOption: PXDisabledOption?
    var businessResult: PXBusinessResult?
    open var payerCosts: [PXPayerCost]?
    open var issuers: [PXIssuer]?
    open var entityTypes: [EntityType]?
    open var financialInstitutions: [PXFinancialInstitution]?
    open var instructionsInfo: PXInstructions?
    open var pointsAndDiscounts: PXPointsAndDiscounts?

    static var error: MPSDKError?

    var errorCallback: (() -> Void)?

    var readyToPay: Bool = false
    var initWithPaymentData = false
    var savedESCCardToken: PXSavedESCCardToken?
    private var checkoutComplete = false
    var paymentMethodConfigPluginShowed = false

    var invalidESCReason: PXESCDeleteReason?

    // Discounts bussines service.
    var paymentConfigurationService = PXPaymentConfigurationServices()

    // Payment plugin
    var paymentPlugin: PXSplitPaymentProcessor?
    var paymentFlow: PXPaymentFlow?

    // Discount and charges
    var chargeRules: [PXPaymentTypeChargeRule]?

    // Init Flow
    var initFlow: InitFlow?
    weak var initFlowProtocol: InitFlowProtocol?

    // OneTap Flow
    var onetapFlow: OneTapFlow?

    lazy var pxNavigationHandler: PXNavigationHandler = PXNavigationHandler.getDefault()

    init(checkoutPreference: PXCheckoutPreference, publicKey: String, privateKey: String?, advancedConfig: PXAdvancedConfiguration? = nil, trackingConfig: PXTrackingConfiguration? = nil) {
        self.publicKey = publicKey
        self.privateKey = privateKey
        self.checkoutPreference = checkoutPreference

        if let advancedConfig = advancedConfig {
            self.advancedConfig = advancedConfig
        }
        self.trackingConfig = trackingConfig
        mercadoPagoServices = MercadoPagoServices(publicKey: publicKey, privateKey: privateKey)
        super.init()
        if String.isNullOrEmpty(checkoutPreference.id), checkoutPreference.payer != nil {
            paymentData.updatePaymentDataWith(payer: checkoutPreference.getPayer())
        }
        PXConfiguratorManager.escConfig = PXESCConfig.createConfig()
        // Create Init Flow
        createInitFlow()
    }

    public func copy(with zone: NSZone? = nil) -> Any {
        let copyObj = MercadoPagoCheckoutViewModel(checkoutPreference: self.checkoutPreference, publicKey: publicKey, privateKey: privateKey)
        copyObj.setNavigationHandler(handler: pxNavigationHandler)
        return copyObj
    }

    func setNavigationHandler(handler: PXNavigationHandler) {
        pxNavigationHandler = handler
    }

    func hasError() -> Bool {
        return MercadoPagoCheckoutViewModel.error != nil
    }

    func applyDefaultDiscountOrClear() {
        if let defaultDiscountConfiguration = search?.selectedDiscountConfiguration {
            attemptToApplyDiscount(defaultDiscountConfiguration)
        } else {
            clearDiscount()
        }
    }

    func attemptToApplyDiscount(_ discountConfiguration: PXDiscountConfiguration?) {
        guard let discountConfiguration = discountConfiguration else {
            clearDiscount()
            return
        }

        guard let campaign = discountConfiguration.getDiscountConfiguration().campaign, shouldApplyDiscount() else {
            clearDiscount()
            return
        }
        let discount = discountConfiguration.getDiscountConfiguration().discount
        let consumedDiscount = !discountConfiguration.getDiscountConfiguration().isAvailable
        let discountDescription = discountConfiguration.getDiscountConfiguration().discountDescription
        self.paymentData.setDiscount(discount, withCampaign: campaign, consumedDiscount: consumedDiscount, discountDescription: discountDescription)
    }

    func clearDiscount() {
        self.paymentData.clearDiscount()
    }

    func shouldApplyDiscount() -> Bool {
        return paymentPlugin != nil
    }

    public func getPaymentPreferences() -> PXPaymentPreference? {
        return self.checkoutPreference.paymentPreference
    }

    public func cardFormManager() -> CardFormViewModel {
        return CardFormViewModel(paymentMethods: getPaymentMethodsForSelection(), mercadoPagoServices: mercadoPagoServices, bankDealsEnabled: advancedConfig.bankDealsEnabled)
    }

    public func getPaymentMethodsForSelection() -> [PXPaymentMethod] {
        let filteredPaymentMethods = search?.availablePaymentMethods.filter {
            return $0.conformsPaymentPreferences(self.getPaymentPreferences()) && $0.paymentTypeId == self.paymentOptionSelected?.getId()
        }
        guard let paymentMethods = filteredPaymentMethods else {
            return []
        }
        return paymentMethods
    }

    func payerInfoFlow() -> PayerInfoViewModel {
        let viewModel = PayerInfoViewModel(identificationTypes: self.identificationTypes!, payer: self.paymentData.payer!, amountHelper: amountHelper)
        return viewModel
    }

    // Returns list with all cards ids with esc
    func getCardsIdsWithESC() -> [String] {
        guard let customPaymentOptions = customPaymentOptions else { return [] }
        let savedCardIds = PXConfiguratorManager.escProtocol.getSavedCardIds(config: PXConfiguratorManager.escConfig)
        return customPaymentOptions
        .filter { $0.containsSavedId(savedCardIds) }
        .filter { PXConfiguratorManager.escProtocol.getESC(config: PXConfiguratorManager.escConfig,
                                                           cardId: $0.getCardId(),
                                                           firstSixDigits: $0.getFirstSixDigits(),
                                                           lastFourDigits: $0.getCardLastForDigits()) != nil }
        .map { $0.getCardId() }
    }

    func paymentVaultViewModel() -> PaymentVaultViewModel {
        var groupName: String?
        if let optionSelected = paymentOptionSelected {
            groupName = optionSelected.getId()
        }

        populateCheckoutStore()

        var customerOptions: [CustomerPaymentMethod]?

        if inRootGroupSelection() { // Solo se muestran las opciones custom y los plugines en root
            customerOptions = self.customPaymentOptions
        }

        return PaymentVaultViewModel(amountHelper: self.amountHelper, paymentMethodOptions: self.paymentMethodOptions!, customerPaymentOptions: customerOptions, paymentMethods: search?.availablePaymentMethods ?? [], groupName: groupName, isRoot: rootVC, email: self.checkoutPreference.payer.email, mercadoPagoServices: mercadoPagoServices, advancedConfiguration: advancedConfig, disabledOption: disabledOption)
    }

    public func entityTypeViewModel() -> AdditionalStepViewModel {
        return EntityTypeViewModel(amountHelper: self.amountHelper, token: self.cardToken, paymentMethod: self.paymentData.getPaymentMethod()!, dataSource: self.entityTypes!, mercadoPagoServices: mercadoPagoServices, advancedConfiguration: advancedConfig)
    }

    public func financialInstitutionViewModel() -> AdditionalStepViewModel {
        return FinancialInstitutionViewModel(amountHelper: self.amountHelper, token: self.cardToken, paymentMethod: self.paymentData.getPaymentMethod()!, dataSource: self.financialInstitutions!, mercadoPagoServices: mercadoPagoServices, advancedConfiguration: advancedConfig)
    }

    public func issuerViewModel() -> AdditionalStepViewModel {
        guard let paymentMethod = self.paymentData.getPaymentMethod() else {
            fatalError("Cannot find payment method")
        }

        return IssuerAdditionalStepViewModel(amountHelper: self.amountHelper, token: self.cardToken, paymentMethod: paymentMethod, dataSource: self.issuers!, mercadoPagoServices: mercadoPagoServices, advancedConfiguration: advancedConfig)
    }

    public func payerCostViewModel() -> AdditionalStepViewModel {
        guard let paymentMethod = self.paymentData.getPaymentMethod() else {
            fatalError("Cannot find payment method")
        }
        var cardInformation: PXCardInformationForm? = self.cardToken
        if cardInformation == nil {
            if let token = paymentOptionSelected as? PXCardInformationForm {
                cardInformation = token
            }
        }

        return PayerCostAdditionalStepViewModel(amountHelper: self.amountHelper, token: cardInformation, paymentMethod: paymentMethod, dataSource: payerCosts!, email: self.checkoutPreference.payer.email, mercadoPagoServices: mercadoPagoServices, advancedConfiguration: advancedConfig)
    }

    public func getSecurityCodeViewModel(isCallForAuth: Bool = false) -> SecurityCodeViewModel {
        let cardInformation: PXCardInformationForm
        if let paymentOptionSelected = paymentOptionSelected as? PXCardInformationForm {
            cardInformation = paymentOptionSelected
        } else if isCallForAuth, let token = paymentData.token {
            cardInformation = token
        } else {
            fatalError("Cannot convert payment option selected to CardInformation")
        }
        guard let paymentMethod = paymentData.paymentMethod else {
            fatalError("Don't have paymentData to open Security View Controller")
        }
        let reason = SecurityCodeViewModel.getSecurityCodeReason(invalidESCReason: invalidESCReason, isCallForAuth: isCallForAuth)
        return SecurityCodeViewModel(paymentMethod: paymentMethod, cardInfo: cardInformation, reason: reason)
    }

    func reviewConfirmViewModel() -> PXReviewViewModel {
        disableChangePaymentMethodIfNeed()
        return PXReviewViewModel(amountHelper: self.amountHelper, paymentOptionSelected: self.paymentOptionSelected!, advancedConfig: advancedConfig, userLogged: !String.isNullOrEmpty(privateKey))
    }

    func resultViewModel() -> PXResultViewModel {
        guard let paymentResult = paymentResult else {
            fatalError("paymentResult is nil")
        }
        var oneTapDto: PXOneTapDto?
        if paymentResult.isRejectedWithRemedy(), let oneTap = search?.oneTap, let remedy = remedy {
            let paymentMethodId = remedy.suggestedPaymentMethod?.alternativePaymentMethod?.paymentMethodId ?? paymentResult.paymentMethodId
            if paymentMethodId == PXPaymentTypes.CONSUMER_CREDITS.rawValue {
                oneTapDto = oneTap.first(where: { $0.paymentMethodId == paymentMethodId })
            } else {
                let cardId = remedy.suggestedPaymentMethod?.alternativePaymentMethod?.customOptionId ?? paymentResult.cardId
                oneTapDto = oneTap.first(where: { $0.oneTapCard?.cardId == cardId })
                if oneTapDto == nil {
                    oneTapDto = oneTap.first(where: { $0.paymentMethodId == cardId })
                }
            }
        }

        // if it is silver bullet update paymentData with suggestedPaymentMethod
        if let suggestedPaymentMethod = remedy?.suggestedPaymentMethod {
            updatePaymentData(suggestedPaymentMethod)
        }

        return PXResultViewModel(amountHelper: amountHelper, paymentResult: paymentResult, instructionsInfo: instructionsInfo, pointsAndDiscounts: pointsAndDiscounts, resultConfiguration: advancedConfig.paymentResultConfiguration, remedy: remedy, oneTapDto: oneTapDto)
    }

    //SEARCH_PAYMENT_METHODS
    public func updateCheckoutModel(paymentMethods: [PXPaymentMethod], cardToken: PXCardToken?) {
        self.cleanPayerCostSearch()
        self.cleanIssuerSearch()
        self.cleanIdentificationTypesSearch()
        self.cleanRemedy()
        self.paymentData.updatePaymentDataWith(paymentMethod: paymentMethods[0])
        self.cardToken = cardToken
        // Sets if esc is enabled to card token
        self.cardToken?.setRequireESC(escEnabled: getAdvancedConfiguration().isESCEnabled())
    }

    //CREDIT_DEBIT
    public func updateCheckoutModel(paymentMethod: PXPaymentMethod?) {
        if let paymentMethod = paymentMethod {
            self.paymentData.updatePaymentDataWith(paymentMethod: paymentMethod)
        }
    }

    public func updateCheckoutModel(financialInstitution: PXFinancialInstitution) {
        if let TDs = self.paymentData.transactionDetails {
            TDs.financialInstitution = financialInstitution.id
        } else {
            let transactionDetails = PXTransactionDetails(externalResourceUrl: nil, financialInstitution: financialInstitution.id, installmentAmount: nil, netReivedAmount: nil, overpaidAmount: nil, totalPaidAmount: nil, paymentMethodReferenceId: nil)
            self.paymentData.transactionDetails = transactionDetails
        }
    }

    public func updateCheckoutModel(issuer: PXIssuer) {
        self.cleanPayerCostSearch()
        self.paymentData.updatePaymentDataWith(issuer: issuer)
    }

    public func updateCheckoutModel(payer: PXPayer) {
        self.paymentData.updatePaymentDataWith(payer: payer)
    }

    public func updateCheckoutModel(identificationTypes: [PXIdentificationType]) {
        self.identificationTypes = identificationTypes
    }

    public func updateCheckoutModel(remedy: PXRemedy) {
        self.remedy = remedy
    }

    public func cardFlowSupportedIdentificationTypes() -> [PXIdentificationType]? {
        return IdentificationTypeValidator().filterSupported(identificationTypes: self.identificationTypes)
    }

    public func updateCheckoutModel(identification: PXIdentification) {
        self.paymentData.cleanToken()
        self.paymentData.cleanIssuer()
        self.paymentData.cleanPayerCost()
        self.cleanPayerCostSearch()
        self.cleanIssuerSearch()

        if paymentData.hasPaymentMethod() && paymentData.getPaymentMethod()!.isCard {
            self.cardToken!.cardholder!.identification = identification
        } else {
            paymentData.payer?.identification = identification
        }
    }

    public func updateCheckoutModel(payerCost: PXPayerCost) {
        self.paymentData.updatePaymentDataWith(payerCost: payerCost)

        if let paymentOptionSelected = paymentOptionSelected {
            if paymentOptionSelected.isCustomerPaymentMethod() {
                self.paymentData.cleanToken()
            }
        }
    }

    public func updateCheckoutModel(entityType: EntityType) {
        self.paymentData.payer?.entityType = entityType.entityTypeId
    }

    // MARK: PAYMENT METHOD OPTION SELECTION
    public func updateCheckoutModel(paymentOptionSelected: PaymentMethodOption) {
        if !self.initWithPaymentData {
            resetInFormationOnNewPaymentMethodOptionSelected()
        }
        resetPaymentOptionSelectedWith(newPaymentOptionSelected: paymentOptionSelected)
    }

    public func updatePaymentOptionSelectedWithRemedy() {
        let alternativePaymentMethod = remedy?.suggestedPaymentMethod?.alternativePaymentMethod
        let payerPaymentMethod = search?.getPayerPaymentMethod(id: alternativePaymentMethod?.customOptionId)
        guard let customOptionSearchItem = payerPaymentMethod,
              customOptionSearchItem.isCustomerPaymentMethod() else { return }
        updateCheckoutModel(paymentOptionSelected: customOptionSearchItem.getCustomerPaymentMethod())

        if let payerCosts = paymentConfigurationService.getPayerCostsForPaymentMethod(customOptionSearchItem.getId()) {
            self.payerCosts = payerCosts
            if let installment = remedy?.suggestedPaymentMethod?.alternativePaymentMethod?.installmentsList?.first,
                let payerCost = payerCosts.first(where: { $0.installments == installment.installments }) {
                updateCheckoutModel(payerCost: payerCost)
            } else if let defaultPayerCost = checkoutPreference.paymentPreference.autoSelectPayerCost(payerCosts) {
                updateCheckoutModel(payerCost: defaultPayerCost)
            }
        } else {
            payerCosts = nil
        }
        if let discountConfiguration = paymentConfigurationService.getDiscountConfigurationForPaymentMethod(customOptionSearchItem.getId()) {
            attemptToApplyDiscount(discountConfiguration)
        } else {
            applyDefaultDiscountOrClear()
        }
    }

    public func resetPaymentOptionSelectedWith(newPaymentOptionSelected: PaymentMethodOption) {
        self.paymentOptionSelected = newPaymentOptionSelected

        if let targetPlugin = paymentOptionSelected as? PXPaymentMethodPlugin {
            self.paymentMethodPluginToPaymentMethod(plugin: targetPlugin)
            return
        }

        if newPaymentOptionSelected.hasChildren() {
            self.paymentMethodOptions = newPaymentOptionSelected.getChildren()
        }

        if self.paymentOptionSelected!.isCustomerPaymentMethod() {
            self.findAndCompletePaymentMethodFor(paymentMethodId: newPaymentOptionSelected.getId())
        } else if !newPaymentOptionSelected.isCard() && !newPaymentOptionSelected.hasChildren() {
            self.paymentData.updatePaymentDataWith(paymentMethod: Utils.findPaymentMethod(self.availablePaymentMethods!, paymentMethodId: newPaymentOptionSelected.getId()))
        }
    }

    public func nextStep() -> CheckoutStep {
        if needToInitFlow() {
            return .START
        }
        if hasError() {
            return .SCREEN_ERROR
        }
        if shouldExitCheckout() {
            return .ACTION_FINISH
        }
        if needGetRemedy() {
            return .SERVICE_GET_REMEDY
        }
        if shouldShowCongrats() {
            return .SCREEN_PAYMENT_RESULT
        }
        if needOneTapFlow() {
            return .FLOW_ONE_TAP
        }
        if !isPaymentTypeSelected() {
            return .SCREEN_PAYMENT_METHOD_SELECTION
        }
        if shouldShowHook(hookStep: .BEFORE_PAYMENT_METHOD_CONFIG) {
            return .SCREEN_HOOK_BEFORE_PAYMENT_METHOD_CONFIG
        }
        if needToShowPaymentMethodConfigPlugin() {
            willShowPaymentMethodConfigPlugin()
            return .SCREEN_PAYMENT_METHOD_PLUGIN_CONFIG
        }
        if shouldShowHook(hookStep: .AFTER_PAYMENT_METHOD_CONFIG) {
            return .SCREEN_HOOK_AFTER_PAYMENT_METHOD_CONFIG
        }
        if shouldShowHook(hookStep: .BEFORE_PAYMENT) {
            return .SCREEN_HOOK_BEFORE_PAYMENT
        }
        if needToCreatePayment() || shouldSkipReviewAndConfirm() {
            readyToPay = false
            return .SERVICE_POST_PAYMENT
        }
        if needReviewAndConfirm() {
            return .SCREEN_REVIEW_AND_CONFIRM
        }
        if needCompleteCard() {
            return .SCREEN_CARD_FORM
        }
        if needToGetIdentificationTypes() {
            return .SERVICE_GET_IDENTIFICATION_TYPES
        }
        if needToGetPayerInfo() {
            return .SCREEN_PAYER_INFO_FLOW
        }
        if needGetIdentification() {
            return .SCREEN_IDENTIFICATION
        }
        if needSecurityCode() {
            return .SCREEN_SECURITY_CODE
        }
        if needCreateToken() {
            return .SERVICE_CREATE_CARD_TOKEN
        }
        if needGetEntityTypes() {
            return .SCREEN_ENTITY_TYPE
        }
        if needGetFinancialInstitutions() {
            return .SCREEN_FINANCIAL_INSTITUTIONS
        }
        if needGetIssuers() {
            return .SERVICE_GET_ISSUERS
        }
        if needIssuerSelectionScreen() {
            return .SCREEN_ISSUERS
        }
        if needChosePayerCost() {
            return .SERVICE_GET_PAYER_COSTS
        }
        if needPayerCostSelectionScreen() {
            return .SCREEN_PAYER_COST
        }
        return .ACTION_FINISH
    }

    fileprivate func autoselectOnlyPaymentMethod() {
        guard let search = self.search else {
            return
        }

        var paymentOptionSelected: PaymentMethodOption?

        if !Array.isNullOrEmpty(search.groups) && search.groups.count == 1 {
            paymentOptionSelected = search.groups.first
        } else if !Array.isNullOrEmpty(search.payerPaymentMethods) && search.payerPaymentMethods.count == 1 {
            paymentOptionSelected = search.payerPaymentMethods.first
        }

        if let paymentOptionSelected = paymentOptionSelected {
            self.updateCheckoutModel(paymentOptionSelected: paymentOptionSelected)
        }
    }

    func getPaymentOptionConfigurations(paymentMethodSearch: PXInitDTO) -> Set<PXPaymentMethodConfiguration> {
        let discountConfigurationsKeys = paymentMethodSearch.coupons.keys
        var configurations = Set<PXPaymentMethodConfiguration>()
        for customOption in paymentMethodSearch.payerPaymentMethods {
            var paymentOptionConfigurations = [PXPaymentOptionConfiguration]()
            for key in discountConfigurationsKeys {
                guard let discountConfiguration = paymentMethodSearch.coupons[key], let payerCostConfiguration = customOption.paymentOptions?[key] else {
                    continue
                }
                let paymentOptionConfiguration = PXPaymentOptionConfiguration(id: key, discountConfiguration: discountConfiguration, payerCostConfiguration: payerCostConfiguration)
                paymentOptionConfigurations.append(paymentOptionConfiguration)
            }
            let paymentMethodConfiguration = PXPaymentMethodConfiguration(paymentOptionID: customOption.id, discountInfo: customOption.discountInfo, creditsInfo: customOption.comment, paymentOptionsConfigurations: paymentOptionConfigurations, selectedAmountConfiguration: customOption.couponToApply)
            configurations.insert(paymentMethodConfiguration)
        }
        return configurations
    }

    internal func updateCustomTexts() {
        // If AdditionalInfo has custom texts override the ones set by MercadoPagoCheckoutBuilder
        if let customTexts = checkoutPreference.pxAdditionalInfo?.pxCustomTexts {
            if let translation = customTexts.payButton {
                Localizator.sharedInstance.addCustomTranslation(.pay_button, translation)
            }
            if let translation = customTexts.payButtonProgress {
                Localizator.sharedInstance.addCustomTranslation(.pay_button_progress, translation)
            }
            if let translation = customTexts.totalDescription {
                Localizator.sharedInstance.addCustomTranslation(.total_to_pay, translation)
                Localizator.sharedInstance.addCustomTranslation(.total_to_pay_onetap, translation)
            }
        }
    }

    public func updateCheckoutModel(paymentMethodSearch: PXInitDTO) {
        let configurations = getPaymentOptionConfigurations(paymentMethodSearch: paymentMethodSearch)
        self.paymentConfigurationService.setConfigurations(configurations)
        self.paymentConfigurationService.setDefaultDiscountConfiguration(paymentMethodSearch.selectedDiscountConfiguration)

        self.search = paymentMethodSearch

        guard let search = self.search else {
            return
        }

        self.rootPaymentMethodOptions = paymentMethodSearch.groups
        self.paymentMethodOptions = self.rootPaymentMethodOptions
        self.availablePaymentMethods = paymentMethodSearch.availablePaymentMethods
        customPaymentOptions?.removeAll()

        for pxCustomOptionSearchItem in search.payerPaymentMethods {
            let customerPaymentMethod = pxCustomOptionSearchItem.getCustomerPaymentMethod()
            customPaymentOptions = Array.safeAppend(customPaymentOptions, customerPaymentMethod)
        }

        let totalPaymentMethodSearchCount = search.getPaymentOptionsCount()

        if totalPaymentMethodSearchCount == 0 {
            self.errorInputs(error: MPSDKError(message: "Hubo un error".localized, errorDetail: "No se ha podido obtener los métodos de pago con esta preferencia".localized, retry: false), errorCallback: { () in
            })
        } else if totalPaymentMethodSearchCount == 1 {
            autoselectOnlyPaymentMethod()
        }

        // MoneyIn "ChoExpress"
        if let defaultPM = getPreferenceDefaultPaymentOption() {
            updateCheckoutModel(paymentOptionSelected: defaultPM)
        }
    }

    public func updateCheckoutModel(token: PXToken) {
        if let esc = token.esc, !String.isNullOrEmpty(esc) {
            PXConfiguratorManager.escProtocol.saveESC(config: PXConfiguratorManager.escConfig, token: token, esc: esc)
        } else {
            PXConfiguratorManager.escProtocol.deleteESC(config: PXConfiguratorManager.escConfig, token: token, reason: .NO_ESC, detail: nil)
        }
        self.paymentData.updatePaymentDataWith(token: token)
    }

    public func updateCheckoutModel(paymentMethodOptions: [PaymentMethodOption]) {
        if self.rootPaymentMethodOptions != nil {
            self.rootPaymentMethodOptions!.insert(contentsOf: paymentMethodOptions, at: 0)
        } else {
            self.rootPaymentMethodOptions = paymentMethodOptions
        }
        self.paymentMethodOptions = self.rootPaymentMethodOptions
    }

    func updateCheckoutModel(paymentData: PXPaymentData) {
        self.paymentData = paymentData
        if paymentData.getPaymentMethod() == nil {
            prepareForNewSelection()
            self.initWithPaymentData = false
        } else {
            self.readyToPay = !self.needToCompletePayerInfo()
        }
    }

    func needToCompletePayerInfo() -> Bool {
        if let paymentMethod = self.paymentData.getPaymentMethod() {
            if paymentMethod.isPayerInfoRequired {
                return !self.isPayerSetted()
            }
        }

        return false
    }

    public func updateCheckoutModel(payment: PXPayment) {
        self.payment = payment
        self.paymentResult = PaymentResult(payment: self.payment!, paymentData: self.paymentData)
    }

    public func isCheckoutComplete() -> Bool {
        return checkoutComplete
    }

    public func setIsCheckoutComplete(isCheckoutComplete: Bool) {
        self.checkoutComplete = isCheckoutComplete
    }

    internal func findAndCompletePaymentMethodFor(paymentMethodId: String) {
        guard let availablePaymentMethods = availablePaymentMethods else {
            fatalError("availablePaymentMethods cannot be nil")
        }
        if paymentMethodId == PXPaymentTypes.ACCOUNT_MONEY.rawValue {
            paymentData.updatePaymentDataWith(paymentMethod: Utils.findPaymentMethod(availablePaymentMethods, paymentMethodId: paymentMethodId))
        } else if let paymentOptionSelected = paymentOptionSelected as? PXCardInformation {
            let cardInformation = paymentOptionSelected
            let paymentMethod = Utils.findPaymentMethod(availablePaymentMethods, paymentMethodId: cardInformation.getPaymentMethodId())
            cardInformation.setupPaymentMethodSettings(paymentMethod.settings)
            cardInformation.setupPaymentMethod(paymentMethod)
            paymentData.updatePaymentDataWith(paymentMethod: cardInformation.getPaymentMethod())
            paymentData.updatePaymentDataWith(issuer: cardInformation.getIssuer())
        }
    }

    func hasCustomPaymentOptions() -> Bool {
        return !Array.isNullOrEmpty(self.customPaymentOptions)
    }

    internal func handleCustomerPaymentMethod() {
        guard let availablePaymentMethods = availablePaymentMethods else {
            fatalError("availablePaymentMethods cannot be nil")
        }
        if let paymentMethodId = self.paymentOptionSelected?.getId(), paymentMethodId == PXPaymentTypes.ACCOUNT_MONEY.rawValue {
            paymentData.updatePaymentDataWith(paymentMethod: Utils.findPaymentMethod(availablePaymentMethods, paymentMethodId: paymentMethodId))
        } else {
            // Se necesita completar información faltante de settings y pm para custom payment options
            guard let cardInformation = paymentOptionSelected as? PXCardInformation else {
                fatalError("Cannot convert paymentOptionSelected to CardInformation")
            }
            let paymentMethod = Utils.findPaymentMethod(availablePaymentMethods, paymentMethodId: cardInformation.getPaymentMethodId())
            cardInformation.setupPaymentMethodSettings(paymentMethod.settings)
            cardInformation.setupPaymentMethod(paymentMethod)
            paymentData.updatePaymentDataWith(paymentMethod: cardInformation.getPaymentMethod())
        }
    }

    func entityTypesFinder(inDict: NSDictionary, forKey: String) -> [EntityType]? {
        if let siteETsDictionary = inDict.value(forKey: forKey) as? NSDictionary {
            let entityTypesKeys = siteETsDictionary.allKeys
            var entityTypes = [EntityType]()

            for ET in entityTypesKeys {
                let entityType = EntityType()
                if let etKey = ET as? String, let etValue = siteETsDictionary.value(forKey: etKey) as? String {
                    entityType.entityTypeId = etKey
                    entityType.name = etValue.localized
                    entityTypes.append(entityType)
                }
            }
            return entityTypes
        }
        return nil
    }

    func getEntityTypes() -> [EntityType] {
        let dictET = ResourceManager.shared.getDictionaryForResource(named: "EntityTypes")
        let site = SiteManager.shared.getSiteId()

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

    func populateCheckoutStore() {
        PXCheckoutStore.sharedInstance.paymentDatas = [self.paymentData]
        if let splitAccountMoney = amountHelper.splitAccountMoney {
            PXCheckoutStore.sharedInstance.paymentDatas.append(splitAccountMoney)
        }
        PXCheckoutStore.sharedInstance.checkoutPreference = self.checkoutPreference
    }

    func getResult() -> PXResult? {
        if let ourPayment = payment {
            return ourPayment
        } else {
            return getGenericPayment()
        }
    }

    func getGenericPayment() -> PXGenericPayment? {
        if let paymentResponse = paymentResult {
            return PXGenericPayment(status: paymentResponse.status, statusDetail: paymentResponse.statusDetail, paymentId: paymentResponse.paymentId)
        } else if let businessResultResponse = businessResult {
            return PXGenericPayment(status: businessResultResponse.paymentStatus, statusDetail: businessResultResponse.paymentStatusDetail, paymentId: businessResultResponse.getReceiptId())
        }
        return nil
    }

    func getOurPayment() -> PXPayment? {
        return payment
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

    func resetInFormationOnNewPaymentMethodOptionSelected() {
        resetInformation()
        hookService.resetHooksToShow()
    }

    func resetInformation() {
        self.clearCollectedData()
        self.cardToken = nil
        self.entityTypes = nil
        self.financialInstitutions = nil
        cleanPayerCostSearch()
        cleanIssuerSearch()
        cleanIdentificationTypesSearch()
        resetPaymentMethodConfigPlugin()
    }

    func clearCollectedData() {
        self.paymentData.clearPaymentMethodData()
        self.paymentData.clearPayerData()

        // Se setea nuevamente el payer que tenemos en la preferencia para no perder los datos
        paymentData.updatePaymentDataWith(payer: checkoutPreference.getPayer())
    }

    func isPayerSetted() -> Bool {
        if let payerData = self.paymentData.getPayer(),
            let payerIdentification = payerData.identification,
            let type = payerIdentification.type,
            let boletoType = BoletoType(rawValue: type) {
            //cpf type requires first name and last name to be a valid payer
            let cpfCase = payerData.firstName != nil && payerData.lastName != nil && boletoType == .cpf
            //cnpj type requires legal name to be a valid payer
            let cnpjCase = payerData.legalName != nil && boletoType == .cnpj
            let validDetail = cpfCase || cnpjCase
            // identification value is required for both scenarios
            let validIdentification = payerIdentification.number != nil
            let validPayer = validDetail && validIdentification
            return validPayer
        }

        return false
    }

    func cleanPayerCostSearch() {
        self.payerCosts = nil
    }

    func cleanIssuerSearch() {
        self.issuers = nil
    }

    func cleanIdentificationTypesSearch() {
        self.identificationTypes = nil
    }

    func cleanRemedy() {
        self.remedy = nil
    }

    func cleanPaymentResult() {
        self.payment = nil
        self.paymentResult = nil
        self.readyToPay = false
        self.setIsCheckoutComplete(isCheckoutComplete: false)
        self.paymentFlow?.cleanPayment()
    }

    func prepareForClone() {
        self.cleanPaymentResult()
        self.wentBackFrom(hook: .BEFORE_PAYMENT)
    }

    func prepareForNewSelection() {
        self.keepDisabledOptionIfNeeded()
        self.cleanPaymentResult()
        self.cleanRemedy()
        self.resetInformation()
        self.resetGroupSelection()
        self.applyDefaultDiscountOrClear()
        self.rootVC = true
        hookService.resetHooksToShow()
    }

    func prepareForInvalidPaymentWithESC(reason: PXESCDeleteReason) {
        if self.paymentData.isComplete() {
            readyToPay = true
            if let cardId = paymentData.getToken()?.cardId, cardId.isNotEmpty {
                savedESCCardToken = PXSavedESCCardToken(cardId: cardId, esc: nil, requireESC: getAdvancedConfiguration().isESCEnabled())
                PXConfiguratorManager.escProtocol.deleteESC(config: PXConfiguratorManager.escConfig, cardId: cardId, reason: reason, detail: nil)
            }
        }
        self.paymentData.cleanToken()
    }

    static internal func clearEnviroment() {
        MercadoPagoCheckoutViewModel.error = nil
    }
    func inRootGroupSelection() -> Bool {
        guard let root = rootPaymentMethodOptions, let actual = paymentMethodOptions else {
            return true
        }
        if let hashableSet = NSSet(array: actual) as? Set<AnyHashable> {
            return NSSet(array: root).isEqual(to: hashableSet)
        }
        return true
    }
}

// MARK: Advanced Config
extension MercadoPagoCheckoutViewModel {
    func getAdvancedConfiguration() -> PXAdvancedConfiguration {
        return advancedConfig
    }

    private func disableChangePaymentMethodIfNeed() {
        if let pmSearch = search, let firsPm = pmSearch.availablePaymentMethods.first {
            if pmSearch.getPaymentOptionsCount() == 1 && !firsPm.isCard {
                 advancedConfig.reviewConfirmConfiguration.disableChangeMethodOption()
            }
        } else {
            advancedConfig.reviewConfirmConfiguration.disableChangeMethodOption()
        }
    }
}

// MARK: Payment Flow
extension MercadoPagoCheckoutViewModel {
    func createPaymentFlow(paymentErrorHandler: PXPaymentErrorHandlerProtocol) -> PXPaymentFlow {
        guard let paymentFlow = paymentFlow else {
            let paymentFlow = PXPaymentFlow(paymentPlugin: paymentPlugin, mercadoPagoServices: mercadoPagoServices, paymentErrorHandler: paymentErrorHandler, navigationHandler: pxNavigationHandler, amountHelper: amountHelper, checkoutPreference: checkoutPreference, ESCBlacklistedStatus: search?.configurations?.ESCBlacklistedStatus)
            if let productId = advancedConfig.productId {
                paymentFlow.setProductIdForPayment(productId)
            }
            self.paymentFlow = paymentFlow
            return paymentFlow
        }
        paymentFlow.model.amountHelper = amountHelper
        paymentFlow.model.checkoutPreference = checkoutPreference
        return paymentFlow
    }
}

extension MercadoPagoCheckoutViewModel {
    func keepDisabledOptionIfNeeded() {
        disabledOption = PXDisabledOption(paymentResult: self.paymentResult)
    }

    func clean() {
        paymentFlow = nil
        initFlow = nil
        onetapFlow = nil
    }
}

// MARK: Remedy
private extension MercadoPagoCheckoutViewModel {
    func updatePaymentData(_ suggestedPaymentMethod: PXSuggestedPaymentMethod) {
        if let alternativePaymentMethod = suggestedPaymentMethod.alternativePaymentMethod,
            let paymentResult = paymentResult,
            let sliderViewModel = onetapFlow?.model.pxOneTapViewModel?.getCardSliderViewModel() {

            var cardId = alternativePaymentMethod.customOptionId ?? paymentResult.cardId
            let paymentMethodId = alternativePaymentMethod.paymentMethodId ?? paymentResult.paymentMethodId
            if paymentMethodId == PXPaymentTypes.CONSUMER_CREDITS.rawValue {
                cardId = paymentMethodId
            }
            if let targetModel = sliderViewModel.first(where: { $0.cardId == cardId && $0.paymentMethodId == paymentMethodId }),
               let newPaymentMethod = onetapFlow?.model.pxOneTapViewModel?.getPaymentMethod(targetId: targetModel.paymentMethodId) {
                paymentResult.paymentData?.payerCost = targetModel.selectedPayerCost
                paymentResult.paymentData?.paymentMethod = newPaymentMethod
                paymentResult.paymentData?.issuer = targetModel.payerPaymentMethod?.issuer ?? PXIssuer(id: targetModel.issuerId, name: nil)
                if let installments = alternativePaymentMethod.installmentsList?.first?.installments,
                   let newPayerCost = targetModel.payerCost.first(where: { $0.installments == installments }) {
                    paymentResult.paymentData?.payerCost = newPayerCost
                }
            }
        }
    }
}
