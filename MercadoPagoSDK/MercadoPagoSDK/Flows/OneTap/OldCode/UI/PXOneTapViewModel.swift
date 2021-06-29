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
}

final class PXOneTapViewModel {
    // MARK: - Privates properties
    private var selectedCard: PXCardSliderViewModel?
    private var cardViewModel: CardViewModel?
    private var installmentViewModel: InstallmentViewModel?
    private var headerViewModel: HeaderViewModel?

    // MARK: - Public properties
    weak var coordinator: OneTapRedirects?

    init(

    ) {

    }

    func shouldValidateWithBiometric(withCardId: String? = nil) {
        coordinator?.goToCVV()
    }
}

// MARK: ViewModels Publics.
extension PXOneTapViewModel {
    func updateCardSliderModel(at index: Int, bottomMessage: PXCardBottomMessage?) {
        if cardSliderViewModel.indices.contains(index) {
            cardSliderViewModel[index].getSelectedApplication()?.bottomMessage = bottomMessage
        }
    }

    func updateAllCardSliderModels(splitPaymentEnabled: Bool) {
        for index in cardSliderViewModel.indices {
            _ = updateCardSliderSplitPaymentPreference(splitPaymentEnabled: splitPaymentEnabled, forIndex: index)
        }
    }

    func updateCardSliderSplitPaymentPreference(splitPaymentEnabled: Bool, forIndex: Int) -> Bool {
        if cardSliderViewModel.indices.contains(forIndex) {
            if splitPaymentEnabled, let selectedApplication = cardSliderViewModel[forIndex].getSelectedApplication() {
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
            } else if let selectedApplication = cardSliderViewModel[forIndex].getSelectedApplication() {
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
        if cardSliderViewModel.indices.contains(forIndex), let selectedApplication = cardSliderViewModel[forIndex].getSelectedApplication() {
            selectedApplication.selectedPayerCost = newPayerCost
            selectedApplication.userDidSelectPayerCost = true
            return true
        }
        return false
    }

    func updateCardSliderViewModel(pxCardSliderViewModel: [PXCardSliderViewModel]) {
        self.cardSliderViewModel = pxCardSliderViewModel
    }

    func getPaymentMethod(paymentMethodId: String) -> PXPaymentMethod? {
        return Utils.findPaymentMethod(paymentMethods, paymentMethodId: paymentMethodId)
    }

    func shouldDisplayChargesHelp() -> Bool {
        return getChargeRuleViewController() != nil
    }

    func getChargeRuleViewController() -> UIViewController? {
        
//        let paymentTypeId = amountHelper.getPaymentData().paymentMethod?.paymentTypeId
//
//        let chargeRule = getChargeRule(paymentTypeId: paymentTypeId)
//        let vc = chargeRule?.detailModal
        return nil
    }

    func shouldUseOldCardForm() -> Bool {
        if let newCardVersion = expressData?.filter({$0.newCard != nil}).first?.newCard?.version {
            return newCardVersion == "v1"
        }
        return false
    }

    func shouldAutoDisplayOfflinePaymentMethods() -> Bool {
        guard let enabledOneTapCards = (expressData?.filter { $0.status.enabled }) else { return false }
        let enabledPureOfflineCards = enabledOneTapCards.filter { ($0.offlineMethods != nil) && ($0.newCard == nil) }
        return enabledOneTapCards.count == enabledPureOfflineCards.count
    }
}

// MARK: Privates.
extension PXOneTapViewModel {
    func getExternalViewControllerForSubtitle() -> UIViewController? {
        return advancedConfiguration.dynamicViewControllersConfiguration.filter({
            $0.position(store: PXCheckoutStore.sharedInstance) == .DID_TAP_ONETAP_HEADER
        }).first?.viewController(store: PXCheckoutStore.sharedInstance)
    }

    func getOfflineMethods() -> PXOfflineMethods? {
        return expressData?
            .compactMap { $0.offlineMethods }
            .first
    }
}

extension PXOneTapViewModel: CardDelegate {
    func cardDidChange(card: CardViewModel) {
        self.selectedCard = card
    }
}

struct PXCardBottomMessage {
    let text: PXText
    let fixed: Bool
}
