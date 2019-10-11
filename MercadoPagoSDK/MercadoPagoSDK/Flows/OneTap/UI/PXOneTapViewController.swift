//
//  PXOneTapViewController.swift
//  MercadoPagoSDK
//
//  Created by Juan sebastian Sanzone on 15/5/18.
//  Copyright © 2018 MercadoPago. All rights reserved.
//

import UIKit

final class PXOneTapViewController: PXComponentContainerViewController {

    // MARK: Definitions
    lazy var itemViews = [UIView]()
    fileprivate var viewModel: PXOneTapViewModel
    private lazy var footerView: UIView = UIView()
    private var discountTermsConditionView: PXTermsAndConditionView?

    let slider = PXCardSlider()

    // MARK: Callbacks
    var callbackPaymentData: ((PXPaymentData) -> Void)
    var callbackConfirm: ((PXPaymentData, Bool) -> Void)
    var callbackUpdatePaymentOption: ((PaymentMethodOption) -> Void)
    var callbackExit: (() -> Void)
    var finishButtonAnimation: (() -> Void)

    var loadingButtonComponent: PXAnimatedButton?
    var installmentInfoRow: PXOneTapInstallmentInfoView?
    var installmentsSelectorView: PXOneTapInstallmentsSelectorView?
    var headerView: PXOneTapHeaderView?
    var selectedCard: PXCardSliderViewModel?

    let timeOutPayButton: TimeInterval

    var cardSliderMarginConstraint: NSLayoutConstraint?
    private var navigationBarTapGesture: UITapGestureRecognizer?

    // MARK: Lifecycle/Publics
    init(viewModel: PXOneTapViewModel, timeOutPayButton: TimeInterval = 15, callbackPaymentData : @escaping ((PXPaymentData) -> Void), callbackConfirm: @escaping ((PXPaymentData, Bool) -> Void), callbackUpdatePaymentOption: @escaping ((PaymentMethodOption) -> Void), callbackExit: @escaping (() -> Void), finishButtonAnimation: @escaping (() -> Void)) {
        self.viewModel = viewModel
        self.callbackPaymentData = callbackPaymentData
        self.callbackConfirm = callbackConfirm
        self.callbackExit = callbackExit
        self.callbackUpdatePaymentOption = callbackUpdatePaymentOption
        self.finishButtonAnimation = finishButtonAnimation
        self.timeOutPayButton = timeOutPayButton
        super.init(adjustInsets: false)
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
        PXNotificationManager.UnsuscribeTo.animateButton(loadingButtonComponent)
        removeNavigationTapGesture()
    }

    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        loadingButtonComponent?.resetButton()
    }

    override public func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        trackScreen(path: TrackingPaths.Screens.OneTap.getOneTapPath(), properties: viewModel.getOneTapScreenProperties())
    }

    func update(viewModel: PXOneTapViewModel) {
        self.viewModel = viewModel
    }
}

// MARK: UI Methods.
extension PXOneTapViewController {
    private func setupNavigationBar() {
        setBackground(color: ThemeManager.shared.navigationBar().backgroundColor)
        navBarTextColor = ThemeManager.shared.labelTintColor()
        loadMPStyles()
        navigationController?.navigationBar.isTranslucent = true
        navigationController?.navigationBar.barTintColor = ThemeManager.shared.whiteColor()
        navigationItem.leftBarButtonItem?.tintColor = ThemeManager.shared.navigationBar().getTintColor()
        navigationController?.navigationBar.backgroundColor = ThemeManager.shared.highlightBackgroundColor()
        navigationController?.navigationBar.setBackgroundImage(UIImage(), for: UIBarMetrics.default)
        navigationController?.navigationBar.backgroundColor = .clear
        addNavigationTapGesture()
    }

