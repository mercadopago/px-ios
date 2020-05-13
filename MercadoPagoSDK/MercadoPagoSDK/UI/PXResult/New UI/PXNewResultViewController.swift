//
//  PXNewResultViewController.swift
//  MercadoPagoSDK
//
//  Created by AUGUSTO COLLERONE ALFONSO on 27/08/2019.
//

import UIKit
import MLBusinessComponents
import AndesUI

class PXNewResultViewController: MercadoPagoUIViewController {

    private weak var ringView: MLBusinessLoyaltyRingView?
    private lazy var elasticHeader = UIView()
    private let statusBarHeight = PXLayout.getStatusBarHeight()
    private var contentViewHeightConstraint: NSLayoutConstraint?

    let scrollView = UIScrollView()
    let viewModel: PXNewResultViewModelInterface
    private var finishButtonAnimation: (() -> Void)?

    init(viewModel: PXNewResultViewModelInterface, callback: @escaping ( _ status: PaymentResult.CongratsState, String?) -> Void, finishButtonAnimation: (() -> Void)? = nil) {
        self.viewModel = viewModel
        self.viewModel.setCallback(callback: callback)
        self.finishButtonAnimation = finishButtonAnimation
        super.init(nibName: nil, bundle: nil)
        self.shouldHideNavigationBar = true
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        setupScrollView()
        addElasticHeader()
    }

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        animateScrollView()
        animateRing()
        let path = viewModel.getTrackingPath()
        if !path.isEmpty {
            trackScreen(path: path, properties: viewModel.getTrackingProperties())

            let behaviourProtocol = PXConfiguratorManager.flowBehaviourProtocol
            behaviourProtocol.trackConversion(result: viewModel.getFlowBehaviourResult())
        }
    }

    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        // remove animated button observer
        unsubscribeFromAnimatedButtonNotifications()
        // remove keyboard observer
        unsubscribeFromKeyboardNotifications()
    }

    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        if let button = getRemedyViewAnimatedButton() {
            button.resetButton()
        }
    }

    deinit {
        NotificationCenter.default.removeObserver(self)
    }

    @objc func keyboardWillBeShown(notification: Notification) {
        if let keyboardSize = (notification.userInfo?[UIResponder.keyboardFrameEndUserInfoKey] as? NSValue)?.cgRectValue {
            let contentInset = UIEdgeInsets(top: 0, left: 0, bottom: keyboardSize.height, right: 0)
            scrollView.contentInset = contentInset
            scrollView.scrollIndicatorInsets = contentInset
            animateContentViewHeightConstraint(isActive: false)
        }
    }

    @objc func keyboardWillBeHidden(notification: Notification) {
        let contentInset = UIEdgeInsets.zero
        scrollView.contentInset = contentInset
        scrollView.scrollIndicatorInsets = contentInset
        animateContentViewHeightConstraint(isActive: true)
    }

    private func animateContentViewHeightConstraint(isActive: Bool) {
        if contentViewHeightConstraint != nil {
            UIViewPropertyAnimator(duration: 0.25, curve: .easeInOut) { [weak self] in
                self?.contentViewHeightConstraint?.isActive = isActive
            }.startAnimation()
        }
    }

    private func animateScrollView() {
        UIViewPropertyAnimator(duration: 0.5, dampingRatio: 1) { [weak self] in
            self?.scrollView.alpha = 1
        }.startAnimation()
    }

    private func setupScrollView() {
        view.removeAllSubviews()
        view.addSubview(scrollView)
        view.backgroundColor = viewModel.getHeaderColor()
        scrollView.backgroundColor = .white
        scrollView.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            scrollView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            scrollView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            scrollView.topAnchor.constraint(equalTo: view.topAnchor),
            scrollView.bottomAnchor.constraint(equalTo: view.bottomAnchor)
        ])
        scrollView.alpha = 0
        scrollView.bounces = true
        scrollView.delegate = self
        scrollView.showsVerticalScrollIndicator = false
        scrollView.showsHorizontalScrollIndicator = false
        scrollView.layoutIfNeeded()

        renderContentView()
    }

    private func renderContentView() {
        //CONTENT VIEW
        let contentView = UIView()
        contentView.backgroundColor = .white
        contentView.translatesAutoresizingMaskIntoConstraints = false
        scrollView.addSubview(contentView)

        //Content View Layout
        NSLayoutConstraint.activate([
            contentView.leadingAnchor.constraint(equalTo: scrollView.leadingAnchor),
            contentView.trailingAnchor.constraint(equalTo: scrollView.trailingAnchor),
            contentView.topAnchor.constraint(equalTo: scrollView.topAnchor),
            contentView.widthAnchor.constraint(equalTo: scrollView.widthAnchor)
        ])

        //FOOTER VIEW
        let footerView = buildFooterView()
        if let model = viewModel as? PXResultViewModel, model.getPaymentStatus() != PXPayment.Status.REJECTED {
            footerView.addSeparatorLineToTop(height: 1)
        }
        scrollView.addSubview(footerView)

        //Footer View Layout
        NSLayoutConstraint.activate([
            footerView.leadingAnchor.constraint(equalTo: scrollView.leadingAnchor),
            footerView.trailingAnchor.constraint(equalTo: scrollView.trailingAnchor),
            footerView.topAnchor.constraint(equalTo: contentView.bottomAnchor),
            footerView.bottomAnchor.constraint(equalTo: scrollView.bottomAnchor)
        ])

        //Calculate content view min height
        self.view.layoutIfNeeded()
        let scrollViewMinHeight: CGFloat = PXLayout.getScreenHeight() - footerView.frame.height - PXLayout.getSafeAreaTopInset() - PXLayout.getSafeAreaBottomInset()
        contentViewHeightConstraint = contentView.heightAnchor.constraint(greaterThanOrEqualToConstant: scrollViewMinHeight)
        if let contentViewHeightConstraint = contentViewHeightConstraint {
            contentViewHeightConstraint.isActive = true
        }

        //Load content views
        let views = getContentViews()
        if views.count > 0 {
            for data in views {
                if let ringView = data.view as? MLBusinessLoyaltyRingView {
                    self.ringView = ringView
                }

                contentView.addViewToBottom(data.view, withMargin: data.verticalMargin)

                NSLayoutConstraint.activate([
                    data.view.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: data.horizontalMargin),
                    data.view.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -data.horizontalMargin)
                ])
            }
            if let resultViewModel = viewModel as? PXResultViewModel,
                resultViewModel.remedy?.cvv != nil || resultViewModel.remedy?.suggestedPaymentMethod != nil,
                contentView.subviews.last is PXRemedyView {
                PXLayout.pinLastSubviewToBottom(view: contentView)
            } else {
                PXLayout.pinLastSubviewToBottom(view: contentView, relation: .lessThanOrEqual)
            }
        }
    }
}

