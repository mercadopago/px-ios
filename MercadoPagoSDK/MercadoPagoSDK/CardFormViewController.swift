//
//  CardFormViewController.swift
//  MercadoPagoSDK
//
//  Created by Demian Tejo on 1/18/16.
//  Copyright © 2016 MercadoPago. All rights reserved.
//

import UIKit
import MercadoPagoTracker


public class CardFormViewController: MercadoPagoUIViewController , UITextFieldDelegate {


    
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
    
    var callback : (( paymentMethod: PaymentMethod,cardtoken: CardToken?) -> Void)?
    
    var textMaskFormater = TextMaskFormater(mask: "XXXX XXXX XXXX XXXX")
    var textEditMaskFormater = TextMaskFormater(mask: "XXXX XXXX XXXX XXXX", completeEmptySpaces :false)
   
    
    var inputButtons : UINavigationBar?
    var errorLabel : MPLabel?
    
    var navItem : UINavigationItem?
    var doneNext : UIBarButtonItem?
    var donePrev : UIBarButtonItem?
    
    var cardFormManager : CardViewModelManager?
    
    override public var screenName : String { get { return "CARD_NUMBER" } }
    
    
    
    required public init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    override func loadMPStyles(){
        
        if self.navigationController != nil {
            
            
            //Navigation bar colors
            let titleDict: NSDictionary = [NSForegroundColorAttributeName: UIColor.systemFontColor(), NSFontAttributeName: UIFont(name: MercadoPago.DEFAULT_FONT_NAME, size: 18)!]
            
            if self.navigationController != nil {
                self.navigationController!.navigationBar.titleTextAttributes = titleDict as? [String : AnyObject]
                self.navigationItem.hidesBackButton = true
                self.navigationController!.interactivePopGestureRecognizer?.delegate = self
                self.navigationController?.navigationBar.barTintColor = MercadoPagoContext.getPrimaryColor()
                self.navigationController?.navigationBar.removeBottomLine()
                self.navigationController?.navigationBar.translucent = false
                self.cardBackground.backgroundColor =  MercadoPagoContext.getComplementaryColor()
 
                var promocionesButton : UIBarButtonItem = UIBarButtonItem(title: "Ver promociones".localized, style: UIBarButtonItemStyle.Plain, target: self, action: "verPromociones")
                promocionesButton.tintColor = UIColor.systemFontColor()

                
                self.navigationItem.rightBarButtonItem = promocionesButton
       

                displayBackButton()
            }
        }
        
    }


    public init(paymentSettings : PaymentPreference?, amount:Double!, token: Token? = nil, cardInformation : CardInformation? = nil, paymentMethods : [PaymentMethod]? = nil,  callback : ((paymentMethod: PaymentMethod, cardToken: CardToken?) -> Void), callbackCancel : (Void -> Void)? = nil) {
        super.init(nibName: "CardFormViewController", bundle: MercadoPago.getBundle())
        self.cardFormManager = CardViewModelManager(amount: amount, paymentMethods: paymentMethods, customerCard: cardInformation, token: token, paymentSettings: paymentSettings)
        self.callbackCancel = callbackCancel
        self.callback = callback
    }
    
    override public init(nibName nibNameOrNil: String?, bundle nibBundleOrNil: NSBundle?) {
        super.init(nibName: nibNameOrNil, bundle: nibBundleOrNil)
    }
    
    public override func viewWillAppear(animated: Bool) {
        
        super.viewWillAppear(animated)
        
        updateLabelsFontColors()
        
        if(callbackCancel != nil){
            self.navigationItem.leftBarButtonItem?.target = self
            self.navigationItem.leftBarButtonItem!.action = Selector("invokeCallbackCancel")
        }
        
         textEditMaskFormater.emptyMaskElement = nil
       
    }
   