    private func setupUI() {
        if contentView.getSubviews().isEmpty {
            viewModel.createCardSliderViewModel()
            if let preSelectedCard = viewModel.getCardSliderViewModel().first {
                selectedCard = preSelectedCard
                viewModel.splitPaymentEnabled = preSelectedCard.amountConfiguration?.splitConfiguration?.splitEnabled ?? false
                viewModel.amountHelper.getPaymentData().payerCost = preSelectedCard.selectedPayerCost
            }
            renderViews()
        }
    }

    private func renderViews() {
        contentView.prepareForRender()

        // Add header view.
        let headerView = getHeaderView(selectedCard: selectedCard)
        self.headerView = headerView
        contentView.addSubviewToBottom(headerView)
        PXLayout.setHeight(owner: headerView, height: PXCardSliderSizeManager.getHeaderViewHeight(viewController: self)).isActive = true
        PXLayout.centerHorizontally(view: headerView).isActive = true
        PXLayout.matchWidth(ofView: headerView).isActive = true

        // Center white View
        let whiteView = getWhiteView()
        contentView.addSubviewToBottom(whiteView)
        PXLayout.setHeight(owner: whiteView, height: PXCardSliderSizeManager.getWhiteViewHeight(viewController: self)).isActive = true
        PXLayout.centerHorizontally(view: whiteView).isActive = true
        PXLayout.pinLeft(view: whiteView, withMargin: 0).isActive = true
        PXLayout.pinRight(view: whiteView, withMargin: 0).isActive = true

        // Add installment row
        let installmentRow = getInstallmentInfoView()
        whiteView.addSubview(installmentRow)
        PXLayout.centerHorizontally(view: installmentRow).isActive = true
        PXLayout.pinLeft(view: installmentRow).isActive = true
        PXLayout.pinRight(view: installmentRow).isActive = true
        PXLayout.matchWidth(ofView: installmentRow).isActive = true
        PXLayout.pinTop(view: installmentRow, withMargin: PXLayout.XXXS_MARGIN).isActive = true

        // Add card slider
        let cardSliderContentView = UIView()
        whiteView.addSubview(cardSliderContentView)
        PXLayout.centerHorizontally(view: cardSliderContentView).isActive = true
        let topMarginConstraint = PXLayout.put(view: cardSliderContentView, onBottomOf: installmentRow, withMargin: 0)
        topMarginConstraint.isActive = true
        cardSliderMarginConstraint = topMarginConstraint

        // CardSlider with GoldenRatio multiplier
        cardSliderContentView.translatesAutoresizingMaskIntoConstraints = false
        let widthSlider: NSLayoutConstraint = cardSliderContentView.widthAnchor.constraint(equalTo: whiteView.widthAnchor)
        widthSlider.isActive = true
        let heightSlider: NSLayoutConstraint = cardSliderContentView.heightAnchor.constraint(equalTo: cardSliderContentView.widthAnchor, multiplier: PXCardSliderSizeManager.goldenRatio)
        heightSlider.isActive = true

        // Add footer payment button.
        if let footerView = getFooterView() {
            whiteView.addSubview(footerView)
            PXLayout.centerHorizontally(view: footerView).isActive = true
            PXLayout.pinLeft(view: footerView, withMargin: PXLayout.M_MARGIN).isActive = true
            PXLayout.pinRight(view: footerView, withMargin: PXLayout.M_MARGIN).isActive = true
            PXLayout.setHeight(owner: footerView, height: PXLayout.XXL_MARGIN).isActive = true
            let bottomMargin = getBottomPayButtonMargin()
            PXLayout.pinBottom(view: footerView, withMargin: bottomMargin).isActive = true
        }

        if let selectedCard = selectedCard, selectedCard.isDisabled {
            loadingButtonComponent?.setDisabled()
        }

        view.layoutIfNeeded()
        let installmentRowWidth: CGFloat = slider.getItemSize(cardSliderContentView).width
        installmentRow.render(installmentRowWidth)

        view.layoutIfNeeded()
        refreshContentViewSize()
        scrollView.isScrollEnabled = false
        scrollView.showsVerticalScrollIndicator = false

        addCardSlider(inContainerView: cardSliderContentView)
    }