// MARK: Elastic header.
extension PXNewResultViewController: UIScrollViewDelegate {
    func addElasticHeader() {
        elasticHeader.removeFromSuperview()
        elasticHeader.backgroundColor = viewModel.getHeaderColor()
        view.insertSubview(elasticHeader, aboveSubview: scrollView)
    }

    func scrollViewWillEndDragging(_ scrollView: UIScrollView, withVelocity velocity: CGPoint, targetContentOffset: UnsafeMutablePointer<CGPoint>) {
        if scrollView.contentOffset.y > 0 && scrollView.contentOffset.y <= 32 {
            UIView.animate(withDuration: 0.25, animations: {
                targetContentOffset.pointee.y = 32
            })
        }
    }

    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        // Elastic header min height
        if -scrollView.contentOffset.y < statusBarHeight {
            elasticHeader.frame = CGRect(x: 0, y: 0, width: view.frame.width, height: statusBarHeight)
        } else {
            elasticHeader.frame = CGRect(x: 0, y: 0, width: view.frame.width, height: -scrollView.contentOffset.y)
        }
    }
}

internal extension UIView {
    func addViewToBottom(_ view: UIView, withMargin margin: CGFloat = 0) {
        view.translatesAutoresizingMaskIntoConstraints = false
        self.addSubview(view)
        if self.subviews.count == 1 {
            PXLayout.pinTop(view: view, withMargin: margin).isActive = true
        } else {
            PXLayout.put(view: view, onBottomOfLastViewOf: self, withMargin: margin)?.isActive = true
        }
    }
}

