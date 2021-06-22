//
//  BaseController.swift
//  MercadoPagoSDKV4
//
//  Created by Matheus Leandro Martins on 22/06/21.
//

import UIKit

protocol BaseViewControllerDelegate: AnyObject {
    func didMoveFromNavigationStack(_ viewController: UIViewController)
}

class BaseViewController: UIViewController {
    // MARK: - Public properties
    weak var coordinatorDelegate: BaseViewControllerDelegate?
    
    // MARK: - View lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        
        navigationController?.delegate = self
    }
}

// MARK: - UINavigationControllerDelegate
extension BaseViewController: UINavigationControllerDelegate {
    override func didMove(toParent parent: UIViewController?) {
        super.didMove(toParent: parent)
        
        if parent == nil { coordinatorDelegate?.didMoveFromNavigationStack(self) }
    }
}


