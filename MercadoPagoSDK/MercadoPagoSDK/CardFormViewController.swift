//
//  CardFormViewController.swift
//  MercadoPagoSDK
//
//  Created by Demian Tejo on 1/18/16.
//  Copyright © 2016 MercadoPago. All rights reserved.
//

import UIKit
fileprivate func < <T : Comparable>(lhs: T?, rhs: T?) -> Bool {
    switch (lhs, rhs) {
    case let (l?, r?):
        return l < r
    case (nil, _?):
        return true
    default:
        return false
    }
}

open class CardFormViewController: MercadoPagoUIViewController , UITextFieldDelegate {
    
    @IBOutlet weak var cardBackground: UIView!
    @IBOutlet weak var cardView: UIView!
    @IBOutlet weak var textBox: HoshiTextField!
    
    var cardViewBack:UIView?
    var cardFront : CardFrontView?
    var cardBack : CardBackView?
    
    var cardNumberLabel: UILabel?
    var numberLabelEmpty: Bool = true
    var nameLabel: MPLabel?
    var expirationDateLabel: MPLabel?
    var expirationLabelEmpty: Bool = true
    var cvvLabel: UILabel?
    
    var editingLabel : UILabel?
    
    var callback : (( _ paymentMethods: [PaymentMethod],_ cardtoken: CardToken?) -> Void)?
    
    var textMaskFormater = TextMaskFormater(mask: "XXXX XXXX XXXX XXXX")
    var textEditMaskFormater = TextMaskFormater(mask: "XXXX XXXX XXXX XXXX", completeEmptySpaces :false)
    
    static public var showBankDeals = true
    
    var inputButtons : UINavigationBar?
    var errorLabel : MPLabel?
    
    var navItem : UINavigationItem?
    var doneNext : UIBarButtonItem?
    var donePrev : UIBarButtonItem?
    
    var cardFormManager : CardViewModelManager!
    
    override open var screenName : String { get { return "CARD_NUMBER" } }
    
    
    
