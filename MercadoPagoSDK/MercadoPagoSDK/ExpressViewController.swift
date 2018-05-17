//
//  ExpressViewController.swift
//  MercadoPagoSDK
//
//  Created by AUGUSTO COLLERONE ALFONSO on 19/3/18.
//  Copyright © 2018 MercadoPago. All rights reserved.
//

import UIKit

class ExpressViewController: UIViewController {

    let popUpViewHeight: CGFloat = 390
    let borderMargin = PXLayout.XXXS_MARGIN
    var blurView: UIVisualEffectView!
    
    fileprivate var viewModel: PXReviewViewModel?
    fileprivate var bottomConstraint = NSLayoutConstraint()
    fileprivate var callbackChangePaymentMethod: (() -> Void)?
    fileprivate var callbackShowCongrats: (() -> Void)?

    // MARK: Lifecycle - Publics
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        presentSheet()
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
    }
    
    func setViewModel(viewModel: PXReviewViewModel) {
        self.viewModel = viewModel
    }
    
    fileprivate lazy var popupView: UIView = {
        
        let view = UIView()
        let boldColor: UIColor = ThemeManager.shared.getTheme().boldLabelTintColor()
        let modalTitle: String = "Confirma tu compra"
        let closeButtonImage = MercadoPago.getImage("white_close")?.withRenderingMode(.alwaysTemplate)
        let closeButtonColor: UIColor = ThemeManager.shared.getTheme().labelTintColor()
        
        let RADIUS_WITH_SAFE_AREA: CGFloat = 32
        let RADIUS_WITHOUT_SAFE_AREA: CGFloat = 15
        let TITLE_VIEW_HEIGHT: CGFloat = 58
        
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


        let line = UIView()
        //line.alpha = 0.6
        line.translatesAutoresizingMaskIntoConstraints = false
        line.backgroundColor = .UIColorFromRGB(0xEEEEEE)
        titleView.addSubview(line)
        PXLayout.pinBottom(view: line).isActive = true
        PXLayout.matchWidth(ofView: line).isActive = true
        PXLayout.centerHorizontally(view: line).isActive = true
        PXLayout.setHeight(owner: line, height: 1).isActive = true
        
        
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
        button.tintColor = closeButtonColor
        titleView.addSubview(button)
        PXLayout.pinRight(view: button, withMargin: PXLayout.XXXS_MARGIN).isActive = true
        PXLayout.centerVertically(view: button).isActive = true
        PXLayout.setWidth(owner: button, width: 50).isActive = true
        PXLayout.setHeight(owner: button, height: 30).isActive = true
        
        
        // Summary component
        let summaryComponent = self.viewModel?.buildSummaryComponent(width: PXLayout.getScreenWidth())
        let summaryView = summaryComponent?.expressRender()
        if let sView = summaryView {
            
            view.addSubview(sView)
            PXLayout.matchWidth(ofView: sView).isActive = true
            PXLayout.centerHorizontally(view: sView).isActive = true
            PXLayout.put(view: sView, onBottomOf: titleView).isActive = true
            sView.addSeparatorLineToBottom(height: 1)
            
            //Item Theme
            let itemTheme: PXItemComponentProps.ItemTheme = (backgroundColor: UIColor.white, boldLabelColor: ThemeManager.shared.getTheme().boldLabelTintColor(), lightLabelColor: ThemeManager.shared.getTheme().labelTintColor())
            /*
            // Item
            let itemProps = PXItemComponentProps(imageURL: nil, title: "AXION Energy", description: "Carga combustible", quantity: 1, unitAmount: 1, amountTitle: "", quantityTitle: "", collectorImage: nil, itemTheme: itemTheme)
            let itemComponent = PXItemComponent(props: itemProps)
            let itemView = itemComponent.expressRender()
            view.addSubview(itemView)
            PXLayout.matchWidth(ofView: itemView).isActive = true
            PXLayout.centerHorizontally(view: itemView).isActive = true
            PXLayout.put(view: itemView, onBottomOf: sView).isActive = true*/
            
            //Payment Method
            let pmImage = MercadoPago.getImage("mediosIconoMaster")
            let pmProps = PXPaymentMethodProps(paymentMethodIcon: pmImage, title: "Mastercard .... 4251".toAttributedString(), subtitle: "HSBC | Pagás 1 X $405".toAttributedString(), descriptionTitle: nil, descriptionDetail: nil, disclaimer: nil, backgroundColor: UIColor.white, lightLabelColor: ThemeManager.shared.getTheme().labelTintColor(), boldLabelColor: boldColor)
            
            let pmComponent = PXPaymentMethodComponent(props: pmProps)
            let pmView = pmComponent.expressRender()
            let color: UIColor = .UIColorFromRGB(0xEEEEEE)
            pmView.layer.borderWidth = 1
            pmView.layer.borderColor = color.cgColor
            pmView.layer.cornerRadius = 4
            view.addSubview(pmView)
            PXLayout.pinLeft(view: pmView, withMargin: 16.0).isActive = true
            PXLayout.pinRight(view: pmView, withMargin: 16.0).isActive = true
            PXLayout.centerHorizontally(view: pmView).isActive = true
            PXLayout.put(view: pmView, onBottomOf: sView, withMargin: 24.0).isActive = true
            PXLayout.setHeight(owner: pmView, height: 70).isActive = true

            let paymentMethodTap = UITapGestureRecognizer(target: self, action: #selector(self.handlePaymentMethodTap(_:)))
            pmView.addGestureRecognizer(paymentMethodTap)





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
            PXLayout.matchWidth(ofView: footerView).isActive = true
            PXLayout.pinBottom(view: footerView).isActive = true
            PXLayout.centerHorizontally(view: footerView).isActive = true
            
            view.layoutIfNeeded()
            
            //let heightForRows = (self.popUpViewHeight - titleView.frame.height - sView.frame.height - footerView.frame.height)/1

            
            view.backgroundColor = UIColor.white
        }

        return view
    }()
}

