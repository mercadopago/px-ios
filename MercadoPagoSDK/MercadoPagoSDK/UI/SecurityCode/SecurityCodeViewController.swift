//
//  SecrurityCodeViewController.swift
//  MercadoPagoSDK
//
//  Created by Demian Tejo on 11/3/16.
//  Copyright © 2016 MercadoPago. All rights reserved.
//
import UIKit

internal class SecurityCodeViewController: MercadoPagoUIViewController, UITextFieldDelegate {

    @IBOutlet weak var keyboardHeightConstraint: NSLayoutConstraint!
    @IBOutlet weak var securityCodeTextField: HoshiTextField!
    @IBOutlet weak var cardCvvThumbnail: UIImageView!
    @IBOutlet weak var panelView: UIView!

    var securityCodeLabel: PXMonospaceLabel!
    var errorLabel: MPLabel?
    var viewModel: SecurityCodeViewModel!
    var textMaskFormater: TextMaskFormater!
    var cardFront: CardFrontView!
    var ccvLabelEmpty: Bool = true
    var toolbar: PXToolbar?

    override public init(nibName nibNameOrNil: String?, bundle nibBundleOrNil: Bundle?) {
        super.init(nibName: nibNameOrNil, bundle: nibBundleOrNil)
    }

    required public init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }

    public init(viewModel: SecurityCodeViewModel, collectSecurityCodeCallback: @escaping (_ cardInformation: PXCardInformationForm, _ securityCode: String) -> Void ) {
        super.init(nibName: "SecurityCodeViewController", bundle: MercadoPagoBundle.bundle())
        self.viewModel = viewModel
        self.viewModel.callback = collectSecurityCodeCallback
    }

    override open func viewDidLoad() {
        super.viewDidLoad()
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillShow), name: UIResponder.keyboardWillShowNotification, object: nil)
        self.hideNavBar()
        loadMPStyles()
        self.securityCodeTextField.placeholder = "security_code".localized
        setupInputAccessoryView()
        self.view.backgroundColor = ThemeManager.shared.getMainColor()
        self.cardFront = CardFrontView(frame: viewModel.getCardBounds())
        self.view.addSubview(cardFront)
        self.securityCodeLabel = cardFront.cardCVV
        self.view.bringSubviewToFront(panelView)
        self.updateCardSkin(cardInformation: viewModel.cardInfo, paymentMethod: viewModel.paymentMethod)

        securityCodeTextField.autocorrectionType = UITextAutocorrectionType.no
        securityCodeTextField.keyboardType = UIKeyboardType.numberPad
        securityCodeTextField.keyboardAppearance = .light
        securityCodeTextField.addTarget(self, action: #selector(SecurityCodeViewController.editingChanged(_:)), for: UIControl.Event.editingChanged)
        securityCodeTextField.delegate = self
        completeCvvLabel()
        if viewModel.paymentMethod.creditsDisplayInfo?.cvvInfo != nil {
            renderCVVInfoView()
        }
    }

    open override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        securityCodeTextField.becomeFirstResponder()
    }
    open override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        self.showNavBar()
    }

    override open func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        trackScreenView()
    }

    @objc func keyboardWillShow(notification: Notification) {
        if let keyboardSize = (notification.userInfo?[UIResponder.keyboardFrameEndUserInfoKey] as? NSValue)?.cgRectValue {
            self.keyboardHeightConstraint.constant = keyboardSize.height - 40
            self.view.layoutIfNeeded()
            self.view.setNeedsUpdateConstraints()
        }
    }

    @objc open func editingChanged(_ textField: UITextField) {
        hideErrorMessage()
        securityCodeLabel.text = textField.text
        self.ccvLabelEmpty = (textField.text != nil && textField.text!.count == 0)
        securityCodeLabel.textColor = self.viewModel.getPaymentMethodFontColor()
        completeCvvLabel()
    }

    @objc func continueAction() {
        securityCodeTextField.resignFirstResponder()
        guard securityCodeTextField.text?.count == viewModel.secCodeLenght() else {
            let errorMessage: String = ("invalid_cvv_length".localized as NSString).replacingOccurrences(of: "{0}", with: ((self.viewModel.secCodeLenght()) as NSNumber).stringValue)
            showErrorMessage(errorMessage)
            return
        }
        self.viewModel.executeCallback(secCode: securityCodeTextField.text)
    }

    @objc func backAction() {
        trackBackEvent()
        if let callbackCancel = callbackCancel {
            callbackCancel()
            return
        }
        self.navigationController?.popViewController(animated: false)
    }

    func setupInputAccessoryView() {
        let frame = CGRect(x: 0, y: 0, width: UIScreen.main.bounds.size.width, height: 44)
        let toolbar = PXToolbar(frame: frame)

        toolbar.barStyle = UIBarStyle.default
        toolbar.isUserInteractionEnabled = true

        let buttonNext = UIBarButtonItem(title: "Continuar".localized, style: .plain, target: self, action: #selector(self.continueAction))
        let buttonPrev = UIBarButtonItem(title: "card_form_previous_button".localized, style: .plain, target: self, action: #selector(self.backAction))

        let flexibleSpace = UIBarButtonItem(barButtonSystemItem: .flexibleSpace, target: nil, action: nil)

        toolbar.items = [buttonPrev, flexibleSpace, buttonNext]

        self.toolbar = toolbar
        self.securityCodeTextField.delegate = self
        self.securityCodeTextField.inputAccessoryView = toolbar
    }

    func updateCardSkin(cardInformation: PXCardInformationForm?, paymentMethod: PXPaymentMethod) {
        self.updateCardThumbnail(paymentMethodColor: paymentMethod.getColor(bin: cardInformation?.getCardBin()))
        self.cardFront.updateCard(token: cardInformation, paymentMethod: paymentMethod)
        cardFront.cardCVV.alpha = 0.8
        cardFront.setCornerRadius(radius: 11)
    }

    func updateCardThumbnail(paymentMethodColor: UIColor) {
        self.cardCvvThumbnail.backgroundColor = paymentMethodColor
        self.cardCvvThumbnail.layer.cornerRadius = 3
        if self.viewModel.secCodeInBack() {
            self.securityCodeLabel.isHidden = true
            self.cardCvvThumbnail.image = ResourceManager.shared.getImage("CardCVVThumbnailBack")
        } else {
            self.securityCodeLabel.isHidden = false
            self.cardCvvThumbnail.image = ResourceManager.shared.getImage("CardCVVThumbnailFront")
        }
    }

    open func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        if ((textField.text?.count)! + string.count) > viewModel.secCodeLenght() {
            return false
        }
        return true
    }

    open func showErrorMessage(_ errorMessage: String) {
        errorLabel = MPLabel(frame: toolbar!.frame)
        self.errorLabel!.backgroundColor = UIColor.UIColorFromRGB(0xEEEEEE)
        self.errorLabel!.textColor = ThemeManager.shared.rejectedColor()
        self.errorLabel!.textAlignment = .center
        self.errorLabel!.text = errorMessage
        self.errorLabel!.font = self.errorLabel!.font.withSize(12)
        securityCodeTextField.borderInactiveColor = ThemeManager.shared.rejectedColor()
        securityCodeTextField.borderActiveColor = ThemeManager.shared.rejectedColor()
        securityCodeTextField.inputAccessoryView = errorLabel
        securityCodeTextField.setNeedsDisplay()
        securityCodeTextField.resignFirstResponder()
        securityCodeTextField.becomeFirstResponder()

        trackError(errorMessage: errorMessage)
    }

    open func hideErrorMessage() {
        self.securityCodeTextField.borderInactiveColor = ThemeManager.shared.secondaryColor()
        self.securityCodeTextField.borderActiveColor = ThemeManager.shared.secondaryColor()
        self.securityCodeTextField.inputAccessoryView = self.toolbar
        self.securityCodeTextField.setNeedsDisplay()
        self.securityCodeTextField.resignFirstResponder()
        self.securityCodeTextField.becomeFirstResponder()
    }

    func completeCvvLabel() {
        if self.ccvLabelEmpty {
            securityCodeLabel!.text = ""
        }

        while addCvvDot() != false {
        }
        securityCodeLabel.textColor = self.viewModel.getPaymentMethodFontColor()
    }

    func addCvvDot() -> Bool {

        let label = self.securityCodeLabel
        //Check for max length including the spacers we added
        if label?.text?.count == self.viewModel.secCodeLenght() {
            return false
        }

        label?.text?.append("•")
        return true
    }
}

