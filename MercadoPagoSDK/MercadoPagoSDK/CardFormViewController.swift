//
//  CardFormViewController.swift
//  MercadoPagoSDK
//
//  Created by Demian Tejo on 1/18/16.
//  Copyright © 2016 MercadoPago. All rights reserved.
//

import UIKit
private func < <T: Comparable>(lhs: T?, rhs: T?) -> Bool {
    switch (lhs, rhs) {
    case let (l?, r?):
        return l < r
    case (nil, _?):
        return true
    default:
        return false
    }
}

open class CardFormViewController: MercadoPagoUIViewController, UITextFieldDelegate {

    @IBOutlet weak var keyboardHeightConstraint: NSLayoutConstraint!
    @IBOutlet weak var cardBackground: UIView!
    var cardView: UIView!
    @IBOutlet weak var textBox: HoshiTextField!

    var cardViewBack: UIView?
    var cardFront: CardFrontView?
    var cardBack: CardBackView?

    var cardNumberLabel: UILabel?
    var numberLabelEmpty: Bool = true
    var nameLabel: MPLabel?
    var expirationDateLabel: MPLabel?
    var expirationLabelEmpty: Bool = true
    var cvvLabel: UILabel?

    var editingLabel: UILabel?

    var callback : (( _ paymentMethods: [PaymentMethod], _ cardtoken: CardToken?) -> Void)?

    var textMaskFormater = TextMaskFormater(mask: "XXXX XXXX XXXX XXXX")
    var textEditMaskFormater = TextMaskFormater(mask: "XXXX XXXX XXXX XXXX", completeEmptySpaces :false)

    static public var showBankDeals = true

    var toolbar: UIToolbar?
    var errorLabel: MPLabel?

    var navItem: UINavigationItem?

    var viewModel: CardFormViewModel!

    override open var screenName: String { get { return TrackingUtil.SCREEN_NAME_CARD_FORM} }
    override open var screenId: String { get { return TrackingUtil.SCREEN_ID_CARD_FORM } }

    public init(cardFormManager: CardFormViewModel, callback : @escaping ((_ paymentMethod: [PaymentMethod], _ cardToken: CardToken?) -> Void), callbackCancel: (() -> Void)? = nil) {
        super.init(nibName: "CardFormViewController", bundle: MercadoPago.getBundle())
        self.viewModel = cardFormManager
        self.callback = callback
        //  self.paymentMethods = cardFormManager.getPaymentMethods()
    }

    override func trackInfo() {
        var finalId = screenId
        if let cardType = self.viewModel.getPaymentMethodTypeId() {
            finalId = finalId + "/" + cardType
        }
        MPXTracker.trackScreen(screenId: finalId, screenName: screenName)
        self.trackStatus()
    }

    func trackStatus() {
        var finalId = screenId

        if let cardType = self.viewModel.getPaymentMethodTypeId() {
            finalId = finalId + "/" + cardType
        }

        if editingLabel === cardNumberLabel {
            MPXTracker.trackScreen(screenId: finalId + TrackingUtil.CARD_NUMBER, screenName: screenName)
        } else if editingLabel === nameLabel {
            MPXTracker.trackScreen(screenId: finalId + TrackingUtil.CARD_HOLDER_NAME, screenName: screenName)
        } else if editingLabel === expirationDateLabel {
            MPXTracker.trackScreen(screenId: finalId + TrackingUtil.CARD_EXPIRATION_DATE, screenName: screenName)
        } else if editingLabel === cvvLabel {
            MPXTracker.trackScreen(screenId: finalId + TrackingUtil.CARD_SECURITY_CODE, screenName: screenName)
        } else if editingLabel == nil {
            MPXTracker.trackScreen(screenId: finalId, screenName: screenName)
        }
    }

