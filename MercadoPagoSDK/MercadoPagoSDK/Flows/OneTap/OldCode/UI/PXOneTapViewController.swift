//
//  PXOneTapViewController.swift
//  MercadoPagoSDK
//
//  Created by Juan sebastian Sanzone on 15/5/18.
//  Copyright © 2018 MercadoPago. All rights reserved.
//

import UIKit
import MLCardForm
import MLUI
import AndesUI

final class PXOneTapViewController: PXComponentContainerViewController {
    // MARK: Definitions
    lazy var itemViews = [UIView]()
    fileprivate var viewModel: PXOneTapViewModel
    private var discountTermsConditionView: PXTermsAndConditionView?

    let slider = PXCardSlider()

    // MARK: Callbacks
    var callbackPaymentData: ((PXPaymentData) -> Void)
    var callbackConfirm: ((PXPaymentData, Bool) -> Void)
    var callbackUpdatePaymentOption: ((PaymentMethodOption) -> Void)
    var callbackRefreshInit: ((String) -> Void)
    var callbackExit: (() -> Void)
    var finishButtonAnimation: (() -> Void)

    var loadingButtonComponent: PXAnimatedButton?
    var installmentInfoRow: PXOneTapInstallmentInfoView?
    var installmentsSelectorView: PXOneTapInstallmentsSelectorView?
    var headerView: PXOneTapHeaderView?
    var whiteView: UIView?
    var selectedCard: PXCardSliderViewModel?

    var currentModal: MLModal?
    var shouldTrackModal: Bool = false
    var currentModalDismissTrackingProperties: [String: Any]?
    let timeOutPayButton: TimeInterval

    var shouldPromptForOfflineMethods = true
    var cardSliderMarginConstraint: NSLayoutConstraint?
    private var navigationBarTapGesture: UITapGestureRecognizer?
    var installmentRow = PXOneTapInstallmentInfoView()
    private var andesBottomSheet: AndesBottomSheetViewController?

