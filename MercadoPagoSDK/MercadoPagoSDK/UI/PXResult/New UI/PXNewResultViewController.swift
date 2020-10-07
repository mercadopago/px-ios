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
    private var touchpointView: MLBusinessTouchpointsView?
    private var autoReturnWorkItem: DispatchWorkItem?

    init(viewModel: PXNewResultViewModelInterface, finishButtonAnimation: (() -> Void)? = nil) {
        self.viewModel = viewModel
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
        PXNewResultUtil.trackScreenAndConversion(viewModel: viewModel)
        if viewModel.shouldAutoReturn() {
            autoReturnWorkItem = DispatchWorkItem { [weak self] in
                if let action = self?.viewModel.getHeaderCloseAction() {
                    action()
                }
            }
            if let autoReturnWorkItem = autoReturnWorkItem {
                DispatchQueue.main.asyncAfter(deadline: .now() + .seconds(5), execute: autoReturnWorkItem)
            }
        }
    }

    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        // remove animated button observer
        unsubscribeFromAnimatedButtonNotifications()
        // remove keyboard observer
        unsubscribeFromKeyboardNotifications()
        // Cancel the work item so it doesn't run
        autoReturnWorkItem?.cancel()
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
        scrollView.accessibilityIdentifier = "scroll_view"
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
        var footerTopAnchor = footerView.topAnchor.constraint(equalTo: contentView.bottomAnchor)
        NSLayoutConstraint.activate([
            footerView.leadingAnchor.constraint(equalTo: scrollView.leadingAnchor),
            footerView.trailingAnchor.constraint(equalTo: scrollView.trailingAnchor),
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
            if let remedyView = contentView.subviews.last as? PXRemedyView,
               remedyView.shouldShowButton() {
                PXLayout.pinLastSubviewToBottom(view: contentView)
            } else {
                PXLayout.pinLastSubviewToBottom(view: contentView, relation: .lessThanOrEqual)
                if contentView.subviews.last is MLBusinessActionCardView {
                    footerTopAnchor = footerView.topAnchor.constraint(equalTo: contentView.bottomAnchor, constant: PXLayout.XXXS_MARGIN)
                }
            }
        }
        footerTopAnchor.isActive = true
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

        if let touchpointView = touchpointView, touchpointView.frame.origin.y < scrollView.contentOffset.y + scrollView.frame.height {
            touchpointView.trackVisiblePrints()
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
        let customOrder = viewModel.getCustomOrder() ?? false
        var views = [ResultViewData]()

        //Header View
        let view = buildHeaderView()
        views.append(ResultViewData(view: view))

        //Remedy body View
        if let view = viewModel.getRemedyView(animatedButtonDelegate: self, remedyViewProtocol: self) {
            subscribeToKeyboardNotifications()
            views.append(ResultViewData(view: view))
            // If payment has remedy don't show anything else in congrats
            return views
        }

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

        // Custom Order
        /// Payment Method View
        /// Split Payment View
        /// Receipt View
        /// Top Custom View
        if customOrder == true {
            views.append(contentsOf: addReceiptAndPaymentViews(customOrder))
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

            //Discounts Top View
            if let discountsTopViewData = buildDiscountsTopView() {
                views.append(discountsTopViewData)
            }

            //Discount Component
            views.append(ResultViewData(view: discountsView, verticalMargin: margin, horizontalMargin: PXLayout.M_MARGIN))

            //Discounts Accessory View
            if let discountsAccessoryViewData = buildDiscountsAccessoryView() {
                views.append(discountsAccessoryViewData)
            }
        }

        // Expense Split View
        if let expenseSplitView = buildExpenseSplitView() {
            views.append(ResultViewData(view: expenseSplitView, verticalMargin: PXLayout.M_MARGIN, horizontalMargin: PXLayout.L_MARGIN))
        }

        //Cross Selling View
        if let crossSellingViews = buildCrossSellingViews() {
            var margin: CGFloat = 0
            if isActionCardViewLastView(views) {
                margin = PXLayout.M_MARGIN
            } else if discountsView != nil && pointsView == nil {
                margin = PXLayout.M_MARGIN
            } else if discountsView == nil && pointsView != nil {
                margin = PXLayout.XXS_MARGIN
            }
            for view in crossSellingViews {
                views.append(ResultViewData(view: view, verticalMargin: margin, horizontalMargin: PXLayout.L_MARGIN))
            }
        }

        //Error body View
        if let view = viewModel.getErrorBodyView() {
            views.append(ResultViewData(view: view))
        }

        // Normal Order
        /// Top Custom View
        /// Receipt View
        /// Payment Method View
        /// Split Payment View
        if customOrder == false {
            let verticalMargin = isActionCardViewLastView(views)
            views.append(contentsOf: addReceiptAndPaymentViews(customOrder, verticalMargin))
        }

        //View receipt action view
        if let viewReceiptActionView = buildViewReceiptActionView() {
            views.append(ResultViewData(view: viewReceiptActionView, verticalMargin: PXLayout.M_MARGIN, horizontalMargin: PXLayout.L_MARGIN))
        }

        //Bottom Custom View
        if let view = viewModel.getBottomCustomView() {
            views.append(ResultViewData(view: view, verticalMargin: isActionCardViewLastView(views) ? PXLayout.M_MARGIN : 0))
        }

        return views
    }

    private func addReceiptAndPaymentViews(_ customOrder: Bool, _ verticalMargin: Bool = false) -> [ResultViewData] {
        var views = [ResultViewData]()

        if customOrder == false {
            //Top Custom View
            if let view = viewModel.getTopCustomView() {
                views.append(ResultViewData(view: view, verticalMargin: getVerticalMarginForViews(verticalMargin, views)))
            }

            //Receipt View
            if let view = buildReceiptView() {
                views.append(ResultViewData(view: view, verticalMargin: getVerticalMarginForViews(verticalMargin, views)))
            }
        }

        //Payment Method View
        if viewModel.shouldShowPaymentMethod(), let view = buildPaymentMethodView() {
            views.append(ResultViewData(view: view, verticalMargin: getVerticalMarginForViews(verticalMargin, views)))
        }

        //Split Payment View
        if viewModel.shouldShowPaymentMethod(), let view = buildSplitPaymentMethodView() {
            views.append(ResultViewData(view: view, verticalMargin: getVerticalMarginForViews(verticalMargin, views)))
        }

        if customOrder == true {
            //Receipt View
            if let view = buildReceiptView() {
                views.append(ResultViewData(view: view))
            }

            //Top Custom View
            if let view = viewModel.getTopCustomView() {
                views.append(ResultViewData(view: view))
            }
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

// MARK: MLBusinessActionCardView
private extension PXNewResultViewController {
    func getVerticalMarginForViews(_ shouldApplyMargin: Bool, _ views: [ResultViewData]) -> CGFloat {
       return shouldApplyVerticalMargin(shouldApplyMargin, views) ? PXLayout.M_MARGIN : 0
    }

    func shouldApplyVerticalMargin(_ margin: Bool, _ views: [ResultViewData]) -> Bool {
        return margin == true && views.last == nil
    }

    func isActionCardViewLastView(_ views: [ResultViewData]) -> Bool {
        return views.last?.view is MLBusinessActionCardView
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
    func buildDiscountsTopView() -> ResultViewData? {
        return getDataForDiscountTopView(discounts: viewModel.getDiscounts())
    }

    //DISCOUNTS TOP VIEW
    func getDataForDiscountTopView(discounts: PXDiscounts?) -> ResultViewData? {
        if let discounts = discounts, discounts.touchpoint != nil, let title = discounts.title {
            let stackview = UIStackView(frame: .zero)
            stackview.distribution = .equalSpacing
            stackview.axis = .vertical
            stackview.addArrangedSubview(buildMPLabel(with: title, font: UIFont.ml_semiboldSystemFont(ofSize: 20.0), numberOfLines: 2))

            if let subtitle = discounts.subtitle, subtitle.isEmpty == false {
                stackview.addArrangedSubview(buildMPLabel(with: subtitle, font: UIFont.ml_lightSystemFont(ofSize: 14.0), numberOfLines: 1))
            }

            return ResultViewData(view: stackview, verticalMargin: PXLayout.M_MARGIN, horizontalMargin: PXLayout.L_MARGIN)
        }
        return nil
    }

    private func buildMPLabel(with text: String, font: UIFont, numberOfLines: Int) -> MPLabel {
        let mpLabel = MPLabel(frame: .zero)
        mpLabel.textColor = UIColor(red: 0, green: 0, blue: 0, alpha: 0.8)
        mpLabel.text = text
        mpLabel.textAlignment = .center
        mpLabel.font = font
        mpLabel.numberOfLines = numberOfLines
        return mpLabel
    }

    func buildDiscountsView() -> UIView? {
        guard let discounts = viewModel.getDiscounts()  else {
            return nil
        }
        guard let data = PXNewResultUtil.getDataForTouchpointsView(discounts: discounts) else {
            guard let data = PXNewResultUtil.getDataForDiscountsView(discounts: discounts) else {
                return nil
            }
            let discountsView = MLBusinessDiscountBoxView(data)
            if let tapAction = viewModel.getDiscountsTapAction() {
                discountsView.addTapAction(tapAction)
            }
            return discountsView
        }
        touchpointView = MLBusinessTouchpointsView()
        touchpointView?.setTouchpointsTracker(with: PXDiscountTracker())
        touchpointView?.setCanOpenMercadoPagoApp(MLBusinessAppDataService().isMpAlreadyInstalled())
        touchpointView?.delegate = self
        touchpointView?.update(with: data)

        return touchpointView
    }

    ////DISCOUNTS ACCESSORY VIEW
    func buildDiscountsAccessoryView() -> ResultViewData? {
        return PXNewResultUtil.getDataForDiscountsAccessoryViewData(discounts: viewModel.getDiscounts())
    }

    ////EXPENSE SPLIT VIEW
    private func buildExpenseSplitView() -> UIView? {
        guard let expenseSplit = viewModel.getExpenseSplit(),
            MLBusinessAppDataService().isMp()
        else { return nil }

        let data = PXNewResultUtil.getDataForExpenseSplitView(expenseSplit: expenseSplit)
        let expenseSplitView = MLBusinessActionCardView(data)
        if let tapAction = viewModel.getExpenseSplitTapAction() {
            expenseSplitView.addTapAction(tapAction)
        }
        return expenseSplitView
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
        guard let paymentData = viewModel.getPaymentViewData() else { return nil }
        let creditsExpectationView = viewModel.getCreditsExpectationView()
        return PXNewCustomView(data: paymentData, bottomView: creditsExpectationView)
    }

    //SPLIT PAYMENT METHOD
    func buildSplitPaymentMethodView() -> UIView? {
        guard let paymentData = viewModel.getSplitPaymentViewData() else { return nil }
        return PXNewCustomView(data: paymentData)
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

extension PXNewResultViewController: MLBusinessTouchpointsUserInteractionHandler {
    func didTap(with selectedIndex: Int, deeplink: String, trackingId: String) {
        viewModel.didTapDiscount(index: selectedIndex, deepLink: deeplink, trackId: trackingId)
    }
}