    private func getBottomPayButtonMargin() -> CGFloat {
        let safeAreaBottomHeight = PXLayout.getSafeAreaBottomInset()
        if safeAreaBottomHeight > 0 {
            return PXLayout.XXS_MARGIN + safeAreaBottomHeight
        }

        if UIDevice.isSmallDevice() {
            return PXLayout.XS_MARGIN
        }

        return PXLayout.M_MARGIN
    }

    private func removeNavigationTapGesture() {
        if let targetGesture = navigationBarTapGesture {
            navigationController?.navigationBar.removeGestureRecognizer(targetGesture)
        }
    }

    private func addNavigationTapGesture() {
        removeNavigationTapGesture()
        navigationBarTapGesture = UITapGestureRecognizer(target: self, action: #selector(didTapOnNavigationbar))
        if let navTapGesture = navigationBarTapGesture {
            navigationController?.navigationBar.addGestureRecognizer(navTapGesture)
        }
    }
}

// MARK: Components Builders.
extension PXOneTapViewController {
    private func getHeaderView(selectedCard: PXCardSliderViewModel?) -> PXOneTapHeaderView {
        let headerView = PXOneTapHeaderView(viewModel: viewModel.getHeaderViewModel(selectedCard: selectedCard), delegate: self)
        return headerView
    }

    private func getFooterView() -> UIView? {
        loadingButtonComponent = PXAnimatedButton(normalText: "Pagar".localized, loadingText: "Procesando tu pago".localized, retryText: "Reintentar".localized)
        loadingButtonComponent?.animationDelegate = self
        loadingButtonComponent?.layer.cornerRadius = 4
        loadingButtonComponent?.add(for: .touchUpInside, {
            self.confirmPayment()
        })
        loadingButtonComponent?.setTitle("Pagar".localized, for: .normal)
        loadingButtonComponent?.backgroundColor = ThemeManager.shared.getAccentColor()
        loadingButtonComponent?.accessibilityIdentifier = "pay_button"
        return loadingButtonComponent
    }

    private func getWhiteView() -> UIView {
        let whiteView = UIView()
        whiteView.backgroundColor = .white
        return whiteView
    }

    private func getInstallmentInfoView() -> PXOneTapInstallmentInfoView {
        installmentInfoRow = PXOneTapInstallmentInfoView()
        installmentInfoRow?.model = viewModel.getInstallmentInfoViewModel()
        installmentInfoRow?.delegate = self
        if let targetView = installmentInfoRow {
            return targetView
        } else {
            return PXOneTapInstallmentInfoView()
        }
    }

    private func addCardSlider(inContainerView: UIView) {
        slider.render(containerView: inContainerView, cardSliderProtocol: self)
        slider.termsAndCondDelegate = self
        slider.update(viewModel.getCardSliderViewModel())
    }
}

// MARK: User Actions.
extension PXOneTapViewController {
    @objc func didTapOnNavigationbar() {
        didTapMerchantHeader()
    }

    @objc func shouldChangePaymentMethod() {
        callbackPaymentData(viewModel.getClearPaymentData())
    }

    private func confirmPayment() {
        if viewModel.shouldValidateWithBiometric(withCardId: selectedCard?.cardId) {
            let biometricModule = PXConfiguratorManager.biometricProtocol
            biometricModule.validate(config: PXConfiguratorManager.biometricConfig, onSuccess: { [weak self] in
                DispatchQueue.main.async {
                    self?.doPayment()
                }
                }, onError: { [weak self] _ in
                    // User abort validation or validation fail.
                    self?.trackEvent(path: TrackingPaths.Events.getErrorPath())
            })
        } else {
            doPayment()
        }
    }

