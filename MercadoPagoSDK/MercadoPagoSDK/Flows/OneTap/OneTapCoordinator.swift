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
        self.controller = NewOneTapController(viewModel: CardManagerViewModel(oneTapModel: OneTapModel(paymentInfos: info, disabledOption: disabledOption, excludedPaymentTypeIds: excludedPaymentTypeIds, publicKey: "TEST-a463d259-b561-45fe-9dcc-0ce320d1a42f", privateKey: "TEST-982391008451128-040514-b988271bf377ab11b0ace4f1ef338fe6-737303098")))
    }
    
    // MARK: - Overrides
    override func start() {
        controller.coordinatorDelegate = self
        navigationController.pushViewController(controller, animated: true)
    }
}

// MARK: - OneTapRedirects
extension OneTapCoordinator: OneTapRedirects {
    func goToCongrats() {
        
    }
    
    func goToBiometric() {
        
    }
    
    func goToCVV() {
        
    }
    
    func goToCardForm() {
        
    }
}
