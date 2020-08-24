//
//  OneTapFlowViewModel.swift
//  MercadoPagoSDK
//
//  Created by Eden Torres on 09/05/2018.
//  Copyright © 2018 MercadoPago. All rights reserved.
//

import Foundation

final internal class OneTapFlowModel: PXFlowModel {
    enum Steps: String {
        case finish
        case screenOneTap
        case screenSecurityCode
        case serviceCreateESCCardToken
        case screenKyC
        case payment
    }
    internal var publicKey: String = ""
    internal var privateKey: String?
    internal var siteId: String = ""
    var paymentData: PXPaymentData
    let checkoutPreference: PXCheckoutPreference
    var paymentOptionSelected: PaymentMethodOption?
    let search: PXInitDTO
    var readyToPay: Bool = false
    var paymentResult: PaymentResult?
    var instructionsInfo: PXInstructions?
    var pointsAndDiscounts: PXPointsAndDiscounts?
    var businessResult: PXBusinessResult?
    var customerPaymentOptions: [CustomerPaymentMethod]?
    var splitAccountMoney: PXPaymentData?
    var disabledOption: PXDisabledOption?
    var pxOneTapViewModel: PXOneTapViewModel?

    // Payment flow
    var paymentFlow: PXPaymentFlow?
    weak var paymentResultHandler: PXPaymentResultHandlerProtocol?

    // One Tap Flow
    weak var oneTapFlow: OneTapFlow?

    var chargeRules: [PXPaymentTypeChargeRule]?

    var invalidESCReason: PXESCDeleteReason?

    // In order to ensure data updated create new instance for every usage
    internal var amountHelper: PXAmountHelper {
        return PXAmountHelper(preference: self.checkoutPreference, paymentData: self.paymentData, chargeRules: chargeRules, paymentConfigurationService: self.paymentConfigurationService, splitAccountMoney: splitAccountMoney)
    }

    let advancedConfiguration: PXAdvancedConfiguration
    let mercadoPagoServices: MercadoPagoServices
    let paymentConfigurationService: PXPaymentConfigurationServices

    init(checkoutViewModel: MercadoPagoCheckoutViewModel, search: PXInitDTO, paymentOptionSelected: PaymentMethodOption?) {
        publicKey = checkoutViewModel.publicKey
        privateKey = checkoutViewModel.privateKey
        siteId = checkoutViewModel.search?.site.id ?? ""
        paymentData = checkoutViewModel.paymentData.copy() as? PXPaymentData ?? checkoutViewModel.paymentData
        checkoutPreference = checkoutViewModel.checkoutPreference
        self.search = search
        self.paymentOptionSelected = paymentOptionSelected
        advancedConfiguration = checkoutViewModel.getAdvancedConfiguration()
        chargeRules = checkoutViewModel.chargeRules
        mercadoPagoServices = checkoutViewModel.mercadoPagoServices
        paymentConfigurationService = checkoutViewModel.paymentConfigurationService
        disabledOption = checkoutViewModel.disabledOption

        // Payer cost pre selection.
        let paymentMethodId = search.oneTap?.first?.paymentMethodId
        let firstCardID = search.oneTap?.first?.oneTapCard?.cardId
        let creditsCase = paymentMethodId == PXPaymentTypes.CONSUMER_CREDITS.rawValue
        let cardCase = firstCardID != nil

        if cardCase || creditsCase {
            if let pmIdentifier = cardCase ? firstCardID : paymentMethodId,
                let payerCost = amountHelper.paymentConfigurationService.getSelectedPayerCostsForPaymentMethod(pmIdentifier) {
                updateCheckoutModel(payerCost: payerCost)
            }
        }
    }
    public func nextStep() -> Steps {
        if needShowOneTap() {
            return .screenOneTap
        }
        if needSecurityCode() {
            return .screenSecurityCode
        }
        if needCreateESCToken() {
            return .serviceCreateESCCardToken
        }
        if needKyC() {
            return .screenKyC
        }
        if needCreatePayment() {
            return .payment
        }
        return .finish
    }
}

