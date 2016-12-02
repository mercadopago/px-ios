//
//  IdentificationViewController.swift
//  MercadoPagoSDK
//
//  Created by Demian Tejo on 5/3/16.
//  Copyright © 2016 MercadoPago. All rights reserved.
//

import UIKit

open class IdentificationViewController: MercadoPagoUIViewController , UITextFieldDelegate, UIPickerViewDataSource, UIPickerViewDelegate {

    
    @IBOutlet weak var tipoDeDocumentoLabel: UILabel!
    
    @IBOutlet weak var textField: UITextField!
    @IBOutlet weak var numberDocLabel: UILabel!
    @IBOutlet weak var numberTextField: HoshiTextField!
    var callback : (( Identification) -> Void)?
    var identificationTypes : [IdentificationType]?
    var identificationType : IdentificationType?
    var defaultMask = TextMaskFormater(mask: "XXX.XXX.XXX",completeEmptySpaces: true,leftToRight: false)
    var indentificationMask = TextMaskFormater(mask: "XXX.XXX.XXX",completeEmptySpaces: true,leftToRight: false)
     var editTextMask = TextMaskFormater(mask: "XXXXXXXXXXXXXX",completeEmptySpaces: false,leftToRight: false)

    @IBOutlet var typePicker: UIPickerView! = UIPickerView()
    
    
    override open var screenName : String { get { return "IDENTIFICATION_NUMBER" } }
    
    public init(callback : @escaping (( _ identification: Identification) -> Void), timer : CountdownTimer? = nil) {
        super.init(nibName: "IdentificationViewController", bundle: MercadoPago.getBundle())
        self.callback = callback
        self.timer = timer
    }
    
    override func loadMPStyles(){
        var titleDict : NSDictionary = [:]
        if self.navigationController != nil {
            if let font = UIFont(name: MercadoPago.DEFAULT_FONT_NAME, size: 18){
                titleDict = [NSForegroundColorAttributeName: UIColor.systemFontColor(), NSFontAttributeName: font]
            }
            if self.navigationController != nil {
                self.navigationController!.navigationBar.titleTextAttributes = titleDict as? [String : AnyObject]
                self.navigationItem.hidesBackButton = true
                self.navigationController!.interactivePopGestureRecognizer?.delegate = self
                self.navigationController?.navigationBar.tintColor = UIColor.white()
                self.navigationController?.navigationBar.barTintColor =  UIColor.primaryColor()
                self.navigationController?.navigationBar.removeBottomLine()
                self.navigationController?.navigationBar.isTranslucent = false
                displayBackButton()
            }
        }
        let pickerView = UIPickerView(frame: CGRect(x: 0, y: 150, width: view.frame.width, height: 216))
        pickerView.backgroundColor = .white()
        pickerView.showsSelectionIndicator = true
        pickerView.backgroundColor = .white()
        pickerView.showsSelectionIndicator = true
        pickerView.dataSource = self
        pickerView.delegate = self
        let toolBar = UIToolbar()
        toolBar.barStyle = UIBarStyle.default
        toolBar.sizeToFit()
        
        
        let doneButton = UIBarButtonItem(title: "OK".localized, style: .plain, target: self, action: #selector(IdentificationViewController.donePicker))
        let spaceButton = UIBarButtonItem(barButtonSystemItem: UIBarButtonSystemItem.flexibleSpace, target: nil, action: nil)
        
        if let font = UIFont(name:MercadoPago.DEFAULT_FONT_NAME, size: 14) {
            doneButton.setTitleTextAttributes([NSFontAttributeName: font], for: UIControlState())
          }

        toolBar.setItems([spaceButton, doneButton], animated: false)
        toolBar.isUserInteractionEnabled = true
        
        textField.inputView = pickerView
        textField.inputAccessoryView = toolBar

    }

    
    open func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
      
        if (string.characters.count < 1){
            return true
        }
        if(textField.text?.characters.count == identificationType!.maxLength){
            return false
        }
        return true
    }

