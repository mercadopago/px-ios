//
//  CardFormViewController.swift
//  MercadoPagoSDK
//
//  Created by Demian Tejo on 1/18/16.
//  Copyright © 2016 MercadoPago. All rights reserved.
//

import UIKit

public class CardFormViewController: MercadoPagoUIViewController , UITextFieldDelegate {

    
    
    @IBOutlet weak var cardView: UIView!
    var cardViewBack:UIView?
 
    var cardFront : CardFrontView?
    var cardBack : CardBackView?
    
    var cardNumberLabel: UILabel?
    var numberLabelEmpty: Bool = true
    var nameLabel: MPLabel?
    var nameLabelEmpty: Bool = true
    var expirationDateLabel: MPLabel?
    var expirationLabelEmpty: Bool = true
    var cvvLabel: UILabel?
    var cvvLabelEmpty: Bool = true

    var editingLabel : UILabel?
    @IBOutlet weak var textBox: HoshiTextField!
   
    var paymentMethods : [PaymentMethod]?
    var paymentMethod : PaymentMethod?
    
    var token : Token?
    var cardToken : CardToken?
    
    var paymentSettings : PaymentPreference?
    var callback : (( paymentMethod: PaymentMethod,cardtoken: CardToken?) -> Void)?
    
    var amount : Double?
    
    //DNI
     var identificationCard : IdentificationCardView?
    
    
    
    
    required public init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    override func loadMPStyles(){
        
        if self.navigationController != nil {
            
            
            //Navigation bar colors
            let titleDict: NSDictionary = [NSForegroundColorAttributeName: UIColor.whiteColor(), NSFontAttributeName: UIFont(name: MercadoPago.DEFAULT_FONT_NAME, size: 18)!]
            
            if self.navigationController != nil {
                self.navigationController!.navigationBar.titleTextAttributes = titleDict as? [String : AnyObject]
                self.navigationItem.hidesBackButton = true
                self.navigationController!.interactivePopGestureRecognizer?.delegate = self
                self.navigationController?.navigationBar.tintColor = UIColor.whiteColor()
                self.navigationController?.navigationBar.barTintColor = UIColor(red: 90, green: 190, blue: 231)
                self.navigationController?.navigationBar.removeBottomLine()
                self.navigationController?.navigationBar.translucent = false
                
 
                var promocionesButton : UIBarButtonItem = UIBarButtonItem(title: "Ver promociones".localized, style: UIBarButtonItemStyle.Plain, target: self, action: "verPromociones")

                
                self.navigationItem.rightBarButtonItem = promocionesButton
                
                
                //Create navigation buttons
                displayBackButton()
            }
        }
        
    }


    public init(paymentSettings : PaymentPreference?, amount:Double!, token: Token? = nil,paymentMethods : [PaymentMethod]? = nil,  callback : ((paymentMethod: PaymentMethod, cardToken: CardToken?) -> Void), callbackCancel : (Void -> Void)? = nil) {
        super.init(nibName: "CardFormViewController", bundle: MercadoPago.getBundle())
        self.paymentSettings = paymentSettings
        self.token = token
        self.paymentMethods = paymentMethods
        self.callback = callback
        self.amount = amount
        self.callbackCancel = callbackCancel

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
        

    }
    
    public override func viewDidAppear(animated: Bool) {
        
        
        cardFront?.frame = cardView.bounds
        cardBack?.frame = cardView.bounds
      
        textBox.placeholder = "Número de tarjeta".localized
        textBox.becomeFirstResponder()

       
    }
  