    required public init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    override func loadMPStyles() {

        if self.navigationController != nil {

            //Navigation bar colors
            var titleDict: NSDictionary = [:]
            //Navigation bar colors
            let fontChosed = Utils.getFont(size: 18)
            titleDict = [NSForegroundColorAttributeName: UIColor.systemFontColor(), NSFontAttributeName: fontChosed]

            if self.navigationController != nil {
                self.navigationController!.navigationBar.titleTextAttributes = titleDict as? [String : AnyObject]
                self.navigationItem.hidesBackButton = true
                self.navigationController!.interactivePopGestureRecognizer?.delegate = self
                self.navigationController?.navigationBar.barTintColor = UIColor.primaryColor()
                self.navigationController?.navigationBar.removeBottomLine()
                self.navigationController?.navigationBar.isTranslucent = false
                self.cardBackground.backgroundColor = UIColor.primaryColor()

                if viewModel.showBankDeals() {
                    let promocionesButton: UIBarButtonItem = UIBarButtonItem(title: "Ver promociones".localized, style: UIBarButtonItemStyle.plain, target: self, action: #selector(CardFormViewController.verPromociones))
                    promocionesButton.tintColor = UIColor.systemFontColor()
                    promocionesButton.setTitleTextAttributes([NSFontAttributeName: Utils.getFont(size: 20)], for: .normal)
                    self.navigationItem.rightBarButtonItem = promocionesButton
                }

                displayBackButton()
            }
        }

    }

    public init(paymentSettings: PaymentPreference?, amount: Double!, token: Token? = nil, cardInformation: CardInformation? = nil, paymentMethods: [PaymentMethod], callback : @escaping ((_ paymentMethod: [PaymentMethod], _ cardToken: CardToken?) -> Void), callbackCancel: (() -> Void)? = nil) {
        super.init(nibName: "CardFormViewController", bundle: MercadoPago.getBundle())
        self.viewModel = CardFormViewModel(amount: amount, paymentMethods: paymentMethods, customerCard: cardInformation, token: token)
        self.callbackCancel = callbackCancel
        self.callback = callback
    }

    override public init(nibName nibNameOrNil: String?, bundle nibBundleOrNil: Bundle?) {
        super.init(nibName: nibNameOrNil, bundle: nibBundleOrNil)
    }

    open override func viewWillAppear(_ animated: Bool) {

        super.viewWillAppear(animated)

        updateLabelsFontColors()

        if let navigation = self.navigationController {
            if navigation.viewControllers.first == self {
                self.callbackCancel = {
                    self.dismiss(animated: true, completion: {})

                }
            }
        }
        if callbackCancel != nil {
            self.navigationItem.leftBarButtonItem?.target = self
            self.navigationItem.leftBarButtonItem!.action = #selector(invokeCallbackCancelShowingNavBar)
        }

        textEditMaskFormater.emptyMaskElement = nil

    }

    open override func viewDidAppear(_ animated: Bool) {

        super.viewDidAppear(animated)

        if self.navigationController != nil {
            if viewModel.showBankDeals() {
                let promocionesButton: UIBarButtonItem = UIBarButtonItem(title: "Ver promociones".localized, style: UIBarButtonItemStyle.plain, target: self, action: #selector(CardFormViewController.verPromociones))
                promocionesButton.tintColor = UIColor.systemFontColor()
                promocionesButton.setTitleTextAttributes([NSFontAttributeName: Utils.getFont(size: 20)], for: .normal)
                self.navigationItem.rightBarButtonItem = promocionesButton
            }
        }

        self.showNavBar()

        textBox.placeholder = "Número de tarjeta".localized
        textBox.becomeFirstResponder()

        self.updateCardSkin()

        if self.viewModel.customerCard != nil {

            let textMaskFormaterAux = TextMaskFormater(mask: "XXXX XXXX XXXX XXXX", completeEmptySpaces: true)
            self.cardNumberLabel?.text = textMaskFormaterAux.textMasked(self.viewModel.customerCard?.getCardBin(), remasked: false)
            self.cardNumberLabel?.text = textMaskFormaterAux.textMasked(self.viewModel.customerCard?.getCardBin(), remasked: false)
            self.prepareCVVLabelForEdit()
        } else if viewModel.token != nil {
            let textMaskFormaterAux = TextMaskFormater(mask: "XXXX XXXX XXXX XXXX", completeEmptySpaces: true)
            self.cardNumberLabel?.text = textMaskFormaterAux.textMasked(viewModel.token?.firstSixDigit, remasked: false)
            self.cardNumberLabel?.text = textMaskFormaterAux.textMasked(viewModel.token?.firstSixDigit, remasked: false)
            self.prepareCVVLabelForEdit()

        }
    }

    override open func viewDidLoad() {
        super.viewDidLoad()
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillShow), name: .UIKeyboardWillShow, object: nil)
        self.getPromos()
        textBox.autocorrectionType = UITextAutocorrectionType.no
        textBox.keyboardType = UIKeyboardType.numberPad
        textBox.addTarget(self, action: #selector(CardFormViewController.editingChanged(_:)), for: UIControlEvents.editingChanged)
        setupInputAccessoryView()
        textBox.delegate = self
        cardFront = CardFrontView()
        cardBack = CardBackView()

        self.cardView = UIView()

        let cardHeight = getCardHeight()
        let cardWidht = getCardWidth()
        let xMargin = (UIScreen.main.bounds.size.width  - cardWidht) / 2
        let yMargin = (UIScreen.main.bounds.size.height - 384 - cardHeight ) / 2

        let rectBackground = CGRect(x: xMargin, y: yMargin, width: cardWidht, height: cardHeight)
        let rect = CGRect(x: 0, y: 0, width: cardWidht, height: cardHeight)
        self.cardView.frame = rectBackground
        cardFront?.frame = rect
        cardBack?.frame = rect
        self.cardView.backgroundColor = UIColor.mpLightGray()
        self.cardView.layer.cornerRadius = 11
        self.cardView.layer.masksToBounds = true
        self.cardBackground.addSubview(self.cardView)

        cardBack!.backgroundColor = UIColor.clear

        cardNumberLabel = cardFront?.cardNumber
        nameLabel = cardFront?.cardName
        expirationDateLabel = cardFront?.cardExpirationDate
        cvvLabel = cardBack?.cardCVV

        cardNumberLabel?.text = textMaskFormater.textMasked("")
        nameLabel?.text = "NOMBRE APELLIDO".localized
        expirationDateLabel?.text = "MM/AA".localized
        cvvLabel?.text = "•••"
        editingLabel = cardNumberLabel

        view.setNeedsUpdateConstraints()
        cardView.addSubview(cardFront!)

    }
    func keyboardWillShow(notification: Notification) {
        if let keyboardSize = (notification.userInfo?[UIKeyboardFrameEndUserInfoKey] as? NSValue)?.cgRectValue {
            self.keyboardHeightConstraint.constant = keyboardSize.height - 40
            self.view.layoutIfNeeded()
            self.view.setNeedsUpdateConstraints()
        }
    }

    private func getPromos() {
        MercadoPagoServices.getPromos(baseURL: MercadoPagoCheckoutViewModel.servicePreference.getDefaultBaseURL(), {(promos : [BankDeal]?) -> Void in
            self.viewModel.promos = promos
            self.updateCardSkin()
        }, failure: { (_: NSError) in
            // Si no se pudieron obtener promociones se ignora tal caso
            CardFormViewController.showBankDeals = false
            self.updateCardSkin()
        })

    }

    func getCardWidth() -> CGFloat {
        let widthTotal = UIScreen.main.bounds.size.width * 0.70
        if widthTotal < 512 {
            if (0.63 * widthTotal) < (UIScreen.main.bounds.size.height - 394) {
                return widthTotal
            } else {
                return (UIScreen.main.bounds.size.height - 394) / 0.63
            }

        } else {
            return 512
        }

    }

    func getCardHeight() -> CGFloat {
        return ( getCardWidth() * 0.63 )
    }

    open func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        if string.characters.count == 0 {
            textField.text = textField.text!.trimmingCharacters(
                in: CharacterSet.whitespacesAndNewlines

            )
        }

        let value: Bool = validateInput(textField, shouldChangeCharactersInRange: range, replacementString: string)
        updateLabelsFontColors()

        return value
    }

