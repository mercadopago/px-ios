//
//  BaseController.swift
//  MercadoPagoSDKV4
//
//  Created by Matheus Leandro Martins on 22/06/21.
//

import UIKit
import MLCardForm

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
    
    func navigationController(_ navigationController: UINavigationController, animationControllerFor operation: UINavigationController.Operation, from fromVC: UIViewController, to toVC: UIViewController) -> UIViewControllerAnimatedTransitioning? {
        if [fromVC, toVC].filter({$0 is MLCardFormViewController || $0 is PXSecurityCodeViewController}).count > 0 {
            return PXOneTapViewControllerTransition()
        }
        return nil
    }
}