    open func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        self.numberDocLabel.resignFirstResponder()
        return true
    }
    
    open func editingChanged(_ textField:UITextField) {
          hideErrorMessage()
       
         numberDocLabel.text = indentificationMask.textMasked(editTextMask.textUnmasked(textField.text))
         textField.text = editTextMask.textMasked(textField.text,remasked: true)
    
        
    }

    required public init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    open func donePicker(){
        textField.resignFirstResponder()
        numberTextField.becomeFirstResponder()
    }
    
    override open func viewDidLoad() {
        super.viewDidLoad()
        numberDocLabel.text = indentificationMask.textMasked("")
        self.tipoDeDocumentoLabel.text =  "DOCUMENTO DEL TITULAR DE LA TARJETA".localized
        self.numberTextField.placeholder = "Número".localized
        self.textField.placeholder = "Tipo".localized
        self.view.backgroundColor = UIColor.complementaryColor()
        numberTextField.autocorrectionType = UITextAutocorrectionType.no
        numberTextField.keyboardType = UIKeyboardType.numberPad
        numberTextField.addTarget(self, action: #selector(IdentificationViewController.editingChanged(_:)), for: UIControlEvents.editingChanged)

        self.setupInputAccessoryView()
        self.getIdentificationTypes()
        typePicker.isHidden = true;
        
        
    }
    open override func viewDidAppear(_ animated: Bool) {
        self.showLoading()
        super.viewDidAppear(animated)
        self.navigationItem.leftBarButtonItem!.action = #selector(invokeCallbackCancel)
    }

 open override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()

    }
    

    

    open func numberOfComponents(in pickerView: UIPickerView) -> Int{
        return 1
    }
   open  

    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int{
        if(self.identificationTypes == nil){
            return 0
        }
       
        return self.identificationTypes!.count
    }
    
    open func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        return self.identificationTypes![row].name
    }
    
    open func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int)
    {
        identificationType =  self.identificationTypes![row]
    //    typeButton.setTitle( self.identificationTypes![row].name, forState: .Normal)
        textField.text = self.identificationTypes![row].name
        typePicker.isHidden = true;
       self.remask()
    }
    
    @IBAction func setType(_ sender: AnyObject) {
        numberTextField.resignFirstResponder()
        typePicker.isHidden = false
        
    }

    var navItem : UINavigationItem?
    var doneNext : UIBarButtonItem?
    var donePrev : UIBarButtonItem?

    
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
        

        inputButtons!.pushItem(navItem!, animated: false)
        
        numberTextField.inputAccessoryView = inputButtons
        
        
    }

    func rightArrowKeyTapped(){
        let idnt = Identification(type: self.identificationType?.name , number: indentificationMask.textUnmasked(numberDocLabel.text))
        
        let cardToken = CardToken(cardNumber: "", expirationMonth: 10, expirationYear: 10, securityCode: "", cardholderName: "", docType: (self.identificationType?.type)!, docNumber:  indentificationMask.textUnmasked(numberDocLabel.text))

        if ((cardToken.validateIdentificationNumber(self.identificationType)) == nil){
            self.numberTextField.resignFirstResponder()
            self.callback!(idnt)
        }else{
            showErrorMessage((cardToken.validateIdentificationNumber(self.identificationType)?.userInfo["identification"] as? String)!)
        }
       
    }
    var inputButtons : UINavigationBar?
     var errorLabel : MPLabel?
    func showErrorMessage(_ errorMessage:String){
        errorLabel = MPLabel(frame: inputButtons!.frame)
        self.errorLabel!.backgroundColor = UIColor(netHex: 0xEEEEEE)
        self.errorLabel!.textColor = UIColor(netHex: 0xf04449)
        self.errorLabel!.text = errorMessage
        self.errorLabel!.textAlignment = .center
        self.errorLabel!.font = self.errorLabel!.font.withSize(12)
        numberTextField.borderInactiveColor = UIColor.red
        numberTextField.borderActiveColor = UIColor.red
        numberTextField.inputAccessoryView = errorLabel
        numberTextField.setNeedsDisplay()
        numberTextField.resignFirstResponder()
        numberTextField.becomeFirstResponder()
        
        
        
    }
    
    func hideErrorMessage(){
        self.numberTextField.borderInactiveColor = UIColor(netHex: 0x3F9FDA)
        self.numberTextField.borderActiveColor = UIColor(netHex: 0x3F9FDA)
        self.numberTextField.inputAccessoryView = self.inputButtons
        self.numberTextField.setNeedsDisplay()
        self.numberTextField.resignFirstResponder()
        self.numberTextField.becomeFirstResponder()
    }
    
    func leftArrowKeyTapped(){
        self.navigationController?.popViewController(animated: false)
        
    }
    
    fileprivate func getIdentificationTypes(){
        doneNext?.isEnabled = false
        MPServicesBuilder.getIdentificationTypes({ (identificationTypes) -> Void in
            self.hideLoading()
            self.doneNext?.isEnabled = true
            self.identificationTypes = identificationTypes
            self.typePicker.reloadAllComponents()
            self.identificationType =  self.identificationTypes![0]
            self.textField.text = self.identificationTypes![0].name
            self.numberTextField.becomeFirstResponder()
            self.remask()
            }, failure : { (error) -> Void in
                self.requestFailure(error, callback: {
                    self.dismiss(animated: true, completion: {})
                    self.getIdentificationTypes()
                    }, callbackCancel: {
                        if self.callbackCancel != nil {
                            self.callbackCancel!()
                        }
                    })
        })
    }
    
    
    fileprivate func remask(){
        if (self.identificationType!.name == "CPF"){
            self.indentificationMask = TextMaskFormater(mask: "XXX.XXX.XXX-XX",completeEmptySpaces: true,leftToRight: true)
        }else if (self.identificationType!.name == "CNPJ"){
            self.indentificationMask = TextMaskFormater(mask: "XX.XXX.XXX/XXXX-XX",completeEmptySpaces: true,leftToRight: true)
        }else{
            self.indentificationMask = defaultMask
        }
        self.numberTextField.text = ""
        self.numberDocLabel.text = indentificationMask.textMasked("")
    }
}



