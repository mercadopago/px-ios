//
//  PXReviewViewController.swift
//  MercadoPagoSDK
//
//  Created by Demian Tejo on 27/2/18.
//  Copyright © 2018 MercadoPago. All rights reserved.
//

import UIKit
import MercadoPagoPXTrackingV4

class PXReviewViewController: PXComponentContainerViewController {

    // MARK: Tracking
    override open var screenName: String { return TrackingUtil.SCREEN_NAME_REVIEW_AND_CONFIRM }
    override open var screenId: String { return TrackingUtil.SCREEN_ID_REVIEW_AND_CONFIRM }

    var footerView: UIView!
    var floatingButtonView: UIView!

    // MARK: Definitions
    var termsConditionView: PXTermsAndConditionView!
    var discountTermsConditionView: PXTermsAndConditionView?
    lazy var itemViews = [UIView]()
    fileprivate var viewModel: PXReviewViewModel!

    var callbackPaymentData: ((PaymentData) -> Void)
    var callbackConfirm: ((PaymentData) -> Void)
    var finishButtonAnimation: (() -> Void)

    weak var loadingButtonComponent: PXAnimatedButton?
    weak var loadingFloatingButtonComponent: PXAnimatedButton?
    let timeOutPayButton: TimeInterval
    let shouldAnimatePayButton: Bool

    // MARK: Lifecycle - Publics
    init(viewModel: PXReviewViewModel, timeOutPayButton: TimeInterval = 15, shouldAnimatePayButton: Bool, callbackPaymentData : @escaping ((PaymentData) -> Void), callbackConfirm: @escaping ((PaymentData) -> Void), finishButtonAnimation: @escaping (() -> Void)) {
        self.viewModel = viewModel
        self.callbackPaymentData = callbackPaymentData
        self.callbackConfirm = callbackConfirm
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
        setupUI()
        self.scrollView.showsVerticalScrollIndicator = false
        self.scrollView.showsHorizontalScrollIndicator = false
        self.view.layoutIfNeeded()
        self.checkFloatingButtonVisibility()
        scrollView.isScrollEnabled = true
        view.isUserInteractionEnabled = true
        // Temporary fix for MP/Meli UX incompatibility
        UIApplication.shared.statusBarStyle = .default
    }

    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        if shouldAnimatePayButton {
            unsubscribeFromNotifications()
            showNavBarForAnimation()
        }
    }

    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        loadingButtonComponent?.resetButton()
        loadingButtonComponent?.setTitle("Confirmar".localized, for: .normal)
        loadingFloatingButtonComponent?.resetButton()
        loadingFloatingButtonComponent?.setTitle("Confirmar".localized, for: .normal)
    }

    override func trackInfo() {
        self.viewModel.trackInfo()
    }

    func update(viewModel: PXReviewViewModel) {
        self.viewModel = viewModel
    }
}

// MARK: UI Methods
extension PXReviewViewController {

    fileprivate func setupUI() {
        navBarTextColor = ThemeManager.shared.getTitleColorForReviewConfirmNavigation()
        loadMPStyles()
        navigationController?.navigationBar.barTintColor = ThemeManager.shared.highlightBackgroundColor()
        navigationItem.leftBarButtonItem?.tintColor = ThemeManager.shared.getTitleColorForReviewConfirmNavigation()
        if contentView.getSubviews().isEmpty {
            renderViews()
        }
    }

