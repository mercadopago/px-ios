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
    init(navigationController: UINavigationController, info: PXInitDTO) {
//        super.init()
        self.navigationController = navigationController
        self.controller = NewOneTapController(viewModel: NewOneTapViewModel(info: info))
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
