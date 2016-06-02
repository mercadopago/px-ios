//
//  IdentificationViewController.swift
//  MercadoPagoSDK
//
//  Created by Demian Tejo on 5/3/16.
//  Copyright © 2016 MercadoPago. All rights reserved.
//

import UIKit

public class IdentificationViewController: MercadoPagoUIViewController , UITextFieldDelegate{

    
    
    @IBOutlet weak var numberDocLabel: UILabel!
    @IBOutlet weak var numberTextField: HoshiTextField!
    var callback : (( identification: Identification) -> Void)?
    var identificationTypes : [IdentificationType]?
    var identificationType : IdentificationType?
    @IBOutlet weak var typeButton: UIButton!

    @IBOutlet var typePicker: UIPickerView! = UIPickerView()
    

    
    public init(callback : (( identification: Identification) -> Void)) {
        super.init(nibName: "IdentificationViewController", bundle: MercadoPago.getBundle())
       
      //  self.edgesForExtendedLayout = UIRectEdge.None

        self.callback = callback
        
        
         
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
                //Create navigation buttons
                displayBackButton()
            }
        }
        
    }

    
    public func textField(textField: UITextField, shouldChangeCharactersInRange range: NSRange, replacementString string: String) -> Bool {
      
        if (string.characters.count < 1){
            return true
        }
        if(textField.text?.characters.count > 9){
            return false
        }
        return true
    }

    public func textFieldShouldReturn(textField: UITextField) -> Bool {
        self.numberDocLabel.resignFirstResponder()
        return true
    }
    
    public func editingChanged(textField:UITextField) {
          hideErrorMessage()
        if(textField.text?.characters.count > 0){
            let num : Int = Int(textField.text!)!
            let myIntString = num.stringFormatedWithSepator
            
            print(myIntString)
            numberDocLabel.text = myIntString
        }
        
    }

    required public init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    
    
    override public func viewDidLoad() {
        super.viewDidLoad()
        numberTextField.autocorrectionType = UITextAutocorrectionType.No
        numberTextField.keyboardType = UIKeyboardType.NumberPad
        numberTextField.addTarget(self, action: "editingChanged:", forControlEvents: UIControlEvents.EditingChanged)

        self.setupInputAccessoryView()
        self.getIdentificationTypes()
        typePicker.hidden = true;
        
    }
    public override func viewDidAppear(animated: Bool) {
        self.showLoading()
        super.viewDidAppear(animated)
        self.navigationItem.leftBarButtonItem!.action = Selector("invokeCallbackCancel")
    }

 public override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()

    }
    

    

    func numberOfComponentsInPickerView(pickerView: UIPickerView!) -> Int{
        return 1
    }
    

    func pickerView(pickerView: UIPickerView!, numberOfRowsInComponent component: Int) -> Int{
        if(self.identificationTypes == nil){
            return 0
        }
       
        return self.identificationTypes!.count
    }
    
    func pickerView(pickerView: UIPickerView!, titleForRow row: Int, forComponent component: Int) -> String! {
        return self.identificationTypes![row].name
    }
    
    func pickerView(pickerView: UIPickerView!, didSelectRow row: Int, inComponent component: Int)
    {
        identificationType =  self.identificationTypes![row]
        typeButton.setTitle( self.identificationTypes![row].name, forState: .Normal)
        typePicker.hidden = true;
    }
    
    @IBAction func setType(sender: AnyObject) {
        numberTextField.resignFirstResponder()
        typePicker.hidden = false
        
    }

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
        navItem!.rightBarButtonItem = doneNext
        navItem!.leftBarButtonItem = donePrev
        inputButtons!.pushNavigationItem(navItem!, animated: false)
        numberTextField.inputAccessoryView = inputButtons
        
        
    }

    func rightArrowKeyTapped(){
        let idnt = Identification(type: identificationType?.name , number: numberDocLabel.text?.stringByReplacingOccurrencesOfString(".", withString: ""))
        
        let cardToken = CardToken(cardNumber: "", expirationMonth: 10, expirationYear: 10, securityCode: "", cardholderName: "", docType: (identificationType?.type)!, docNumber:  (numberDocLabel.text?.stringByReplacingOccurrencesOfString(".", withString: ""))!)

        if ((cardToken.validateIdentificationNumber(identificationType)) == nil){
            self.numberTextField.resignFirstResponder()
            self.callback!(identification:idnt)
        }else{
            showErrorMessage((cardToken.validateIdentificationNumber(identificationType)?.userInfo["identification"] as? String)!)
        }
       
    }
    var inputButtons : UINavigationBar?
     var errorLabel : MPLabel?
    func showErrorMessage(errorMessage:String){
        errorLabel = MPLabel(frame: inputButtons!.frame)
        self.errorLabel!.backgroundColor = UIColor(netHex: 0xEEEEEE)
        self.errorLabel!.textColor = UIColor(netHex: 0xf04449)
        self.errorLabel!.text = errorMessage
        self.errorLabel!.textAlignment = .Center
        self.errorLabel!.font = self.errorLabel!.font.fontWithSize(12)
        numberTextField.borderInactiveColor = UIColor.redColor()
        numberTextField.borderActiveColor = UIColor.redColor()
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
        self.navigationController?.popViewControllerAnimated(false)
        
    }
    
    private func getIdentificationTypes(){
        doneNext?.enabled = false
        MPServicesBuilder.getIdentificationTypes({ (identificationTypes) -> Void in
            self.hideLoading()
            self.doneNext?.enabled = true
            self.identificationTypes = identificationTypes
            self.typePicker.reloadAllComponents()
            self.identificationType =  self.identificationTypes![0]
            self.typeButton.setTitle( self.identificationTypes![0].name, forState: .Normal)
            self.numberTextField.becomeFirstResponder()
            }, failure : { (error) -> Void in
                self.requestFailure(error)
        })
    }
}


struct Number {
    static let formatterWithSepator: NSNumberFormatter = {
        let formatter = NSNumberFormatter()
        formatter.groupingSeparator = "."
        formatter.numberStyle = .DecimalStyle
        return formatter
    }()
}
extension IntegerType {
    var stringFormatedWithSepator: String {
        return Number.formatterWithSepator.stringFromNumber(hashValue) ?? ""
    }
}