    open func verPromociones() {
        self.navigationController?.present(UINavigationController(rootViewController: self.startPromosStep(promos : self.viewModel.promos)), animated: true, completion: {})
    }

    func startPromosStep(promos: [BankDeal]? = nil,
                         _ callback: (() -> Void)? = nil) -> PromoViewController {
        return PromoViewController(promos : promos, callback : callback)
    }

    open func editingChanged(_ textField: UITextField) {
        hideMessage()
        if editingLabel == cardNumberLabel {
            showOnlyOneCardMessage()
            editingLabel?.text = textMaskFormater.textMasked(textEditMaskFormater.textUnmasked(textField.text!))
            textField.text! = textEditMaskFormater.textMasked(textField.text!, remasked: true)
            self.updateCardSkin()
            updateLabelsFontColors()
        } else if editingLabel == nameLabel {
            editingLabel?.text = formatName(textField.text!)
            updateLabelsFontColors()
        } else if editingLabel == expirationDateLabel {
            editingLabel?.text = formatExpirationDate(textField.text!)

            updateLabelsFontColors()
        } else {
            editingLabel?.text = textField.text!
            completeCvvLabel()

        }

    }

    open func textFieldShouldReturn(_ textField: UITextField) -> Bool {

        if editingLabel == nameLabel {
            self.prepareExpirationLabelForEdit()
        }
        return true
    }

    /* Metodos para formatear el texto ingresado de forma que se muestre
     de forma adecuada dependiendo de cada campo de texto */