    private func renderViews() {
        unsubscribeFromNotifications()
        self.contentView.prepareForRender()

        // Add title view.
        let titleView = getTitleComponentView()
        contentView.addSubview(titleView)
        PXLayout.pinTop(view: titleView).isActive = true
        PXLayout.centerHorizontally(view: titleView).isActive = true
        PXLayout.matchWidth(ofView: titleView).isActive = true

        // Add summary view.
        let summaryView = getSummaryComponentView()
        contentView.addSubviewToBottom(summaryView)
        PXLayout.centerHorizontally(view: summaryView).isActive = true
        PXLayout.matchWidth(ofView: summaryView).isActive = true

        // Add CFT view.
        if let cftView = getCFTComponentView() {
            contentView.addSubviewToBottom(cftView)
            PXLayout.centerHorizontally(view: cftView).isActive = true
            PXLayout.matchWidth(ofView: cftView).isActive = true
        }

        // Add discount terms and conditions.
        if self.viewModel.shouldShowDiscountTermsAndCondition() {
            let discountTCView = viewModel.getDiscountTermsAndConditionView()
            discountTermsConditionView = discountTCView
            discountTCView.addSeparatorLineToBottom(height: 1, horizontalMarginPercentage: 100)
            contentView.addSubviewToBottom(discountTCView)
            PXLayout.matchWidth(ofView: discountTCView).isActive = true
            PXLayout.centerHorizontally(view: discountTCView).isActive = true
            discountTCView.delegate = self
        }

        // Add item views
        itemViews = buildItemComponentsViews()
        for itemView in itemViews {
            contentView.addSubviewToBottom(itemView)
            PXLayout.centerHorizontally(view: itemView).isActive = true
            PXLayout.matchWidth(ofView: itemView).isActive = true
            itemView.addSeparatorLineToBottom(height: 1)
        }

        // Top Custom View
        if let topCustomView = getTopCustomView() {
            topCustomView.addSeparatorLineToBottom(height: 1)
            topCustomView.clipsToBounds = true
            contentView.addSubviewToBottom(topCustomView)
            PXLayout.matchWidth(ofView: topCustomView).isActive = true
            PXLayout.centerHorizontally(view: topCustomView).isActive = true
        }

        // Add payment method view.
        if let paymentMethodView = getPaymentMethodComponentView() {
            paymentMethodView.addSeparatorLineToBottom(height: 1)
            contentView.addSubviewToBottom(paymentMethodView)
            PXLayout.matchWidth(ofView: paymentMethodView).isActive = true
            PXLayout.centerHorizontally(view: paymentMethodView).isActive = true
        }

        // Bottom Custom View
        if let bottomCustomView = getBottomCustomView() {
            bottomCustomView.addSeparatorLineToBottom(height: 1)
            bottomCustomView.clipsToBounds = true
            contentView.addSubviewToBottom(bottomCustomView)
            PXLayout.matchWidth(ofView: bottomCustomView).isActive = true
            PXLayout.centerHorizontally(view: bottomCustomView).isActive = true
        }

        // Add terms and conditions.
        if viewModel.shouldShowTermsAndCondition() {
            termsConditionView = getTermsAndConditionView()
            contentView.addSubview(termsConditionView)
            PXLayout.matchWidth(ofView: termsConditionView).isActive = true
            PXLayout.centerHorizontally(view: termsConditionView).isActive = true
            contentView.addSubviewToBottom(termsConditionView)
            termsConditionView.delegate = self
        }

        //Add Footer
        footerView = getFooterView()
        footerView.backgroundColor = .clear
        contentView.addSubviewToBottom(footerView)
        PXLayout.matchWidth(ofView: footerView).isActive = true
        PXLayout.centerHorizontally(view: footerView, to: contentView).isActive = true
        self.view.layoutIfNeeded()
        PXLayout.setHeight(owner: footerView, height: footerView.frame.height).isActive = true

        // Add floating button
        floatingButtonView = getFloatingButtonView()
        view.addSubview(floatingButtonView)
        PXLayout.setHeight(owner: floatingButtonView, height: viewModel.getFloatingConfirmViewHeight()).isActive = true
        PXLayout.matchWidth(ofView: floatingButtonView).isActive = true
        PXLayout.centerHorizontally(view: floatingButtonView).isActive = true
        PXLayout.pinBottom(view: floatingButtonView, to: view, withMargin: 0).isActive = true

        contentView.backgroundColor = ThemeManager.shared.detailedBackgroundColor()
        scrollView.backgroundColor = ThemeManager.shared.detailedBackgroundColor()
        
        // Add elastic header.
        addElasticHeader(headerBackgroundColor: summaryView.backgroundColor, navigationCustomTitle: PXReviewTitleComponentProps.DEFAULT_TITLE.localized, textColor: ThemeManager.shared.getTitleColorForReviewConfirmNavigation())

        self.view.layoutIfNeeded()
        PXLayout.pinFirstSubviewToTop(view: self.contentView)?.isActive = true
        PXLayout.pinLastSubviewToBottom(view: self.contentView)?.isActive = true

        super.refreshContentViewSize()
        self.checkFloatingButtonVisibility()
    }
}

