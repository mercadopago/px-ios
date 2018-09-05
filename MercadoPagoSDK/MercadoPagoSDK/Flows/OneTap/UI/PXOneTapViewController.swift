//
//  PXOneTapViewController.swift
//  MercadoPagoSDK
//
//  Created by Juan sebastian Sanzone on 15/5/18.
//  Copyright © 2018 MercadoPago. All rights reserved.
//

import UIKit

final class PXOneTapViewController: PXComponentContainerViewController {
    // MARK: Tracking
    override var screenName: String { return TrackingUtil.ScreenId.REVIEW_AND_CONFIRM_ONE_TAP }
    override var screenId: String { return TrackingUtil.ScreenId.REVIEW_AND_CONFIRM_ONE_TAP }

    // MARK: Definitions
    lazy var itemViews = [UIView]()
    fileprivate var viewModel: PXOneTapViewModel
    private lazy var footerView: UIView = UIView()
    private var discountTermsConditionView: PXTermsAndConditionView?

    // MARK: Callbacks
    var callbackPaymentData: ((PXPaymentData) -> Void)
    var callbackConfirm: ((PXPaymentData) -> Void)
    var callbackExit: (() -> Void)
    var finishButtonAnimation: (() -> Void)

    var loadingButtonComponent: PXAnimatedButton?

    let timeOutPayButton: TimeInterval
    let shouldAnimatePayButton: Bool

    // MARK: Lifecycle/Publics
    init(viewModel: PXOneTapViewModel, timeOutPayButton: TimeInterval = 15, shouldAnimatePayButton: Bool, callbackPaymentData : @escaping ((PXPaymentData) -> Void), callbackConfirm: @escaping ((PXPaymentData) -> Void), callbackExit: @escaping (() -> Void), finishButtonAnimation: @escaping (() -> Void)) {
        self.viewModel = viewModel
        self.callbackPaymentData = callbackPaymentData
        self.callbackConfirm = callbackConfirm
        self.callbackExit = callbackExit
        self.finishButtonAnimation = finishButtonAnimation
        self.timeOutPayButton = timeOutPayButton
        self.shouldAnimatePayButton = shouldAnimatePayButton
        super.init()
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        setupNavigationBar()
        setupUI()
        scrollView.isScrollEnabled = true
        view.isUserInteractionEnabled = true
    }

    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        if isMovingToParentViewController {
            viewModel.trackTapBackEvent()
        }

        if shouldAnimatePayButton {
            PXNotificationManager.UnsuscribeTo.animateButtonForSuccess(loadingButtonComponent)
            PXNotificationManager.UnsuscribeTo.animateButtonForError(loadingButtonComponent)
            PXNotificationManager.UnsuscribeTo.animateButtonForWarning(loadingButtonComponent)
        }
    }

    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        loadingButtonComponent?.resetButton()
        loadingButtonComponent?.setTitle("Confirmar".localized, for: .normal)
    }

    override func trackInfo() {
        self.viewModel.trackInfo()
    }

    func update(viewModel: PXOneTapViewModel) {
        self.viewModel = viewModel
    }
    
    override func adjustInsets() {
        
    }
}

// MARK: UI Methods.
extension PXOneTapViewController {
    private func setupNavigationBar() {
        navBarTextColor = ThemeManager.shared.labelTintColor()
        loadMPStyles()
        navigationController?.navigationBar.isTranslucent = true
        navigationController?.navigationBar.barTintColor = ThemeManager.shared.whiteColor()
        navigationItem.leftBarButtonItem?.tintColor = ThemeManager.shared.labelTintColor()
        navigationController?.navigationBar.backgroundColor =  UIColor(red: 0.0, green: 0.0, blue: 0.0, alpha: 0.0)
        navigationController?.navigationBar.setBackgroundImage(UIImage(), for: UIBarMetrics.default)
    }