    fileprivate func formatName(_ name: String) -> String {
        if name.characters.count == 0 {
            self.viewModel.cardholderNameEmpty = true
            return "NOMBRE APELLIDO".localized
        }
        self.viewModel.cardholderNameEmpty = false
        return name.uppercased()
    }
    fileprivate func formatCVV(_ cvv: String) -> String {
        completeCvvLabel()
        return cvv
    }
    fileprivate func formatExpirationDate(_ expirationDate: String) -> String {
        if expirationDate.characters.count == 0 {
            expirationLabelEmpty = true
            return "MM/AA".localized
        }
        expirationLabelEmpty = false
        return expirationDate
    }

    /* Metodos para preparar los diferentes labels del formulario para ser editados */
    fileprivate func prepareNumberLabelForEdit() {
        editingLabel = cardNumberLabel
        viewModel.cardToken = nil
        textBox.resignFirstResponder()
        textBox.keyboardType = UIKeyboardType.numberPad
        textBox.becomeFirstResponder()
        textBox.text = textEditMaskFormater.textMasked(cardNumberLabel!.text?.trimSpaces())
        textBox.placeholder = "Número de tarjeta".localized
        self.trackStatus()
    }
    fileprivate func prepareNameLabelForEdit() {
        editingLabel = nameLabel
        textBox.resignFirstResponder()
        textBox.keyboardType = UIKeyboardType.alphabet
        textBox.becomeFirstResponder()
        textBox.text = viewModel.cardholderNameEmpty ?  "" : nameLabel!.text!.replacingOccurrences(of: " ", with: "")
        textBox.placeholder = "Nombre y apellido".localized
        self.trackStatus()

    }
    fileprivate func prepareExpirationLabelForEdit() {
        editingLabel = expirationDateLabel
        textBox.resignFirstResponder()
        textBox.keyboardType = UIKeyboardType.numberPad
        textBox.becomeFirstResponder()
        textBox.text = expirationLabelEmpty ?  "" : expirationDateLabel!.text
        textBox.placeholder = "Fecha de expiración".localized
        self.trackStatus()
    }
    fileprivate func prepareCVVLabelForEdit() {

        if !self.viewModel.isAmexCard(self.cardNumberLabel!.text!) {
            UIView.transition(from: self.cardFront!, to: self.cardBack!, duration: viewModel.animationDuration, options: UIViewAnimationOptions.transitionFlipFromLeft, completion: { (_) -> Void in
                self.updateLabelsFontColors()
            })
            cvvLabel = cardBack?.cardCVV
            cardFront?.cardCVV.text = "•••"
            cardFront?.cardCVV.alpha = 0
            cardBack?.cardCVV.alpha = 1
        } else {
            cvvLabel = cardFront?.cardCVV
            cardBack?.cardCVV.text = "••••"
            cardBack?.cardCVV.alpha = 0
            cardFront?.cardCVV.alpha = 1
        }

        editingLabel = cvvLabel
        textBox.resignFirstResponder()
        textBox.keyboardType = UIKeyboardType.numberPad
        textBox.becomeFirstResponder()
        textBox.text = self.viewModel.cvvEmpty  ?  "" : cvvLabel!.text!.replacingOccurrences(of: " ", with: "")
        textBox.placeholder = "Código de seguridad".localized
        self.trackStatus()
    }

    /* Metodos para validar si un texto ingresado es valido, dependiendo del tipo
     de campo que se este llenando */

    func validateInput(_ textField: UITextField, shouldChangeCharactersInRange range: NSRange, replacementString string: String) -> Bool {

        switch editingLabel! {
        case cardNumberLabel! :
            if string.characters.count == 0 {
                return true
            }
            if ((textEditMaskFormater.textUnmasked(textField.text).characters.count) == 6) && (string.characters.count > 0) {
                if !viewModel.hasGuessedPM() {
                    return false
                }
            } else {

                if (textEditMaskFormater.textUnmasked(textField.text).characters.count) == viewModel.getGuessedPM()?.cardNumberLenght() {

                    return false
                }

            }
            return true

        case nameLabel! : return validInputName(textField.text! + string)

        case expirationDateLabel! : return validInputDate(textField, shouldChangeCharactersInRange: range, replacementString: string)

        case cvvLabel! : return self.viewModel.isValidInputCVV(textField.text! + string)
        default : return false
        }
    }

    func validInputName(_ text: String) -> Bool {
        return true
    }
    func validInputDate(_ textField: UITextField, shouldChangeCharactersInRange range: NSRange, replacementString string: String) -> Bool {
        //Range.Lenth will greater than 0 if user is deleting text - Allow it to replce
        if range.length > 0 {
            return true
        }

        //Dont allow empty strings
        if string == " " {
            return false
        }

        //Check for max length including the spacers we added
        if range.location == 5 {
            return false
        }

        var originalText = textField.text
        let replacementText = string.replacingOccurrences(of: "/", with: "")

        //Verify entered text is a numeric value
        let digits = CharacterSet.decimalDigits
        for char in replacementText.unicodeScalars {
            if !digits.contains(UnicodeScalar(char.value)!) {
                return false
            }
        }

        if originalText!.characters.count == 2 {
            originalText?.append("/")
            textField.text = originalText
        }

        return true
    }