// MARK: Component Builders
extension PXReviewViewController {

    fileprivate func buildItemComponentsViews() -> [UIView] {
        var itemViews = [UIView]()
        let itemComponents = viewModel.buildItemComponents()
        for items in itemComponents {
            itemViews.append(items.render())
        }
        return itemViews
    }

    fileprivate func isConfirmButtonVisible() -> Bool {
        guard let floatingButton = self.floatingButtonView, let fixedButton = self.footerView else {
            return false
        }
        let floatingButtonCoordinates = floatingButton.convert(CGPoint.zero, from: self.view.window)
        let fixedButtonCoordinates = fixedButton.convert(CGPoint.zero, from: self.view.window)
        return fixedButtonCoordinates.y > floatingButtonCoordinates.y
    }

    fileprivate func getPaymentMethodComponentView() -> UIView? {
        let action = PXComponentAction(label: PXStrings.review_change_payment_method_action.PXLocalized, action: { [weak self] in
            if let reviewViewModel = self?.viewModel {
                self?.viewModel.trackChangePaymentMethodEvent()
                self?.callbackPaymentData(reviewViewModel.getClearPaymentData())
            }
        })
        if let paymentMethodComponent = viewModel.buildPaymentMethodComponent(withAction: action) {
            return paymentMethodComponent.render()
        }

        return nil
    }

    fileprivate func getSummaryComponentView() -> UIView {
        let summaryComponent = viewModel.buildSummaryComponent(width: PXLayout.getScreenWidth())
        let summaryView = summaryComponent.render()
        return summaryView
    }

    fileprivate func getTitleComponentView() -> UIView {
        let titleComponent = viewModel.buildTitleComponent()
        return titleComponent.render()
    }

    fileprivate func getCFTComponentView() -> UIView? {
        if viewModel.hasPayerCostAddionalInfo() {
            let cftView = PXCFTComponentView(withCFTValue: self.viewModel.amountHelper.paymentData.payerCost?.getCFTValue(), titleColor: ThemeManager.shared.labelTintColor(), backgroundColor: ThemeManager.shared.highlightBackgroundColor())
            return cftView
        }
        return nil
    }

    fileprivate func getFloatingButtonView() -> PXContainedActionButtonView {
        let component = PXContainedActionButtonComponent(props: PXContainedActionButtonProps(title: "Confirmar".localized, action: {
            if self.shouldAnimatePayButton {
                self.subscribeLoadingButtonToNotifications(loadingButton: self.loadingFloatingButtonComponent)
                self.loadingFloatingButtonComponent?.startLoading(timeOut: self.timeOutPayButton)
            }
            self.confirmPayment()
            }, animationDelegate: self))
        let containedButtonView = PXContainedActionButtonRenderer().render(component)
        loadingFloatingButtonComponent = containedButtonView.button
        loadingFloatingButtonComponent?.layer.cornerRadius = 4
        containedButtonView.backgroundColor = ThemeManager.shared.detailedBackgroundColor()
        return containedButtonView
    }

    fileprivate func getFooterView() -> UIView {
        let payAction = PXComponentAction(label: "Confirmar".localized) {
            if self.shouldAnimatePayButton {
                self.subscribeLoadingButtonToNotifications(loadingButton: self.loadingButtonComponent)
                self.loadingButtonComponent?.startLoading(timeOut: self.timeOutPayButton)
            }
            self.confirmPayment()
        }
        let footerProps = PXFooterProps(buttonAction: payAction, animationDelegate: self)
        let footerComponent = PXFooterComponent(props: footerProps)
        let footerView =  PXFooterRenderer().render(footerComponent)
        loadingButtonComponent = footerView.principalButton
        loadingButtonComponent?.layer.cornerRadius = 4
        return footerView
    }

    fileprivate func getTermsAndConditionView() -> PXTermsAndConditionView {
        let termsAndConditionView = PXTermsAndConditionView()
        return termsAndConditionView
    }