    private func doPayment() {
        self.subscribeLoadingButtonToNotifications()
        self.loadingButtonComponent?.startLoading(timeOut: self.timeOutPayButton)
        scrollView.isScrollEnabled = false
        view.isUserInteractionEnabled = false
        if let selectedCardItem = selectedCard {
            viewModel.amountHelper.getPaymentData().payerCost = selectedCardItem.selectedPayerCost
            let properties = viewModel.getConfirmEventProperties(selectedCard: selectedCardItem, selectedIndex: slider.getSelectedIndex())
            trackEvent(path: TrackingPaths.Events.OneTap.getConfirmPath(), properties: properties)
        }
        let splitPayment = viewModel.splitPaymentEnabled
        self.hideBackButton()
        self.hideNavBar()
        self.callbackConfirm(self.viewModel.amountHelper.getPaymentData(), splitPayment)
    }

    func resetButton(error: MPSDKError) {
        loadingButtonComponent?.resetButton()
        loadingButtonComponent?.showErrorToast()
        trackEvent(path: TrackingPaths.Events.getErrorPath(), properties: viewModel.getErrorProperties(error: error))
    }

    private func cancelPayment() {
        self.callbackExit()
    }
}

// MARK: Summary delegate.
extension PXOneTapViewController: PXOneTapHeaderProtocol {

    func splitPaymentSwitchChangedValue(isOn: Bool, isUserSelection: Bool) {
        viewModel.splitPaymentEnabled = isOn
        if isUserSelection {
            self.viewModel.splitPaymentSelectionByUser = isOn
            //Update all models payer cost and selected payer cost
            viewModel.updateAllCardSliderModels(splitPaymentEnabled: isOn)
        }

        if let installmentInfoRow = installmentInfoRow, installmentInfoRow.isExpanded() {
            installmentInfoRow.toggleInstallments()
        }

        //Update installment row
        installmentInfoRow?.model = viewModel.getInstallmentInfoViewModel()

        // If it's debit and has split, update split message
        if let infoRow = installmentInfoRow, viewModel.getCardSliderViewModel().indices.contains(infoRow.getActiveRowIndex()) {
            let selectedCard = viewModel.getCardSliderViewModel()[infoRow.getActiveRowIndex()]

            if selectedCard.paymentTypeId == PXPaymentTypes.DEBIT_CARD.rawValue {
                selectedCard.displayMessage = viewModel.getSplitMessageForDebit(amountToPay: selectedCard.selectedPayerCost?.totalAmount ?? 0)
            }

            // Installments arrow animation
            if selectedCard.shouldShowArrow {
                installmentInfoRow?.showArrow()
            } else {
                installmentInfoRow?.hideArrow()
            }
        }
    }

    func didTapMerchantHeader() {
        if let externalVC = viewModel.getExternalViewControllerForSubtitle() {
            PXComponentFactory.Modal.show(viewController: externalVC, title: externalVC.title)
        }
    }

    func didTapCharges() {
        if let vc = viewModel.getChargeRuleViewController() {
            let defaultTitle = "onetap_purchase_summary_charges".localized_beta
            let title = vc.title ?? defaultTitle
            PXComponentFactory.Modal.show(viewController: vc, title: title) {
                if UIDevice.isSmallDevice() {
                    self.setupNavigationBar()
                }
            }
        }
    }

    func didTapDiscount() {
        let discountViewController = PXDiscountDetailViewController(amountHelper: viewModel.amountHelper)

        if let discount = viewModel.amountHelper.discount {
            PXComponentFactory.Modal.show(viewController: discountViewController, title: discount.getDiscountDescription()) {
                self.setupNavigationBar()
            }
        } else if viewModel.amountHelper.consumedDiscount {
            PXComponentFactory.Modal.show(viewController: discountViewController, title: "modal_title_consumed_discount".localized_beta) {
                self.setupNavigationBar()
            }
        }
    }
}

// MARK: CardSlider delegate.
extension PXOneTapViewController: PXCardSliderProtocol {

