//
//  PXOneTapViewModel.swift
//  MercadoPagoSDK
//
//  Created by Juan sebastian Sanzone on 15/5/18.
//  Copyright © 2018 MercadoPago. All rights reserved.
//

import Foundation
import MLCardDrawer

protocol OneTapRedirects: AnyObject {
    func goToCongrats()
    func goToBiometric()
    func goToCVV()
    func goToCardForm()
    func showOfflinePaymentSheet(offlineController: PXOfflineMethodsViewController)
}

final class PXOneTapViewModel {
    // MARK: - Privates properties
    private let oneTapModel: OneTapModel
    private var selectedCard: PXCardSliderViewModel
    private var cardViewModel: CardViewModel
    private var installmentViewModel: InstallmentViewModel
    private var headerViewModel: HeaderViewModel

    // MARK: - Public properties
    weak var coordinator: OneTapRedirects?

    init(oneTapModel: OneTapModel, oneTapCardDesignModel: OneTapCardDesignModel) {
        self.oneTapModel = oneTapModel
        self.cardViewModel = CardViewModel(oneTapModel: oneTapCardDesignModel)
        self.installmentViewModel = InstallmentViewModel(cards: cardViewModel.getCards())
        self.headerViewModel = HeaderViewModel(selectedCard: selectedCard,
                                               amountHelper: cardViewModel.getAmountHelper(),
                                               additionalInfoSummary: cardViewModel.getAdditionalInfoSummary(),
                                               shouldDisplayChargesHelp: shouldDisplayChargesHelp(),
                                               item: cardViewModel.getItem())
    }

    func shouldValidateWithBiometric(withCardId: String? = nil) -> Bool {
        coordinator?.goToCVV()
        return true
    }
    
    func validateWithBiometric(onSuccess: @escaping () -> Void, onError: @escaping (Error) -> Void) {
        let config = PXConfiguratorManager.biometricConfig
        config.setAmount(NSDecimalNumber(value: cardViewModel.getAmountHelper().amountToPay))
        PXConfiguratorManager.biometricProtocol.validate(config: PXConfiguratorManager.biometricConfig, onSuccess: onSuccess, onError: onError)
    }
    
    // MARK: - Controller Methods
    func getCards() -> [PXCardSliderViewModel] {
        return cardViewModel.getCards()
    }
    
    func getInstallments() -> [PXOneTapInstallmentInfoViewModel] {
        return installmentViewModel.getInstallments()
    }
    
    func getApplications() -> [PXOneTapApplication] {
        return cardViewModel.getApplications()
    }
    
    func getHeaderViewModel() -> PXOneTapHeaderViewModel {
        return headerViewModel.getHeaderViewModel()
    }
    
    func getModal(modalKey: String) -> PXModal? {
        return cardViewModel.getModal(modalKey: modalKey)
    }
    
    func getSplitMessageForDebit(amountToPay: Double) -> NSAttributedString {
        return cardViewModel.getSplitMessageForDebit(amountToPay: amountToPay)
    }
    
    func getSelectedCard() -> PXCardSliderViewModel {
        return selectedCard
    }
    
    func getAmountHelper() -> PXAmountHelper {
        return cardViewModel.getAmountHelper()
    }
    
    func getCardBottomMessage(paymentTypeId: String?, benefits: PXBenefits?, status: PXStatus?, selectedPayerCost: PXPayerCost?, displayInfo: PXOneTapDisplayInfo?) -> PXCardBottomMessage? {
        return cardViewModel.getCardBottomMessage(paymentTypeId: paymentTypeId,
                                                  benefits: benefits,
                                                  status: status,
                                                  selectedPayerCost: selectedPayerCost,
                                                  displayInfo: displayInfo)
    }
    
    func getExperiment() -> PXExperiment? {
        return oneTapModel.experimentsViewModel.getExperiment(name: PXExperimentsViewModel.HIGHLIGHT_INSTALLMENTS)
    }
    
    func showOfflinePaymentOptions() {
        guard let offlinePaymentOptions = getOfflineMethods() else { return }
        let offlineViewModel = PXOfflineMethodsViewModel(
            offlinePaymentTypes: offlinePaymentOptions.paymentTypes,
            paymentMethods: cardViewModel.getPaymentMethods(),
            amountHelper: cardViewModel.getAmountHelper(),
            paymentOptionSelected: oneTapModel.paymentOptionSelected,
            advancedConfig: oneTapModel.advancedConfiguration,
            userLogged: oneTapModel.userLogged,
            disabledOption: cardViewModel.getDisabledOption(),
            payerCompliance: cardViewModel.getPayerCompliance(),
            displayInfo: offlinePaymentOptions.displayInfo
        )
        
        let offlineController = PXOfflineMethodsViewController(viewModel: offlineViewModel)
        
        coordinator?.showOfflinePaymentSheet(offlineController: offlineController)
    }
    