// MARK: Ring Animate.
extension PXNewResultViewController {
    private func animateRing() {
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) { [weak self] in
            self?.ringView?.fillPercentProgressWithAnimation()
        }
    }
}

// MARK: Get content views
extension PXNewResultViewController {
    func getContentViews() -> [ResultViewData] {
        var views = [ResultViewData]()

        //Header View
        let view = buildHeaderView()
        views.append(ResultViewData(view: view))

        //Instructions View
        if let view = viewModel.getInstructionsView() {
            views.append(ResultViewData(view: view))
        }

        //Top text box View
        if let topTextBoxView = buildTopTextBoxView() {
            views.append(ResultViewData(view: topTextBoxView, verticalMargin: PXLayout.ZERO_MARGIN, horizontalMargin: PXLayout.ZERO_MARGIN))
        }

        //Important View
        if let view = viewModel.getImportantView() {
            views.append(ResultViewData(view: view))
        }

        //Points and Discounts
        let pointsView = buildPointsView()
        let discountsView = buildDiscountsView()

        //Points
        if let pointsView = pointsView {
            views.append(ResultViewData(view: pointsView, verticalMargin: PXLayout.M_MARGIN, horizontalMargin: PXLayout.L_MARGIN))
        }

        //Discounts
        if let discountsView = discountsView {
            var margin = PXLayout.M_MARGIN
            if pointsView != nil {
                //Dividing Line
                views.append(ResultViewData(view: MLBusinessDividingLineView(hasTriangle: true), verticalMargin: PXLayout.M_MARGIN, horizontalMargin: PXLayout.L_MARGIN))
                margin -= 8
            }
            views.append(ResultViewData(view: discountsView, verticalMargin: margin, horizontalMargin: PXLayout.M_MARGIN))

            //Discounts Accessory View
            if let discountsAccessoryViewData = buildDiscountsAccessoryView() {
                views.append(discountsAccessoryViewData)
            }
        }

        //Cross Selling View
        if let crossSellingViews = buildCrossSellingViews() {
            var margin: CGFloat = 0
            if discountsView != nil && pointsView == nil {
                margin = PXLayout.M_MARGIN
            } else if discountsView == nil && pointsView != nil {
                margin = PXLayout.XXS_MARGIN
            }
            for view in crossSellingViews {
                views.append(ResultViewData(view: view, verticalMargin: margin, horizontalMargin: PXLayout.L_MARGIN))
            }
        }

        //Top Custom View
        if let view = viewModel.getTopCustomView() {
            views.append(ResultViewData(view: view))
        }

        //Receipt View
        if let view = buildReceiptView() {
            views.append(ResultViewData(view: view))
        }

        //Error body View
        if let view = viewModel.getErrorBodyView() {
            views.append(ResultViewData(view: view))
        }

        //Remedy body View
        if let view = viewModel.getRemedyView(animatedButtonDelegate: self, remedyViewProtocol: self) {
            subscribeToKeyboardNotifications()
            views.append(ResultViewData(view: view))
        }

        //Payment Method View
        if viewModel.shouldShowPaymentMethod(), let view = buildPaymentMethodView() {
            views.append(ResultViewData(view: view))
        }

        //Split Payment View
        if viewModel.shouldShowPaymentMethod(), let view = buildSplitPaymentMethodView() {
            views.append(ResultViewData(view: view))
        }

        //View receipt action view
        if let viewReceiptActionView = buildViewReceiptActionView() {
            views.append(ResultViewData(view: viewReceiptActionView, verticalMargin: PXLayout.M_MARGIN, horizontalMargin: PXLayout.L_MARGIN))
        }

        //Bottom Custom View
        if let view = viewModel.getBottomCustomView() {
            views.append(ResultViewData(view: view))
        }

        return views
    }

    private func getRemedyViewAnimatedButton() -> PXAnimatedButton? {
        if let remedyView = scrollView.subviews.first?.subviews.first(where: { $0 is PXRemedyView }) as? PXRemedyView? {
            return remedyView?.button
        }
        return nil
    }
}