    func newCardDidSelected(targetModel: PXCardSliderViewModel) {

        selectedCard = targetModel

        trackEvent(path: TrackingPaths.Events.OneTap.getSwipePath())

        // Installments arrow animation
        if targetModel.shouldShowArrow {
            installmentInfoRow?.showArrow()
        } else {
            installmentInfoRow?.hideArrow()
        }

        // Add card. - card o credits payment method selected
        let validData = targetModel.cardData != nil || targetModel.isCredits
        let shouldDisplay = validData && !targetModel.isDisabled
        if shouldDisplay {
            displayCard(targetModel: targetModel)
        } else {
            loadingButtonComponent?.setDisabled()
            headerView?.updateModel(viewModel.getHeaderViewModel(selectedCard: nil))
        }
    }

    func displayCard(targetModel: PXCardSliderViewModel) {
        // New payment method selected.
        let newPaymentMethodId: String = targetModel.paymentMethodId
        let newPayerCost: PXPayerCost? = targetModel.selectedPayerCost

        if let newPaymentMethod = viewModel.getPaymentMethod(targetId: newPaymentMethodId) {
            let currentPaymentData: PXPaymentData = viewModel.amountHelper.getPaymentData()
            currentPaymentData.payerCost = newPayerCost
            currentPaymentData.paymentMethod = newPaymentMethod
            currentPaymentData.issuer = PXIssuer(id: targetModel.issuerId, name: nil)
            callbackUpdatePaymentOption(targetModel)
            loadingButtonComponent?.setEnabled()

        } else {
            loadingButtonComponent?.setDisabled()
        }
        headerView?.updateModel(viewModel.getHeaderViewModel(selectedCard: selectedCard))

        headerView?.updateSplitPaymentView(splitConfiguration: selectedCard?.amountConfiguration?.splitConfiguration)

        // If it's debit and has split, update split message
        if let totalAmount = targetModel.selectedPayerCost?.totalAmount, targetModel.paymentTypeId == PXPaymentTypes.DEBIT_CARD.rawValue {
            targetModel.displayMessage = viewModel.getSplitMessageForDebit(amountToPay: totalAmount)
        }
    }

    func disabledCardDidTap(isAccountMoney: Bool) {
        let vc = PXDisabledViewController(isAccountMoney: isAccountMoney)
        PXComponentFactory.Modal.show(viewController: vc, title: nil)
    }

    func addPaymentMethodCardDidTap() {
        shouldChangePaymentMethod()
    }

    func didScroll(offset: CGPoint) {
        installmentInfoRow?.setSliderOffset(offset: offset)
    }

    func didEndDecelerating() {
        installmentInfoRow?.didEndDecelerating()
    }
}

// MARK: Installment Row Info delegate.
extension PXOneTapViewController: PXOneTapInstallmentInfoViewProtocol, PXOneTapInstallmentsSelectorProtocol {
    func payerCostSelected(_ payerCost: PXPayerCost) {
        // Update cardSliderViewModel
        if let infoRow = installmentInfoRow, viewModel.updateCardSliderViewModel(newPayerCost: payerCost, forIndex: infoRow.getActiveRowIndex()) {
            // Update selected payer cost.
            let currentPaymentData: PXPaymentData = viewModel.amountHelper.getPaymentData()
            currentPaymentData.payerCost = payerCost
            // Update installmentInfoRow viewModel
            installmentInfoRow?.model = viewModel.getInstallmentInfoViewModel()
            PXFeedbackGenerator.heavyImpactFeedback()
        }
        installmentInfoRow?.toggleInstallments()
    }