    override public func viewDidLoad() {
        super.viewDidLoad()


        if (self.paymentMethods == nil){
            MPServicesBuilder.getPaymentMethods({ (paymentMethods) -> Void in
                self.paymentMethods = paymentMethods
                }) { (error) -> Void in
                    // Mensaje de error correspondiente, ver que hacemos con el flujo
            }
        }
 
        
        textBox.autocorrectionType = UITextAutocorrectionType.No
         textBox.keyboardType = UIKeyboardType.NumberPad
        textBox.addTarget(self, action: "editingChanged:", forControlEvents: UIControlEvents.EditingChanged)
        setupInputAccessoryView()
        textBox.delegate = self
        cardFront = CardFrontView()
        cardBack = CardBackView()
        identificationCard = IdentificationCardView()
        cardBack!.backgroundColor = UIColor.clearColor()
        
        cardNumberLabel = cardFront?.cardNumber
        nameLabel = cardFront?.cardName
        expirationDateLabel = cardFront?.cardExpirationDate
        cvvLabel = cardBack?.cardCVV
        
      //  cardNumberLabel!.addGestureRecognizer(UITapGestureRecognizer(target: self, action: "touchNumber:"))
        cardNumberLabel?.text = "•••• •••• •••• ••••"
     //   nameLabel!.addGestureRecognizer(UITapGestureRecognizer(target: self, action: "touchName:"))
        nameLabel?.text = "NOMBRE APELLIDO".localized
    //    expirationDateLabel!.addGestureRecognizer(UITapGestureRecognizer(target: self, action: "touchDate:"))
        expirationDateLabel?.text = "MM/AA".localized
     //   cvvLabel!.addGestureRecognizer(UITapGestureRecognizer(target: self, action: "touchCVV:"))
        cvvLabel?.text = "...".localized
        editingLabel = cardNumberLabel

        

        view.setNeedsUpdateConstraints()
        hidratateWithToken()
        cardView.addSubview(cardFront!)

    }


var changeNumber = false
    
    public func textField(textField: UITextField, shouldChangeCharactersInRange range: NSRange, replacementString string: String) -> Bool {
        let value : Bool = validateInput(textField, shouldChangeCharactersInRange: range, replacementString: string)
        updateLabelsFontColors()

        return value
    }


    public func verPromociones(){
        
        self.navigationController?.presentViewController(MPStepBuilder.startPromosStep(), animated: true, completion: {})
    }
    
