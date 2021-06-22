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
    private let controller: UIViewController
    
    // MARK: - Initialization
    init(navigationController: UINavigationController) {
//        super.init()
        self.navigationController = navigationController
        self.controller = UIViewController()
        controller.view.backgroundColor = .purple
    }
    
    // MARK: - Overrides
    override func start() {
        navigationController.pushViewController(controller, animated: true)
    }
}
