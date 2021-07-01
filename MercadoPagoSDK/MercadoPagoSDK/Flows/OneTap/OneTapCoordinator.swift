//
//  OneTapCoordinator.swift
//  MercadoPagoSDKV4
//
//  Created by Matheus Leandro Martins on 22/06/21.
//

import UIKit

protocol OneTapCoodinatorDelegate: AnyObject {
    func didUpdateCard(selectedCard: PXCardSliderViewModel)
    func userDidUpdateCardList(cardList: [PXCardSliderViewModel])
    func refreshFlow(cardId: String)
    func closeFlow()
}

final class OneTapCoordinator: BaseCoordinator {
    // MARK: - Private properties
    private let navigationController: UINavigationController
    private let controller: PXOneTapViewController
    
    // MARK: - Public properties
    weak var delegate: OneTapCoodinatorDelegate?
    
    // MARK: - Initialization
    init(
        navigationController: UINavigationController,
        oneTapCardDesignModel: OneTapCardDesignModel,
        oneTapModel: OneTapModel
    ) {
//        super.init()
        self.navigationController = navigationController
        //TODO: Initialize old controller
        self.controller = PXOneTapViewController(viewModel: PXOneTapViewModel(
                                                    oneTapModel: oneTapModel,
                                                    oneTapCardDesignModel: oneTapCardDesignModel)
        )
    }
    
    // MARK: - Overrides
    override func start() {
        controller.coordinatorDelegate = self
        navigationController.pushViewController(controller, animated: true)
    }
}

// MARK: - OneTapRedirects
extension OneTapCoordinator: OneTapCoordinatorActions {
    func didUpdateCard(selectedCard: PXCardSliderViewModel) {
        
    }
    
    func userDidUpdateCardList(cardList: [PXCardSliderViewModel]) {
        
    }
    
    func refreseInitFlow(cardId: String) {
        
    }
    
    func userDidCloseFlow() {
        
    }
    
    func showOfflinePaymentSheet(offlineController: PXOfflineMethodsViewController) {
        let sheet = PXOfflineMethodsSheetViewController(viewController: offlineController,
                                                        offlineViewModel: offlineController.viewModel,
                                                        whiteViewHeight: 250)
        offlineController.eventsDelegate = self
        navigationController.present(sheet, animated: true, completion: nil)
    }
    
    func goToCongrats() {
        
    }
    
    func goToBiometric() {
        
    }
    
    func goToCVV() {

    }
    
    func goToCardForm() {
        
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