    public override func viewDidAppear(animated: Bool) {
        
        
        cardFront?.frame = cardView.bounds
        cardBack?.frame = cardView.bounds
        textBox.placeholder = "Número de tarjeta".localized
        textBox.becomeFirstResponder()


        
        self.updateCardSkin()
        //C4A

        
        if self.cardFormManager!.customerCard != nil {

            let textMaskFormaterAux = TextMaskFormater(mask: "XXXX XXXX XXXX XXXX", completeEmptySpaces: true)
            self.cardNumberLabel?.text = textMaskFormaterAux.textMasked(self.cardFormManager!.customerCard?.getCardBin(), remasked: false)
            self.cardNumberLabel?.text = textMaskFormaterAux.textMasked(self.cardFormManager!.customerCard?.getCardBin(), remasked: false)
            
            let textMaskFormaterAuxSec = TextMaskFormater(mask: "XXXX XXXX XXXX XXXX", completeEmptySpaces: true, leftToRight: false)
         //   textMaskFormaterAuxSec.textMasked(self.)
            self.prepareCVVLabelForEdit()
        }else if cardFormManager!.token != nil {
            let textMaskFormaterAux = TextMaskFormater(mask: "XXXX XXXX XXXX XXXX", completeEmptySpaces: true)
            self.cardNumberLabel?.text = textMaskFormaterAux.textMasked(cardFormManager!.token?.firstSixDigit, remasked: false)
            self.cardNumberLabel?.text = textMaskFormaterAux.textMasked(cardFormManager!.token?.firstSixDigit, remasked: false)
            
            let textMaskFormaterAuxSec = TextMaskFormater(mask: "XXXX XXXX XXXX XXXX", completeEmptySpaces: true, leftToRight: false)
            //   textMaskFormaterAuxSec.textMasked(self.)
            self.prepareCVVLabelForEdit()
            
            
        }

       
    }
    
