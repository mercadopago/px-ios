//
//  PXSecurityCodeViewController.swift
//  MercadoPagoSDK
//
//  Created by Esteban Adrian Boffa on 04/08/2020.
//

import Foundation
import MLUI
import MLCardDrawer
import AndesUI

final class PXSecurityCodeViewController: MercadoPagoUIViewController {

    let viewModel: PXSecurityCodeViewModel
    let cardContainerView = UIView()
    let titleLabel = UILabel()
    let subtitleLabel = UILabel()
    var loadingButtonComponent: PXAnimatedButton?
    var cardDrawer: MLCardDrawerController?
    var attemptsWithInternetError: Int = 0
    var andesTextFieldCode = AndesTextFieldCode()
    var andesTextFieldCodeIsComplete = false

    // MARK: Constraints
    var loadingButtonBottomConstraint = NSLayoutConstraint()
    var titleLabelTopConstraint = NSLayoutConstraint()
    var subtitleTopConstraint = NSLayoutConstraint()
    var textFieldContainerTopConstraint = NSLayoutConstraint()
    var textFieldContainerBottomConstraint = NSLayoutConstraint()
    var andesTextFieldCodeCenterYConstraint = NSLayoutConstraint()

    // MARK: Callbacks
    let finishButtonAnimationCallback: () -> Void
    let collectSecurityCodeCallback: (PXCardInformationForm, String?) -> Void

    init(viewModel: PXSecurityCodeViewModel, finishButtonAnimationCallback: @escaping () -> Void, collectSecurityCodeCallback: @escaping (PXCardInformationForm, String?) -> Void) {
        self.viewModel = viewModel
        self.finishButtonAnimationCallback = finishButtonAnimationCallback
        self.collectSecurityCodeCallback = collectSecurityCodeCallback
        super.init(nibName: nil, bundle: nil)
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        trackScreenView()
        setNavBarBackgroundColor(color: .white)
        setNavBarTextColor(color: .black)
        renderViews()
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        setupKeyboardNotifications()
        setupNavBarStyle(style: .default)
    }

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        setupAnimations()
    }

    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        removeKeyboardNotifications()
        loadingButtonComponent?.dismissSnackbar()
        setupNavBarStyle(style: ThemeManager.shared.navigationControllerMemento?.navBarStyle ?? .black)
    }
}

// MARK: Privates
private extension PXSecurityCodeViewController {
    func confirmPayment() {
        trackEvent(event: PXSecurityCodeTrackingEvents.didConfirmCode(viewModel.getScreenProperties()))
        doPayment()
    }

    func doPayment() {
        if viewModel.internetProtocol?.hasInternetConnection() ?? true {
            enableUI(false)
            andesTextFieldCode.setFocus()
            subscribeLoadingButtonToNotifications()
            loadingButtonComponent?.startLoading(timeOut: 15)
            collectSecurityCodeCallback(viewModel.cardInfo, andesTextFieldCode.text)
        } else {
            trackEvent(event: GeneralErrorTrackingEvents.error(viewModel.getNoConnectionProperties()))
            attemptsWithInternetError += 1
            if attemptsWithInternetError < 4 {
                loadingButtonComponent?.showErrorToast(title: "px_connectivity_neutral_error".localized, actionTitle: nil, type: MLSnackbarType.default(), duration: MLSnackbarDuration.short, action: nil)
            } else {
                progressButtonAnimationTimeOut()
            }
        }
    }

    func subscribeLoadingButtonToNotifications() {
        guard let loadingButton = loadingButtonComponent else { return }
        PXNotificationManager.SuscribeTo.animateButton(loadingButton, selector: #selector(loadingButton.animateFinish))
    }

    func enableUI(_ enabled: Bool) {
        view.isUserInteractionEnabled = enabled
        navigationController?.navigationBar.isUserInteractionEnabled = enabled
        if enabled, andesTextFieldCodeIsComplete {
            andesTextFieldCode.state = .IDLE
            loadingButtonComponent?.isUserInteractionEnabled = true
        } else {
            andesTextFieldCode.state = .DISABLED
            loadingButtonComponent?.isUserInteractionEnabled = false
        }
    }

    func unsubscribeFromNotifications() {
        PXNotificationManager.UnsuscribeTo.animateButton(loadingButtonComponent)
    }
}

// MARK: PXAnimatedButtonDelegate
extension PXSecurityCodeViewController: PXAnimatedButtonDelegate {
    func shakeDidFinish() {
        displayBackButton()
        enableUI(true)
        unsubscribeFromNotifications()
        UIView.animate(withDuration: 0.3, animations: {
            self.loadingButtonComponent?.backgroundColor = self.andesTextFieldCodeIsComplete ? ThemeManager.shared.getAccentColor() : ThemeManager.shared.greyColor()
        })
    }