    func setSplitPayment(isEnable: Bool) {
        cardViewModel.setSplitPayment(isEnable: isEnable)
    }
    
    func setPayerCost(value: PXPayerCost?) {
        cardViewModel.getAmoutHelper().getPaymentData().payerCost = value
    }
}

// MARK: ViewModels Publics.
extension PXOneTapViewModel {
    func updateCardSliderModel(at index: Int, bottomMessage: PXCardBottomMessage?) {
        if cardViewModel.getCards().indices.contains(index) {
            cardViewModel.setBottomMessage(at: index, bottomMessage: bottomMessage)
        }
    }

    func updateAllCardSliderModels(splitPaymentEnabled: Bool) {
        for index in cardViewModel.getCards().indices  {
            _ = updateCardSliderSplitPaymentPreference(splitPaymentEnabled: splitPaymentEnabled, for: index)
        }
    }

    func updateCardSliderSplitPaymentPreference(splitPaymentEnabled: Bool, for index: Int) -> Bool {
        if cardViewModel.getCards().indices.contains(index) {
            if splitPaymentEnabled, let selectedApplication = cardViewModel.getSelectedApplication(at: index) {
                selectedApplication.payerCost = selectedApplication.amountConfiguration?.splitConfiguration?.primaryPaymentMethod?.payerCosts ?? []
                selectedApplication.selectedPayerCost = selectedApplication.amountConfiguration?.splitConfiguration?.primaryPaymentMethod?.selectedPayerCost
                selectedApplication.amountConfiguration?.splitConfiguration?.splitEnabled = splitPaymentEnabled

                // Show arrow to switch installments
                if selectedApplication.payerCost.count > 1 {
                    selectedApplication.shouldShowArrow = true
                } else {
                    selectedApplication.shouldShowArrow = false
                }
                return true
            } else if let selectedApplication = cardViewModel.getSelectedApplication(at: index) {
                selectedApplication.payerCost = selectedApplication.amountConfiguration?.payerCosts ?? []
                selectedApplication.selectedPayerCost = selectedApplication.amountConfiguration?.selectedPayerCost
                selectedApplication.amountConfiguration?.splitConfiguration?.splitEnabled = splitPaymentEnabled

                // Show arrow to switch installments
                if selectedApplication.payerCost.count > 1 {
                    selectedApplication.shouldShowArrow = true
                } else {
                    selectedApplication.shouldShowArrow = false
                }
                return true
            }
            return false
        }
        return false
    }

    func updateCardSliderViewModel(newPayerCost: PXPayerCost?, forIndex: Int) -> Bool {
        if cardViewModel.getCards().indices.contains(forIndex), let selectedApplication = cardViewModel.getSelectedApplication(at: forIndex) {
            selectedApplication.selectedPayerCost = newPayerCost
            selectedApplication.userDidSelectPayerCost = true
            return true
        }
        return false
    }

    func updateCardSliderViewModel(pxCardSliderViewModel: [PXCardSliderViewModel]) {
        cardViewModel.setDataSource(dataSource: pxCardSliderViewModel)
    }

    func getPaymentMethod(paymentMethodId: String) -> PXPaymentMethod? {
        return Utils.findPaymentMethod(cardViewModel.getPaymentMethods(), paymentMethodId: paymentMethodId)
    }

    func shouldDisplayChargesHelp() -> Bool {
        return getChargeRuleViewController() != nil
    }

    func getChargeRuleViewController() -> UIViewController? {
        
        let paymentTypeId = cardViewModel.getAmoutHelper().getPaymentData().paymentMethod?.paymentTypeId

        let chargeRule = cardViewModel.getChargeRule(paymentTypeId: paymentTypeId)
        let vc = chargeRule?.detailModal
        return vc
    }

    func shouldUseOldCardForm() -> Bool {
        if let newCardVersion = cardViewModel.getExpressData()?.filter({$0.newCard != nil}).first?.newCard?.version {
            return newCardVersion == "v1"
        }
        return false
    }

    func shouldAutoDisplayOfflinePaymentMethods() -> Bool {
        guard let enabledOneTapCards = (cardViewModel.getExpressData()?.filter { $0.status.enabled }) else { return false }
        let enabledPureOfflineCards = enabledOneTapCards.filter { ($0.offlineMethods != nil) && ($0.newCard == nil) }
        return enabledOneTapCards.count == enabledPureOfflineCards.count
    }
    
    func doPayment() {
        if let selectedApplication = selectedCard.getSelectedApplication() {
            cardViewModel.getAmountHelper().getPaymentData().payerCost = selectedApplication.selectedPayerCost
        }
        let splitPayment = cardViewModel.getIsSplitPaymentEnabled()
//        callbackConfirm(viewModel.amountHelper.getPaymentData(), splitPayment)
    }
}