// MARK: Create view model
internal extension OneTapFlowModel {
    func savedCardSecurityCodeViewModel() -> SecurityCodeViewModel {
        guard let cardInformation = self.paymentOptionSelected as? PXCardInformation else {
            fatalError("Cannot convert payment option selected to CardInformation")
        }

        guard let paymentMethod = paymentData.paymentMethod else {
            fatalError("Don't have paymentData to open Security View Controller")
        }

        let reason = SecurityCodeViewModel.getSecurityCodeReason(invalidESCReason: invalidESCReason)
        return SecurityCodeViewModel(paymentMethod: paymentMethod, cardInfo: cardInformation, reason: reason)
    }

    func oneTapViewModel() -> PXOneTapViewModel {
        let viewModel = PXOneTapViewModel(amountHelper: amountHelper, paymentOptionSelected: paymentOptionSelected, advancedConfig: advancedConfiguration, userLogged: false, disabledOption: disabledOption, currentFlow: oneTapFlow, payerPaymentMethods: search.payerPaymentMethods, experiments: search.experiments)
        viewModel.publicKey = publicKey
        viewModel.privateKey = privateKey
        viewModel.siteId = siteId
        viewModel.excludedPaymentTypeIds = checkoutPreference.getExcludedPaymentTypesIds()
        viewModel.expressData = search.oneTap
        viewModel.payerCompliance = search.payerCompliance
        viewModel.paymentMethods = search.availablePaymentMethods
        viewModel.items = checkoutPreference.items
        viewModel.additionalInfoSummary = checkoutPreference.pxAdditionalInfo?.pxSummary
        viewModel.modals = search.modals
        return viewModel
    }
}

// MARK: Update view models
internal extension OneTapFlowModel {
    func updateCheckoutModel(paymentData: PXPaymentData, splitAccountMoneyEnabled: Bool) {
        self.paymentData = paymentData

        if splitAccountMoneyEnabled, let paymentOptionSelected = paymentOptionSelected {
            let splitConfiguration = amountHelper.paymentConfigurationService.getSplitConfigurationForPaymentMethod(paymentOptionSelected.getId())

            // Set total amount to pay with card without discount
            paymentData.transactionAmount = PXAmountHelper.getRoundedAmountAsNsDecimalNumber(amount: splitConfiguration?.primaryPaymentMethod?.amount)

            let accountMoneyPMs = search.availablePaymentMethods.filter { (paymentMethod) -> Bool in
                return paymentMethod.id == splitConfiguration?.secondaryPaymentMethod?.id
            }
            if let accountMoneyPM = accountMoneyPMs.first {
                splitAccountMoney = PXPaymentData()
                // Set total amount to pay with account money without discount
                splitAccountMoney?.transactionAmount = PXAmountHelper.getRoundedAmountAsNsDecimalNumber(amount: splitConfiguration?.secondaryPaymentMethod?.amount)
                splitAccountMoney?.updatePaymentDataWith(paymentMethod: accountMoneyPM)

                let campaign = amountHelper.paymentConfigurationService.getDiscountConfigurationForPaymentMethodOrDefault(paymentOptionSelected.getId())?.getDiscountConfiguration().campaign
                let isDiscountAvailable = amountHelper.paymentConfigurationService.getDiscountConfigurationForPaymentMethodOrDefault(paymentOptionSelected.getId())?.getDiscountConfiguration().isAvailable
                if let discount = splitConfiguration?.primaryPaymentMethod?.discount, let campaign = campaign, let isDiscountAvailable = isDiscountAvailable {
                    paymentData.setDiscount(discount, withCampaign: campaign, consumedDiscount: !isDiscountAvailable)
                }
                if let discount = splitConfiguration?.secondaryPaymentMethod?.discount, let campaign = campaign, let isDiscountAvailable = isDiscountAvailable {
                    splitAccountMoney?.setDiscount(discount, withCampaign: campaign, consumedDiscount: !isDiscountAvailable)
                }
            }
        } else {
            splitAccountMoney = nil
        }

        self.readyToPay = true
    }

    func updateCheckoutModel(token: PXToken) {
        self.paymentData.updatePaymentDataWith(token: token)
    }