// MARK: CVVInfoView
private extension SecurityCodeViewController {
    func renderCVVInfoView() {
        cardFront.alpha = 0
        cardCvvThumbnail.image = nil
        Utils().loadImageFromURLWithCache(withUrl: viewModel.paymentMethod.creditsDisplayInfo?.cvvInfo?.imageUrl, targetView: cardCvvThumbnail, placeholderView: nil, fallbackView: nil, fadeInEnabled: true) { [weak self] newImage in
            self?.cardCvvThumbnail.image = newImage
        }

        let titleLabel = buildLabel(viewModel.paymentMethod.creditsDisplayInfo?.cvvInfo?.title)
        titleLabel.font = UIFont.ml_semiboldSystemFont(ofSize: PXLayout.XL_FONT)
        view.addSubview(titleLabel)
        NSLayoutConstraint.activate([
            titleLabel.topAnchor.constraint(equalTo: view.topAnchor, constant: PXLayout.XXXL_MARGIN),
            titleLabel.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: PXLayout.XL_MARGIN),
            titleLabel.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -PXLayout.XL_MARGIN)
        ])

        let subtitleLabel = buildLabel(viewModel.paymentMethod.creditsDisplayInfo?.cvvInfo?.message)
        subtitleLabel.font = UIFont.ml_regularSystemFont(ofSize: PXLayout.XS_FONT)
        view.addSubview(subtitleLabel)
        NSLayoutConstraint.activate([
            subtitleLabel.topAnchor.constraint(equalTo: titleLabel.bottomAnchor, constant: PXLayout.XS_MARGIN),
            subtitleLabel.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: PXLayout.XL_MARGIN),
            subtitleLabel.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -PXLayout.XL_MARGIN)
        ])
    }

    func buildLabel(_ message: String?) -> UILabel {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.textAlignment = .center
        label.text = message ?? ""
        label.textColor = ThemeManager.shared.statusBarStyle() == UIStatusBarStyle.default ? UIColor.black : ThemeManager.shared.whiteColor()
        label.numberOfLines = 0
        return label
    }
}

// MARK: Tracking
extension SecurityCodeViewController {

    func trackScreenView() {
        let screenPath = TrackingPaths.Screens.getSecurityCodePath(paymentTypeId: viewModel.paymentMethod.paymentTypeId)
        trackScreen(path: screenPath, properties: viewModel.getScreenProperties(), treatBackAsAbort: true)
    }

    func trackError(errorMessage: String) {
        let properties = viewModel.getInvalidUserInputErrorProperties(message: errorMessage)
        trackEvent(path: TrackingPaths.Events.getErrorPath(), properties: properties)
    }
}
