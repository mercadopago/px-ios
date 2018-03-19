//
//  ExpressViewController.swift
//  MercadoPagoSDK
//
//  Created by AUGUSTO COLLERONE ALFONSO on 19/3/18.
//  Copyright © 2018 MercadoPago. All rights reserved.
//

import UIKit

class ExpressViewController: UIViewController {
    
    let popUpViewHeight: CGFloat = 500
    let borderMargin = PXLayout.XXXS_MARGIN
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        UIView.animate(withDuration: 0.5, animations: {
            self.view.alpha = 1
            if #available(iOS 10.0, *) {
                self.view.backgroundColor = UIColor(displayP3Red: 0, green: 0, blue: 0, alpha: 0.7)
            } else {
                // Fallback on earlier versions
            }
        }) { (true) in
            self.popupViewTapped()
        }
    }
    
    private lazy var popupView: UIView = {
        let view = UIView()
        view.backgroundColor = .white
        view.alpha = 1
        
        if PXLayout.getSafeAreaTopInset() > 0 {
            view.layer.cornerRadius = 35
        } else {
            view.layer.cornerRadius = 15
        }
        
        view.clipsToBounds = true
        
        
        // Payment Method
        let image = MercadoPago.getImage("mediosIconoMaster")
        let pmProps = PXPaymentMethodProps(paymentMethodIcon: image, title: "Mastercard 1234".toAttributedString(), subtitle: "HSBC".toAttributedString(), descriptionTitle: nil, descriptionDetail: nil, disclaimer: nil, backgroundColor: .red, lightLabelColor: .gray, boldLabelColor: .black)
        
        let pmComponent = PXPaymentMethodComponent(props: pmProps)
        let pmView = pmComponent.expressRender()
        pmView.addSeparatorLineToBottom(height: 1)
        view.addSubview(pmView)
        PXLayout.matchWidth(ofView: pmView).isActive = true
        PXLayout.centerHorizontally(view: pmView).isActive = true
        PXLayout.pinTop(view: pmView).isActive = true
        
        //Footer
        let mainAction = PXComponentAction(label: "Pagar", action: {
            print("pagar")
        })
        let footerProps = PXFooterProps(buttonAction: mainAction)
        let footerComponent = PXFooterComponent(props: footerProps)
        let footerView = footerComponent.render()
        view.addSubview(footerView)
        footerView.addSeparatorLineToTop(height: 1)
        PXLayout.matchWidth(ofView: footerView).isActive = true
        PXLayout.pinBottom(view: footerView).isActive = true
        PXLayout.centerHorizontally(view: footerView).isActive = true
    
        
        
        return view
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.view.backgroundColor = .clear
        layout()
    }
    
    private var bottomConstraint = NSLayoutConstraint()
    
    private func layout() {
        popupView.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(popupView)
        PXLayout.centerHorizontally(view: popupView).isActive = true
        PXLayout.setHeight(owner: popupView, height: popUpViewHeight).isActive = true
        PXLayout.pinLeft(view: popupView, withMargin: borderMargin).isActive = true
        PXLayout.pinRight(view: popupView, withMargin: borderMargin).isActive = true
//        popupView.leadingAnchor.constraint(equalTo: view.leadingAnchor).isActive = true
//        popupView.trailingAnchor.constraint(equalTo: view.trailingAnchor).isActive = true
        bottomConstraint = popupView.bottomAnchor.constraint(equalTo: view.bottomAnchor, constant: popUpViewHeight + borderMargin)
        bottomConstraint.isActive = true
//        popupView.heightAnchor.constraint(equalToConstant: popUpViewHeight).isActive = true
    }
    
    
    @objc private func popupViewTapped() {
        if #available(iOS 10.0, *) {
            let transitionAnimator = UIViewPropertyAnimator(duration: 0.75, dampingRatio: 1, animations: {
                self.bottomConstraint.constant = 0 - self.borderMargin
                self.view.layoutIfNeeded()
            })
            
            transitionAnimator.addCompletion { position in
//                switch position {
//                case .start:
//                    self.currentState = state.opposite
//                case .end:
//                    self.currentState = state
//                case .current:
//                    ()
//                }
//                switch self.currentState {
//                case .open:
//                    self.bottomConstraint.constant = 0
//                case .closed:
//                    self.bottomConstraint.constant = 440
//                }
            }
            transitionAnimator.startAnimation()
            
        } else {
            // Fallback on earlier versions
        }
    }
    
}