    public func editingChanged(textField:UITextField){
        if (textField.text?.characters.last == " "){
            textField.text = textField.text!.substringToIndex(textField.text!.endIndex.predecessor())
        }
        hideErrorMessage()
        if(editingLabel == cardNumberLabel){
            editingLabel?.text = formatCardNumberText(textField.text!)
            if(!changeNumber){
                changeNumber = true
                completeNumberLabel()
                changeNumber = false
            }
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
    private func formatCardNumberText(numberText:String) -> String{
        if(numberText.characters.count == 0){
            numberLabelEmpty = true
            return "•••• •••• •••• ••••"
        }
        numberLabelEmpty = false
        return numberText
    }
    
    private func formatName(name:String) -> String{
        if(name.characters.count == 0){
            nameLabelEmpty = true
            return "NOMBRE APELLIDO".localized
        }
        nameLabelEmpty = false
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
        editingLabel = cardNumberLabel
        textBox.resignFirstResponder()
        textBox.keyboardType = UIKeyboardType.NumberPad
        textBox.becomeFirstResponder()
        textBox.text = numberLabelEmpty ?  "" : cardNumberLabel!.text
        textBox.placeholder = "Número de tarjeta".localized
    }
    private func prepareNameLabelForEdit(){
        editingLabel = nameLabel
        textBox.resignFirstResponder()
        textBox.keyboardType = UIKeyboardType.Alphabet
        textBox.becomeFirstResponder()
        textBox.text = nameLabelEmpty ?  "" : nameLabel!.text!.stringByReplacingOccurrencesOfString(" ", withString: "")
        textBox.placeholder = "Nombre y apellido".localized

    }
    private func prepareExpirationLabelForEdit(){
        editingLabel = expirationDateLabel
        textBox.resignFirstResponder()
        textBox.keyboardType = UIKeyboardType.NumberPad
        textBox.becomeFirstResponder()
        textBox.text = expirationLabelEmpty ?  "" : expirationDateLabel!.text
        textBox.placeholder = "Fecha de expiración".localized
    }
    private func prepareCVVLabelForEdit(){
        if(isAmexCard()){
            cvvLabel = cardFront?.cardCVV
            cardBack?.cardCVV.text = "••••".localized
            cardBack?.cardCVV.alpha = 0
            cardFront?.cardCVV.alpha = 1
        }else{
            cvvLabel = cardBack?.cardCVV
            cardFront?.cardCVV.text = "•••".localized
            cardFront?.cardCVV.alpha = 0
            cardBack?.cardCVV.alpha = 1
        }
        editingLabel = cvvLabel
        textBox.resignFirstResponder()
        textBox.keyboardType = UIKeyboardType.NumberPad
        textBox.becomeFirstResponder()
        textBox.text = cvvLabelEmpty  ?  "" : cvvLabel!.text!.stringByReplacingOccurrencesOfString(" ", withString: "")
        textBox.placeholder = "Código de seguridad".localized
    }
    
    
    /* Metodos para escucha de los touch sobre los labels */
    func touchNumber(sender:UITapGestureRecognizer){
        prepareNumberLabelForEdit()
        updateLabelsFontColors()
    }
    func touchName(sender:UITapGestureRecognizer){
        prepareNameLabelForEdit()
        updateLabelsFontColors()
    }
    func touchDate(sender:UITapGestureRecognizer){
        prepareExpirationLabelForEdit()
        updateLabelsFontColors()
    }
    func touchCVV(sender:UITapGestureRecognizer){
        prepareCVVLabelForEdit()
        updateLabelsFontColors()
    }

    /* Metodos para validar si un texto ingresado es valido, dependiendo del tipo
        de campo que se este llenando */
    
    func validateInput(textField: UITextField, shouldChangeCharactersInRange range: NSRange, replacementString string: String) -> Bool {
       
        
        switch editingLabel! {
       
        case cardNumberLabel! :
            if(((textField.text?.characters.count)! == 7) && (string.characters.count > 0)){
                if (paymentMethod == nil){
                    return false
                }
            }
            if(isAmexCard()){
                return validAmexInputNumber(textField, shouldChangeCharactersInRange: range, replacementString: string)
            }else{
                return validInputNumber(textField, shouldChangeCharactersInRange: range, replacementString: string)
            }

       
        case nameLabel! : return validInputName(textField.text! + string)
       
        case expirationDateLabel! : return validInputDate(textField, shouldChangeCharactersInRange: range, replacementString: string)
        
        case cvvLabel! : return validInputCVV(textField.text! + string)
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
    
    
    func validInputCVV(text : String) -> Bool{
        if( text.characters.count > self.cvvLenght() ){
            return false
        }
        let num = Int(text)
        return (num != nil)
    }
    
    func cvvLenght() -> Int{
        var lenght : Int
        
        if ((paymentMethod?.settings == nil)||(paymentMethod?.settings.count == 0)){
            lenght = 3 // Default
        }else{
            lenght = (paymentMethod?.settings[0].securityCode.length)!
        }
        return lenght
    }
    
    
    var inputButtons : UINavigationBar?
    var errorLabel : MPLabel?
    
    var navItem : UINavigationItem?
    var doneNext : UIBarButtonItem?
    var donePrev : UIBarButtonItem?

    func setupInputAccessoryView() {
        inputButtons = UINavigationBar(frame: CGRectMake(0, 0, UIScreen.mainScreen().bounds.size.width, 44))
        inputButtons!.barStyle = UIBarStyle.Default;
        inputButtons!.backgroundColor = UIColor(netHex: 0xEEEEEE);
        inputButtons!.alpha = 1;
        navItem = UINavigationItem()
        
        
        doneNext = UIBarButtonItem(title: "Continuar", style: .Plain, target: self, action: "rightArrowKeyTapped")
        donePrev =  UIBarButtonItem(title: "Anterior", style: .Plain, target: self, action: "leftArrowKeyTapped")
        
        if let font = UIFont(name:MercadoPago.DEFAULT_FONT_NAME, size: 14) {
            doneNext!.setTitleTextAttributes([NSFontAttributeName: font], forState: UIControlState.Normal)
            donePrev!.setTitleTextAttributes([NSFontAttributeName: font], forState: UIControlState.Normal)
        }
        
        
        donePrev?.setTitlePositionAdjustment(UIOffset(horizontal: UIScreen.mainScreen().bounds.size.width / 8, vertical: 0), forBarMetrics: UIBarMetrics.Default)
        doneNext?.setTitlePositionAdjustment(UIOffset(horizontal: -UIScreen.mainScreen().bounds.size.width / 8, vertical: 0), forBarMetrics: UIBarMetrics.Default)
        navItem!.rightBarButtonItem = doneNext
        navItem!.leftBarButtonItem = donePrev
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
              if (self.paymentMethod!.secCodeInBack()){
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
            if (checkCardNumber() == false){
                if (paymentMethod != nil){
                        showErrorMessage((cardtoken?.validateCardNumber(paymentMethod!)?.userInfo["cardNumber"] as? String)!)
                }else{
                    if (cardNumberLabel?.text?.characters.count == 0){
                        showErrorMessage("Ingresa el número de la tarjeta de crédito")
                    }else{
                        showErrorMessage("Revisa este dato")
                    }

                }

                return
            }
            prepareNameLabelForEdit()
            
        case nameLabel! :
          if (checkCardName() == false){
                showErrorMessage("Ingresa el nombre y apellido impreso en la tarjeta")

                return
            }
            prepareExpirationLabelForEdit()
            
        case expirationDateLabel! :
            if (checkExpirationDateCard() == false){
                showErrorMessage((cardtoken?.validateExpiryDate()?.userInfo["expiryDate"] as? String)!)

                return
            }
            if(!isAmexCard()){
                UIView.transitionFromView(self.cardFront!, toView: self.cardBack!, duration: 1, options: UIViewAnimationOptions.TransitionFlipFromLeft, completion: { (completion) -> Void in
                    self.updateLabelsFontColors()
                })
            }
            
            self.prepareCVVLabelForEdit()
            
        case cvvLabel! :
            if (checkCVV() == false){
                
                showErrorMessage("Ingresa los " + ((paymentMethod?.secCodeLenght())! as NSNumber).stringValue + " números del código de seguridad")
                
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
    
    func getBIN() -> String?{
        if(numberLabelEmpty){
            return nil
        }
        let trimmedNumber = cardNumberLabel?.text?.stringByReplacingOccurrencesOfString(" ", withString: "")
        
        
        if (trimmedNumber!.characters.count < 6){
            return nil
        }else{
            let bin = trimmedNumber!.substringToIndex((trimmedNumber?.startIndex.advancedBy(6))!)
            return bin
        }
    }
    
    func matchedPaymentMethod () -> PaymentMethod? {
        if(paymentMethods == nil){
            return nil
        }
        if(getBIN() == nil){
            return nil
        }
        
        
        for (_, value) in paymentMethods!.enumerate() {
            
            if (value.conformsPaymentPreferences(self.paymentSettings)){
                if (value.conformsToBIN(getBIN()!)){
                    return value.cloneWithBIN(getBIN()!)
                }
            }
                
        }
        return nil
    }
    
    func clearCardSkin(){
        
        UIView.animateWithDuration(0.7, animations: { () -> Void in
            self.cardFront?.cardLogo.alpha =  0
            self.cardView.backgroundColor = UIColor(netHex: 0xEEEEEE)
            }) { (finish) -> Void in
                self.cardFront?.cardLogo.image =  nil
                
        }
        cardFront?.cardCVV.alpha = 0
        paymentMethod = nil
        self.updateLabelsFontColors()
        
    }
    
    func updateCardSkin(){
       
        if (textBox.text?.characters.count==7){
            let pmMatched = self.matchedPaymentMethod()
            
               paymentMethod = pmMatched
            if(paymentMethod != nil){
                UIView.animateWithDuration(0.7, animations: { () -> Void in
               self.cardFront?.cardLogo.image =  MercadoPago.getImageFor(self.paymentMethod!)
                    self.cardView.backgroundColor = MercadoPago.getColorFor(self.paymentMethod!)
                    self.cardFront?.cardLogo.alpha = 1
                })
                
               
            }else{
                self.clearCardSkin()
                showErrorMessage("Método de pago no soportado".localized)
                return
            }
        }else if (textBox.text?.characters.count<7){
            self.clearCardSkin()
        }
        
        if((paymentMethod != nil)&&(!paymentMethod!.secCodeInBack())){
            cvvLabel = cardFront?.cardCVV
            cardBack?.cardCVV.text = ""
            cardFront?.cardCVV.alpha = 1
             cardFront?.cardCVV.text = "••••".localized
            cvvLabelEmpty = true
        }else{
            cvvLabel = cardBack?.cardCVV
            cardFront?.cardCVV.text = ""
            cardFront?.cardCVV.alpha = 0
            cardBack?.cardCVV.text = "•••".localized
            cvvLabelEmpty = true
        }
        self.updateLabelsFontColors()
    }
    
    func isAmexCard() -> Bool{
        if(getBIN() == nil){
            return false
        }
        if(paymentMethod != nil){
            return paymentMethod!.isAmex()
        }else{
            return false
        }
    }
    
    
    
    func delightedLabels(){
        if (paymentMethod == nil){
            cardNumberLabel?.textColor = MPLabel.defaultColorText
            nameLabel?.textColor = MPLabel.defaultColorText
            expirationDateLabel?.textColor = MPLabel.defaultColorText
        }else{
            cardNumberLabel?.textColor = MercadoPago.getFontColorFor(self.paymentMethod!)
            nameLabel?.textColor = MercadoPago.getFontColorFor(self.paymentMethod!)
            expirationDateLabel?.textColor = MercadoPago.getFontColorFor(self.paymentMethod!)
            
        }
        cvvLabel?.textColor = MPLabel.defaultColorText
        cardNumberLabel?.alpha = 0.7
        nameLabel?.alpha =  0.7
        expirationDateLabel?.alpha = 0.7
        cvvLabel?.alpha = 0.7
        
        
    }
    
    func lightEditingLabel(){
        if (editingLabel != cvvLabel){
            if (paymentMethod == nil){
                editingLabel?.textColor = MPLabel.highlightedColorText
            }else{
                editingLabel?.textColor =  MercadoPago.getEditingFontColorFor(self.paymentMethod!)
            }

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
    
    
    var cardtoken : CardToken?
    
    func tokenHidratate(){
        let number =  numberLabelEmpty ? "" :cardNumberLabel?.text
        let month = getMonth()
        let year = getYear()
        let secCode = cvvLabelEmpty ? "" :cvvLabel?.text
        let name = nameLabelEmpty ? "" : nameLabel?.text
        
        cardtoken = CardToken(cardNumber: number, expirationMonth: month, expirationYear: year, securityCode: secCode, cardholderName: name!, docType: "", docNumber: "")
        
    }
    
    func checkCardNumber() -> Bool{
        
        if(self.paymentMethod == nil){
            return false
        }
        tokenHidratate()
        let errorMethod = cardtoken!.validateCardNumber(paymentMethod!)
        if((errorMethod) != nil){
            return false
        }
        return true
    }
    func checkCardName() -> Bool{
        tokenHidratate()
        if ( cardtoken!.validateCardholderName() != nil ){
            return false
        }
        return true
    }
    func checkExpirationDateCard() -> Bool{
         tokenHidratate()
        let errorMethod = cardtoken!.validateExpiryDate()
        if((errorMethod) != nil){
            return false
        }
        return true
    }
    func checkCVV() -> Bool{
         tokenHidratate()
        if (cvvLabel?.text?.stringByReplacingOccurrencesOfString("•", withString: "").characters.count < paymentMethod?.secCodeLenght()){
            return false
        }
        let errorMethod = cardtoken!.validateSecurityCode()
        if((errorMethod) != nil){
            return false
        }
        return true
    }
    
    func makeToken(){
        tokenHidratate()
        
        if (paymentMethod != nil){ 
            let errorMethod = cardtoken!.validateCardNumber(paymentMethod!)
            if((errorMethod) != nil){
                markErrorLabel(cardNumberLabel!)
                return
            }
        }else{

                markErrorLabel(cardNumberLabel!)
                return
        }
        
        let errorDate = cardtoken!.validateExpiryDate()
        if((errorDate) != nil){
            markErrorLabel(expirationDateLabel!)
            return
        }
        let errorName = cardtoken!.validateCardholderName()
        if((errorName) != nil){
            markErrorLabel(nameLabel!)
            return
        }
        let errorCVV = cardtoken!.validateSecurityCode()
        if((errorCVV) != nil){
            markErrorLabel(cvvLabel!)
            UIView.transitionFromView(self.cardBack!, toView: self.cardFront!, duration: 1, options: UIViewAnimationOptions.TransitionFlipFromLeft, completion: nil)
            return
        }

        
         self.callback!(paymentMethod: self.paymentMethod!, cardtoken: cardtoken)
    }
    
    
    func getMonth()->Int{
        let stringMMYY = expirationDateLabel?.text?.stringByReplacingOccurrencesOfString("/", withString: "")
        let validInt = Int(stringMMYY!)
        if(validInt == nil){
            return 0
        }
        let floatMMYY = Float(validInt! / 100)
        let mm : Int = Int(floor(floatMMYY))
        return mm
    }
    func getYear()->Int{
        let stringMMYY = expirationDateLabel?.text?.stringByReplacingOccurrencesOfString("/", withString: "")
        let validInt = Int(stringMMYY!)
        if(validInt == nil){
            return 0
        }
        let floatMMYY = Float( validInt! / 100 )
        let mm : Int = Int(floor(floatMMYY))
        let yy = Int(stringMMYY!)! - (mm*100)
        return yy
    }
    
    
    
    func completeNumberLabel(){
        if (cardNumberLabel!.text?.stringByReplacingOccurrencesOfString("•", withString: "").characters.count == 0){
            cardNumberLabel?.text = cardNumberLabel?.text?.stringByReplacingOccurrencesOfString("•", withString: "")
        }
        
        while (addDot() != false){
            
        }
    }
    
    
    func addCvvDot() -> Bool {
    
        var label = self.cvvLabel
        //Check for max length including the spacers we added
        if label?.text?.characters.count == cvvLenght(){
            return false
        }
        
        label?.text?.appendContentsOf("•")
        return true

    }
    
    func completeCvvLabel(){
        if (cvvLabel!.text?.stringByReplacingOccurrencesOfString("•", withString: "").characters.count == 0){
            cvvLabel?.text = cvvLabel?.text?.stringByReplacingOccurrencesOfString("•", withString: "")
            cvvLabelEmpty = true
        } else {
            cvvLabelEmpty = false
        }
        
        while (addCvvDot() != false){
            
        }
    }

    
    func confirmPaymentMethod(){
        self.textBox.resignFirstResponder()
        makeToken()
    }
    
    
    func hidratateWithToken(){
        if ( self.token == nil ){
            return
        }
        self.nameLabel?.text = self.token?.cardHolder?.name
        self.cardNumberLabel?.text = self.token?.getMaskNumber()
        self.expirationDateLabel?.text = self.token?.getExpirationDateFormated()
    }

    
    
    
    func validInputNumber(textField: UITextField, shouldChangeCharactersInRange range: NSRange, replacementString string: String) -> Bool{
        
        if (textField.text?.characters.count == 0){
            return true
        }
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
        if range.location == 19
        {
            return false
        }
        
        var originalText = textField.text
        let replacementText = string.stringByReplacingOccurrencesOfString(" ", withString: "")
        
        //Verify entered text is a numeric value
        let digits = NSCharacterSet.decimalDigitCharacterSet()
        for char in replacementText.unicodeScalars
        {
            if !digits.longCharacterIsMember(char.value)
            {
                return false
            }
        }
        
        //Put an empty space after every 4 places
        if (originalText!.stringByReplacingOccurrencesOfString(" ", withString: "").characters.count % 4 == 0)
        {
            originalText?.appendContentsOf(" ")
            textField.text = originalText
        }
        
        return true
        
        
    }
    func validAmexInputNumber(textField: UITextField, shouldChangeCharactersInRange range: NSRange, replacementString string: String) -> Bool{
        
        if range.length > 0
        {
            return true
        }
        
        //Dont allow empty strings
        if string == " "
        {
            return false
        }
        var originalText = textField.text
        let numberOfDigits = originalText!.stringByReplacingOccurrencesOfString(" ", withString: "").characters.count
        let replacementText = string.stringByReplacingOccurrencesOfString(" ", withString: "")
         let numberOfDigitsToAdd = replacementText.characters.count
        //Check for max length including the spacers we added
        if (numberOfDigits + numberOfDigitsToAdd) > 15
        {
            return false
        }
        
        
        
        
        //Verify entered text is a numeric value
        let digits = NSCharacterSet.decimalDigitCharacterSet()
        for char in replacementText.unicodeScalars
        {
            if !digits.longCharacterIsMember(char.value)
            {
                return false
            }
        }
        
        
        if ((numberOfDigits == 4)||(numberOfDigits == 10))
        {
            originalText?.appendContentsOf(" ")
            textField.text = originalText
        }
        
        return true
        
        
    }
    
    
    
    
    func addDot() -> Bool{
        if ((paymentMethod == nil) || (!paymentMethod!.isAmex())){
            return addDotDefault()
        } else {
            return  addDotAmex()
        }
    }
    
    func addDotAmex() -> Bool{
        

        var label = cardNumberLabel
   
        
        if label?.text?.characters.count == 19
        {
            return false
        }

        
        let digits = (label?.text?.stringByReplacingOccurrencesOfString(" ", withString: "").characters.count)!
        
        if ( digits == 4) ||  ( digits == 9)
        {
            
            label?.text?.appendContentsOf(" ")
            label?.text = label?.text?.stringByReplacingOccurrencesOfString("  ", withString: " •")
        }
        if (label?.text?.characters.count < 17){
            label?.text?.appendContentsOf("•")
        }else{
            label?.text?.appendContentsOf(" ")
        }
        
        return true
        
    }

    func addDotDefault() -> Bool{
        
        var label = cardNumberLabel
        
        
        //Check for max length including the spacers we added
        if label?.text?.characters.count == 19
        {
            return false
        }
        
        if ((label?.text?.stringByReplacingOccurrencesOfString(" ", withString: "").characters.count)! % 4 == 0)
        {
            
            label?.text?.appendContentsOf(" ")
            label?.text = label?.text?.stringByReplacingOccurrencesOfString("  ", withString: " •")
        }
        label?.text?.appendContentsOf("•")
        return true
        
        
    }

    
    
    
}