    func updateCheckoutModel(payerCost: PXPayerCost) {
        guard let paymentOptionSelected = paymentOptionSelected else {
            return
        }

        let isCredits = paymentOptionSelected.getId() == PXPaymentTypes.CONSUMER_CREDITS.rawValue
        if paymentOptionSelected.isCard() || isCredits {
            self.paymentData.updatePaymentDataWith(payerCost: payerCost)
            self.paymentData.cleanToken()
        }
    }
}

// MARK: Flow logic
internal extension OneTapFlowModel {
    func needShowOneTap() -> Bool {
        if readyToPay {
            return false
        }

        return true
    }

    func needSecurityCode() -> Bool {
        guard let paymentMethod = self.paymentData.getPaymentMethod() else {
            return false
        }

        guard let paymentOptionSelected = paymentOptionSelected else {
            return false
        }

        if !readyToPay {
            return false
        }

        let hasInstallmentsIfNeeded = paymentData.hasPayerCost() || !paymentMethod.isCreditCard
        let paymentOptionSelectedId = paymentOptionSelected.getId()
        let isCustomerCard = paymentOptionSelected.isCustomerPaymentMethod() && paymentOptionSelectedId != PXPaymentTypes.ACCOUNT_MONEY.rawValue && paymentOptionSelectedId != PXPaymentTypes.CONSUMER_CREDITS.rawValue

        if isCustomerCard && !paymentData.hasToken() && hasInstallmentsIfNeeded {
            if let customOptionSearchItem = search.payerPaymentMethods.first(where: { $0.id == paymentOptionSelectedId}) {
                if hasSavedESC() {
                    if customOptionSearchItem.escStatus == PXESCStatus.REJECTED.rawValue {
                        invalidESCReason = .ESC_CAP
                        return true
                    } else {
                        return false
                    }
                } else {
                    return true
                }
            } else {
                return true
            }
        }
        return false
    }

    func needCreateESCToken() -> Bool {
        guard let paymentMethod = self.paymentData.getPaymentMethod() else {
            return false
        }

        let hasInstallmentsIfNeeded = self.paymentData.getPayerCost() != nil || !paymentMethod.isCreditCard
        let savedCardWithESC = !paymentData.hasToken() && paymentMethod.isCard && hasSavedESC() && hasInstallmentsIfNeeded

        return savedCardWithESC
    }

    func needKyC() -> Bool {
        return !(search.payerCompliance?.offlineMethods.isCompliant ?? true) && paymentOptionSelected?.additionalInfoNeeded?() ?? false
    }

    func needCreatePayment() -> Bool {
        if !readyToPay {
            return false
        }
        return paymentData.isComplete(shouldCheckForToken: false) && paymentFlow != nil && paymentResult == nil && businessResult == nil
    }

    func hasSavedESC() -> Bool {
        if let card = paymentOptionSelected as? PXCardInformation {
            return PXConfiguratorManager.escProtocol.getESC(config: PXConfiguratorManager.escConfig, cardId: card.getCardId(), firstSixDigits: card.getFirstSixDigits(), lastFourDigits: card.getCardLastForDigits()) == nil ? false : true
        }
        return false
    }

    func needToShowLoading() -> Bool {
        guard let paymentMethod = paymentData.getPaymentMethod() else {
            return true
        }
        if let paymentFlow = paymentFlow, paymentMethod.isAccountMoney || hasSavedESC() {
            return paymentFlow.hasPaymentPluginScreen()
        }
        return true
    }

    func getTimeoutForOneTapReviewController() -> TimeInterval {
        if let paymentFlow = paymentFlow {
            paymentFlow.model.amountHelper = amountHelper
            let tokenTimeOut: TimeInterval = mercadoPagoServices.getTimeOut()
            // Payment Flow timeout + tokenization TimeOut
            return paymentFlow.getPaymentTimeOut() + tokenTimeOut
        }
        return 0
    }

    func getKyCDeepLink() -> String? {
        return search.payerCompliance?.offlineMethods.turnComplianceDeepLink
    }
}