    func setupInputAccessoryView() {
        if viewModel.shoudShowOnlyOneCardMessage() && self.editingLabel == self.cardNumberLabel {
            showOnlyOneCardMessage()
        } else {
            setupToolbarButtons()
        }
    }

    func setupToolbarButtons() {

        if self.toolbar == nil {
            let frame =  CGRect(x: 0, y: 0, width: UIScreen.main.bounds.size.width, height: 44)

            let toolbar = UIToolbar(frame: frame)

            toolbar.barStyle = UIBarStyle.default
            toolbar.backgroundColor = UIColor.mpLightGray()
            toolbar.alpha = 1
            toolbar.isUserInteractionEnabled = true

            let buttonNext = UIBarButtonItem(title: "Continuar".localized, style: .done, target: self, action: #selector(CardFormViewController.rightArrowKeyTapped))
            let buttonPrev = UIBarButtonItem(title: "Anterior".localized, style: .plain, target: self, action: #selector(CardFormViewController.leftArrowKeyTapped))

            let font = Utils.getFont(size: 14)
            buttonNext.setTitleTextAttributes([NSFontAttributeName: font], for: .normal)
            buttonPrev.setTitleTextAttributes([NSFontAttributeName: font], for: .normal)

            buttonNext.setTitlePositionAdjustment(UIOffset(horizontal: UIScreen.main.bounds.size.width / 8, vertical: 0), for: UIBarMetrics.default)
            buttonPrev.setTitlePositionAdjustment(UIOffset(horizontal: -UIScreen.main.bounds.size.width / 8, vertical: 0), for: UIBarMetrics.default)

            let flexibleSpace = UIBarButtonItem(barButtonSystemItem: .flexibleSpace, target: nil, action: nil)

            toolbar.items = [flexibleSpace, buttonPrev, flexibleSpace, buttonNext, flexibleSpace]
            if self.viewModel.customerCard != nil || self.viewModel.token != nil {
                navItem!.leftBarButtonItem?.isEnabled = false
            }

            textBox.delegate = self
            self.toolbar = toolbar
        }
        textBox.inputAccessoryView = self.toolbar
    }

    func setOnlyOneCardMessage(message: String, color: UIColor, isError: Bool) {
        let frame =  CGRect(x: 0, y: 0, width: UIScreen.main.bounds.size.width, height: 44)
        let onlyOnePaymentMethodLabel = MPCardFormToolbarLabel(frame: frame)
        onlyOnePaymentMethodLabel.backgroundColor = color
        onlyOnePaymentMethodLabel.textColor = UIColor.white
        onlyOnePaymentMethodLabel.text = message
        onlyOnePaymentMethodLabel.font = Utils.getLightFont(size: 14)
        setTextBox(isError: isError, inputAccessoryView: onlyOnePaymentMethodLabel)

    }

    func showOnlyOneCardMessage() {
        if viewModel.shoudShowOnlyOneCardMessage() {
            setOnlyOneCardMessage(message: viewModel.getOnlyOneCardAvailableMessage(), color: UIColor.px_grayBaseText(), isError: false)
        }
    }

    func showCardNotSupportedErrorMessage() {
       let paymentMethods = self.viewModel.paymentMethods

        if viewModel.shoudShowOnlyOneCardMessage() {
                setOnlyOneCardMessage(message: self.viewModel.getOnlyOneCardAvailableMessage(), color: UIColor.mpRedPinkErrorMessage(), isError: true)
        }else {
            let cardNotAvailableError = CardNotAvailableErrorView(frame: (toolbar?.frame)!, paymentMethods: paymentMethods, showAvaibleCardsCallback: {
                self.editingLabel?.text = ""
                self.textBox.text = ""
                self.hideMessage()
                let availableCardsDetail =  AvailableCardsViewController(paymentMethods: paymentMethods)
                self.navigationController?.present(availableCardsDetail, animated: true, completion: {})
            })
            setTextBox(isError: true, inputAccessoryView: cardNotAvailableError)
        }
    }

    func setTextBox(isError: Bool, inputAccessoryView: UIView) {
        if isError {
            textBox.borderInactiveColor = UIColor.red
            textBox.borderActiveColor = UIColor.red
        }
        textBox.inputAccessoryView = inputAccessoryView
        textBox.setNeedsDisplay()
        textBox.resignFirstResponder()
        textBox.becomeFirstResponder()
    }

    func showMessage(_ errorMessage: String) {

        errorLabel = MPLabel(frame: toolbar!.frame)
        self.errorLabel!.backgroundColor = UIColor.mpLightGray()
        self.errorLabel!.textColor = UIColor.mpRedErrorMessage()
        self.errorLabel!.text = errorMessage
        self.errorLabel!.textAlignment = .center
        self.errorLabel!.font = self.errorLabel!.font.withSize(12)
        setTextBox(isError: true, inputAccessoryView: errorLabel!)
    }

    func hideMessage() {
        self.textBox.borderInactiveColor = UIColor(netHex: 0x3F9FDA)
        self.textBox.borderActiveColor = UIColor(netHex: 0x3F9FDA)
        setupToolbarButtons()
        self.textBox.setNeedsDisplay()
        self.textBox.resignFirstResponder()
        self.textBox.becomeFirstResponder()
    }

    func leftArrowKeyTapped() {
        switch editingLabel! {
        case cardNumberLabel! :
            return
        case nameLabel! :
            self.prepareNumberLabelForEdit()
        case expirationDateLabel! :
            prepareNameLabelForEdit()

        case cvvLabel! :
            if (self.viewModel.getGuessedPM()?.secCodeInBack())! {
                UIView.transition(from: self.cardBack!, to: self.cardFront!, duration: viewModel.animationDuration, options: UIViewAnimationOptions.transitionFlipFromRight, completion: { (_) -> Void in
                })
            }

            prepareExpirationLabelForEdit()
        default : self.updateLabelsFontColors()
        }
        self.updateLabelsFontColors()
    }

    func rightArrowKeyTapped() {
        switch editingLabel! {

        case cardNumberLabel! :
            if !validateCardNumber() {
                if viewModel.guessedPMS != nil {
                    showMessage((viewModel.cardToken?.validateCardNumber(viewModel.getGuessedPM()!))!)
                } else {
                    if cardNumberLabel?.text?.characters.count == 0 {
                        showMessage("Ingresa el número de la tarjeta de crédito".localized)
                    } else {
                        showMessage("Revisa este dato".localized)
                    }

                }

                return
            }
            prepareNameLabelForEdit()

        case nameLabel! :
            if !self.validateCardholderName() {
                showMessage("Ingresa el nombre y apellido impreso en la tarjeta".localized)

                return
            }
            prepareExpirationLabelForEdit()

        case expirationDateLabel! :

            if viewModel.guessedPMS != nil {
                let bin = self.viewModel.getBIN(self.cardNumberLabel!.text!)
                if !(viewModel.getGuessedPM()?.isSecurityCodeRequired((bin)!))! {
                    self.confirmPaymentMethod()
                    return
                }
            }
            if !self.validateExpirationDate() {
                showMessage((viewModel.cardToken?.validateExpiryDate())!)

                return
            }
            self.prepareCVVLabelForEdit()

        case cvvLabel! :
            if !self.validateCvv() {

                showMessage(("Ingresa los %1$s números del código de seguridad".localized as NSString).replacingOccurrences(of: "%1$s", with: ((viewModel.getGuessedPM()?.secCodeLenght())! as NSNumber).stringValue))
                return
            }
            self.confirmPaymentMethod()
        default : updateLabelsFontColors()
        }
        updateLabelsFontColors()
    }

    func closeKeyboard() {
        textBox.resignFirstResponder()
        delightedLabels()
    }

    func clearCardSkin() {

        if self.cardFront?.cardLogo.image != nil, self.cardFront?.cardLogo.image != MercadoPago.getCardDefaultLogo() {
            self.cardFront?.cardLogo.alpha = 0
            self.cardFront?.cardLogo.image =  MercadoPago.getCardDefaultLogo()
            UIView.animate(withDuration: 0.7, animations: { () -> Void in
                self.cardView.backgroundColor = UIColor.cardDefaultColor()
                self.cardFront?.cardLogo.alpha = 1
            })
        } else if self.cardFront?.cardLogo.image == nil {
            self.cardFront?.cardLogo.image = MercadoPago.getCardDefaultLogo()
            self.cardView.backgroundColor = UIColor.cardDefaultColor()
        }

        let textMaskFormaterAux = TextMaskFormater(mask: "XXXX XXXX XXXX XXXX")
        let textEditMaskFormaterAux = TextMaskFormater(mask: "XXXX XXXX XXXX XXXX", completeEmptySpaces :false)

        cardNumberLabel?.text = textMaskFormaterAux.textMasked(textMaskFormater.textUnmasked(cardNumberLabel!.text))
        if editingLabel == cardNumberLabel {
            textBox.text = textEditMaskFormaterAux.textMasked(textEditMaskFormater.textUnmasked(textBox.text))
        }
        textEditMaskFormater = textMaskFormaterAux
        textEditMaskFormater = textEditMaskFormaterAux
        cardFront?.cardCVV.alpha = 0
        viewModel.guessedPMS = nil
        self.updateLabelsFontColors()

    }

    func updateCardSkin() {
        guard let _ = viewModel.getBIN(self.cardNumberLabel!.text!) else {
            viewModel.guessedPMS = nil
            viewModel.cardToken = nil
            self.clearCardSkin()
            return
        }
        if textEditMaskFormater.textUnmasked(textBox.text).characters.count>=6 || viewModel.customerCard != nil ||
            viewModel.cardToken != nil {
            hideMessage()
            let pmMatched = self.viewModel.matchedPaymentMethod(self.cardNumberLabel!.text!)
            viewModel.guessedPMS = pmMatched
            let bin = viewModel.getBIN(self.cardNumberLabel!.text!)
            if let paymentMethod = viewModel.getGuessedPM() {

                if self.cardFront?.cardLogo.image == MercadoPago.getCardDefaultLogo() {
                    self.cardFront?.cardLogo.alpha = 0
                    self.cardFront?.cardLogo.image =  paymentMethod.getImage()
                    UIView.animate(withDuration: 0.7, animations: { () -> Void in
                        self.cardView.backgroundColor = (paymentMethod.getColor(bin: bin))
                        self.cardFront?.cardLogo.alpha = 1
                    })
                } else if self.cardFront?.cardLogo.image == nil {
                    self.cardFront?.cardLogo.image =  paymentMethod.getImage()
                    self.cardView.backgroundColor = (paymentMethod.getColor(bin: bin))
                }

                let labelMask = paymentMethod.getLabelMask(bin: bin)
                let editTextMask = paymentMethod.getEditTextMask(bin: bin)
                let textMaskFormaterAux = TextMaskFormater(mask: labelMask)
                let textEditMaskFormaterAux = TextMaskFormater(mask:editTextMask, completeEmptySpaces :false)
                cardNumberLabel?.text = textMaskFormaterAux.textMasked(textMaskFormater.textUnmasked(cardNumberLabel!.text))
                if editingLabel == cardNumberLabel {
                    textBox.text = textEditMaskFormaterAux.textMasked(textEditMaskFormater.textUnmasked(textBox.text))
                }
                if editingLabel == cvvLabel {
                    editingLabel!.text = textBox.text
                    cvvLabel!.text = textBox.text
                }
                textMaskFormater = textMaskFormaterAux
                textEditMaskFormater = textEditMaskFormaterAux
            } else {
                self.clearCardSkin()
                //FIXME PASAR FRAME VER QUE ONDA TOOLBAR
                showCardNotSupportedErrorMessage()
                return
            }

        }
        if self.cvvLabel == nil || self.cvvLabel!.text!.characters.count == 0 {
            if (viewModel.guessedPMS != nil)&&(!(viewModel.getGuessedPM()?.secCodeInBack())!) {
                cvvLabel = cardFront?.cardCVV
                cardBack?.cardCVV.text = ""
                cardFront?.cardCVV.alpha = 1
                cardFront?.cardCVV.text = "••••".localized
                self.viewModel.cvvEmpty = true
            } else {
                cvvLabel = cardBack?.cardCVV
                cardFront?.cardCVV.text = ""
                cardFront?.cardCVV.alpha = 0
                cardBack?.cardCVV.text = "•••".localized
                self.viewModel.cvvEmpty = true
            }
        }

        self.updateLabelsFontColors()
    }

    func delightedLabels() {
        cardNumberLabel?.textColor = self.viewModel.getLabelTextColor(cardNumber: cardNumberLabel?.text)
        nameLabel?.textColor = self.viewModel.getLabelTextColor(cardNumber: cardNumberLabel?.text)
        expirationDateLabel?.textColor = self.viewModel.getLabelTextColor(cardNumber: cardNumberLabel?.text)

        cvvLabel?.textColor = MPLabel.defaultColorText
        cardNumberLabel?.alpha = 0.7
        nameLabel?.alpha =  0.7
        expirationDateLabel?.alpha = 0.7
        cvvLabel?.alpha = 0.7
    }

    func lightEditingLabel() {
        if editingLabel != cvvLabel {
            editingLabel?.textColor = self.viewModel.getEditingLabelColor(cardNumber: cardNumberLabel?.text)
        }
        editingLabel?.alpha = 1
    }

    func updateLabelsFontColors() {
        self.delightedLabels()
        self.lightEditingLabel()

    }

    func markErrorLabel(_ label: UILabel) {
        label.textColor = MPLabel.errorColorText
    }

    fileprivate func createSavedCardToken() -> CardToken {
        let securityCode = self.viewModel.customerCard!.isSecurityCodeRequired() ? self.cvvLabel?.text : nil
        return  SavedCardToken(card: viewModel.customerCard!, securityCode: securityCode, securityCodeRequired: self.viewModel.customerCard!.isSecurityCodeRequired())
    }

    func makeToken() {

        if viewModel.token != nil { // C4A
            let ct = CardToken()
            ct.securityCode = cvvLabel?.text
            self.callback!(viewModel.guessedPMS!, ct)
            return
        }

        if viewModel.customerCard != nil {
            self.viewModel.buildSavedCardToken(self.cvvLabel!.text!)
            if !viewModel.cardToken!.validate() {
                markErrorLabel(cvvLabel!)
            }
        } else if self.viewModel.token != nil { // C4A
            let ct = CardToken()
            ct.securityCode = cvvLabel?.text
            self.callback!(viewModel.guessedPMS!, ct)
            return
        } else {
            self.viewModel.tokenHidratate(cardNumberLabel!.text!, expirationDate: self.expirationDateLabel!.text!, cvv: self.cvvLabel!.text!, cardholderName : self.nameLabel!.text!)

            if viewModel.guessedPMS != nil {
                let errorMethod = viewModel.cardToken!.validateCardNumber(viewModel.getGuessedPM()!)
                if (errorMethod) != nil {
                    markErrorLabel(cardNumberLabel!)
                    return
                }
            } else {

                markErrorLabel(cardNumberLabel!)
                return
            }

            let errorDate = viewModel.cardToken!.validateExpiryDate()
            if (errorDate) != nil {
                markErrorLabel(expirationDateLabel!)
                return
            }
            let errorName = viewModel.cardToken!.validateCardholderName()
            if (errorName) != nil {
                markErrorLabel(nameLabel!)
                return
            }
            let bin = self.viewModel.getBIN(self.cardNumberLabel!.text!)!
            if viewModel.getGuessedPM()!.isSecurityCodeRequired(bin) {
                let errorCVV = viewModel.cardToken!.validateSecurityCode()
                if (errorCVV) != nil {
                    markErrorLabel(cvvLabel!)
                    UIView.transition(from: self.cardBack!, to: self.cardFront!, duration: viewModel.animationDuration, options: UIViewAnimationOptions.transitionFlipFromLeft, completion: nil)
                    return
                }
            }
        }

        self.callback!(viewModel.guessedPMS!, self.viewModel.cardToken!)
    }

    func addCvvDot() -> Bool {

        let label = self.cvvLabel
        //Check for max length including the spacers we added
        if label?.text?.characters.count == viewModel.cvvLenght() {
            return false
        }

        label?.text?.append("•")
        return true

    }

    func completeCvvLabel() {
        if (cvvLabel!.text?.replacingOccurrences(of: "•", with: "").characters.count == 0) {
            cvvLabel?.text = cvvLabel?.text?.replacingOccurrences(of: "•", with: "")
            self.viewModel.cvvEmpty = true
        } else {
            self.viewModel.cvvEmpty = false
        }

        while addCvvDot() != false {

        }
    }

    func confirmPaymentMethod() {
        self.textBox.resignFirstResponder()
        makeToken()
    }

    internal func validateCardNumber() -> Bool {
        return self.viewModel.validateCardNumber(self.cardNumberLabel!, expirationDateLabel: self.expirationDateLabel!, cvvLabel: self.cvvLabel!, cardholderNameLabel: self.nameLabel!)
    }

    internal func validateCardholderName() -> Bool {
        return self.viewModel.validateCardholderName(self.cardNumberLabel!, expirationDateLabel: self.expirationDateLabel!, cvvLabel: self.cvvLabel!, cardholderNameLabel: self.nameLabel!)
    }

    internal func validateCvv() -> Bool {
        return self.viewModel.validateCvv(self.cardNumberLabel!, expirationDateLabel: self.expirationDateLabel!, cvvLabel: self.cvvLabel!, cardholderNameLabel: self.nameLabel!)
    }

    internal func validateExpirationDate() -> Bool {
        return self.viewModel.validateExpirationDate(self.cardNumberLabel!, expirationDateLabel: self.expirationDateLabel!, cvvLabel: self.cvvLabel!, cardholderNameLabel: self.nameLabel!)
    }

}