    private func setupUI() {
        if contentView.getSubviews().isEmpty {
            renderViews()
            super.prepareForAnimation(customAnimations: PXSpruce.PXDefaultAnimation.rightToLeftAnimation)
            super.animateContentView(customAnimations: PXSpruce.PXDefaultAnimation.rightToLeftAnimation)
        }
    }

    private func renderViews() {
        contentView.prepareForRender()

        // Add item-price view.
        if let itemView = getItemComponentView() {
            contentView.addSubviewToBottom(itemView)
            PXLayout.centerHorizontally(view: itemView).isActive = true
            PXLayout.matchWidth(ofView: itemView).isActive = true
            let tapGesture = UITapGestureRecognizer(target: self, action: #selector(self.shouldOpenSummary))
            itemView.addGestureRecognizer(tapGesture)
        }

        // Add payment method.
        if let paymentMethodView = getPaymentMethodComponentView() {
            contentView.addSubviewToBottom(paymentMethodView, withMargin: PXLayout.M_MARGIN)
            PXLayout.pinLeft(view: paymentMethodView, withMargin: PXLayout.M_MARGIN).isActive = true
            PXLayout.pinRight(view: paymentMethodView, withMargin: PXLayout.M_MARGIN).isActive = true
            let paymentMethodTapAction = UITapGestureRecognizer(target: self, action: #selector(self.shouldChangePaymentMethod))
            paymentMethodView.addGestureRecognizer(paymentMethodTapAction)
        }

        // Add discount terms and conditions.
        if viewModel.shouldShowDiscountTermsAndCondition() {
            let discountTCView = viewModel.getDiscountTermsAndConditionView(shouldAddMargins: false)
            discountTermsConditionView = discountTCView
            contentView.addSubviewToBottom(discountTCView, withMargin: PXLayout.S_MARGIN)
            PXLayout.matchWidth(ofView: discountTCView).isActive = true
            PXLayout.centerHorizontally(view: discountTCView).isActive = true
            discountTCView.delegate = self
        }

        // Add footer payment button.
        if let footerView = getFooterView() {
            contentView.addSubviewToBottom(footerView, withMargin: PXLayout.M_MARGIN)
            PXLayout.centerHorizontally(view: footerView).isActive = true
            PXLayout.pinLeft(view: footerView, withMargin: PXLayout.M_MARGIN).isActive = true
            PXLayout.pinRight(view: footerView, withMargin: PXLayout.M_MARGIN).isActive = true
            PXLayout.setHeight(owner: footerView, height: PXLayout.XXL_MARGIN).isActive = true
        }

        view.layoutIfNeeded()
        refreshContentViewSize()
        _ = centerContentView(margin: -PXLayout.getStatusBarHeight())
        
    }
    
}

// MARK: Components Builders.
extension PXOneTapViewController {
    private func getItemComponentView() -> UIView? {
        if let oneTapItemComponent = viewModel.getItemComponent() {
            return oneTapItemComponent.render()
        }
        return nil
    }

    private func getPaymentMethodComponentView() -> UIView? {
        if let paymentMethodComponent = viewModel.getPaymentMethodComponent() {
            return paymentMethodComponent.oneTapRender()
        }
        return nil
    }

    private func getFooterView() -> UIView? {
        loadingButtonComponent = PXAnimatedButton(normalText: "Confirmar".localized, loadingText: "Procesando tu pago".localized, retryText: "Reintentar".localized)
        loadingButtonComponent?.animationDelegate = self
        loadingButtonComponent?.layer.cornerRadius = 4
        loadingButtonComponent?.add(for: .touchUpInside, {
            if self.shouldAnimatePayButton {
                self.subscribeLoadingButtonToNotifications()
                self.loadingButtonComponent?.startLoading(timeOut: self.timeOutPayButton)
            }
            self.confirmPayment()
        })
        loadingButtonComponent?.setTitle("Confirmar".localized, for: .normal)
        loadingButtonComponent?.backgroundColor = ThemeManager.shared.getAccentColor()

        return loadingButtonComponent
    }

    private func getDiscountDetailView() -> UIView? {
        if self.viewModel.amountHelper.discount != nil || self.viewModel.amountHelper.consumedDiscount {
            let discountDetailVC = PXDiscountDetailViewController(amountHelper: self.viewModel.amountHelper, shouldShowTitle: true)
            return discountDetailVC.getContentView()
        }
        return nil
    }

}

// MARK: User Actions.
extension PXOneTapViewController: PXTermsAndConditionViewDelegate {
    @objc func shouldOpenSummary() {
        viewModel.trackTapSummaryDetailEvent()
        if viewModel.shouldShowSummaryModal() {
            if let summaryProps = viewModel.getSummaryProps(), summaryProps.count > 0 {
                let summaryViewController = PXOneTapSummaryModalViewController()
                summaryViewController.setProps(summaryProps: summaryProps, bottomCustomView: getDiscountDetailView())
                PXComponentFactory.Modal.show(viewController: summaryViewController, title: "Detalle".localized)
            } else {
                if let discountView = getDiscountDetailView() {
                    let summaryViewController = PXOneTapSummaryModalViewController()
                    summaryViewController.setProps(summaryProps: nil, bottomCustomView: discountView)
                    PXComponentFactory.Modal.show(viewController: summaryViewController, title: nil)
                }
            }
        }
    }

    @objc func shouldChangePaymentMethod() {
        viewModel.trackChangePaymentMethodEvent()
        callbackPaymentData(viewModel.getClearPaymentData())
    }

    private func confirmPayment() {
        scrollView.isScrollEnabled = false
        view.isUserInteractionEnabled = false
        self.viewModel.trackConfirmActionEvent()
        self.hideBackButton()
        self.hideNavBar()
        self.callbackConfirm(self.viewModel.amountHelper.paymentData)
    }

    func resetButton() {
        loadingButtonComponent?.shake()
    }

    private func cancelPayment() {
        self.callbackExit()
    }

    func shouldOpenTermsCondition(_ title: String, screenName: String, url: URL) {
        let webVC = WebViewController(url: url, screenName: screenName, navigationBarTitle: title)
        webVC.title = title
        self.navigationController?.pushViewController(webVC, animated: true)
    }
}

// MARK: Payment Button animation delegate
@available(iOS 9.0, *)
extension PXOneTapViewController: PXAnimatedButtonDelegate {
    func shakeDidFinish() {
        displayBackButton()
        scrollView.isScrollEnabled = true
        view.isUserInteractionEnabled = true
        unsubscribeFromNotifications()
        UIView.animate(withDuration: 0.3, animations: {
            self.loadingButtonComponent?.backgroundColor = ThemeManager.shared.getAccentColor()
        })
    }

    func expandAnimationInProgress() {
    }

    func didFinishAnimation() {
        self.finishButtonAnimation()
    }

    func progressButtonAnimationTimeOut() {
        loadingButtonComponent?.shake()
    }
}

// MARK: Notifications
extension PXOneTapViewController {
    func subscribeLoadingButtonToNotifications() {
        guard let loadingButton = loadingButtonComponent else {
            return
        }
        PXNotificationManager.SuscribeTo.animateButtonForSuccess(loadingButton, selector: #selector(loadingButton.animateFinishSuccess))
        PXNotificationManager.SuscribeTo.animateButtonForError(loadingButton, selector: #selector(loadingButton.animateFinishError))
        PXNotificationManager.SuscribeTo.animateButtonForWarning(loadingButton, selector: #selector(loadingButton.animateFinishWarning))
    }

    func unsubscribeFromNotifications() {
        PXNotificationManager.UnsuscribeTo.animateButtonForSuccess(loadingButtonComponent)
        PXNotificationManager.UnsuscribeTo.animateButtonForError(loadingButtonComponent)
        PXNotificationManager.UnsuscribeTo.animateButtonForWarning(loadingButtonComponent)
    }
}