    required public init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    override func loadMPStyles(){
        
        if self.navigationController != nil {
            
            
            //Navigation bar colors
            var titleDict: NSDictionary = [:]
            //Navigation bar colors
            if let fontChosed = UIFont(name: MercadoPago.DEFAULT_FONT_NAME, size: 18) {
                titleDict = [NSForegroundColorAttributeName: MercadoPagoContext.getTextColor(), NSFontAttributeName:fontChosed]
            }
            
            if self.navigationController != nil {
                self.navigationController!.navigationBar.titleTextAttributes = titleDict as? [String : AnyObject]
                self.navigationItem.hidesBackButton = true
                self.navigationController!.interactivePopGestureRecognizer?.delegate = self
                self.navigationController?.navigationBar.barTintColor = MercadoPagoContext.getPrimaryColor()
                self.navigationController?.navigationBar.removeBottomLine()
                self.navigationController?.navigationBar.isTranslucent = false
                self.cardBackground.backgroundColor =  MercadoPagoContext.getComplementaryColor()
                
                if self.timer == nil && cardFormManager.showBankDeals(){
                    let promocionesButton : UIBarButtonItem = UIBarButtonItem(title: "Ver promociones".localized, style: UIBarButtonItemStyle.plain, target: self, action: #selector(CardFormViewController.verPromociones))
                    promocionesButton.tintColor = UIColor.systemFontColor()
                    self.navigationItem.rightBarButtonItem = promocionesButton
                }
                
                
                displayBackButton()
            }
        }
        
    }
    
    public init(paymentSettings : PaymentPreference?, amount:Double!, token: Token? = nil, cardInformation : CardInformation? = nil, paymentMethods : [PaymentMethod]? = nil,  timer : CountdownTimer? = nil, callback : @escaping ((_ paymentMethod: [PaymentMethod], _ cardToken: CardToken?) -> Void), callbackCancel : ((Void) -> Void)? = nil) {
        super.init(nibName: "CardFormViewController", bundle: MercadoPago.getBundle())
        self.cardFormManager = CardViewModelManager(amount: amount, paymentMethods: paymentMethods, customerCard: cardInformation, token: token, paymentSettings: paymentSettings)
        self.callbackCancel = callbackCancel
        self.callback = callback
        self.timer = timer
    }
    
    override public init(nibName nibNameOrNil: String?, bundle nibBundleOrNil: Bundle?) {
        super.init(nibName: nibNameOrNil, bundle: nibBundleOrNil)
    }
    
    open override func viewWillAppear(_ animated: Bool) {
        
        super.viewWillAppear(animated)
        
        updateLabelsFontColors()
        
        if(callbackCancel != nil){
            self.navigationItem.leftBarButtonItem?.target = self
            self.navigationItem.leftBarButtonItem!.action = #selector(invokeCallbackCancel)
        }
        
        textEditMaskFormater.emptyMaskElement = nil
        
    }
    
    open override func viewDidAppear(_ animated: Bool) {
        
        super.viewDidAppear(animated)
        self.showNavBar()
        cardFront?.frame = cardView.bounds
        cardBack?.frame = cardView.bounds
        textBox.placeholder = "Número de tarjeta".localized
        textBox.becomeFirstResponder()
        
        self.updateCardSkin()
        
        if self.cardFormManager.customerCard != nil {
            
            let textMaskFormaterAux = TextMaskFormater(mask: "XXXX XXXX XXXX XXXX", completeEmptySpaces: true)
            self.cardNumberLabel?.text = textMaskFormaterAux.textMasked(self.cardFormManager.customerCard?.getCardBin(), remasked: false)
            self.cardNumberLabel?.text = textMaskFormaterAux.textMasked(self.cardFormManager.customerCard?.getCardBin(), remasked: false)
            self.prepareCVVLabelForEdit()
        } else if cardFormManager.token != nil {
            let textMaskFormaterAux = TextMaskFormater(mask: "XXXX XXXX XXXX XXXX", completeEmptySpaces: true)
            self.cardNumberLabel?.text = textMaskFormaterAux.textMasked(cardFormManager.token?.firstSixDigit, remasked: false)
            self.cardNumberLabel?.text = textMaskFormaterAux.textMasked(cardFormManager.token?.firstSixDigit, remasked: false)
            self.prepareCVVLabelForEdit()
            
        }
    }
    
    override open func viewDidLoad() {
        super.viewDidLoad()
        
        if (self.cardFormManager.paymentMethods == nil){
            MPServicesBuilder.getPaymentMethods({ (paymentMethods) -> Void in
                
                self.cardFormManager.paymentMethods = paymentMethods
                
                self.updateCardSkin()
                
                
            }) { (error) -> Void in
                // Mensaje de error correspondiente, ver que hacemos con el flujo
            }
        }
        
        
        textBox.autocorrectionType = UITextAutocorrectionType.no
        textBox.keyboardType = UIKeyboardType.numberPad
        textBox.addTarget(self, action: #selector(CardFormViewController.editingChanged(_:)), for: UIControlEvents.editingChanged)
        setupInputAccessoryView()
        textBox.delegate = self
        cardFront = CardFrontView()
        cardBack = CardBackView()
        
        cardBack!.backgroundColor = UIColor.clear
        
        cardNumberLabel = cardFront?.cardNumber
        nameLabel = cardFront?.cardName
        expirationDateLabel = cardFront?.cardExpirationDate
        cvvLabel = cardBack?.cardCVV
        
        cardNumberLabel?.text = textMaskFormater.textMasked("")
        nameLabel?.text = "NOMBRE APELLIDO".localized
        expirationDateLabel?.text = "MM/AA".localized
        cvvLabel?.text = "..."
        editingLabel = cardNumberLabel
        
        view.setNeedsUpdateConstraints()
        cardView.addSubview(cardFront!)
        
    }
    
    
    open func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        if (string.characters.count == 0){
            textField.text = textField.text!.trimmingCharacters(
                in: CharacterSet.whitespacesAndNewlines
                
            )
        }
        
        let value : Bool = validateInput(textField, shouldChangeCharactersInRange: range, replacementString: string)
        updateLabelsFontColors()
        
        return value
    }
    
    
    open func verPromociones(){
        self.navigationController?.present(UINavigationController(rootViewController: MPStepBuilder.startPromosStep()), animated: true, completion: {})
    }
    
    
    open func editingChanged(_ textField:UITextField){
        hideErrorMessage()
        if(editingLabel == cardNumberLabel){
            editingLabel?.text = textMaskFormater.textMasked(textEditMaskFormater.textUnmasked(textField.text!))
            textField.text! = textEditMaskFormater.textMasked(textField.text!, remasked: true)
            self.updateCardSkin()
            updateLabelsFontColors()
        }else if(editingLabel == nameLabel){
            editingLabel?.text = formatName(textField.text!)
            updateLabelsFontColors()
        }else if(editingLabel == expirationDateLabel){
            editingLabel?.text = formatExpirationDate(textField.text!)
            
            updateLabelsFontColors()
        }else{
            editingLabel?.text = textField.text!
            completeCvvLabel()
            
        }
        
        
    }
    
    open func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        
        if(editingLabel == nameLabel){
            self.prepareExpirationLabelForEdit()
        }
        return true
    }
    
    
    /* Metodos para formatear el texto ingresado de forma que se muestre
     de forma adecuada dependiendo de cada campo de texto */
    
