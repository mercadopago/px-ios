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
    var blurView: UIVisualEffectView!
    
    fileprivate var bottomConstraint = NSLayoutConstraint()
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        presentSheet()
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.view.backgroundColor = .clear
        let blurEffect = UIBlurEffect(style: UIBlurEffectStyle.dark)
        blurView = UIVisualEffectView(effect: blurEffect)
        blurView.frame = self.view.bounds
        blurView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        blurView.alpha = 0
        self.view.addSubview(blurView)
        setupUI()
    }
    
    fileprivate lazy var popupView: UIView = {
        
        let view = UIView()
        
        let boldColor: UIColor = ThemeManager.shared.getTheme().boldLabelTintColor()
        
        let modalTitle: String = "Confirma tu compra"
        let closeButtonImage = MercadoPago.getImage("white_close")?.withRenderingMode(.alwaysTemplate)
        
        let RADIUS_WITH_SAFE_AREA: CGFloat = 32
        let RADIUS_WITHOUT_SAFE_AREA: CGFloat = 15
        let TITLE_VIEW_HEIGHT: CGFloat = 58
        
        view.backgroundColor = .white
        view.alpha = 1
        
        if PXLayout.getSafeAreaTopInset() > 0 {
            view.layer.cornerRadius = RADIUS_WITH_SAFE_AREA
        } else {
            view.layer.cornerRadius = RADIUS_WITHOUT_SAFE_AREA
        }
        
        view.clipsToBounds = true
        
        //Title
        let titleView = UIView()
        titleView.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(titleView)
        PXLayout.matchWidth(ofView: titleView).isActive = true
        PXLayout.centerHorizontally(view: titleView).isActive = true
        PXLayout.pinTop(view: titleView).isActive = true
        PXLayout.setHeight(owner: titleView, height: TITLE_VIEW_HEIGHT).isActive = true
        titleView.addSeparatorLineToBottom(height: 1)
        
        let titleLabel = UILabel()
        titleView.addSubview(titleLabel)
        PXLayout.pinLeft(view: titleLabel, withMargin: PXLayout.M_MARGIN - 4
            ).isActive = true
        PXLayout.matchWidth(ofView: titleLabel).isActive = true
        PXLayout.centerVertically(view: titleLabel).isActive = true
        PXLayout.setHeight(owner: titleLabel, height: TITLE_VIEW_HEIGHT).isActive = true
        titleLabel.text = modalTitle.localized
        titleLabel.font = Utils.getFont(size: PXLayout.M_FONT)
        titleLabel.textColor = boldColor
        
        //Cancel button
        let button = UIButton()
        button.setTitle("", for: .normal)
        button.add(for: .touchUpInside, {
            self.hideSheet()
        })
        button.setImage(closeButtonImage, for: .normal)
        button.tintColor = boldColor
        titleView.addSubview(button)
        PXLayout.pinRight(view: button, withMargin: PXLayout.XXXS_MARGIN - 2).isActive = true
        PXLayout.centerVertically(view: button).isActive = true
        PXLayout.setWidth(owner: button, width: 50).isActive = true
        PXLayout.setHeight(owner: button, height: 30).isActive = true
        
        //Item
        let itemProps = PXItemComponentProps(imageURL: nil, title: "AXION Energy", description: "Carga combustible", quantity: 1, unitAmount: 1, backgroundColor: .white, boldLabelColor: boldColor, lightLabelColor: .gray)
        let itemComponent = PXItemComponent(props: itemProps)
        let itemView = itemComponent.expressRender()
        itemView.addSeparatorLineToBottom(height: 1)
        view.addSubview(itemView)
        PXLayout.matchWidth(ofView: itemView).isActive = true
        PXLayout.centerHorizontally(view: itemView).isActive = true
        PXLayout.put(view: itemView, onBottomOf: titleView).isActive = true
        
        //Payment Method
        let pmImage = MercadoPago.getImage("mediosIconoMaster")
        let pmProps = PXPaymentMethodProps(paymentMethodIcon: pmImage, title: "Mastercard .... 4251".toAttributedString(), subtitle: "HSBC | Pagás 1 X $405".toAttributedString(), descriptionTitle: nil, descriptionDetail: nil, disclaimer: nil, backgroundColor: .white, lightLabelColor: .gray, boldLabelColor: boldColor)
        
        let pmComponent = PXPaymentMethodComponent(props: pmProps)
        let pmView = pmComponent.expressRender()
        pmView.addSeparatorLineToBottom(height: 1)
        view.addSubview(pmView)
        PXLayout.matchWidth(ofView: pmView).isActive = true
        PXLayout.centerHorizontally(view: pmView).isActive = true
        PXLayout.put(view: pmView, onBottomOf: itemView).isActive = true
        
        //Footer
        var footerView: PXFooterView = PXFooterView()
        var loadingButtonComponent: PXPrimaryButton?
        let mainAction = PXComponentAction(label: "Pagar", action: {
            print("Debug - Pagando")
            loadingButtonComponent?.startLoading(loadingText:"Pagando...", retryText:"Pagar")
        })
        let footerProps = PXFooterProps(buttonAction: mainAction)
        let footerComponent = PXFooterComponent(props: footerProps)
        footerView = footerComponent.expressRender()
        loadingButtonComponent = footerView.getPrincipalButton()
        loadingButtonComponent?.animationDelegate = self
        view.addSubview(footerView)
        footerView.addSeparatorLineToTop(height: 1)
        PXLayout.matchWidth(ofView: footerView).isActive = true
        PXLayout.pinBottom(view: footerView).isActive = true
        PXLayout.centerHorizontally(view: footerView).isActive = true
        
        return view
    }()
}