    func expandAnimationInProgress() {
        andesTextFieldCode.removeFocus()
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.2) { [weak self] in
            self?.hideNavBar()
        }
    }

    func didFinishAnimation() {
        finishButtonAnimationCallback()
    }

    func progressButtonAnimationTimeOut() {
        loadingButtonComponent?.resetButton()
        loadingButtonComponent?.showErrorToast(title: "px_connectivity_error".localized, actionTitle: "px_snackbar_error_action".localized, type: MLSnackbarType.error(), duration: MLSnackbarDuration.long) { [weak self] in
            guard let self = self else { return }
            self.trackAbortEvent(properties: self.viewModel.getScreenProperties())
            self.navigationController?.popViewController(animated: false)
        }
        enableUI(true)
    }

    func resetButton() {
        progressButtonAnimationTimeOut()
    }
}

// MARK: Keyboard Notifications
private extension PXSecurityCodeViewController {
    func setupKeyboardNotifications() {
        let notificationCenter = NotificationCenter.default
        notificationCenter.addObserver(self, selector: #selector(keyboardDidChange), name: UIResponder.keyboardWillHideNotification, object: nil)
        notificationCenter.addObserver(self, selector: #selector(keyboardDidChange), name: UIResponder.keyboardWillChangeFrameNotification, object: nil)
    }

    func removeKeyboardNotifications() {
        NotificationCenter.default.removeObserver(self)
    }

    @objc func keyboardDidChange(notification: Notification) {
        if let userInfo = notification.userInfo, let keyboardScreenEndFrame = (userInfo[UIResponder.keyboardFrameEndUserInfoKey] as? NSValue)?.cgRectValue {
            let keyboardViewEndFrame = view.convert(keyboardScreenEndFrame, from: view.window)

            var animator = PXAnimator(duration: 0.8, dampingRatio: 0.8)
            animator.addAnimation(animation: { [weak self] in
                guard let self = self else { return }
                self.loadingButtonComponent?.alpha = 1
                self.loadingButtonBottomConstraint.constant = -keyboardViewEndFrame.height - PXLayout.S_MARGIN
            })
            animator.animate()
        }
    }
}

// MARK: UI
private extension PXSecurityCodeViewController {
    func setupNavBarStyle(style: UIBarStyle) {
        navigationController?.navigationBar.barStyle = style
    }

    func renderViews() {
        setupView()
        setupTitle()
        viewModel.shouldShowCard() ? setupCardContainerView() : setupSubtitle()
        setupAndesTextFieldCode()
        setupLoadingButton()
        setupTextFieldAndButtonConstraints()
    }

    func setupView() {
        view.backgroundColor = .white
    }

    func setupTitle() {
        titleLabel.translatesAutoresizingMaskIntoConstraints = false
        titleLabel.backgroundColor = .white
        titleLabel.text = viewModel.getTitle()
        titleLabel.textAlignment = .left
        titleLabel.font = UIFont.ml_semiboldSystemFont(ofSize: PXLayout.XL_FONT)
        titleLabel.numberOfLines = 2
        titleLabel.textColor = UIColor.black.withAlphaComponent(0.8)
        titleLabel.alpha = 0
        // zPosition is set to 1 because in the wallet the title in the animation moves behind the navBar, making the title to appear, then it disappears when it moves behind the navBar and finally appears again below the navBar. zPosition is set to 0 again in animation completion
        titleLabel.layer.zPosition = 1
        view.addSubview(titleLabel)

        titleLabelTopConstraint = titleLabel.topAnchor.constraint(equalTo: view.topAnchor, constant: -300)
        NSLayoutConstraint.activate([
            titleLabel.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: PXLayout.SM_MARGIN),
            titleLabel.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -PXLayout.SM_MARGIN),
            titleLabelTopConstraint
        ])
    }