    // MARK: Lifecycle/Publics
    init(viewModel: PXOneTapViewModel, timeOutPayButton: TimeInterval = 15, callbackPaymentData : @escaping ((PXPaymentData) -> Void), callbackConfirm: @escaping ((PXPaymentData, Bool) -> Void), callbackUpdatePaymentOption: @escaping ((PaymentMethodOption) -> Void), callbackRefreshInit: @escaping ((String) -> Void), callbackExit: @escaping (() -> Void), finishButtonAnimation: @escaping (() -> Void)) {
        self.viewModel = viewModel
        self.callbackPaymentData = callbackPaymentData
        self.callbackConfirm = callbackConfirm
        self.callbackRefreshInit = callbackRefreshInit
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
        isUIEnabled(true)
        addPulseViewNotifications()
        setLoadingButtonState()
    }

    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        unsubscribeFromNotifications()
        removePulseViewNotifications()
        removeNavigationTapGesture()
    }

    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        loadingButtonComponent?.resetButton()
    }

    override public func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        navigationController?.delegate = self
        slider.showBottomMessageIfNeeded(index: 0, targetIndex: 0)
        setupAutoDisplayOfflinePaymentMethods()
        UIAccessibility.post(notification: .layoutChanged, argument: headerView?.getMerchantView()?.getMerchantTitleLabel())
        trackScreen(event: MercadoPagoUITrackingEvents.reviewOneTap(viewModel.getOneTapScreenProperties(oneTapApplication: viewModel.applications)))
    }

    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        installmentRow.addChevronBackgroundViewGradient()
        headerView?.updateConstraintsIfNecessary()
    }

    @objc func willEnterForeground() {
        installmentRow.pulseView?.setupAnimations()
    }

    func update(viewModel: PXOneTapViewModel, cardId: String) {
        self.viewModel = viewModel

        viewModel.createCardSliderViewModel()
        let cardSliderViewModel = viewModel.getCardSliderViewModel()
        slider.update(cardSliderViewModel)
        installmentInfoRow?.update(model: viewModel.getInstallmentInfoViewModel())

        DispatchQueue.main.async {
            // Trick to wait for the slider to finish the update
            if let index = cardSliderViewModel.firstIndex(where: { $0.getCardId() == cardId }) {
                self.selectCardInSliderAtIndex(index)
            } else {
                //Select first item
                self.selectFirstCardInSlider()
            }
        }

        if let viewControllers = navigationController?.viewControllers {
            viewControllers.filter{ $0 is MLCardFormViewController || $0 is MLCardFormWebPayViewController }.forEach{
                ($0 as? MLCardFormViewController)?.dismissLoadingAndPop()
                ($0 as? MLCardFormWebPayViewController)?.dismissLoadingAndPop()
            }
        }
    }

    func setupAutoDisplayOfflinePaymentMethods() {
        if viewModel.shouldAutoDisplayOfflinePaymentMethods() && shouldPromptForOfflineMethods {
            shouldPromptForOfflineMethods = false
            shouldAddNewOfflineMethod()
        }
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
                viewModel.splitPaymentEnabled = preSelectedCard.getSelectedApplication()?.amountConfiguration?.splitConfiguration?.splitEnabled ?? false
                viewModel.amountHelper.getPaymentData().payerCost = preSelectedCard.getSelectedApplication()?.selectedPayerCost
            }
            renderViews()
        } else {
            installmentRow.pulseView?.setupAnimations()
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
        self.whiteView  = whiteView
        contentView.addSubviewToBottom(whiteView)
        PXLayout.setHeight(owner: whiteView, height: PXCardSliderSizeManager.getWhiteViewHeight(viewController: self)).isActive = true
        PXLayout.pinLeft(view: whiteView, withMargin: 0).isActive = true
        PXLayout.pinRight(view: whiteView, withMargin: 0).isActive = true

        // Add installment row
        installmentRow = getInstallmentInfoView()
        whiteView.addSubview(installmentRow)
        PXLayout.pinLeft(view: installmentRow).isActive = true
        PXLayout.pinRight(view: installmentRow).isActive = true
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
            PXLayout.pinLeft(view: footerView, withMargin: PXLayout.M_MARGIN).isActive = true
            PXLayout.pinRight(view: footerView, withMargin: PXLayout.M_MARGIN).isActive = true
            PXLayout.setHeight(owner: footerView, height: PXLayout.XXL_MARGIN).isActive = true
            let bottomMargin = getBottomPayButtonMargin()
            PXLayout.pinBottom(view: footerView, withMargin: bottomMargin).isActive = true
        }

        view.layoutIfNeeded()
        let installmentRowWidth: CGFloat = slider.getItemSize(cardSliderContentView).width
        installmentRow.render(installmentRowWidth, experiment: viewModel.experimentsViewModel.getExperiment(name: PXExperimentsViewModel.HIGHLIGHT_INSTALLMENTS))

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
        loadingButtonComponent?.add(for: .touchUpInside, { [weak self] in
            self?.handlePayButton()
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
        installmentInfoRow?.update(model: viewModel.getInstallmentInfoViewModel())
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

    private func setLoadingButtonState() {
        if let selectedCard = selectedCard, let selectedApplication = selectedCard.getSelectedApplication(), (selectedApplication.status.isDisabled() || selectedCard.getCardId() == nil) {
            loadingButtonComponent?.setDisabled(animated: false)
        }
    }
}

// MARK: User Actions.
extension PXOneTapViewController {
    @objc func didTapOnNavigationbar() {
        didTapMerchantHeader()
    }

    func shouldAddNewOfflineMethod() {
        if let offlineMethods = viewModel.getOfflineMethods() {
            let offlineViewModel = PXOfflineMethodsViewModel(offlinePaymentTypes: offlineMethods.paymentTypes, paymentMethods: viewModel.paymentMethods, amountHelper: viewModel.amountHelper, paymentOptionSelected: viewModel.paymentOptionSelected, advancedConfig: viewModel.advancedConfiguration, userLogged: viewModel.userLogged, disabledOption: viewModel.disabledOption, payerCompliance: viewModel.payerCompliance, displayInfo: offlineMethods.displayInfo)

            let vc = PXOfflineMethodsViewController(viewModel: offlineViewModel, callbackConfirm: callbackConfirm, callbackUpdatePaymentOption: callbackUpdatePaymentOption, finishButtonAnimation: finishButtonAnimation) { [weak self] in
                    self?.navigationController?.popViewController(animated: false)
            }

            let sheet = PXOfflineMethodsSheetViewController(viewController: vc,
                                                            offlineViewModel: offlineViewModel,
                                                            whiteViewHeight: PXCardSliderSizeManager.getWhiteViewHeight(viewController: self))

            self.present(sheet, animated: true, completion: nil)
        }
    }

    private func handleBehaviour(_ behaviour: PXBehaviour, isSplit: Bool) {
        if let target = behaviour.target {
            let properties = viewModel.getTargetBehaviourProperties(behaviour)
            trackEvent(event: OneTapTrackingEvents.didGetTargetBehaviour(properties))
            openKyCDeeplinkWithoutCallback(target)
        } else if let modal = behaviour.modal, let modalConfig = viewModel.modals?[modal] {
            let properties = viewModel.getDialogOpenProperties(behaviour, modalConfig)
            trackEvent(event: OneTapTrackingEvents.didOpenDialog(properties))

            let mainActionProperties = viewModel.getDialogActionProperties(behaviour, modalConfig, "main_action", modalConfig.mainButton)
            let secondaryActionProperties = viewModel.getDialogActionProperties(behaviour, modalConfig, "secondary_action", modalConfig.secondaryButton)
            let primaryAction = getActionForModal(modalConfig.mainButton, isSplit: isSplit, trackingPath: TrackingPaths.Events.OneTap.getDialogActionPath(), properties: mainActionProperties)
            let secondaryAction = getActionForModal(modalConfig.secondaryButton, isSplit: isSplit, trackingPath: TrackingPaths.Events.OneTap.getDialogActionPath(), properties: secondaryActionProperties)
            let vc = PXOneTapDisabledViewController(title: modalConfig.title, description: modalConfig.description, primaryButton: primaryAction, secondaryButton: secondaryAction, iconUrl: modalConfig.imageUrl)
            shouldTrackModal = true
            currentModalDismissTrackingProperties = viewModel.getDialogDismissProperties(behaviour, modalConfig)
            currentModal = PXComponentFactory.Modal.show(viewController: vc, title: nil, dismissBlock: { [weak self] in
                guard let self = self else { return }
                self.trackDialogEvent(trackingPath: TrackingPaths.Events.OneTap.getDialogDismissPath(), properties: self.currentModalDismissTrackingProperties)
            })
        }
    }

    func trackDialogEvent(trackingPath: String?, properties: [String: Any]?) {
        if shouldTrackModal, let _ = trackingPath, let properties = properties {
            shouldTrackModal = false
            trackEvent(event: OneTapTrackingEvents.didDismissDialog(properties))
        }
    }

    private func getActionForModal(_ action: PXRemoteAction? = nil, isSplit: Bool = false, trackingPath: String? = nil, properties: [String: Any]? = nil) -> PXAction? {
        let nonSplitDefaultAction: () -> Void = { [weak self] in
            guard let self = self else { return }
            self.currentModal?.dismiss()
            self.selectFirstCardInSlider()
            self.trackDialogEvent(trackingPath: trackingPath, properties: properties)
        }
        let splitDefaultAction: () -> Void = { [weak self] in
            guard let self = self else { return }
            self.currentModal?.dismiss()
        }

        guard let action = action else {
            return nil
        }

        guard let target = action.target else {
            let defaultAction = isSplit ? splitDefaultAction : nonSplitDefaultAction
            return PXAction(label: action.label, action: defaultAction)
        }

        return PXAction(label: action.label, action: { [weak self] in
            guard let self = self else { return }
            self.currentModal?.dismiss()
            self.openKyCDeeplinkWithoutCallback(target)
            self.trackDialogEvent(trackingPath: trackingPath, properties: properties)
        })
    }

    private func handlePayButton() {
        if let selectedCard = getSuspendedCardSliderViewModel(), let selectedApplication = selectedCard.getSelectedApplication() {
            if let tapPayBehaviour = selectedApplication.behaviours?[PXBehaviour.Behaviours.tapPay.rawValue] {
                handleBehaviour(tapPayBehaviour, isSplit: false)
            }
        } else {
            confirmPayment()
        }
    }

    private func getSuspendedCardSliderViewModel() -> PXCardSliderViewModel? {
        if let selectedCard = selectedCard, let selectedApplication = selectedCard.getSelectedApplication(), selectedApplication.status.detail == "suspended" {
            return selectedCard
        }
        return nil
    }

    private func confirmPayment() {
        isUIEnabled(false)
        if viewModel.shouldValidateWithBiometric() {
            viewModel.validateWithBiometric(onSuccess: { [weak self] in
                DispatchQueue.main.async {
                    self?.doPayment()
                }
            }, onError: { [weak self] _ in
                // User abort validation or validation fail.
                self?.isUIEnabled(true)
                self?.trackEvent(event: GeneralErrorTrackingEvents.error([:]))
            })
        } else {
            doPayment()
        }
    }

    private func doPayment() {
        subscribeLoadingButtonToNotifications()
        loadingButtonComponent?.startLoading(timeOut: timeOutPayButton)
        if let selectedCardItem = selectedCard, let selectedApplication = selectedCardItem.getSelectedApplication() {
            viewModel.amountHelper.getPaymentData().payerCost = selectedApplication.selectedPayerCost
            let properties = viewModel.getConfirmEventProperties(selectedCard: selectedCardItem, selectedIndex: slider.getSelectedIndex())
            trackEvent(event: OneTapTrackingEvents.didConfirmPayment(properties))
        }
        let splitPayment = viewModel.splitPaymentEnabled
        hideBackButton()
        hideNavBar()
        callbackConfirm(viewModel.amountHelper.getPaymentData(), splitPayment)
    }

    func isUIEnabled(_ enabled: Bool) {
        view.isUserInteractionEnabled = enabled
        loadingButtonComponent?.isUserInteractionEnabled = enabled
    }

    func resetButton(error: MPSDKError) {
        progressButtonAnimationTimeOut()
        trackEvent(event: GeneralErrorTrackingEvents.error(viewModel.getErrorProperties(error: error)))
    }

    private func cancelPayment() {
        self.callbackExit()
    }

    private func openKyCDeeplinkWithoutCallback(_ target: String) {
        let index = target.firstIndex(of: "&")
        if let index = index {
            let deepLink = String(target[..<index])
            PXDeepLinkManager.open(deepLink)
        }
    }
}

// MARK: Summary delegate.
extension PXOneTapViewController: PXOneTapHeaderProtocol {

    func splitPaymentSwitchChangedValue(isOn: Bool, isUserSelection: Bool) {
        if isUserSelection, let selectedCard = getSuspendedCardSliderViewModel(), let selectedApplication = selectedCard.getSelectedApplication(), let splitConfiguration = selectedApplication.amountConfiguration?.splitConfiguration, let switchSplitBehaviour = selectedApplication.behaviours?[PXBehaviour.Behaviours.switchSplit.rawValue] {
            handleBehaviour(switchSplitBehaviour, isSplit: true)
            splitConfiguration.splitEnabled = false
            headerView?.updateSplitPaymentView(splitConfiguration: splitConfiguration)
            return
        }

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
        installmentInfoRow?.update(model: viewModel.getInstallmentInfoViewModel())

        if let infoRow = installmentInfoRow, viewModel.getCardSliderViewModel().indices.contains(infoRow.getActiveRowIndex()) {
            let selectedCard = viewModel.getCardSliderViewModel()[infoRow.getActiveRowIndex()]
            
            guard let selectedApplication = selectedCard.getSelectedApplication() else { return }

            // If it's debit and has split, update split message
            if selectedApplication.paymentTypeId == PXPaymentTypes.DEBIT_CARD.rawValue {
                selectedApplication.displayMessage = viewModel.getSplitMessageForDebit(amountToPay: selectedApplication.selectedPayerCost?.totalAmount ?? 0)
            }

            // Installments arrow animation
            if selectedApplication.shouldShowArrow {
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
            let defaultTitle = "Cargos".localized
            let title = vc.title ?? defaultTitle
            PXComponentFactory.Modal.show(viewController: vc, title: title) { [weak self] in
                if UIDevice.isSmallDevice() {
                    self?.setupNavigationBar()
                }
            }
        }
    }

    func didTapDiscount() {
        var discountDescription: PXDiscountDescription?
        
        guard let selectedApplication = selectedCard?.getSelectedApplication() else { return }
        
        if let discountConfiguration = viewModel.amountHelper.paymentConfigurationService.getDiscountConfigurationForPaymentMethodOrDefault(paymentOptionID: selectedCard?.getCardId(), paymentMethodId: selectedApplication.paymentMethodId, paymentTypeId: selectedApplication.paymentTypeId),
            let description = discountConfiguration.getDiscountConfiguration().discountDescription {
            discountDescription = description
        }

        if let discountDescription = discountDescription {
            let discountViewController = PXDiscountDetailViewController(amountHelper: viewModel.amountHelper, discountDescription: PXDiscountDescriptionViewModel(discountDescription))
            if viewModel.amountHelper.discount != nil {
                PXComponentFactory.Modal.show(viewController: discountViewController, title: nil) {
                self.setupNavigationBar()
                }
            }
        }
    }
}

// MARK: CardSlider delegate.
extension PXOneTapViewController: PXCardSliderProtocol {

    func newCardDidSelected(targetModel: PXCardSliderViewModel) {
        
        guard let selectedApplication = targetModel.getSelectedApplication() else { return }

        selectedCard = targetModel

        trackEvent(event: OneTapTrackingEvents.didSwipe)

        // Installments arrow animation
        if selectedApplication.shouldShowArrow {
            installmentInfoRow?.showArrow()
        } else {
            installmentInfoRow?.hideArrow()
        }
        
        // Update installment info row
        installmentInfoRow?.update(model: viewModel.getInstallmentInfoViewModel())

        // Add card. - card o credits payment method selected
        let validData = selectedApplication.cardData != nil || targetModel.isCredits
        let shouldDisplay = validData && !selectedApplication.status.isDisabled()
        if shouldDisplay {
            displayCard(targetModel: targetModel)
            loadingButtonComponent?.setEnabled()
        } else {
            displayCard(targetModel: targetModel)
            loadingButtonComponent?.setDisabled()
            headerView?.updateModel(viewModel.getHeaderViewModel(selectedCard: nil))
        }
    }

    func displayCard(targetModel: PXCardSliderViewModel) {
        
        guard let selectedApplication = targetModel.getSelectedApplication() else { return }
        
        // New payment method selected.
        let newPaymentMethodId: String = selectedApplication.payerPaymentMethod?.paymentMethodId ?? selectedApplication.paymentMethodId
        let newPayerCost: PXPayerCost? = selectedApplication.selectedPayerCost

        let currentPaymentData: PXPaymentData = viewModel.amountHelper.getPaymentData()
        
        if let newPaymentMethod = viewModel.getPaymentMethod(paymentMethodId: newPaymentMethodId) {
            currentPaymentData.payerCost = newPayerCost
            currentPaymentData.paymentMethod = newPaymentMethod
            currentPaymentData.issuer = selectedApplication.payerPaymentMethod?.issuer ?? PXIssuer(id: targetModel.getIssuerId(), name: nil)
            callbackUpdatePaymentOption(targetModel)
            loadingButtonComponent?.setEnabled()
        } else {
            currentPaymentData.payerCost = nil
            currentPaymentData.paymentMethod = nil
            currentPaymentData.issuer = nil
            loadingButtonComponent?.setDisabled()
        }
        headerView?.updateModel(viewModel.getHeaderViewModel(selectedCard: selectedCard))

        headerView?.updateSplitPaymentView(splitConfiguration: selectedApplication.amountConfiguration?.splitConfiguration)
        
        let paymentTypeId = selectedApplication.payerPaymentMethod?.paymentTypeId ?? selectedApplication.paymentTypeId

        // If it's debit and has split, update split message
        if let totalAmount = selectedApplication.selectedPayerCost?.totalAmount, paymentTypeId == PXPaymentTypes.DEBIT_CARD.rawValue {
            selectedApplication.displayMessage = viewModel.getSplitMessageForDebit(amountToPay: totalAmount)
        }
    }

    func selectFirstCardInSlider() {
        selectCardInSliderAtIndex(0)
    }

    func selectCardInSliderAtIndex(_ index: Int) {
        let cardSliderViewModel = viewModel.getCardSliderViewModel()
        if (0 ... cardSliderViewModel.count - 1).contains(index) {
            do {
                try slider.goToItemAt(index: index, animated: false)
            } catch {
                // We shouldn't reach this line. Track friction
                let properties = viewModel.getSelectCardEventProperties(index: index, count: cardSliderViewModel.count)
                trackEvent(event: GeneralErrorTrackingEvents.error(properties))
                selectFirstCardInSlider()
                return
            }
            let card = cardSliderViewModel[index]
            newCardDidSelected(targetModel: card)
        }
    }

    func cardDidTap(status: PXStatus) {
        if status.isDisabled() {
            showDisabledCardModal(status: status)
        } else if let selectedCard = selectedCard, let selectedApplication = selectedCard.getSelectedApplication(), let tapCardBehaviour = selectedApplication.behaviours?[PXBehaviour.Behaviours.tapCard.rawValue] {
            handleBehaviour(tapCardBehaviour, isSplit: false)
        }
    }

    func showDisabledCardModal(status: PXStatus) {

        guard let message = status.secondaryMessage else {return}

        let primaryAction = getActionForModal()
        let vc = PXOneTapDisabledViewController(title: nil, description: message, primaryButton: primaryAction, secondaryButton: nil, iconUrl: nil)

        self.currentModal = PXComponentFactory.Modal.show(viewController: vc, title: nil)

        trackScreen(event: MercadoPagoUITrackingEvents.disabledPaymentMethods)
    }

    internal func addNewCardDidTap() {
        if viewModel.shouldUseOldCardForm() {
            callbackPaymentData(viewModel.getClearPaymentData())
        } else {
            if let newCard = viewModel.expressData?.compactMap({ $0.newCard }).first {
                if newCard.sheetOptions != nil {
                    // Present sheet to pick standard card form or webpay
                    let sheet = buildBottomSheet(newCard: newCard)
                    present(sheet, animated: true, completion: nil)
                } else {
                    // Add new card using card form based on init type
                    // There might be cases when there's a different option besides standard type
                    // Eg: Money In for Chile should use only debit, therefor init type shuld be webpay_tbk
                    addNewCard(initType: newCard.cardFormInitType)
                }
            } else {
                // This is a fallback. There should be always a newCard in expressData
                // Add new card using standard card form
                addNewCard()
            }
        }
    }

    private func buildBottomSheet(newCard: PXOneTapNewCardDto) -> AndesBottomSheetViewController {
        if let andesBottomSheet = andesBottomSheet {
            return andesBottomSheet
        }
        let viewController = PXOneTapSheetViewController(newCard: newCard)
        viewController.delegate = self
        let sheet = AndesBottomSheetViewController(rootViewController: viewController)
        sheet.titleBar.text = newCard.label.message
        sheet.titleBar.textAlignment = .center
        andesBottomSheet = sheet
        return sheet
    }

    private func addNewCard(initType: String? = "standard") {
        let siteId = viewModel.siteId
        let flowId = MPXTracker.sharedInstance.getFlowName() ?? "unknown"
        let builder: MLCardFormBuilder

        if let privateKey = viewModel.privateKey {
            builder = MLCardFormBuilder(privateKey: privateKey, siteId: siteId, flowId: flowId, lifeCycleDelegate: self)
        } else {
            builder = MLCardFormBuilder(publicKey: viewModel.publicKey, siteId: siteId, flowId: flowId, lifeCycleDelegate: self)
        }

        builder.setLanguage(Localizator.sharedInstance.getLanguage())
        builder.setExcludedPaymentTypes(viewModel.excludedPaymentTypeIds)
        builder.setNavigationBarCustomColor(backgroundColor: ThemeManager.shared.navigationBar().backgroundColor, textColor: ThemeManager.shared.navigationBar().tintColor)
        var cardFormVC: UIViewController
        switch initType {
        case "webpay_tbk":
            cardFormVC = MLCardForm(builder: builder).setupWebPayController()
        default:
            builder.setAnimated(true)
            cardFormVC = MLCardForm(builder: builder).setupController()
        }
        navigationController?.pushViewController(cardFormVC, animated: true)
    }

    func addNewOfflineDidTap() {
        shouldAddNewOfflineMethod()
    }

    func didScroll(offset: CGPoint) {
        installmentInfoRow?.setSliderOffset(offset: offset)
    }

    func didEndDecelerating() {
        installmentInfoRow?.didEndDecelerating()
    }

    func didEndScrollAnimation() {
        installmentInfoRow?.didEndScrollAnimation()
    }
}

extension PXOneTapViewController: PXOneTapSheetViewControllerProtocol {
    func didTapOneTapSheetOption(sheetOption: PXOneTapSheetOptionsDto) {
        andesBottomSheet?.dismiss(animated: true, completion: { [weak self] in
            self?.addNewCard(initType: sheetOption.cardFormInitType)
        })
    }
}

// MARK: Installment Row Info delegate.
extension PXOneTapViewController: PXOneTapInstallmentInfoViewProtocol, PXOneTapInstallmentsSelectorProtocol {
    func cardTapped(status: PXStatus) {
      cardDidTap(status: status)
    }

    func payerCostSelected(_ payerCost: PXPayerCost) {
        let selectedIndex = slider.getSelectedIndex()
        // Update cardSliderViewModel
        if let infoRow = installmentInfoRow, viewModel.updateCardSliderViewModel(newPayerCost: payerCost, forIndex: infoRow.getActiveRowIndex()) {
            // Update selected payer cost.
            let currentPaymentData: PXPaymentData = viewModel.amountHelper.getPaymentData()
            currentPaymentData.payerCost = payerCost
            // Update installmentInfoRow viewModel
            installmentInfoRow?.update(model: viewModel.getInstallmentInfoViewModel())
            PXFeedbackGenerator.heavyImpactFeedback()

            //Update card bottom message
            let bottomMessage = viewModel.getCardBottomMessage(paymentTypeId: selectedCard?.getSelectedApplication()?.paymentTypeId, benefits: selectedCard?.getSelectedApplication()?.benefits, status: selectedCard?.getSelectedApplication()?.status, selectedPayerCost: payerCost, displayInfo: selectedCard?.getDisplayInfo())
            viewModel.updateCardSliderModel(at: selectedIndex, bottomMessage: bottomMessage)
            slider.update(viewModel.getCardSliderViewModel())
        }
        installmentInfoRow?.toggleInstallments(completion: { [weak self] (_) in
            self?.slider.showBottomMessageIfNeeded(index: selectedIndex, targetIndex: selectedIndex)
        })
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

        self.installmentsSelectorView?.collapse(animator: pxAnimator, completion: { [weak self] in
            guard let self = self else { return }
            self.installmentInfoRow?.enableTap()
            self.installmentsSelectorView?.removeFromSuperview()
            self.installmentsSelectorView?.layoutIfNeeded()
        })
    }

    func showInstallments(installmentData: PXInstallment?, selectedPayerCost: PXPayerCost?, interest: PXInstallmentsConfiguration?, reimbursement: PXInstallmentsConfiguration?) {
        guard let installmentData = installmentData, let installmentInfoRow = installmentInfoRow else {
            return
        }

        if let selectedCardItem = selectedCard {
            let properties = self.viewModel.getInstallmentsScreenProperties(installmentData: installmentData, selectedCard: selectedCardItem)
            trackScreen(event: MercadoPagoUITrackingEvents.installments(properties), treatAsViewController: false)
        }

        PXFeedbackGenerator.selectionFeedback()

        installmentRow.removePulseView()

        self.installmentsSelectorView?.removeFromSuperview()
        self.installmentsSelectorView?.layoutIfNeeded()
        let viewModel = PXOneTapInstallmentsSelectorViewModel(installmentData: installmentData, selectedPayerCost: selectedPayerCost, interest: interest, reimbursement: reimbursement)
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
        isUIEnabled(true)
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
        loadingButtonComponent?.showErrorToast(title: "review_and_confirm_toast_error".localized, actionTitle: nil, type: MLSnackbarType.error(), duration: .short, action: nil)
    }
}

// MARK: Notifications
private extension PXOneTapViewController {
    func subscribeLoadingButtonToNotifications() {
        guard let loadingButton = loadingButtonComponent else {
            return
        }
        PXNotificationManager.SuscribeTo.animateButton(loadingButton, selector: #selector(loadingButton.animateFinish))
    }

    func unsubscribeFromNotifications() {
        PXNotificationManager.UnsuscribeTo.animateButton(loadingButtonComponent)
    }

    func addPulseViewNotifications() {
        NotificationCenter.default.addObserver(self, selector: #selector(willEnterForeground), name: UIApplication.willEnterForegroundNotification, object: nil)
    }

    func removePulseViewNotifications() {
        NotificationCenter.default.removeObserver(self)
    }
}

// MARK: Terms and Conditions
extension PXOneTapViewController: PXTermsAndConditionViewDelegate {
    func shouldOpenTermsCondition(_ title: String, url: URL) {
        let webVC = WebViewController(url: url, navigationBarTitle: title)
        webVC.title = title
        navigationController?.pushViewController(webVC, animated: true)
    }
}

extension PXOneTapViewController: MLCardFormLifeCycleDelegate {
    func didAddCard(cardID: String) {
        callbackRefreshInit(cardID)
    }

    func didFailAddCard() {
    }
}