    override public func viewDidLoad() {
        super.viewDidLoad()


        if (self.cardFormManager!.paymentMethods == nil){
            MPServicesBuilder.getPaymentMethods({ (paymentMethods) -> Void in

                self.updateCardSkin()

                self.cardFormManager?.paymentMethods = paymentMethods

                }) { (error) -> Void in
                    // Mensaje de error correspondiente, ver que hacemos con el flujo
            }
        }
 
        
        textBox.autocorrectionType = UITextAutocorrectionType.No
         textBox.keyboardType = UIKeyboardType.NumberPad
        textBox.addTarget(self, action: #selector(CardFormViewController.editingChanged(_:)), forControlEvents: UIControlEvents.EditingChanged)
        setupInputAccessoryView()
        textBox.delegate = self
        cardFront = CardFrontView()
        cardBack = CardBackView()

        cardBack!.backgroundColor = UIColor.clearColor()
        
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
        hidratateWithToken()
        cardView.addSubview(cardFront!)

    }


    public func textField(textField: UITextField, shouldChangeCharactersInRange range: NSRange, replacementString string: String) -> Bool {
        if (string.characters.count == 0){
            textField.text = textField.text!.stringByTrimmingCharactersInSet(
                NSCharacterSet.whitespaceAndNewlineCharacterSet()
                
            )
        }
        
        let value : Bool = validateInput(textField, shouldChangeCharactersInRange: range, replacementString: string)
        updateLabelsFontColors()

        return value
    }


    public func verPromociones(){
        self.navigationController?.presentViewController(UINavigationController(rootViewController: MPStepBuilder.startPromosStep()), animated: true, completion: {})
    }
    
    
    public func editingChanged(textField:UITextField){
    

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
    
    public func textFieldShouldReturn(textField: UITextField) -> Bool {
    
        if(editingLabel == nameLabel){
                self.prepareExpirationLabelForEdit()
        }
        return true
    }

    
    /* Metodos para formatear el texto ingresado de forma que se muestre
        de forma adecuada dependiendo de cada campo de texto */

    private func formatName(name:String) -> String{
        if(name.characters.count == 0){
            self.cardFormManager?.cardholderNameEmpty = true
            return "NOMBRE APELLIDO".localized
        }
        self.cardFormManager?.cardholderNameEmpty = false
        return name.uppercaseString
    }
    private func formatCVV(cvv:String) -> String{
               completeCvvLabel()
        return cvv
    }
    private func formatExpirationDate(expirationDate:String) -> String{
        if(expirationDate.characters.count == 0){
            expirationLabelEmpty = true
            return "MM/AA".localized
        }
        expirationLabelEmpty = false
        return expirationDate
    }
    
    
    /* Metodos para preparar los diferentes labels del formulario para ser editados */
    private func prepareNumberLabelForEdit(){
         MPTracker.trackScreenName(MercadoPagoContext.sharedInstance, screenName: "CARD_NUMBER")
        editingLabel = cardNumberLabel
        textBox.resignFirstResponder()
        textBox.keyboardType = UIKeyboardType.NumberPad
        textBox.becomeFirstResponder()
        textBox.text = textEditMaskFormater.textMasked(cardNumberLabel!.text?.trimSpaces())
        textBox.placeholder = "Número de tarjeta".localized
    }
    private func prepareNameLabelForEdit(){
         MPTracker.trackScreenName(MercadoPagoContext.sharedInstance, screenName: "CARD_HOLDER")
        editingLabel = nameLabel
        textBox.resignFirstResponder()
        textBox.keyboardType = UIKeyboardType.Alphabet
        textBox.becomeFirstResponder()
        textBox.text = cardFormManager!.cardholderNameEmpty ?  "" : nameLabel!.text!.stringByReplacingOccurrencesOfString(" ", withString: "")
        textBox.placeholder = "Nombre y apellido".localized

    }
    private func prepareExpirationLabelForEdit(){
         MPTracker.trackScreenName(MercadoPagoContext.sharedInstance, screenName: "CARD_EXPIRY_DATE")
        editingLabel = expirationDateLabel
        textBox.resignFirstResponder()
        textBox.keyboardType = UIKeyboardType.NumberPad
        textBox.becomeFirstResponder()
        textBox.text = expirationLabelEmpty ?  "" : expirationDateLabel!.text
        textBox.placeholder = "Fecha de expiración".localized
    }
    private func prepareCVVLabelForEdit(){
         MPTracker.trackScreenName(MercadoPagoContext.sharedInstance, screenName: "CARD_SECURITY_CODE")
        
        if(!self.cardFormManager!.isAmexCard(self.cardNumberLabel!.text!)){
            UIView.transitionFromView(self.cardFront!, toView: self.cardBack!, duration: 1, options: UIViewAnimationOptions.TransitionFlipFromLeft, completion: { (completion) -> Void in
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
        textBox.keyboardType = UIKeyboardType.NumberPad
        textBox.becomeFirstResponder()
        textBox.text = self.cardFormManager!.cvvEmpty  ?  "" : cvvLabel!.text!.stringByReplacingOccurrencesOfString(" ", withString: "")
        textBox.placeholder = "Código de seguridad".localized
    }
    
    
    /* Metodos para validar si un texto ingresado es valido, dependiendo del tipo
        de campo que se este llenando */
    
    func validateInput(textField: UITextField, shouldChangeCharactersInRange range: NSRange, replacementString string: String) -> Bool {
       
        switch editingLabel! {
        case cardNumberLabel! :
            if (string.characters.count == 0){
                return true
            }
            if(((textEditMaskFormater.textUnmasked(textField.text).characters.count) == 6) && (string.characters.count > 0)){
                if (cardFormManager!.paymentMethod == nil){
                    return false
                }
            }else{
                if ((textEditMaskFormater.textUnmasked(textField.text).characters.count) == cardFormManager!.paymentMethod?.cardNumberLenght()){
                    return false
                }
                
            }
           return true
       
        case nameLabel! : return validInputName(textField.text! + string)
       
        case expirationDateLabel! : return validInputDate(textField, shouldChangeCharactersInRange: range, replacementString: string)
        
        case cvvLabel! : return self.cardFormManager!.isValidInputCVV(textField.text! + string)
        default : return false
        }
    }
  
    
    func validInputName(text : String) -> Bool{
        return true
    }
    func validInputDate(textField: UITextField, shouldChangeCharactersInRange range: NSRange, replacementString string: String) -> Bool{
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
        let replacementText = string.stringByReplacingOccurrencesOfString("/", withString: "")
        
        //Verify entered text is a numeric value
        let digits = NSCharacterSet.decimalDigitCharacterSet()
        for char in replacementText.unicodeScalars
        {
            if !digits.longCharacterIsMember(char.value)
            {
                return false
            }
        }
        
        
        if originalText!.characters.count == 2
        {
            originalText?.appendContentsOf("/")
            textField.text = originalText
        }
        
        return true


    }
    

    func setupInputAccessoryView() {
        inputButtons = UINavigationBar(frame: CGRectMake(0, 0, UIScreen.mainScreen().bounds.size.width, 44))
        inputButtons!.barStyle = UIBarStyle.Default;
        inputButtons!.backgroundColor = UIColor(netHex: 0xEEEEEE);
        inputButtons!.alpha = 1;
        navItem = UINavigationItem()
        doneNext = UIBarButtonItem(title: "Continuar".localized, style: .Plain, target: self, action: #selector(CardFormViewController.rightArrowKeyTapped))
        
        donePrev =  UIBarButtonItem(title: "Anterior".localized, style: .Plain, target: self, action: #selector(CardFormViewController.leftArrowKeyTapped))
        if let font = UIFont(name:MercadoPago.DEFAULT_FONT_NAME, size: 14) {
            doneNext!.setTitleTextAttributes([NSFontAttributeName: font], forState: UIControlState.Normal)
            donePrev!.setTitleTextAttributes([NSFontAttributeName: font], forState: UIControlState.Normal)
        }
        donePrev?.setTitlePositionAdjustment(UIOffset(horizontal: UIScreen.mainScreen().bounds.size.width / 8, vertical: 0), forBarMetrics: UIBarMetrics.Default)
        doneNext?.setTitlePositionAdjustment(UIOffset(horizontal: -UIScreen.mainScreen().bounds.size.width / 8, vertical: 0), forBarMetrics: UIBarMetrics.Default)
        navItem!.rightBarButtonItem = doneNext
        navItem!.leftBarButtonItem = donePrev

        if self.cardFormManager!.customerCard != nil || self.cardFormManager!.token != nil{
            navItem!.leftBarButtonItem?.enabled = false
        }
        inputButtons!.pushNavigationItem(navItem!, animated: false)
        textBox.inputAccessoryView = inputButtons
       
        
    }
    
    func showErrorMessage(errorMessage:String){
        errorLabel = MPLabel(frame: inputButtons!.frame)
        self.errorLabel!.backgroundColor = UIColor(netHex: 0xEEEEEE)
        self.errorLabel!.textColor = UIColor(netHex: 0xf04449)
        self.errorLabel!.text = errorMessage
        self.errorLabel!.textAlignment = .Center
        self.errorLabel!.font = self.errorLabel!.font.fontWithSize(12)
        textBox.borderInactiveColor = UIColor.redColor()
        textBox.borderActiveColor = UIColor.redColor()
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
              if (self.cardFormManager!.paymentMethod!.secCodeInBack()){
                UIView.transitionFromView(self.cardBack!, toView: self.cardFront!, duration: 1, options: UIViewAnimationOptions.TransitionFlipFromRight, completion: { (completion) -> Void in
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
                if (cardFormManager!.paymentMethod != nil){
                    showErrorMessage((cardFormManager!.cardToken?.validateCardNumber(cardFormManager!.paymentMethod!)?.userInfo["cardNumber"] as? String)!)
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
            
            if (cardFormManager!.paymentMethod != nil){
                let bin = self.cardFormManager?.getBIN(self.cardNumberLabel!.text!)
                //TODO : esto te estalla en la cara cris
                if (!(cardFormManager!.paymentMethod?.isSecurityCodeRequired((bin)!))!){
                    self.confirmPaymentMethod()
                    return
                }
            }
            if (!self.validateExpirationDate()){
                showErrorMessage((cardFormManager!.cardToken?.validateExpiryDate()?.userInfo["expiryDate"] as? String)!)

                return
            }
            
            
            self.prepareCVVLabelForEdit()
            
            
            
        case cvvLabel! :
            if (!self.validateCvv()){
                
                showErrorMessage(("Ingresa los %1$s números del código de seguridad".localized as NSString).stringByReplacingOccurrencesOfString("%1$s", withString: ((cardFormManager!.paymentMethod?.secCodeLenght())! as NSNumber).stringValue))
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
        
        UIView.animateWithDuration(0.7, animations: { () -> Void in
            self.cardFront?.cardLogo.alpha =  0
            self.cardView.backgroundColor = UIColor(netHex: 0xEEEEEE)
            }) { (finish) -> Void in
                self.cardFront?.cardLogo.image =  nil
                
        }
        let textMaskFormaterAux = TextMaskFormater(mask: "XXXX XXXX XXXX XXXX")
        let textEditMaskFormaterAux = TextMaskFormater(mask: "XXXX XXXX XXXX XXXX", completeEmptySpaces :false)

        cardNumberLabel?.text = textMaskFormaterAux.textMasked(textMaskFormater.textUnmasked(cardNumberLabel!.text))
        if (editingLabel == cardNumberLabel){
            textBox.text = textEditMaskFormaterAux.textMasked(textEditMaskFormater.textUnmasked(textBox.text))
        }
        textEditMaskFormater = textMaskFormaterAux
        textEditMaskFormater = textEditMaskFormaterAux
        cardFront?.cardCVV.alpha = 0
        cardFormManager!.paymentMethod = nil
        self.updateLabelsFontColors()
        
    }
    
    func updateCardSkin(){
       

        if (textEditMaskFormater.textUnmasked(textBox.text).characters.count==6 || cardFormManager!.customerCard != nil || cardFormManager!.token != nil){
            let pmMatched = self.cardFormManager!.matchedPaymentMethod(self.cardNumberLabel!.text!)
            cardFormManager!.paymentMethod = pmMatched
            if(cardFormManager!.paymentMethod != nil){
                UIView.animateWithDuration(0.7, animations: { () -> Void in
               self.cardFront?.cardLogo.image =  MercadoPago.getImageFor(self.cardFormManager!.paymentMethod!)
                    self.cardView.backgroundColor = MercadoPago.getColorFor(self.cardFormManager!.paymentMethod!)
                    self.cardFront?.cardLogo.alpha = 1
                })
                let labelMask = (cardFormManager!.paymentMethod?.getLabelMask() != nil) ? cardFormManager!.paymentMethod?.getLabelMask() : "XXXX XXXX XXXX XXXX"
                let editTextMask = (cardFormManager!.paymentMethod?.getEditTextMask() != nil) ? cardFormManager!.paymentMethod?.getEditTextMask() : "XXXX XXXX XXXX XXXX"
                let textMaskFormaterAux = TextMaskFormater(mask: labelMask)
                let textEditMaskFormaterAux = TextMaskFormater(mask:editTextMask, completeEmptySpaces :false)
                cardNumberLabel?.text = textMaskFormaterAux.textMasked(textMaskFormater.textUnmasked(cardNumberLabel!.text))
                if (editingLabel == cardNumberLabel){
                    textBox.text = textEditMaskFormaterAux.textMasked(textEditMaskFormater.textUnmasked(textBox.text))
                }
                textMaskFormater = textMaskFormaterAux
                textEditMaskFormater = textEditMaskFormaterAux
            }else{
                self.clearCardSkin()
                showErrorMessage("Método de pago no soportado".localized)
                return
            }
            
        }else if (textBox.text?.characters.count<7){
            self.clearCardSkin()
        }
        
        if((cardFormManager!.paymentMethod != nil)&&(!cardFormManager!.paymentMethod!.secCodeInBack())){
            cvvLabel = cardFront?.cardCVV
            cardBack?.cardCVV.text = ""
            cardFront?.cardCVV.alpha = 1
            cardFront?.cardCVV.text = "••••".localized
            self.cardFormManager!.cvvEmpty = true
        }else{
            cvvLabel = cardBack?.cardCVV
            cardFront?.cardCVV.text = ""
            cardFront?.cardCVV.alpha = 0
            cardBack?.cardCVV.text = "•••".localized
            self.cardFormManager!.cvvEmpty = true
        }
        self.updateLabelsFontColors()
    }
    
    
    
    func delightedLabels(){
        cardNumberLabel?.textColor = self.cardFormManager!.getLabelTextColor()
        nameLabel?.textColor = self.cardFormManager!.getLabelTextColor()
        expirationDateLabel?.textColor = self.cardFormManager!.getLabelTextColor()
        
        cvvLabel?.textColor = MPLabel.defaultColorText
        cardNumberLabel?.alpha = 0.7
        nameLabel?.alpha =  0.7
        expirationDateLabel?.alpha = 0.7
        cvvLabel?.alpha = 0.7
        
        
    }
    
    func lightEditingLabel(){
        if (editingLabel != cvvLabel){
            editingLabel?.textColor = self.cardFormManager?.getEditingLabelColor()
        }
       editingLabel?.alpha = 1
    }
    
    func updateLabelsFontColors(){
        self.delightedLabels()
        self.lightEditingLabel()

    }
    
    func markErrorLabel(label: UILabel){
        label.textColor = MPLabel.errorColorText
    }
    
    private func createSavedCardToken() -> CardToken {
        let securityCode = self.cardFormManager!.customerCard!.isSecurityCodeRequired() ? self.cvvLabel?.text : nil
        return  SavedCardToken(card: cardFormManager!.customerCard!, securityCode: securityCode, securityCodeRequired: self.cardFormManager!.customerCard!.isSecurityCodeRequired())
    }
    
    func makeToken(){
        

        if (cardFormManager!.token != nil){ // C4A
            var ct = CardToken()
            ct.securityCode = cvvLabel?.text
            self.callback!(paymentMethod: cardFormManager!.paymentMethod!, cardtoken: ct)
            return
        }

        if cardFormManager!.customerCard != nil {
            self.cardFormManager!.buildSavedCardToken(self.cvvLabel!.text!)
            if !cardFormManager!.cardToken!.validate() {

                markErrorLabel(cvvLabel!)
            }
        } else {
            self.cardFormManager!.tokenHidratate(cardNumberLabel!.text!, expirationDate: self.expirationDateLabel!.text!, cvv: self.cvvLabel!.text!, cardholderName : self.nameLabel!.text!)
            
            if (cardFormManager!.paymentMethod != nil){
                let errorMethod = cardFormManager!.cardToken!.validateCardNumber(cardFormManager!.paymentMethod!)
                if((errorMethod) != nil){
                    markErrorLabel(cardNumberLabel!)
                    return
                }
            }else{
                
                markErrorLabel(cardNumberLabel!)
                return
            }
            
            let errorDate = cardFormManager!.cardToken!.validateExpiryDate()
            if((errorDate) != nil){
                markErrorLabel(expirationDateLabel!)
                return
            }
            let errorName = cardFormManager!.cardToken!.validateCardholderName()
            if((errorName) != nil){
                markErrorLabel(nameLabel!)
                return
            }
            let bin = self.cardFormManager!.getBIN(self.cardNumberLabel!.text!)!
            if(cardFormManager!.paymentMethod!.isSecurityCodeRequired(bin)){
                let errorCVV = cardFormManager!.cardToken!.validateSecurityCode()
                if((errorCVV) != nil){
                    markErrorLabel(cvvLabel!)
                    UIView.transitionFromView(self.cardBack!, toView: self.cardFront!, duration: 1, options: UIViewAnimationOptions.TransitionFlipFromLeft, completion: nil)
                    return
                }
            }
        }
        
        self.callback!(paymentMethod: self.cardFormManager!.paymentMethod!, cardtoken: self.cardFormManager!.cardToken!)
    }
    
    func addCvvDot() -> Bool {
    
        var label = self.cvvLabel
        //Check for max length including the spacers we added
        if label?.text?.characters.count == cardFormManager!.cvvLenght(){
            return false
        }
        
        label?.text?.appendContentsOf("•")
        return true

    }
    
    func completeCvvLabel(){
        if (cvvLabel!.text?.stringByReplacingOccurrencesOfString("•", withString: "").characters.count == 0){
            cvvLabel?.text = cvvLabel?.text?.stringByReplacingOccurrencesOfString("•", withString: "")
            self.cardFormManager!.cvvEmpty = true
        } else {
            self.cardFormManager!.cvvEmpty = false
        }
        
        while (addCvvDot() != false){
            
        }
    }

    
    func confirmPaymentMethod(){
        self.textBox.resignFirstResponder()
        makeToken()
    }
    
    
    func hidratateWithToken(){

        return
        if ( self.cardFormManager!.token == nil ){
            return
        }
        self.nameLabel?.text = self.cardFormManager!.token?.cardHolder?.name
        self.cardNumberLabel?.text = self.cardFormManager!.token?.getMaskNumber()
        self.expirationDateLabel?.text = self.cardFormManager!.token?.getExpirationDateFormated()
        self.updateCardSkin()
    }
    
    internal func validateCardNumber() -> Bool {
        return self.cardFormManager!.validateCardNumber(self.cardNumberLabel!, expirationDateLabel: self.expirationDateLabel!, cvvLabel: self.cvvLabel!, cardholderNameLabel: self.nameLabel!)
    }
    
    internal func validateCardholderName() -> Bool {
        return self.cardFormManager!.validateCardholderName(self.cardNumberLabel!, expirationDateLabel: self.expirationDateLabel!, cvvLabel: self.cvvLabel!, cardholderNameLabel: self.nameLabel!)
    }
    
    internal func validateCvv() -> Bool {
        return self.cardFormManager!.validateCvv(self.cardNumberLabel!, expirationDateLabel: self.expirationDateLabel!, cvvLabel: self.cvvLabel!, cardholderNameLabel: self.nameLabel!)
    }
    
    
    internal func validateExpirationDate() -> Bool {
        return self.cardFormManager!.validateExpirationDate(self.cardNumberLabel!, expirationDateLabel: self.expirationDateLabel!, cvvLabel: self.cvvLabel!, cardholderNameLabel: self.nameLabel!)
    }
    

}