    func setupSubtitle() {
        subtitleLabel.translatesAutoresizingMaskIntoConstraints = false
        subtitleLabel.text = viewModel.getSubtitle()
        subtitleLabel.textAlignment = .left
        subtitleLabel.font = UIFont.ml_regularSystemFont(ofSize: PXLayout.XS_FONT)
        subtitleLabel.numberOfLines = 2
        subtitleLabel.textColor = UIColor.black.withAlphaComponent(0.8)
        subtitleLabel.alpha = 1
        view.insertSubview(subtitleLabel, belowSubview: titleLabel)

        subtitleTopConstraint = subtitleLabel.topAnchor.constraint(equalTo: titleLabel.bottomAnchor, constant: -300)
        NSLayoutConstraint.activate([
            subtitleLabel.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: PXLayout.SM_MARGIN),
            subtitleLabel.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -PXLayout.SM_MARGIN),
            subtitleTopConstraint
        ])
    }

    func getVerticalCardSpace() -> CGFloat {
        let cardHeight = CardSizeManager.getHeightByGoldenAspectRatio(width: view.frame.size.width - 60)
        let scaledCardHeight = cardHeight * 0.6
        let verticalCardSpace = (cardHeight - scaledCardHeight) / 2
        return verticalCardSpace
    }

    func setupCardContainerView() {
        cardContainerView.translatesAutoresizingMaskIntoConstraints = false
        cardContainerView.alpha = 0
        cardContainerView.layer.cornerRadius = 9
        cardContainerView.clipsToBounds = true
        cardContainerView.backgroundColor = .clear
        view.addSubview(cardContainerView)
        NSLayoutConstraint.activate([
            cardContainerView.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 30),
            cardContainerView.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -30),
            cardContainerView.heightAnchor.constraint(equalTo: cardContainerView.widthAnchor, multiplier: PXCardSliderSizeManager.goldenRatio),
            cardContainerView.topAnchor.constraint(equalTo: view.topAnchor, constant: (titleLabel.intrinsicContentSize.height + PXLayout.L_MARGIN) - getVerticalCardSpace())
        ])
        cardDrawer = MLCardDrawerController(viewModel.cardUI, viewModel.cardData)
        cardDrawer?.setUp(inView: cardContainerView)
        cardDrawer?.show()
        cardContainerView.transform = CGAffineTransform.identity.scaledBy(x: 0.6, y: 0.6)
    }

    func setupAndesTextFieldCode() {
        andesTextFieldCode = AndesTextFieldCode(label: viewModel.getAndesTextFieldCodeLabel(), helpLabel: nil, style: viewModel.getAndesTextFieldCodeStyle(), state: .IDLE)
        andesTextFieldCode.delegate = self
        andesTextFieldCode.alpha = 0
        view.addSubview(andesTextFieldCode)
    }

    func setupLoadingButton() {
        loadingButtonComponent = PXAnimatedButton(normalText: "Pagar".localized, loadingText: "Procesando tu pago".localized, retryText: "Reintentar".localized)
        loadingButtonComponent?.translatesAutoresizingMaskIntoConstraints = false
        loadingButtonComponent?.animationDelegate = self
        loadingButtonComponent?.layer.cornerRadius = 4
        loadingButtonComponent?.add(for: .touchUpInside, { [weak self] in
            self?.confirmPayment()
        })
        loadingButtonComponent?.setTitle("Pagar".localized, for: .normal)
        loadingButtonComponent?.backgroundColor = ThemeManager.shared.getAccentColor()
        loadingButtonComponent?.accessibilityIdentifier = "pay_button"
        if let loadingButtonComponent = loadingButtonComponent {
            view.addSubview(loadingButtonComponent)
        }
        loadingButtonComponent?.setDisabled()
        loadingButtonComponent?.alpha = 0
    }

    func setupTextFieldAndButtonConstraints() {
        // Build container and constraints
        let container = UILayoutGuide()
        container.identifier = "containerLayoutGuide"
        view.addLayoutGuide(container)

        textFieldContainerTopConstraint = container.topAnchor.constraint(equalTo: viewModel.shouldShowCard() ? cardContainerView.bottomAnchor : subtitleLabel.bottomAnchor, constant: 300)
        textFieldContainerBottomConstraint = container.bottomAnchor.constraint(equalTo: loadingButtonComponent?.topAnchor ?? view.bottomAnchor, constant: 300)
        andesTextFieldCodeCenterYConstraint = andesTextFieldCode.centerYAnchor.constraint(equalTo: container.centerYAnchor, constant: -100)

        NSLayoutConstraint.activate([
            container.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            container.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            textFieldContainerTopConstraint,
            textFieldContainerBottomConstraint,
            andesTextFieldCode.centerXAnchor.constraint(equalTo: container.centerXAnchor),
            andesTextFieldCodeCenterYConstraint
        ])

        if let loadingButtonComponent = loadingButtonComponent {
            loadingButtonBottomConstraint = loadingButtonComponent.bottomAnchor.constraint(equalTo: view.bottomAnchor, constant: -PXLayout.S_MARGIN)
            NSLayoutConstraint.activate([
                loadingButtonComponent.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: PXLayout.M_MARGIN),
                loadingButtonComponent.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -PXLayout.M_MARGIN),
                loadingButtonComponent.heightAnchor.constraint(equalToConstant: 48),
                loadingButtonBottomConstraint
            ])
        }
    }

    func setupAnimations() {
        view.layoutIfNeeded()
        andesTextFieldCode.setFocus()
        if viewModel.shouldShowCard() {
            cardContainerView.alpha = 1
            cardDrawer?.showSecurityCode()
        }
        var animator = PXAnimator(duration: 0.8, dampingRatio: 0.8)
        animator.addAnimation(animation: { [weak self] in
            guard let self = self else { return }
            self.titleLabelTopConstraint.constant = 0
            self.titleLabel.alpha = 1
            self.view.layoutIfNeeded()
        })
        animator.addCompletion {
            var animator = PXAnimator(duration: 0.8, dampingRatio: 0.8)
            animator.addAnimation(animation: { [weak self] in
                guard let self = self else { return }
                self.titleLabel.layer.zPosition = 0
                self.subtitleTopConstraint.constant = PXLayout.XXS_MARGIN
                self.subtitleLabel.alpha = 1
                self.textFieldContainerTopConstraint.constant = self.viewModel.shouldShowCard() ? -self.getVerticalCardSpace() : 0
                self.andesTextFieldCode.alpha = 1
                self.textFieldContainerBottomConstraint.constant = 0
                self.andesTextFieldCodeCenterYConstraint.constant = 0
                self.view.layoutIfNeeded()
            })
            animator.animate()
        }
        animator.animate()
    }
}

// MARK: Publics
extension PXSecurityCodeViewController {
    func getStatusAndNavBarHeight() -> CGFloat {
        return UIApplication.shared.statusBarFrame.size.height + (navigationController?.navigationBar.frame.height ?? 0.0)
    }
}

// MARK: AndesTextFieldCodeDelegate
extension PXSecurityCodeViewController: AndesTextFieldCodeDelegate {
    func textDidChange(_ text: String) {
        viewModel.cardData.securityCode = text
        cardDrawer = MLCardDrawerController(viewModel.cardUI, viewModel.cardData)
    }

    func textDidComplete(_ isComplete: Bool) {
        andesTextFieldCodeIsComplete = isComplete
        isComplete ? loadingButtonComponent?.setEnabled() : loadingButtonComponent?.setDisabled()
    }
}

// MARK: Tracking
private extension PXSecurityCodeViewController {
    func trackScreenView() {
        let screenPath = TrackingPaths.Screens.getSecurityCodePath(paymentTypeId: viewModel.paymentMethod.paymentTypeId)
        trackScreen(path: screenPath, properties: viewModel.getScreenProperties(), treatBackAsAbort: true)
    }
}
