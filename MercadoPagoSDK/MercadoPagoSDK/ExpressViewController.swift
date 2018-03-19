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
            self.animatePopUpView(isDeployed: false)
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
        
        //Title
        let titleView = UIView()
        titleView.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(titleView)
        PXLayout.matchWidth(ofView: titleView).isActive = true
        PXLayout.centerHorizontally(view: titleView).isActive = true
        PXLayout.pinTop(view: titleView).isActive = true
        PXLayout.setHeight(owner: titleView, height: 45).isActive = true
        
        let image = MercadoPago.getImage("mercadopago")
        let imageView = UIImageView(image: image)
        imageView.translatesAutoresizingMaskIntoConstraints = false
        imageView.contentMode = .scaleAspectFit
        titleView.addSeparatorLineToBottom(height: 1)
        
        titleView.addSubview(imageView)
        PXLayout.pinLeft(view: imageView, withMargin: PXLayout.S_MARGIN
            ).isActive = true
        PXLayout.centerVertically(view: imageView).isActive = true
        PXLayout.setWidth(owner: imageView, width: 100).isActive = true
        PXLayout.setHeight(owner: imageView, height: 40).isActive = true
        
            //Cancel button
        let button = PXSecondaryButton()
        button.setTitle("Cancelar", for: .normal)
        button.add(for: .touchUpInside, {
            self.animatePopUpView(isDeployed: true)
            self.dismiss(animated: true, completion: nil)
        })
        titleView.addSubview(button)
        PXLayout.pinRight(view: button, withMargin: PXLayout.S_MARGIN).isActive = true
        PXLayout.centerVertically(view: button).isActive = true
        PXLayout.setWidth(owner: button, width: 80).isActive = true
        PXLayout.setHeight(owner: button, height: 40).isActive = true
        
        
        //Item
        let itemProps = PXItemComponentProps(imageURL: nil, title: "AXION Energy", description: "Carga 39,05 Lts SUPER", quantity: 1, unitAmount: 1, backgroundColor: .white, boldLabelColor: .black, lightLabelColor: .gray)
        let itemComponent = PXItemComponent(props: itemProps)
        let itemView = itemComponent.expressRender()
        itemView.addSeparatorLineToBottom(height: 1)
        view.addSubview(itemView)
        PXLayout.matchWidth(ofView: itemView).isActive = true
        PXLayout.centerHorizontally(view: itemView).isActive = true
        PXLayout.put(view: itemView, onBottomOf: titleView).isActive = true
        
        
        //Payment Method
        let pmImage = MercadoPago.getImage("mediosIconoMaster")
        let pmProps = PXPaymentMethodProps(paymentMethodIcon: pmImage, title: "Mastercard terminada en 4251".toAttributedString(), subtitle: "HSBC".toAttributedString(), descriptionTitle: "3 cuotas de $405".toAttributedString(), descriptionDetail: nil, disclaimer: nil, backgroundColor: .white, lightLabelColor: .gray, boldLabelColor: .black)
        
        let pmComponent = PXPaymentMethodComponent(props: pmProps)
        let pmView = pmComponent.expressRender()
        pmView.addSeparatorLineToBottom(height: 1)
        view.addSubview(pmView)
        PXLayout.matchWidth(ofView: pmView).isActive = true
        PXLayout.centerHorizontally(view: pmView).isActive = true
        PXLayout.put(view: pmView, onBottomOf: itemView).isActive = true
        
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
        bottomConstraint = popupView.bottomAnchor.constraint(equalTo: view.bottomAnchor, constant: popUpViewHeight + borderMargin)
        bottomConstraint.isActive = true
    }
    
    
    private func animatePopUpView(isDeployed: Bool) {
        if #available(iOS 10.0, *) {
            var bottomContraint = 0 - self.borderMargin
            if isDeployed {
                bottomContraint = self.borderMargin + popUpViewHeight
            }
            let transitionAnimator = UIViewPropertyAnimator(duration: 0.75, dampingRatio: 1, animations: {
                self.bottomConstraint.constant = bottomContraint
                self.view.layoutIfNeeded()
            })
            
            transitionAnimator.addCompletion { position in
                
            }
            transitionAnimator.startAnimation()
            
        } else {
            // Fallback on earlier versions
        }
    }
}