    fileprivate func getTopCustomView() -> UIView? {
        if let component = self.viewModel.buildTopCustomComponent(), let componentView = component.render(store: PXCheckoutStore.sharedInstance, theme: ThemeManager.shared.getCurrentTheme()) {
            return componentView
        }
        return nil
    }

    fileprivate func getBottomCustomView() -> UIView? {
        if let component = self.viewModel.buildBottomCustomComponent(), let componentView = component.render(store: PXCheckoutStore.sharedInstance, theme: ThemeManager.shared.getCurrentTheme()) {
            return componentView
        }
        return nil
    }

    override func scrollViewDidScroll(_ scrollView: UIScrollView) {
        super.scrollViewDidScroll(scrollView)
        let loadingButtonAnimated = loadingButtonComponent?.isAnimated() ?? false
        let loadingFloatingButtonAnimated = loadingFloatingButtonComponent?.isAnimated() ?? false
        if !loadingButtonAnimated && !loadingFloatingButtonAnimated {
            self.checkFloatingButtonVisibility()
        }
    }

    func checkFloatingButtonVisibility() {
       if !isConfirmButtonVisible() {
            self.floatingButtonView.alpha = 1
            self.footerView?.alpha = 0
        } else {
            self.floatingButtonView.alpha = 0
            self.footerView?.alpha = 1
        }
    }
}

// MARK: Actions.
extension PXReviewViewController: PXTermsAndConditionViewDelegate {

    fileprivate func confirmPayment() {
        scrollView.isScrollEnabled = false
        view.isUserInteractionEnabled = false
        self.viewModel.trackConfirmActionEvent()
        self.hideBackButton()
        self.callbackConfirm(self.viewModel.amountHelper.paymentData)
    }

    func resetButton() {
        loadingFloatingButtonComponent?.shake()
        loadingButtonComponent?.shake()
    }

    func shouldOpenTermsCondition(_ title: String, screenName: String, url: URL) {
        let webVC = WebViewController(url: url, screenName: screenName, navigationBarTitle: title)
        webVC.title = title
        self.navigationController?.pushViewController(webVC, animated: true)
    }
}

// MARK: Payment Button animation delegate
@available(iOS 9.0, *)
extension PXReviewViewController: PXAnimatedButtonDelegate {
    func shakeDidFinish() {
        showNavBarForAnimation()
        displayBackButton()
        scrollView.isScrollEnabled = true
        view.isUserInteractionEnabled = true
        unsubscribeFromNotifications()
        UIView.animate(withDuration: 0.3, animations: {
            self.loadingButtonComponent?.backgroundColor = ThemeManager.shared.getAccentColor()
            self.loadingFloatingButtonComponent?.backgroundColor = ThemeManager.shared.getAccentColor()
        })
    }

    func expandAnimationInProgress() {
        if isNavBarHidden() {
            UIView.animate(withDuration: 0.3, animations: {
                self.navigationController?.isNavigationBarHidden = true
            })
        } else {
            hideNavBarForAnimation()
        }
    }

    func didFinishAnimation() {
        self.finishButtonAnimation()
    }

    func progressButtonAnimationTimeOut() {
        loadingButtonComponent?.resetButton()
        loadingFloatingButtonComponent?.resetButton()
        loadingFloatingButtonComponent?.shake()
        loadingButtonComponent?.shake()
    }

    func hideNavBarForAnimation() {
        self.navigationController?.navigationBar.layer.zPosition = -1
    }

    func showNavBarForAnimation() {
        self.navigationController?.navigationBar.layer.zPosition = 0
    }
}

// MARK: Notifications
extension PXReviewViewController {
    func subscribeLoadingButtonToNotifications(loadingButton: PXAnimatedButton?) {
        guard let loadingButton = loadingButton else {
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

        PXNotificationManager.UnsuscribeTo.animateButtonForSuccess(loadingFloatingButtonComponent)
        PXNotificationManager.UnsuscribeTo.animateButtonForError(loadingFloatingButtonComponent)
        PXNotificationManager.UnsuscribeTo.animateButtonForWarning(loadingFloatingButtonComponent)
    }
}