// MARK: Privates.
extension PXOneTapViewModel {
    func getExternalViewControllerForSubtitle() -> UIViewController? {
        return oneTapModel.advancedConfiguration.dynamicViewControllersConfiguration.filter({
            $0.position(store: PXCheckoutStore.sharedInstance) == .DID_TAP_ONETAP_HEADER
        }).first?.viewController(store: PXCheckoutStore.sharedInstance)
    }

    private func getOfflineMethods() -> PXOfflineMethods? {
        return cardViewModel.getExpressData()?
            .compactMap { $0.offlineMethods }
            .first
    }
}

extension PXOneTapViewModel: CardDelegate {
    func cardDidChange(card: CardViewModel) {
//        self.selectedCard = card
    }
}

struct PXCardBottomMessage {
    let text: PXText
    let fixed: Bool
}

// MARK: Tracking
extension PXOneTapViewModel {
    func getAvailablePaymentMethodForTracking() -> [Any] {
        var dic: [Any] = []
        if let expressData = cardViewModel.getExpressData() {
            for expressItem in expressData where expressItem.newCard == nil {
                
                var itemForTracking : [String: Any]
                
                if expressItem.oneTapCard != nil {
                    itemForTracking = expressItem.getCardForTracking(amountHelper: getAmountHelper())
                } else if expressItem.accountMoney != nil {
                    itemForTracking = expressItem.getAccountMoneyForTracking()
                } else {
                    itemForTracking = expressItem.getPaymentMethodForTracking()
                }
                
                if let applicationsArray = expressItem.applications {
                    var applications: [[String : Any]] = []
                    
                    applicationsArray.forEach { application in
                        applications.append(getValidationProgramProperties(oneTapApplication: application))
                    }
                    
                    if var extraInfo = itemForTracking["extra_info"] as? [String: Any] {
                        extraInfo["methods_applications"] = applications
                        itemForTracking["extra_info"] = extraInfo
                    }
                    
                }
                
                dic.append(itemForTracking)
            }
        }
        return dic
    }

    func getPaymentMethodsQuantityForTracking(enabled: Bool) -> Int {
        var availablePMQuantity = 0
        if let expressData = cardViewModel.getExpressData() {
            for expressItem in expressData where expressItem.status.enabled == enabled && expressItem.newCard == nil {
                availablePMQuantity += 1
            }
        }
        return availablePMQuantity
    }

    func getInstallmentsScreenProperties(installmentData: PXInstallment, selectedCard: PXCardSliderViewModel) -> [String: Any] {
        var properties: [String: Any] = [:]
        properties["payment_method_id"] = getAmountHelper().getPaymentData().paymentMethod?.id
        properties["payment_method_type"] = getAmountHelper().getPaymentData().paymentMethod?.paymentTypeId
        properties["card_id"] =  selectedCard.getCardId()
        if let issuerId = getAmountHelper().getPaymentData().issuer?.id {
            properties["issuer_id"] = Int64(issuerId)
        }
        var dic: [Any] = []
        for payerCost in installmentData.payerCosts {
            dic.append(payerCost.getPayerCostForTracking())
        }
        properties["available_installments"] = dic
        return properties
    }

    func getConfirmEventProperties(selectedCard: PXCardSliderViewModel, selectedIndex: Int) -> [String: Any] {
        guard let paymentMethod = getAmountHelper().getPaymentData().paymentMethod else {
            return [:]
        }
        let cardIdsEsc = PXTrackingStore.sharedInstance.getData(forKey: PXTrackingStore.cardIdsESC) as? [String] ?? []

        var properties: [String: Any] = [:]
        properties["payment_method_selected_index"] = selectedIndex
        if paymentMethod.isCard {
            properties["payment_method_type"] = paymentMethod.paymentTypeId
            properties["payment_method_id"] = paymentMethod.id
            properties["review_type"] = "one_tap"
            var extraInfo: [String: Any] = [:]
            extraInfo["card_id"] = selectedCard.getCardId
            extraInfo["has_esc"] = cardIdsEsc.contains(selectedCard.getCardId() ?? "")
            extraInfo["selected_installment"] = getAmountHelper().getPaymentData().payerCost?.getPayerCostForTracking()
            if let issuerId = getAmountHelper().getPaymentData().issuer?.id {
                extraInfo["issuer_id"] = Int64(issuerId)
            }
            //TODO: Check funtions of commented lines -- tracking
//            extraInfo["has_split"] = splitPaymentEnabled
            properties["extra_info"] = extraInfo
        } else {
            properties["payment_method_type"] = paymentMethod.id
            properties["payment_method_id"] = paymentMethod.id
            properties["review_type"] = "one_tap"
            var extraInfo: [String: Any] = [:]
            extraInfo["balance"] = selectedCard.getAccountMoney()
            extraInfo["selected_installment"] = getAmountHelper().getPaymentData().payerCost?.getPayerCostForTracking(isDigitalCurrency: paymentMethod.isDigitalCurrency)
            properties["extra_info"] = extraInfo
        }
        return properties
    }

