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
    
    func getHeaderView() -> PXOneTapHeaderViewModel {
        return headerViewModel.getHeaderViewModel()
    }
    
    func getModal(modalKey: String) -> PXModal? {
        return cardViewModel.getModal(modalKey: modalKey)
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
        let vc = chargeRule.detailModal
        return vc
    }

    func shouldUseOldCardForm() -> Bool {
        if let newCardVersion = cardViewModel.getExpressData()?.filter({$0.newCard != nil}).first?.newCard?.version {
            return newCardVersion == "v1"
        }
        return false
    }

    func shouldAutoDisplayOfflinePaymentMethods() -> Bool {
        guard let enabledOneTapCards = (cardViewModel.getExpressData()?.filter { $0.status.enabled }) else { PXReviewViewModeleturn false }
        let enabledPureOfflineCards = enabledOneTapCards.filter { ($0.offlineMethods != nil) && ($0.newCard == nil) }
        return enabledOneTapCards.count == enabledPureOfflineCards.count
    }
}

// MARK: Privates.
extension PXOneTapViewModel {
//    func getExternalViewControllerForSubtitle() -> UIViewController? {
//        return advancedConfiguration.dynamicViewControllersConfiguration.filter({
//            $0.position(store: PXCheckoutStore.sharedInstance) == .DID_TAP_ONETAP_HEADER
//        }).first?.viewController(store: PXCheckoutStore.sharedInstance)
//    }

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