// MARK: Views builders
extension PXNewResultViewController {
    //HEADER
    func buildHeaderView() -> UIView {
        let headerData = PXNewResultHeaderData(color: viewModel.getHeaderColor(),
                                               title: viewModel.getHeaderTitle(),
                                               icon: viewModel.getHeaderIcon(),
                                               iconURL: viewModel.getHeaderURLIcon(),
                                               badgeImage: viewModel.getHeaderBadgeImage(),
                                               closeAction: viewModel.getHeaderCloseAction())
        return PXNewResultHeader(data: headerData)
    }

    //RECEIPT
    func buildReceiptView() -> UIView? {
        guard let data = PXNewResultUtil.getDataForReceiptView(paymentId: viewModel.getReceiptId()), viewModel.mustShowReceipt() else {
            return nil
        }

        return PXNewCustomView(data: data)
    }

    //POINTS AND DISCOUNTS
    ////POINTS
    func buildPointsView() -> UIView? {
        guard let data = PXNewResultUtil.getDataForPointsView(points: viewModel.getPoints()) else {
            return nil
        }
        let pointsView = MLBusinessLoyaltyRingView(data, fillPercentProgress: false)

        if let tapAction = viewModel.getPointsTapAction() {
            pointsView.addTapAction(tapAction)
        }

        return pointsView
    }
    ////DISCOUNTS
    func buildDiscountsView() -> UIView? {
        guard let data = PXNewResultUtil.getDataForDiscountsView(discounts: viewModel.getDiscounts()) else {
            return nil
        }
        let discountsView = MLBusinessDiscountBoxView(data)

        if let tapAction = viewModel.getDiscountsTapAction() {
            discountsView.addTapAction(tapAction)
        }

        return discountsView
    }

    ////DISCOUNTS ACCESSORY VIEW
    func buildDiscountsAccessoryView() -> ResultViewData? {
        return PXNewResultUtil.getDataForDiscountsAccessoryViewData(discounts: viewModel.getDiscounts())
    }

    ////CROSS SELLING
    func buildCrossSellingViews() -> [UIView]? {
        guard let data = PXNewResultUtil.getDataForCrossSellingView(crossSellingItems: viewModel.getCrossSellingItems()) else {
            return nil
        }
        var itemsViews = [UIView]()
        for itemData in data {
            let itemView = MLBusinessCrossSellingBoxView(itemData)
            if let tapAction = viewModel.getCrossSellingTapAction() {
                itemView.addTapAction(action: tapAction)
            }

            itemsViews.append(itemView)
        }
        return itemsViews
    }

    ////VIEW RECEIPT ACTION
    func buildViewReceiptActionView() -> UIView? {
        guard let viewReceiptAction = viewModel.getViewReceiptAction() else {
            return nil
        }
        if !MLBusinessAppDataService().isMpAlreadyInstalled() {
            return nil
        }

        let button = AndesButton(text: viewReceiptAction.label, hierarchy: .quiet, size: AndesButtonSize.large)
        button.add(for: .touchUpInside) { [weak self] in
            self?.trackEvent(path: TrackingPaths.Events.Congrats.getSuccessTapViewReceiptPath())
            //open deep link
            PXDeepLinkManager.open(viewReceiptAction.target)
        }
        return button
    }

    ////TOP TEXT BOX
    func buildTopTextBoxView() -> UIView? {
        guard let topTextBox = viewModel.getTopTextBox() else {
            return nil
        }
        let containerView = UIView()
        containerView.translatesAutoresizingMaskIntoConstraints = false
        containerView.addSeparatorLineToBottom(height: 1)

        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.attributedText = topTextBox.getAttributedString(fontSize: PXLayout.XS_FONT)
        label.numberOfLines = 0

        containerView.addSubview(label)
        NSLayoutConstraint.activate([
            label.topAnchor.constraint(equalTo: containerView.topAnchor, constant: PXLayout.L_MARGIN),
            label.bottomAnchor.constraint(equalTo: containerView.bottomAnchor, constant: -PXLayout.L_MARGIN),
            label.leadingAnchor.constraint(equalTo: containerView.leadingAnchor, constant: PXLayout.M_MARGIN),
            label.trailingAnchor.constraint(equalTo: containerView.trailingAnchor, constant: -PXLayout.M_MARGIN)
        ])

        return containerView
    }

