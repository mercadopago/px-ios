//
//  OneTapFlow+Screens.swift
//  MercadoPagoSDK
//
//  Created by Eden Torres on 09/05/2018.
//  Copyright © 2018 MercadoPago. All rights reserved.
//

import Foundation

extension OneTapFlow {
    func showOneTapViewController() {
        let callbackPaymentData: ((PXPaymentData) -> Void) = { [weak self] (paymentData: PXPaymentData) in
            self?.cancelFlowForNewPaymentSelection()
        }
        let callbackConfirm: ((PXPaymentData, Bool) -> Void) = { [weak self] (paymentData, splitAccountMoneyEnabled) in
            guard let self = self else { return }
            self.model.updateCheckoutModel(paymentData: paymentData, splitAccountMoneyEnabled: splitAccountMoneyEnabled)
            // Deletes default one tap option in payment method search
            self.executeNextStep()
        }
        let callbackUpdatePaymentOption: ((PaymentMethodOption) -> Void) = { [weak self] paymentMethodOption in
            if let cardSliderViewModel = paymentMethodOption as? PXCardSliderViewModel,
               let paymentMethodType = cardSliderViewModel.getSelectedApplication()?.paymentTypeId,
               let customerPaymentMethodOption = self?.getCustomerPaymentMethodOption(cardId: cardSliderViewModel.getCardId() ?? "", paymentMethodType: paymentMethodType) {
                // Customer card.
                self?.model.paymentOptionSelected = customerPaymentMethodOption
            } else {
                self?.model.paymentOptionSelected = paymentMethodOption
            }
        }

        let finishButtonAnimation: (() -> Void) = { [weak self] in
            self?.executeNextStep()
        }
//        model.pxOneTapViewModel = viewModel
        
//        let viewController = NewOneTapController(viewModel: viewModel)
        
//        let viewController = PXOneTapViewController(viewModel: viewModel, timeOutPayButton: model.getTimeoutForOneTapReviewController(), callbackPaymentData: callbackPaymentData, callbackConfirm: callbackConfirm, callbackUpdatePaymentOption: callbackUpdatePaymentOption, callbackRefreshInit: callbackRefreshInit, callbackExit: callbackExit, finishButtonAnimation: finishButtonAnimation)
        pxNavigationHandler.coordinateToOneTap(oneTapCardDesignModel: model.getOneTapCardDesignModel(),
                                               oneTapModel: model.getOneTapModel(), coordinatorDelegate: self)
//        pxNavigationHandler.navigationController.pushViewController(viewController, animated: true)
    }

    func updateOneTapViewModel(cardId: String) {
        if let oneTapViewController = pxNavigationHandler.navigationController.viewControllers.first(where: { $0 is PXOneTapViewController }) as? PXOneTapViewController {
            let viewModel = model.getOneTapCardDesignModel()
//            model.pxOneTapViewModel = viewModel
//            oneTapViewController.update(viewModel: viewModel, cardId: cardId)
        }
    }

    func showSecurityCodeScreen() {
        guard !isPXSecurityCodeViewControllerLastVC() else { return }
        let securityCodeVc = PXSecurityCodeViewController(viewModel: model.savedCardSecurityCodeViewModel(),
            finishButtonAnimationCallback: { [weak self] in
                self?.executeNextStep()
            }, collectSecurityCodeCallback: { [weak self] _, securityCode in
                self?.getTokenizationService().createCardToken(securityCode: securityCode)
        })
        pxNavigationHandler.pushViewController(viewController: securityCodeVc, animated: true)
    }

    func showKyCScreen() {
        MPXTracker.sharedInstance.trackEvent(event: OneTapTrackingEvents.didTapOnOfflineMethods)
        PXDeepLinkManager.open(model.getKyCDeepLink())
    }
}

extension OneTapFlow: OneTapCoodinatorDelegate {
    func updatePaymentOption(paymentMethodOption: PaymentMethodOption) {
        if let cardSliderViewModel = paymentMethodOption as? PXCardSliderViewModel,
           let paymentMethodType = cardSliderViewModel.getSelectedApplication()?.paymentTypeId,
           let customerPaymentMethodOption = getCustomerPaymentMethodOption(cardId: cardSliderViewModel.getCardId() ?? "", paymentMethodType: paymentMethodType) {
            // Customer card.
            model.paymentOptionSelected = customerPaymentMethodOption
        } else {
            model.paymentOptionSelected = paymentMethodOption
        }
    }
    
    func refreshFlow(cardId: String) {
        self.refreshInitFlow(cardId: cardId)
    }
    
    func didUpdateCard(selectedCard: PXCardSliderViewModel) {
        self.model.selectedCard = selectedCard
    }
    
    func userDidUpdateCardList(cardList: [PXCardSliderViewModel]) {
        self.model.cardList = cardList
    }
    
    func closeFlow() {
        self.cancelFlow()
    }
    
    func clearPaymentData() {
        cancelFlowForNewPaymentSelection()
    }
    
    func finishButtonAnimation() {
        executeNextStep()
    }
    
    func userDidConfirmPayment(paymentData: PXPaymentData, isSplitAccountPaymentEnable: Bool) {
        model.updateCheckoutModel(paymentData: paymentData, splitAccountMoneyEnabled: isSplitAccountPaymentEnable)
        // Deletes default one tap option in payment method search
        executeNextStep()
    }
}
