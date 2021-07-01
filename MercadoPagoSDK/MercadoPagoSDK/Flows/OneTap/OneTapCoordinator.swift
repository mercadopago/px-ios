//
//  OneTapCoordinator.swift
//  MercadoPagoSDKV4
//
//  Created by Matheus Leandro Martins on 22/06/21.
//

import UIKit

final class OneTapCoordinator: BaseCoordinator {
    // MARK: - Private properties
    private let navigationController: UINavigationController
    private let controller: NewOneTapController
    
    // MARK: - Initialization
    init(navigationController: UINavigationController, info: PXInitDTO, disabledOption: PXDisabledOption?, excludedPaymentTypeIds: [String]) {
//        super.init()
        self.navigationController = navigationController
        //TODO: Initialize old controller
        self.controller = NewOneTapController(viewModel: CardViewModel(oneTapModel: OneTapCardDesignModel(paymentInfos: info, disabledOption: disabledOption, excludedPaymentTypeIds: excludedPaymentTypeIds, publicKey: "TEST-a463d259-b561-45fe-9dcc-0ce320d1a42f", privateKey: "TEST-982391008451128-040514-b988271bf377ab11b0ace4f1ef338fe6-737303098")))
    }
    
    // MARK: - Overrides
    override func start() {
        controller.coordinatorDelegate = self
        navigationController.pushViewController(controller, animated: true)
    }
}

// MARK: - OneTapRedirects
extension OneTapCoordinator: OneTapRedirects {
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
    
    func showOfflinePaymentSheet(sheet: PXOfflineMethodsSheetViewController) {
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