    func hideInstallments() {
        self.installmentsSelectorView?.layoutIfNeeded()
        self.installmentInfoRow?.disableTap()

        //Animations
        loadingButtonComponent?.show(duration: 0.1)

        let animationDuration = 0.5

        slider.show(duration: animationDuration)

        var pxAnimator = PXAnimator(duration: animationDuration, dampingRatio: 1)
        pxAnimator.addAnimation(animation: { [weak self] in
            self?.cardSliderMarginConstraint?.constant = 0
            self?.contentView.layoutIfNeeded()
        })

        self.installmentsSelectorView?.collapse(animator: pxAnimator, completion: {
            self.installmentInfoRow?.enableTap()
            self.installmentsSelectorView?.removeFromSuperview()
            self.installmentsSelectorView?.layoutIfNeeded()
        })
    }

    func showInstallments(installmentData: PXInstallment?, selectedPayerCost: PXPayerCost?) {
        guard let installmentData = installmentData, let installmentInfoRow = installmentInfoRow else {
            return
        }

        if let selectedCardItem = selectedCard {
            let properties = self.viewModel.getInstallmentsScreenProperties(installmentData: installmentData, selectedCard: selectedCardItem)
            trackScreen(path: TrackingPaths.Screens.OneTap.getOneTapInstallmentsPath(), properties: properties, treatAsViewController: false)
        }

        PXFeedbackGenerator.selectionFeedback()

        self.installmentsSelectorView?.removeFromSuperview()
        self.installmentsSelectorView?.layoutIfNeeded()
        let viewModel = PXOneTapInstallmentsSelectorViewModel(installmentData: installmentData, selectedPayerCost: selectedPayerCost)
        let installmentsSelectorView = PXOneTapInstallmentsSelectorView(viewModel: viewModel)
        installmentsSelectorView.delegate = self
        self.installmentsSelectorView = installmentsSelectorView

        contentView.addSubview(installmentsSelectorView)
        PXLayout.matchWidth(ofView: installmentsSelectorView).isActive = true
        PXLayout.centerHorizontally(view: installmentsSelectorView).isActive = true
        PXLayout.put(view: installmentsSelectorView, onBottomOf: installmentInfoRow).isActive = true
        let installmentsSelectorViewHeight = PXCardSliderSizeManager.getWhiteViewHeight(viewController: self) - PXOneTapInstallmentInfoView.DEFAULT_ROW_HEIGHT
        PXLayout.setHeight(owner: installmentsSelectorView, height: installmentsSelectorViewHeight).isActive = true

        installmentsSelectorView.layoutIfNeeded()
        self.installmentInfoRow?.disableTap()

        //Animations
        loadingButtonComponent?.hide(duration: 0.1)

        let animationDuration = 0.5
        slider.hide(duration: animationDuration)

        var pxAnimator = PXAnimator(duration: animationDuration, dampingRatio: 1)
        pxAnimator.addAnimation(animation: { [weak self] in
            self?.cardSliderMarginConstraint?.constant = installmentsSelectorViewHeight
            self?.contentView.layoutIfNeeded()
        })

        installmentsSelectorView.expand(animator: pxAnimator) {
            self.installmentInfoRow?.enableTap()
        }
        installmentsSelectorView.tableView.reloadData()
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
        loadingButtonComponent?.resetButton()
        loadingButtonComponent?.showErrorToast()
    }
}

// MARK: Notifications
extension PXOneTapViewController {
    func subscribeLoadingButtonToNotifications() {
        guard let loadingButton = loadingButtonComponent else {
            return
        }
        PXNotificationManager.SuscribeTo.animateButton(loadingButton, selector: #selector(loadingButton.animateFinish))
    }

    func unsubscribeFromNotifications() {
        PXNotificationManager.UnsuscribeTo.animateButton(loadingButtonComponent)
    }
}

// MARK: Terms and Conditions
extension PXOneTapViewController: PXTermsAndConditionViewDelegate {
    func shouldOpenTermsCondition(_ title: String, url: URL) {
        let webVC = WebViewController(url: url, navigationBarTitle: title)
        webVC.title = title
        self.navigationController?.pushViewController(webVC, animated: true)
    }
}