    func getOneTapScreenProperties(oneTapApplication: [PXOneTapApplication]) -> [String: Any] {
        var properties: [String: Any] = [:]
        let availablePaymentMethods = getAvailablePaymentMethodForTracking()
        let availablePMQuantity = getPaymentMethodsQuantityForTracking(enabled: true)
        let disabledPMQuantity = getPaymentMethodsQuantityForTracking(enabled: false)
        properties["available_methods"] = availablePaymentMethods
        properties["available_methods_quantity"] = availablePMQuantity
        properties["disabled_methods_quantity"] = disabledPMQuantity
        properties["total_amount"] = getAmountHelper().preferenceAmount
        properties["discount"] = getAmountHelper().getDiscountForTracking()
        var itemsDic: [Any] = []
        for item in getAmountHelper().preference.items {
            itemsDic.append(item.getItemForTracking())
        }
        properties["items"] = itemsDic
        return properties
    }

    func getErrorProperties(error: MPSDKError) -> [String: Any] {
        var properties: [String: Any] = [:]
        properties["path"] = TrackingPaths.Screens.OneTap.getOneTapPath()
        properties["style"] = Tracking.Style.snackbar
        properties["id"] = Tracking.Error.Id.genericError
        properties["message"] = "review_and_confirm_toast_error".localized
        properties["attributable_to"] = Tracking.Error.Atrributable.mercadopago
        var extraDic: [String: Any] = [:]
        extraDic["api_url"] =  error.requestOrigin
        properties["extra_info"] = extraDic
        return properties
    }

    func getSelectCardEventProperties(index: Int, count: Int) -> [String: Any] {
        var properties: [String: Any] = [:]
        properties["path"] = TrackingPaths.Screens.OneTap.getOneTapPath()
        properties["style"] = Tracking.Style.noScreen
        properties["id"] = Tracking.Error.Id.genericError
        properties["message"] = "No se pudo seleccionar la tarjeta ingresada"
        properties["attributable_to"] = Tracking.Error.Atrributable.mercadopago
        var extraDic: [String: Any] = [:]
        extraDic["index"] =  index
        extraDic["count"] =  count
        properties["extra_info"] = extraDic
        return properties
    }

    func getTargetBehaviourProperties(_ behaviour: PXBehaviour) -> [String: Any] {
        var properties: [String: Any] = [:]
        if let target = behaviour.target {
            properties["behaviour"] = behaviour.modal ?? ""
            properties["deepLink"] = target
        }
        return properties
    }

    func getDialogOpenProperties(_ behaviour: PXBehaviour, _ modalConfig: PXModal) -> [String: Any] {
        var properties: [String: Any] = [:]
        if behaviour.target != nil {
            return getTargetBehaviourProperties(behaviour)
        } else if let modal = behaviour.modal {
            properties["description"] = modal
            var actions = 0
            if modalConfig.mainButton != nil { actions += 1 }
            if modalConfig.secondaryButton != nil { actions += 1 }
            properties["actions"] = actions
        }
        return properties
    }

    func getDialogDismissProperties(_ behaviour: PXBehaviour, _ modalConfig: PXModal) -> [String: Any] {
        return getDialogOpenProperties(behaviour, modalConfig)
    }
    
    func getValidationProgramProperties(oneTapApplication: PXOneTapApplication) -> [String : Any] {
        var properties: [String: Any] = [:]
        var subProperties: [[String: Any]] = []
        properties["enable"] = oneTapApplication.status.enabled
        properties["payment_method_id"] = oneTapApplication.paymentMethod.id
        properties["payment_type_id"] = oneTapApplication.paymentMethod.type
        properties["status_detail"] = oneTapApplication.status.detail
        oneTapApplication.validationPrograms?.forEach { program in
            var programDict: [String: Any] = [:]
            programDict["id"] = program.id
            programDict["mandatory"] = program.mandatory
            subProperties.append(programDict)
        }
        properties["validation_programs"] = subProperties
        return properties
    }

    func getDialogActionProperties(_ behaviour: PXBehaviour, _ modalConfig: PXModal, _ type: String, _ button: PXRemoteAction?) -> [String: Any]? {
        guard let button = button else { return nil }
        var properties = getDialogOpenProperties(behaviour, modalConfig)
        properties["type"] = type
        properties["deepLink"] = button.target ?? ""
        return properties
    }
}

