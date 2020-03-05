//
//  PXNewResultViewController.swift
//  MercadoPagoSDK
//
//  Created by AUGUSTO COLLERONE ALFONSO on 27/08/2019.
//

import UIKit
import MLBusinessComponents

class PXNewResultViewController: MercadoPagoUIViewController {

    private weak var ringView: MLBusinessLoyaltyRingView?
    private lazy var elasticHeader = UIView()
    private lazy var NAVIGATION_BAR_DELTA_Y: CGFloat = 29.8
    private lazy var NAVIGATION_BAR_SECONDARY_DELTA_Y: CGFloat = 0
    private lazy var navigationTitleStatusStep: Int = 0

    private let statusBarHeight = PXLayout.getStatusBarHeight()

    let scrollView = UIScrollView()
    let viewModel: PXNewResultViewModelInterface

    internal var changePaymentMethodCallback: (() -> Void)?

    init(viewModel: PXNewResultViewModelInterface, callback: @escaping ( _ status: PaymentResult.CongratsState) -> Void) {
        self.viewModel = viewModel
        self.viewModel.setCallback(callback: callback)
        super.init(nibName: nil, bundle: nil)
        self.shouldHideNavigationBar = true
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        setupScrollView()
        addElasticHeader(headerBackgroundColor: viewModel.getHeaderColor())
    }

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        animateScrollView()
        animateRing()
        if !String.isNullOrEmpty(viewModel.getTrackingPath()) {
            trackScreen(path: viewModel.getTrackingPath(), properties: viewModel.getTrackingProperties())

            let behaviourProtocol = PXConfiguratorManager.flowBehaviourProtocol
            behaviourProtocol.trackConversion(result: viewModel.getFlowBehaviourResult())
        }
    }

    private func animateScrollView() {
        let animator = UIViewPropertyAnimator(duration: 0.5, dampingRatio: 1) {
            self.scrollView.alpha = 1
        }
        animator.startAnimation()
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

    func renderContentView() {
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
            contentView.widthAnchor.constraint(equalTo: view.widthAnchor)
        ])

        //FOOTER VIEW
        let footerView = buildFooterView()
        footerView.addSeparatorLineToTop(height: 1)
        scrollView.addSubview(footerView)

        //Footer View Layout
        NSLayoutConstraint.activate([
            footerView.leadingAnchor.constraint(equalTo: scrollView.leadingAnchor),
            footerView.trailingAnchor.constraint(equalTo: scrollView.trailingAnchor),
            footerView.topAnchor.constraint(equalTo: contentView.bottomAnchor),
            footerView.bottomAnchor.constraint(equalTo: scrollView.bottomAnchor),
            footerView.widthAnchor.constraint(equalTo: view.widthAnchor)
        ])

        //Calculate content view min height
        self.view.layoutIfNeeded()
        let scrollViewMinHeight: CGFloat = PXLayout.getScreenHeight() - footerView.frame.height - PXLayout.getSafeAreaTopInset() - PXLayout.getSafeAreaBottomInset()
        NSLayoutConstraint.activate([
            contentView.heightAnchor.constraint(greaterThanOrEqualToConstant: scrollViewMinHeight)
        ])

        //Load content views
        let views = getContentViews()
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
        PXLayout.pinLastSubviewToBottom(view: contentView, relation: .lessThanOrEqual)
    }
}

// MARK: Elastic header.
extension PXNewResultViewController: UIScrollViewDelegate {
    func addElasticHeader(headerBackgroundColor: UIColor?, navigationDeltaY: CGFloat?=nil, navigationSecondaryDeltaY: CGFloat?=nil) {
        elasticHeader.removeFromSuperview()
        scrollView.delegate = self
        elasticHeader.backgroundColor = headerBackgroundColor
        if let customDeltaY = navigationDeltaY {
            NAVIGATION_BAR_DELTA_Y = customDeltaY
        }
        if let customSecondaryDeltaY = navigationSecondaryDeltaY {
            NAVIGATION_BAR_SECONDARY_DELTA_Y = customSecondaryDeltaY
        }

        view.insertSubview(elasticHeader, aboveSubview: scrollView)
        scrollView.bounces = true
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
        if let view = buildInstructionsView() {
            views.append(ResultViewData(view: view))
        }

        //Important View
        if let view = buildImportantView() {
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
        if let view = buildTopCustomView() {
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
        if let view = viewModel.getRemedyBodyView() {
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

        //Bottom Custom View
        if let view = buildBottomCustomView() {
            views.append(ResultViewData(view: view))
        }

        return views
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

    //INSTRUCTIONS
    func buildInstructionsView() -> UIView? {
        return viewModel.getInstructionsView()
    }

    //PAYMENT METHOD
    func buildPaymentMethodView() -> UIView? {
        guard let paymentData = viewModel.getPaymentData() else {
            return nil
        }
        guard let amountHelper = viewModel.getAmountHelper() else {
            return nil
        }
        guard let data = PXNewResultUtil.getDataForPaymentMethodView(paymentData: paymentData, amountHelper: amountHelper) else {
            return nil
        }

        if paymentData.paymentMethod?.id == "consumer_credits", let creditsExpectationView = viewModel.getCreditsExpectationView() {
            return PXNewCustomView(data: data, bottomView: creditsExpectationView)
        }

        return PXNewCustomView(data: data)
    }

    //SPLIT PAYMENT METHOD
    func buildSplitPaymentMethodView() -> UIView? {
        guard let paymentData = viewModel.getSplitPaymentData() else {
            return nil
        }
        guard let amountHelper = viewModel.getSplitAmountHelper() else {
            return nil
        }
        guard let data = PXNewResultUtil.getDataForPaymentMethodView(paymentData: paymentData, amountHelper: amountHelper) else {
            return nil
        }

        let view = PXNewCustomView(data: data)
        return view
    }

    //FOOTER
    func buildFooterView() -> UIView {
        let footerProps = PXFooterProps(buttonAction: viewModel.getFooterMainAction(), linkAction: viewModel.getFooterSecondaryAction())
        return PXFooterComponent(props: footerProps).render()
    }

    //CUSTOM
    ////IMPORTANT
    func buildImportantView() -> UIView? {
        return viewModel.getImportantView()
    }

    ////TOP CUSTOM
    func buildTopCustomView() -> UIView? {
        return viewModel.getTopCustomView()
    }

    ////BOTTOM CUSTOM
    func buildBottomCustomView() -> UIView? {
        return viewModel.getBottomCustomView()
    }
}