extension ExpressViewController {
    
    fileprivate func setupUI() {
        view.backgroundColor = .clear
        let blurEffect = UIBlurEffect(style: UIBlurEffectStyle.dark)
        blurView = UIVisualEffectView(effect: blurEffect)
        blurView.frame = self.view.bounds
        blurView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        blurView.alpha = 0
        view.addSubview(blurView)

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

    @objc func fadeOut() {

        let initialFrame = CGRect(x: 0, y: 0, width: PXLayout.getScreenWidth(), height: 0)
        let animatedHeaderView: UIView = UIView(frame: initialFrame)
        animatedHeaderView.backgroundColor = ThemeManager.shared.getMainColor()
        popupView.addSubview(animatedHeaderView)

        if #available(iOS 10.0, *) {

            var height: CGFloat = 153
            if PXLayout.getSafeAreaTopInset() > 0 {
                height = 177
            }
            let finalFrame = CGRect(x: 0, y: 0, width: PXLayout.getScreenWidth(), height: height)
            let transitionAnimator = UIViewPropertyAnimator(duration: 0.65, dampingRatio: 1, animations: {
                animatedHeaderView.frame = finalFrame
            })

            transitionAnimator.addCompletion { _ in
                UIView.animate(withDuration: 0.4, animations: {
                    self.view.alpha = 0
                }) { finish in
                    self.dismiss(animated: false, completion: nil)
                }
            }

            transitionAnimator.startAnimation()
        } else {
            UIView.animate(withDuration: 0.5, animations: {
                self.view.alpha = 0
            }) { finish in
                self.dismiss(animated: false, completion: nil)
            }
        }
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

    fileprivate func expandSheet() {

        self.popupView.layer.masksToBounds = true

        if #available(iOS 10.0, *) {

            let targetFrame = view.frame

            let transitionAnimator = UIViewPropertyAnimator(duration: 0.60, dampingRatio: 1.3, animations: {
                self.popupView.frame = targetFrame
                self.popupView.layer.cornerRadius = 0
            })

            transitionAnimator.addCompletion({ [weak self] _ in

            })

            transitionAnimator.startAnimation()

        } else {
            // TODO: Fallback on earlier versions
        }
    }
}

//MARK: - Button animation delegate
extension ExpressViewController: PXAnimatedButtonDelegate {
    func expandAnimationInProgress() {
        expandSheet()
    }

    func didFinishAnimation() {
        // self.perform(#selector(ExpressViewController.hideSheet), with: self, afterDelay: 2.2) // receipent mode.
        self.callbackShowCongrats?()
        UIView.animate(withDuration: 0.5, animations: {
            self.view.alpha = 0
        }) { finish in
            self.dismiss(animated: false, completion: nil)
        }
    }
}

//MARK: - User Actions
extension ExpressViewController {

    func handlePaymentMethodTap(_ sender: UITapGestureRecognizer) {
        shouldOpenGroups()
    }

    fileprivate func shouldOpenGroups() {
        if #available(iOS 10.0, *) {
            let targetFrame = view.frame
            let transitionAnimator = UIViewPropertyAnimator(duration: 0.65, dampingRatio: 1.3, animations: {
                self.popupView.frame = targetFrame
                self.popupView.layer.cornerRadius = 0
            })

            transitionAnimator.addCompletion({ [weak self] _ in
                self?.callbackChangePaymentMethod?()
                self?.fadeOut()
            })

            transitionAnimator.startAnimation()

            let overlayWhite = UIView(frame: self.view.frame)
            overlayWhite.alpha = 0
            overlayWhite.backgroundColor = .white
            popupView.addSubview(overlayWhite)
            UIView.animate(withDuration: 0.5, animations: {
                overlayWhite.alpha = 1
            })

        } else {
            self.callbackChangePaymentMethod?()
            // TODO: Fallback on earlier versions
        }
    }
}

//MARK: Public interfase
extension ExpressViewController  {
    func setChangePaymentMethodAction(callbackAction: @escaping (() -> Void)) {
        self.callbackChangePaymentMethod = callbackAction
    }

    func setShowCongratsAction(callbackAction: @escaping (() -> Void)) {
        self.callbackShowCongrats = callbackAction
    }
}

class MockPaymentOption: PaymentMethodOption {
    
    func getId() -> String {
        return "1"
    }
    
    func getDescription() -> String {
        return "Mock Payment option description"
    }
    
    func getComment() -> String {
        return ""
    }
    
    func hasChildren() -> Bool {
        return false
    }
    
    func getChildren() -> [PaymentMethodOption]? {
        return nil
    }
    
    func isCard() -> Bool {
        return false
    }
    
    func isCustomerPaymentMethod() -> Bool {
        return false
    }
}