    fileprivate func formatName(_ name:String) -> String{
        if(name.characters.count == 0){
            self.cardFormManager.cardholderNameEmpty = true
            return "NOMBRE APELLIDO".localized
        }
        self.cardFormManager.cardholderNameEmpty = false
        return name.uppercased()
    }
    fileprivate func formatCVV(_ cvv:String) -> String{
        completeCvvLabel()
        return cvv
    }
    fileprivate func formatExpirationDate(_ expirationDate:String) -> String{
        if(expirationDate.characters.count == 0){
            expirationLabelEmpty = true
            return "MM/AA".localized
        }
        expirationLabelEmpty = false
        return expirationDate
    }
    
    
    /* Metodos para preparar los diferentes labels del formulario para ser editados */
    fileprivate func prepareNumberLabelForEdit(){
        MPTracker.trackScreenName(MercadoPagoContext.sharedInstance, screenName: "CARD_NUMBER")
        editingLabel = cardNumberLabel
        cardFormManager.cardToken = nil
        textBox.resignFirstResponder()
        textBox.keyboardType = UIKeyboardType.numberPad
        textBox.becomeFirstResponder()
        textBox.text = textEditMaskFormater.textMasked(cardNumberLabel!.text?.trimSpaces())
        textBox.placeholder = "Número de tarjeta".localized
    }
    fileprivate func prepareNameLabelForEdit(){
        MPTracker.trackScreenName(MercadoPagoContext.sharedInstance, screenName: "CARD_HOLDER")
        editingLabel = nameLabel
        textBox.resignFirstResponder()
        textBox.keyboardType = UIKeyboardType.alphabet
        textBox.becomeFirstResponder()
        textBox.text = cardFormManager.cardholderNameEmpty ?  "" : nameLabel!.text!.replacingOccurrences(of: " ", with: "")
        textBox.placeholder = "Nombre y apellido".localized
        
    }
    fileprivate func prepareExpirationLabelForEdit(){
        MPTracker.trackScreenName(MercadoPagoContext.sharedInstance, screenName: "CARD_EXPIRY_DATE")
        editingLabel = expirationDateLabel
        textBox.resignFirstResponder()
        textBox.keyboardType = UIKeyboardType.numberPad
        textBox.becomeFirstResponder()
        textBox.text = expirationLabelEmpty ?  "" : expirationDateLabel!.text
        textBox.placeholder = "Fecha de expiración".localized
    }
    fileprivate func prepareCVVLabelForEdit(){
        MPTracker.trackScreenName(MercadoPagoContext.sharedInstance, screenName: "CARD_SECURITY_CODE")
        
        if(!self.cardFormManager.isAmexCard(self.cardNumberLabel!.text!)){
            UIView.transition(from: self.cardFront!, to: self.cardBack!, duration: 1, options: UIViewAnimationOptions.transitionFlipFromLeft, completion: { (completion) -> Void in
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
        textBox.text = self.cardFormManager.cvvEmpty  ?  "" : cvvLabel!.text!.replacingOccurrences(of: " ", with: "")
        textBox.placeholder = "Código de seguridad".localized
    }
    
    
    /* Metodos para validar si un texto ingresado es valido, dependiendo del tipo
     de campo que se este llenando */
    
    func validateInput(_ textField: UITextField, shouldChangeCharactersInRange range: NSRange, replacementString string: String) -> Bool {
        
        switch editingLabel! {
        case cardNumberLabel! :
            if (string.characters.count == 0){
                return true
            }
            if(((textEditMaskFormater.textUnmasked(textField.text).characters.count) == 6) && (string.characters.count > 0)){
                if (!cardFormManager.hasGuessedPM()){
                    return false
                }
            }else{
                
                
                if ((textEditMaskFormater.textUnmasked(textField.text).characters.count) == cardFormManager.getGuessedPM()?.cardNumberLenght()){
                    
                    return false
                }
                
            }
            return true
            
        case nameLabel! : return validInputName(textField.text! + string)
            
        case expirationDateLabel! : return validInputDate(textField, shouldChangeCharactersInRange: range, replacementString: string)
            
        case cvvLabel! : return self.cardFormManager.isValidInputCVV(textField.text! + string)
        default : return false
        }
    }
    
    
    func validInputName(_ text : String) -> Bool{
        return true
    }
    func validInputDate(_ textField: UITextField, shouldChangeCharactersInRange range: NSRange, replacementString string: String) -> Bool{
        //Range.Lenth will greater than 0 if user is deleting text - Allow it to replce
        if range.length > 0
        {
            return true
        }
        
        //Dont allow empty strings
        if string == " "
        {
            return false
        }
        
        //Check for max length including the spacers we added
        if range.location == 5
        {
            return false
        }
        
        var originalText = textField.text
        let replacementText = string.replacingOccurrences(of: "/", with: "")
        
        //Verify entered text is a numeric value
        let digits = CharacterSet.decimalDigits
        for char in replacementText.unicodeScalars
        {
            if !digits.contains(UnicodeScalar(char.value)!)
            {
                return false
            }
        }
        
        if originalText!.characters.count == 2
        {
            originalText?.append("/")
            textField.text = originalText
        }
        
        return true
    }
    
    func setupInputAccessoryView() {
        inputButtons = UINavigationBar(frame: CGRect(x: 0, y: 0, width: UIScreen.main.bounds.size.width, height: 44))
        inputButtons!.barStyle = UIBarStyle.default;
        inputButtons!.backgroundColor = UIColor(netHex: 0xEEEEEE);
        inputButtons!.alpha = 1;
        let frame =  CGRect(x: 0, y: 0, width: UIScreen.main.bounds.size.width / 2, height: 40)
        
        let buttonNext = UIButton(frame: frame)
        buttonNext.setTitle("Continuar".localized, for: .normal)
        buttonNext.addTarget(self, action: #selector(CardFormViewController.rightArrowKeyTapped), for: .touchUpInside)
        buttonNext.setTitleColor(UIColor(netHex:0x007AFF), for: .normal)
        
        let buttonPrev = UIButton(frame: frame)
        buttonPrev.setTitle("Anterior".localized, for: .normal)
        buttonPrev.addTarget(self, action: #selector(CardFormViewController.leftArrowKeyTapped), for: .touchUpInside)
        buttonPrev.setTitleColor(UIColor(netHex:0x007AFF), for: .normal)
        
        /*
         if let font = UIFont(name:MercadoPago.DEFAULT_FONT_NAME, size: 14) {
         buttonNext.setTitleTextAttributes([NSFontAttributeName: font], forState: UIControlState.Normal)
         buttonPrev.setTitleTextAttributes([NSFontAttributeName: font], forState: UIControlState.Normal)
         }
         */
        navItem = UINavigationItem()
        doneNext = UIBarButtonItem(customView: buttonNext)
        donePrev = UIBarButtonItem(customView: buttonPrev)
        
        
        donePrev?.setTitlePositionAdjustment(UIOffset(horizontal: UIScreen.main.bounds.size.width / 8, vertical: 0), for: UIBarMetrics.default)
        doneNext?.setTitlePositionAdjustment(UIOffset(horizontal: -UIScreen.main.bounds.size.width / 8, vertical: 0), for: UIBarMetrics.default)
        navItem!.rightBarButtonItem = doneNext
        navItem!.leftBarButtonItem = donePrev
        
        
        if self.cardFormManager.customerCard != nil || self.cardFormManager.token != nil{
            navItem!.leftBarButtonItem?.isEnabled = false
        }
        inputButtons!.pushItem(navItem!, animated: false)
        textBox.inputAccessoryView = inputButtons
        
        
    }
    
    func showErrorMessage(_ errorMessage:String){
        
        errorLabel = MPLabel(frame: inputButtons!.frame)
        self.errorLabel!.backgroundColor = UIColor(netHex: 0xEEEEEE)
        self.errorLabel!.textColor = UIColor(netHex: 0xf04449)
        self.errorLabel!.text = errorMessage
        self.errorLabel!.textAlignment = .center
        self.errorLabel!.font = self.errorLabel!.font.withSize(12)
        textBox.borderInactiveColor = UIColor.red
        textBox.borderActiveColor = UIColor.red
        textBox.inputAccessoryView = errorLabel
        textBox.setNeedsDisplay()
        textBox.resignFirstResponder()
        textBox.becomeFirstResponder()
    }
    
    func hideErrorMessage(){
        self.textBox.borderInactiveColor = UIColor(netHex: 0x3F9FDA)
        self.textBox.borderActiveColor = UIColor(netHex: 0x3F9FDA)
        self.textBox.inputAccessoryView = self.inputButtons
        self.textBox.setNeedsDisplay()
        self.textBox.resignFirstResponder()
        self.textBox.becomeFirstResponder()
    }
    
    
    func leftArrowKeyTapped(){
        switch editingLabel! {
        case cardNumberLabel! :
            return
        case nameLabel! :
            self.prepareNumberLabelForEdit()
        case expirationDateLabel! :
            prepareNameLabelForEdit()
            
        case cvvLabel! :
            if (self.cardFormManager.getGuessedPM()?.secCodeInBack())!{
                UIView.transition(from: self.cardBack!, to: self.cardFront!, duration: 1, options: UIViewAnimationOptions.transitionFlipFromRight, completion: { (completion) -> Void in
                })
            }
            
            prepareExpirationLabelForEdit()
        default : self.updateLabelsFontColors()
        }
        self.updateLabelsFontColors()
    }
    
    
    func rightArrowKeyTapped(){
        switch editingLabel! {
            
        case cardNumberLabel! :
            if !validateCardNumber() {
                if (cardFormManager.guessedPMS != nil){
                    //showErrorMessage((cardFormManager.cardToken?.validateCardNumber(cardFormManager.getGuessedPM()!)?.userInfo["cardNumber"] as? String)!)
                    showErrorMessage((cardFormManager.cardToken?.validateCardNumber(cardFormManager.getGuessedPM()!))!)
                }else{
                    if (cardNumberLabel?.text?.characters.count == 0){
                        showErrorMessage("Ingresa el número de la tarjeta de crédito".localized)
                    }else{
                        showErrorMessage("Revisa este dato".localized)
                    }
                    
                }
                
                return
            }
            prepareNameLabelForEdit()
            
        case nameLabel! :
            if (!self.validateCardholderName()){
                showErrorMessage("Ingresa el nombre y apellido impreso en la tarjeta".localized)
                
                return
            }
            prepareExpirationLabelForEdit()
            
        case expirationDateLabel! :
            
            if (cardFormManager.guessedPMS != nil){
                let bin = self.cardFormManager.getBIN(self.cardNumberLabel!.text!)
                if (!(cardFormManager.getGuessedPM()?.isSecurityCodeRequired((bin)!))!){
                    self.confirmPaymentMethod()
                    return
                }
            }
            if (!self.validateExpirationDate()){
                showErrorMessage((cardFormManager.cardToken?.validateExpiryDate())!)
                
                return
            }
            self.prepareCVVLabelForEdit()
            
            
        case cvvLabel! :
            if (!self.validateCvv()){
                
                showErrorMessage(("Ingresa los %1$s números del código de seguridad".localized as NSString).replacingOccurrences(of: "%1$s", with: ((cardFormManager.getGuessedPM()?.secCodeLenght())! as NSNumber).stringValue))
                return
            }
            self.confirmPaymentMethod()
        default : updateLabelsFontColors()
        }
        updateLabelsFontColors()
    }
    
    func closeKeyboard(){
        textBox.resignFirstResponder()
        delightedLabels()
    }
    
    func clearCardSkin(){
        
        UIView.animate(withDuration: 0.7, animations: { () -> Void in
            self.cardFront?.cardLogo.alpha =  0
            self.cardView.backgroundColor = UIColor(netHex: 0xEEEEEE)
            })
        self.cardFront?.cardLogo.image =  nil
        let textMaskFormaterAux = TextMaskFormater(mask: "XXXX XXXX XXXX XXXX")
        let textEditMaskFormaterAux = TextMaskFormater(mask: "XXXX XXXX XXXX XXXX", completeEmptySpaces :false)
        
        cardNumberLabel?.text = textMaskFormaterAux.textMasked(textMaskFormater.textUnmasked(cardNumberLabel!.text))
        if (editingLabel == cardNumberLabel){
            textBox.text = textEditMaskFormaterAux.textMasked(textEditMaskFormater.textUnmasked(textBox.text))
        }
        textEditMaskFormater = textMaskFormaterAux
        textEditMaskFormater = textEditMaskFormaterAux
        cardFront?.cardCVV.alpha = 0
        cardFormManager.guessedPMS = nil
        self.updateLabelsFontColors()
        
    }
    
    func updateCardSkin(){
        guard let _ = cardFormManager.getBIN(textBox.text!) else{
            cardFormManager.guessedPMS = nil
            cardFormManager.cardToken = nil
            self.clearCardSkin()
            return
        }
        if (textEditMaskFormater.textUnmasked(textBox.text).characters.count==6 || cardFormManager.customerCard != nil || cardFormManager.cardToken != nil){
            let pmMatched = self.cardFormManager.matchedPaymentMethod(self.cardNumberLabel!.text!)
            cardFormManager.guessedPMS = pmMatched
            if(cardFormManager.getGuessedPM()  != nil){
                self.cardFront?.cardLogo.image =  MercadoPago.getImageFor(self.cardFormManager.getGuessedPM()!)
                UIView.animate(withDuration: 0.7, animations: { () -> Void in
                    self.cardView.backgroundColor = MercadoPago.getColorFor(self.cardFormManager.getGuessedPM()!)
                    self.cardFront?.cardLogo.alpha = 1
                })
                let labelMask = (cardFormManager.getGuessedPM()?.getLabelMask() != nil) ? cardFormManager.getGuessedPM()?.getLabelMask() : "XXXX XXXX XXXX XXXX"
                let editTextMask = (cardFormManager.getGuessedPM()?.getEditTextMask() != nil) ? cardFormManager.getGuessedPM()?.getEditTextMask() : "XXXX XXXX XXXX XXXX"
                let textMaskFormaterAux = TextMaskFormater(mask: labelMask)
                let textEditMaskFormaterAux = TextMaskFormater(mask:editTextMask, completeEmptySpaces :false)
                cardNumberLabel?.text = textMaskFormaterAux.textMasked(textMaskFormater.textUnmasked(cardNumberLabel!.text))
                if (editingLabel == cardNumberLabel){
                    textBox.text = textEditMaskFormaterAux.textMasked(textEditMaskFormater.textUnmasked(textBox.text))
                }
                if (editingLabel == cvvLabel){
                    editingLabel!.text = textBox.text
                    cvvLabel!.text = textBox.text
                }
                textMaskFormater = textMaskFormaterAux
                textEditMaskFormater = textEditMaskFormaterAux
            }else{
                self.clearCardSkin()
                showErrorMessage("Método de pago no soportado".localized)
                return
            }
            
        }
        if self.cvvLabel == nil || self.cvvLabel!.text!.characters.count == 0 {
            if((cardFormManager.guessedPMS != nil)&&(!(cardFormManager.getGuessedPM()?.secCodeInBack())!)){
                cvvLabel = cardFront?.cardCVV
                cardBack?.cardCVV.text = ""
                cardFront?.cardCVV.alpha = 1
                cardFront?.cardCVV.text = "••••".localized
                self.cardFormManager.cvvEmpty = true
            }else{
                cvvLabel = cardBack?.cardCVV
                cardFront?.cardCVV.text = ""
                cardFront?.cardCVV.alpha = 0
                cardBack?.cardCVV.text = "•••".localized
                self.cardFormManager.cvvEmpty = true
            }
        }
        
        self.updateLabelsFontColors()
    }
    
    func delightedLabels(){
        cardNumberLabel?.textColor = self.cardFormManager.getLabelTextColor()
        nameLabel?.textColor = self.cardFormManager.getLabelTextColor()
        expirationDateLabel?.textColor = self.cardFormManager.getLabelTextColor()
        
        cvvLabel?.textColor = MPLabel.defaultColorText
        cardNumberLabel?.alpha = 0.7
        nameLabel?.alpha =  0.7
        expirationDateLabel?.alpha = 0.7
        cvvLabel?.alpha = 0.7
    }
    
    func lightEditingLabel(){
        if (editingLabel != cvvLabel){
            editingLabel?.textColor = self.cardFormManager.getEditingLabelColor()
        }
        editingLabel?.alpha = 1
    }
    
    func updateLabelsFontColors(){
        self.delightedLabels()
        self.lightEditingLabel()
        
    }
    
    func markErrorLabel(_ label: UILabel){
        label.textColor = MPLabel.errorColorText
    }
    
    fileprivate func createSavedCardToken() -> CardToken {
        let securityCode = self.cardFormManager.customerCard!.isSecurityCodeRequired() ? self.cvvLabel?.text : nil
        return  SavedCardToken(card: cardFormManager.customerCard!, securityCode: securityCode, securityCodeRequired: self.cardFormManager.customerCard!.isSecurityCodeRequired())
    }
    
    func makeToken(){
        
        if (cardFormManager.token != nil){ // C4A
            let ct = CardToken()
            ct.securityCode = cvvLabel?.text
            self.callback!(cardFormManager.guessedPMS!, ct)
            return
        }
        
        if cardFormManager.customerCard != nil {
            self.cardFormManager.buildSavedCardToken(self.cvvLabel!.text!)
            if !cardFormManager.cardToken!.validate() {
                markErrorLabel(cvvLabel!)
            }
        } else if (self.cardFormManager.token != nil){ // C4A
            let ct = CardToken()
            ct.securityCode = cvvLabel?.text
            self.callback!(cardFormManager.guessedPMS!, ct)
            return
        } else {
            self.cardFormManager.tokenHidratate(cardNumberLabel!.text!, expirationDate: self.expirationDateLabel!.text!, cvv: self.cvvLabel!.text!, cardholderName : self.nameLabel!.text!)
            
            if (cardFormManager.guessedPMS != nil){
                let errorMethod = cardFormManager.cardToken!.validateCardNumber(cardFormManager.getGuessedPM()!)
                if((errorMethod) != nil){
                    markErrorLabel(cardNumberLabel!)
                    return
                }
            }else{
                
                markErrorLabel(cardNumberLabel!)
                return
            }
            
            let errorDate = cardFormManager.cardToken!.validateExpiryDate()
            if((errorDate) != nil){
                markErrorLabel(expirationDateLabel!)
                return
            }
            let errorName = cardFormManager.cardToken!.validateCardholderName()
            if((errorName) != nil){
                markErrorLabel(nameLabel!)
                return
            }
            let bin = self.cardFormManager.getBIN(self.cardNumberLabel!.text!)!
            if(cardFormManager.getGuessedPM()!.isSecurityCodeRequired(bin)){
                let errorCVV = cardFormManager.cardToken!.validateSecurityCode()
                if((errorCVV) != nil){
                    markErrorLabel(cvvLabel!)
                    UIView.transition(from: self.cardBack!, to: self.cardFront!, duration: 1, options: UIViewAnimationOptions.transitionFlipFromLeft, completion: nil)
                    return
                }
            }
        }
        
        self.callback!(cardFormManager.guessedPMS!, self.cardFormManager.cardToken!)
    }
    
    func addCvvDot() -> Bool {
        
        let label = self.cvvLabel
        //Check for max length including the spacers we added
        if label?.text?.characters.count == cardFormManager.cvvLenght(){
            return false
        }
        
        label?.text?.append("•")
        return true
        
    }
    
    func completeCvvLabel(){
        if (cvvLabel!.text?.replacingOccurrences(of: "•", with: "").characters.count == 0){
            cvvLabel?.text = cvvLabel?.text?.replacingOccurrences(of: "•", with: "")
            self.cardFormManager.cvvEmpty = true
        } else {
            self.cardFormManager.cvvEmpty = false
        }
        
        while (addCvvDot() != false){
            
        }
    }
    
    
    func confirmPaymentMethod(){
        self.textBox.resignFirstResponder()
        makeToken()
    }
    
    
    
    internal func validateCardNumber() -> Bool {
        return self.cardFormManager.validateCardNumber(self.cardNumberLabel!, expirationDateLabel: self.expirationDateLabel!, cvvLabel: self.cvvLabel!, cardholderNameLabel: self.nameLabel!)
    }
    
    internal func validateCardholderName() -> Bool {
        return self.cardFormManager.validateCardholderName(self.cardNumberLabel!, expirationDateLabel: self.expirationDateLabel!, cvvLabel: self.cvvLabel!, cardholderNameLabel: self.nameLabel!)
    }
    
    internal func validateCvv() -> Bool {
        return self.cardFormManager.validateCvv(self.cardNumberLabel!, expirationDateLabel: self.expirationDateLabel!, cvvLabel: self.cvvLabel!, cardholderNameLabel: self.nameLabel!)
    }
    
    
    internal func validateExpirationDate() -> Bool {
        return self.cardFormManager.validateExpirationDate(self.cardNumberLabel!, expirationDateLabel: self.expirationDateLabel!, cvvLabel: self.cvvLabel!, cardholderNameLabel: self.nameLabel!)
    }
    
}
