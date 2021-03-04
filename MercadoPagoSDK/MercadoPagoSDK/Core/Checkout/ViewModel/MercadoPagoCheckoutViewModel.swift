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
    case SCREEN_SECURITY_CODE
    case SERVICE_CREATE_CARD_TOKEN
    case SERVICE_POST_PAYMENT
    case SERVICE_GET_REMEDY
    case SCREEN_PAYMENT_RESULT
    case SCREEN_ERROR
    case SCREEN_PAYMENT_METHOD_PLUGIN_CONFIG
    case FLOW_ONE_TAP
}

internal class MercadoPagoCheckoutViewModel: NSObject, NSCopying {
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
    @available(*, deprecated, message: "No longer used")
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
        PXConfiguratorManager.threeDSConfig = PXThreeDSConfig.createConfig(privateKey: privateKey)

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

    public func getPaymentMethodsForSelection() -> [PXPaymentMethod] {
        let filteredPaymentMethods = search?.availablePaymentMethods.filter {
            return $0.conformsPaymentPreferences(self.getPaymentPreferences()) && $0.paymentTypeId == self.paymentOptionSelected?.getId()
        }
        guard let paymentMethods = filteredPaymentMethods else {
            return []
        }
        return paymentMethods
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

    public func getPXSecurityCodeViewModel(isCallForAuth: Bool = false) -> PXSecurityCodeViewModel {
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

        let reason = PXSecurityCodeViewModel.getSecurityCodeReason(invalidESCReason: invalidESCReason, isCallForAuth: isCallForAuth)
        let cardSliderViewModel = onetapFlow?.model.pxOneTapViewModel?.getCardSliderViewModel(cardId: paymentOptionSelected?.getId())
        let cardUI = cardSliderViewModel?.cardUI ?? TemplateCard()
        let cardData = cardSliderViewModel?.selectedApplication?.cardData ?? PXCardDataFactory()

        return PXSecurityCodeViewModel(paymentMethod: paymentMethod, cardInfo: cardInformation, reason: reason, cardUI: cardUI, cardData: cardData, internetProtocol: mercadoPagoServices)
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

    public func updateCheckoutModel(payer: PXPayer) {
        self.paymentData.updatePaymentDataWith(payer: payer)
    }

    public func updateCheckoutModel(remedy: PXRemedy) {
        self.remedy = remedy
    }

    public func updateCheckoutModel(identification: PXIdentification) {
        self.paymentData.cleanToken()
        self.paymentData.cleanIssuer()
        self.paymentData.cleanPayerCost()
        self.cleanPayerCostSearch()

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
        guard let customOptionSearchItem = search?.getPayerPaymentMethod(id: alternativePaymentMethod?.customOptionId, paymentMethodId: alternativePaymentMethod?.paymentMethodId, paymentTypeId: alternativePaymentMethod?.paymentTypeId),
              customOptionSearchItem.isCustomerPaymentMethod() else { return }
        updateCheckoutModel(paymentOptionSelected: customOptionSearchItem.getCustomerPaymentMethod())

        if let payerCosts = paymentConfigurationService.getPayerCostsForPaymentMethod(paymentOptionID: customOptionSearchItem.getId(), paymentMethodId: customOptionSearchItem.paymentMethodId, paymentTypeId: customOptionSearchItem.getPaymentType()) {
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
        if let discountConfiguration = paymentConfigurationService.getDiscountConfigurationForPaymentMethod(paymentOptionID: customOptionSearchItem.getId(), paymentMethodId: customOptionSearchItem.paymentMethodId, paymentTypeId: customOptionSearchItem.getPaymentType()) {
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
        if needToShowPaymentMethodConfigPlugin() {
            willShowPaymentMethodConfigPlugin()
            return .SCREEN_PAYMENT_METHOD_PLUGIN_CONFIG
        }
        if needToCreatePayment() || shouldSkipReviewAndConfirm() {
            readyToPay = false
            return .SERVICE_POST_PAYMENT
        }
        if needSecurityCode() {
            return .SCREEN_SECURITY_CODE
        }
        if needCreateToken() {
            return .SERVICE_CREATE_CARD_TOKEN
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
            let paymentMethodConfiguration = PXPaymentMethodConfiguration(customOptionSearchItem: customOption, paymentOptionsConfigurations: paymentOptionConfigurations)
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
        } else if let cardInformation = paymentOptionSelected as? PXCardInformation {
            if let paymentMethod = Utils.findPaymentMethod(availablePaymentMethods, paymentMethodId: cardInformation.getPaymentMethodId()) {
                cardInformation.setupPaymentMethodSettings(paymentMethod.settings)
                cardInformation.setupPaymentMethod(paymentMethod)
            }
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
            if let paymentMethod = Utils.findPaymentMethod(availablePaymentMethods, paymentMethodId: cardInformation.getPaymentMethodId()) {
                cardInformation.setupPaymentMethodSettings(paymentMethod.settings)
                cardInformation.setupPaymentMethod(paymentMethod)
            }
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
            return PXGenericPayment(status: paymentResponse.status, statusDetail: paymentResponse.statusDetail, paymentId: paymentResponse.paymentId, paymentMethodId: paymentResponse.paymentMethodId, paymentMethodTypeId: paymentResponse.paymentMethodTypeId)
        } else if let businessResultResponse = businessResult {
            return PXGenericPayment(status: businessResultResponse.paymentStatus, statusDetail: businessResultResponse.paymentStatusDetail, paymentId: businessResultResponse.getReceiptId(), paymentMethodId: businessResultResponse.getPaymentMethodId(), paymentMethodTypeId: businessResultResponse.getPaymentMethodTypeId())
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
    }

    func resetInformation() {
        self.clearCollectedData()
        self.cardToken = nil
        self.entityTypes = nil
        self.financialInstitutions = nil
        cleanPayerCostSearch()
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
            let payerIdentification = payerData.identification {
            let validPayer = payerIdentification.number != nil
            return validPayer
        }

        return false
    }

    func cleanPayerCostSearch() {
        self.payerCosts = nil
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
    }

    func prepareForNewSelection() {
        self.keepDisabledOptionIfNeeded()
        self.cleanPaymentResult()
        self.cleanRemedy()
        self.resetInformation()
        self.resetGroupSelection()
        self.applyDefaultDiscountOrClear()
        self.rootVC = true
    }

    func isPXSecurityCodeViewControllerLastVC() -> Bool {
        return pxNavigationHandler.navigationController.viewControllers.last is PXSecurityCodeViewController
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
            // TODO: check for this on the where condition: && $0.paymentMethodId == paymentMethodId
            if let targetModel = sliderViewModel.first(where: { $0.cardId == cardId  }) {
                guard let selectedApplication = targetModel.selectedApplication else { return }
                if let paymentMethods = availablePaymentMethods,
                   let newPaymentMethod = Utils.findPaymentMethod(paymentMethods, paymentMethodId: selectedApplication.paymentMethodId) {
                    paymentResult.paymentData?.payerCost = selectedApplication.selectedPayerCost
                    paymentResult.paymentData?.paymentMethod = newPaymentMethod
                    paymentResult.paymentData?.issuer = selectedApplication.payerPaymentMethod?.issuer ?? PXIssuer(id: targetModel.issuerId, name: nil)
                    if let installments = alternativePaymentMethod.installmentsList?.first?.installments,
                       let newPayerCost = selectedApplication.payerCost.first(where: { $0.installments == installments }) {
                        paymentResult.paymentData?.payerCost = newPayerCost
                    }
}
            }
        }
    }
}