    //INSTRUCTIONS
    func buildInstructionsView() -> UIView? {
        return viewModel.getInstructionsView()
    }

    //PAYMENT METHOD
    func buildPaymentMethodView() -> UIView? {
        guard let paymentData = viewModel.getPaymentData(),
            let amountHelper = viewModel.getAmountHelper(),
            let data = PXNewResultUtil.getDataForPaymentMethodView(paymentData: paymentData, amountHelper: amountHelper) else {
            return nil
        }

        if paymentData.paymentMethod?.id == "consumer_credits", let creditsExpectationView = viewModel.getCreditsExpectationView() {
            return PXNewCustomView(data: data, bottomView: creditsExpectationView)
        }

        return PXNewCustomView(data: data)
    }

    //SPLIT PAYMENT METHOD
    func buildSplitPaymentMethodView() -> UIView? {
        guard let paymentData = viewModel.getSplitPaymentData(),
            let amountHelper = viewModel.getSplitAmountHelper(),
            let data = PXNewResultUtil.getDataForPaymentMethodView(paymentData: paymentData, amountHelper: amountHelper) else {
            return nil
        }

        return PXNewCustomView(data: data)
    }

    //FOOTER
    func buildFooterView() -> UIView {
        let footerProps = PXFooterProps(buttonAction: viewModel.getFooterMainAction(), linkAction: viewModel.getFooterSecondaryAction(), useAndesButtonForLinkAction: viewModel.isPaymentResultRejectedWithRemedy())
        return PXFooterComponent(props: footerProps).render()
    }
}

// MARK: Animated Button delegate
extension PXNewResultViewController: PXAnimatedButtonDelegate {
    func shakeDidFinish() {
        scrollView.isScrollEnabled = true
        view.isUserInteractionEnabled = true
        unsubscribeFromAnimatedButtonNotifications()
        if let button = getRemedyViewAnimatedButton() {
            UIView.animate(withDuration: 0.3, animations: {
                button.backgroundColor = ThemeManager.shared.getAccentColor()
            })
        }
    }

    func expandAnimationInProgress() {
        UIView.animate(withDuration: 0.5, animations: { [weak self] in
            if let scrollView = self?.scrollView {
                self?.view.bringSubviewToFront(scrollView)
            }
            if let footerView = self?.scrollView.subviews.first(where: { $0 is PXFooterView }) {
                self?.scrollView.sendSubviewToBack(footerView)
            }
        })
    }

    func didFinishAnimation() {
        if let finishButtonAnimation = finishButtonAnimation {
            finishButtonAnimation()
        }
    }

    func progressButtonAnimationTimeOut() {
        if let button = getRemedyViewAnimatedButton() {
            button.resetButton()
            button.showErrorToast()
        }
    }
}

extension PXNewResultViewController: PXRemedyViewProtocol {
    func remedyViewButtonTouchUpInside(_ sender: PXAnimatedButton) {
        subscribeToAnimatedButtonNotifications(button: sender)
        sender.startLoading()
        scrollView.isScrollEnabled = false
        view.isUserInteractionEnabled = false
        hideBackButton()
        hideNavBar()
    }
}

// MARK: Notifications
extension PXNewResultViewController {
    func subscribeToKeyboardNotifications() {
        let center = NotificationCenter.default
        center.addObserver(self, selector: #selector(keyboardWillBeShown(notification:)), name: UIResponder.keyboardWillShowNotification, object: nil)
        center.addObserver(self, selector: #selector(keyboardWillBeHidden(notification:)), name: UIResponder.keyboardWillHideNotification, object: nil)
    }

    func unsubscribeFromKeyboardNotifications() {
        let center = NotificationCenter.default
        center.removeObserver(self, name: UIResponder.keyboardWillShowNotification, object: nil)
        center.removeObserver(self, name: UIResponder.keyboardWillHideNotification, object: nil)
    }

    func subscribeToAnimatedButtonNotifications(button: PXAnimatedButton) {
        PXNotificationManager.SuscribeTo.animateButton(button, selector: #selector(button.animateFinish))
    }

    func unsubscribeFromAnimatedButtonNotifications() {
        if let button = getRemedyViewAnimatedButton() {
            PXNotificationManager.UnsuscribeTo.animateButton(button)
        }
    }
}
