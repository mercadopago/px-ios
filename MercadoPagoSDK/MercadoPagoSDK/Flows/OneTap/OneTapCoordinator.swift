//
//  OneTapCoordinator.swift
//  MercadoPagoSDKV4
//
//  Created by Matheus Leandro Martins on 22/06/21.
//

import UIKit
import MLCardForm

protocol OneTapCoodinatorDelegate: AnyObject {
    func didUpdateCard(selectedCard: PXCardSliderViewModel)
    func userDidUpdateCardList(cardList: [PXCardSliderViewModel])
    func refreshFlow(cardId: String)
    func closeFlow()
}

final class OneTapCoordinator: BaseCoordinator {
    // MARK: - Private properties
    private let navigationController: UINavigationController
    private let oneTapViewModel: PXOneTapViewModel
    private lazy var oneTapController: PXOneTapViewController = PXOneTapViewController(viewModel: oneTapViewModel)
    
    // MARK: - Public properties
    weak var delegate: OneTapCoodinatorDelegate?
    
    // MARK: - Initialization
    init(
        navigationController: UINavigationController,
        cardViewModel: CardViewModel,
        selectedCard: PXCardSliderViewModel,
        oneTapModel: OneTapModel
    ) {
        self.navigationController = navigationController
        self.oneTapViewModel = PXOneTapViewModel(oneTapModel: oneTapModel, cardViewModel: cardViewModel, selectedCard: selectedCard)
    }
    
    // MARK: - Overrides
    override func start() {
        oneTapViewModel.coordinator = self
        oneTapController.coordinatorDelegate = self
        navigationController.pushViewController(oneTapController, animated: true)
    }
}

// MARK: - OneTapRedirects
extension OneTapCoordinator: OneTapCoordinatorActions {
    func goToCardForm(cardFormParameters: CardFormParameters, initType: String) {
        let flowId = MPXTracker.sharedInstance.getFlowName() ?? "unknown"
        let builder: MLCardFormBuilder

        if let privateKey = cardFormParameters.privateKey {
            builder = MLCardFormBuilder(privateKey: privateKey, siteId: cardFormParameters.siteId, flowId: flowId, lifeCycleDelegate: self)
        } else {
            builder = MLCardFormBuilder(publicKey: cardFormParameters.publicKey, siteId: cardFormParameters.siteId, flowId: flowId, lifeCycleDelegate: self)
        }

        builder.setLanguage(Localizator.sharedInstance.getLanguage())
        builder.setExcludedPaymentTypes(cardFormParameters.excludedPaymentTypeIds)
        builder.setNavigationBarCustomColor(backgroundColor: ThemeManager.shared.navigationBar().backgroundColor, textColor: ThemeManager.shared.navigationBar().tintColor)
        var cardFormVC: UIViewController
        switch initType {
        case "webpay_tbk":
            cardFormVC = MLCardForm(builder: builder).setupWebPayController()
        default:
            builder.setAnimated(true)
            cardFormVC = MLCardForm(builder: builder).setupController()
        }
        navigationController.pushViewController(cardFormVC, animated: true)
    }
    
    func didUpdateCard(selectedCard: PXCardSliderViewModel) {
        delegate?.didUpdateCard(selectedCard: selectedCard)
    }
    
    func userDidUpdateCardList(cardList: [PXCardSliderViewModel]) {
        delegate?.userDidUpdateCardList(cardList: cardList)
    }
    
    func refreseInitFlow(cardId: String) {
        delegate?.refreshFlow(cardId: cardId)
    }
    
    func userDidCloseFlow() {
        delegate?.closeFlow()
    }
    
    func showOfflinePaymentSheet(offlineController: PXOfflineMethodsViewController) {
        let sheet = PXOfflineMethodsSheetViewController(viewController: offlineController,
                                                        offlineViewModel: offlineController.viewModel,
                                                        whiteViewHeight: PXCardSliderSizeManager.getWhiteViewHeight(viewController: oneTapController))

        offlineController.eventsDelegate = self
        navigationController.present(sheet, animated: true, completion: nil)
    }
}

extension OneTapCoordinator: OfflineMethodsEventsDelegate {
    func userDidConfirm(paymentData: PXPaymentData, isSplitPayment: Bool) {
        
    }
    
    func didFinishCheckout() {
        
    }
    
    func finishButtonAnimation() {
        
    }
    
    func updatePaymentOption(paymentOption: PaymentMethodOption) {
        
    }
}

extension OneTapCoordinator: MLCardFormLifeCycleDelegate {
    func didAddCard(cardID: String) {
        
    }
    
    func didFailAddCard() {
        
    }
    
    
}