extension ExpressViewController {
    
    fileprivate func setupUI() {
        popupView.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(popupView)
        PXLayout.centerHorizontally(view: popupView).isActive = true
        PXLayout.setHeight(owner: popupView, height: popUpViewHeight).isActive = true
        PXLayout.pinLeft(view: popupView, withMargin: borderMargin).isActive = true
        PXLayout.pinRight(view: popupView, withMargin: borderMargin).isActive = true
        bottomConstraint = popupView.bottomAnchor.constraint(equalTo: view.bottomAnchor, constant: popUpViewHeight + borderMargin)
        bottomConstraint.isActive = true
    }
    
    fileprivate func presentSheet() {
        UIView.animate(withDuration: 0.3, animations: {
            self.view.alpha = 1
            self.blurView.alpha = 1
        }) { (true) in
            self.animatePopUpView(isDeployed: false)
        }
    }
    
    @objc func hideSheet() {
        animatePopUpView(isDeployed: true)
    }
    
    fileprivate func animatePopUpView(isDeployed: Bool) {
        if #available(iOS 10.0, *) {
            var bottomContraint = 0 - self.borderMargin
            if isDeployed {
                bottomContraint = self.borderMargin + popUpViewHeight
            }
            let transitionAnimator = UIViewPropertyAnimator(duration: 0.65, dampingRatio: 1, animations: {
                self.bottomConstraint.constant = bottomContraint
                self.view.layoutIfNeeded()
            })
            
            transitionAnimator.addCompletion { position in
                if isDeployed {
                    UIView.animate(withDuration: 0.3, animations: {
                        self.blurView.alpha = 0
                    }, completion: { finish in
                        self.dismiss(animated: false, completion: nil)
                    })
                }
            }
            
            transitionAnimator.startAnimation()
            
        } else {
            // TODO: Fallback on earlier versions
        }
    }
}

extension ExpressViewController: PXAnimatedButtonDelegate {
    func didFinishAnimation() {
        self.perform(#selector(ExpressViewController.hideSheet), with: self, afterDelay: 2.2)
    }
}
