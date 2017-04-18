//
//  SecrurityCodeViewController.swift
//  MercadoPagoSDK
//
//  Created by Demian Tejo on 11/3/16.
//  Copyright © 2016 MercadoPago. All rights reserved.
//

import UIKit

open class SecurityCodeViewController: MercadoPagoUIViewController, UITextFieldDelegate{
    
    var securityCodeLabel: UILabel!
    @IBOutlet weak var securityCodeTextField: HoshiTextField!
    @IBOutlet weak var errorLabel: UILabel!
    
    @IBOutlet weak var panelView: UIView!
    var viewModel : SecurityCodeViewModel!
    @IBOutlet weak var button: UIButton!
    var textMaskFormater : TextMaskFormater!
    var cardFront : CardFrontView!
    var cardBack : CardBackView!
    var ccvLabelEmpty : Bool = true
    
    override open var screenName : String { get{ return "SECURITY_CODE" } }
    
    
    override open func viewDidLoad() {
        super.viewDidLoad()
         self.hideNavBar()
        loadMPStyles()
        self.button.setTitle("Continuar".localized,for: .normal)
        self.errorLabel.alpha = 0
        self.securityCodeTextField.placeholder = "security_code".localized
        self.errorLabel.text = "Revisa este dato".localized
        self.view.backgroundColor = UIColor.primaryColor()
        self.cardFront = CardFrontView.init(frame: viewModel.getCardBounds())
        self.cardBack = CardBackView.init(frame: viewModel.getCardBounds())
        if (viewModel.showFrontCard()){
            self.view.addSubview(cardFront)
            self.securityCodeLabel = cardFront.cardCVV
        }else{
             self.view.addSubview(cardBack)
            self.securityCodeLabel = cardBack.cardCVV
        }
        self.view.bringSubview(toFront: panelView)
        self.updateCardSkin(cardInformation: viewModel.cardInfo , paymentMethod: viewModel.paymentMethod)
        
        securityCodeTextField.autocorrectionType = UITextAutocorrectionType.no
        securityCodeTextField.keyboardType = UIKeyboardType.numberPad
        securityCodeTextField.addTarget(self, action: #selector(SecurityCodeViewController.editingChanged(_:)), for: UIControlEvents.editingChanged)
        securityCodeTextField.delegate = self
        completeCvvLabel()
    }

    override open func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    override public init(nibName nibNameOrNil: String?, bundle nibBundleOrNil: Bundle?) {
        super.init(nibName: nibNameOrNil, bundle: nibBundleOrNil)
    }
    
    required public init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }

    public init(viewModel : SecurityCodeViewModel, collectSecurityCodeCallback: @escaping (_ cardInformation: CardInformation, _ securityCode: String) -> Void ) {
        super.init(nibName: "SecurityCodeViewController", bundle: MercadoPago.getBundle())
        self.viewModel = viewModel
        self.viewModel.callback = collectSecurityCodeCallback
    }
    
    open override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        securityCodeTextField.becomeFirstResponder()
        self.button.titleLabel?.font = Utils.getFont(size: 16)
        
       
    }
    open override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        self.showNavBar()
    }
    
    override func loadMPStyles(){

        if self.navigationController != nil {
            self.navigationController!.interactivePopGestureRecognizer?.delegate = self
            self.navigationController?.navigationBar.tintColor = UIColor(red: 255, green: 255, blue: 255)
            self.navigationController?.navigationBar.barTintColor = UIColor.primaryColor()
            self.navigationController?.navigationBar.removeBottomLine()
            self.navigationController?.navigationBar.isTranslucent = false
            
            self.navigationController?.navigationBar.setValue(true, forKey: "hidesShadow") //saca linea molesta
            displayBackButton()
        }
    }
    
    
    @IBAction func cloneToken(_ sender: AnyObject) {
        securityCodeTextField.resignFirstResponder()
        guard securityCodeTextField.text?.characters.count == viewModel.secCodeLenght() else {
            showErrorMessage()
            return
        }
        self.viewModel.executeCallback(secCode:  securityCodeTextField.text)
    }
    
    func updateCardSkin(cardInformation: CardInformationForm?, paymentMethod: PaymentMethod?) {
        if viewModel.showFrontCard() {
            if let paymentMethod = paymentMethod{
                self.cardFront.cardLogo.alpha = 1
                if let token = cardInformation{
                    self.cardFront.cardLogo.image =  paymentMethod.getImage(bin: cardInformation?.getCardBin())
                    self.cardFront.backgroundColor = paymentMethod.getColor(bin: cardInformation?.getCardBin())
                    self.textMaskFormater = TextMaskFormater(mask: paymentMethod.getLabelMask(bin: cardInformation?.getCardBin()), completeEmptySpaces: true, leftToRight: false)
                    let fontColor = paymentMethod.getFontColor(bin: cardInformation?.getCardBin())
                    cardFront.cardNumber.textColor =  fontColor
                    cardFront.cardNumber.text =  self.textMaskFormater.textMasked(token.getCardLastForDigits())
                }
                cardFront.cardName.text = ""
                cardFront.cardExpirationDate.text = ""
                cardFront.cardNumber.alpha = 0.8
                cardFront.cardCVV.alpha = 0.8
                cardFront.layer.cornerRadius = 11
            }

        }else {
            if let paymentMethod = paymentMethod{
                self.cardBack.backgroundColor = paymentMethod.getColor(bin: cardInformation?.getCardBin())
                let fontColor = paymentMethod.getFontColor(bin: cardInformation?.getCardBin())
                cardBack.cardCVV.alpha = 0.8
                cardBack.cardCVV.textColor =  fontColor
                cardBack.layer.cornerRadius = 11
            }

        }
        
    }
    open func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        
        if (((textField.text?.characters.count)! + string.characters.count) > viewModel.secCodeLenght()){
            return false
        }
        return true
    }
    
    open func editingChanged(_ textField:UITextField){
        hideErrorMessage()
        securityCodeLabel.text = textField.text
        self.ccvLabelEmpty = (textField.text != nil && textField.text!.characters.count == 0)
        securityCodeLabel.textColor  = UIColor.black
        completeCvvLabel()
        
    }
    
    open func showErrorMessage(){
        self.errorLabel.alpha = 1
    }
    open func hideErrorMessage(){
        self.errorLabel.alpha = 0
    }

    func completeCvvLabel(){
        if (self.ccvLabelEmpty) {
            securityCodeLabel!.text = ""
        }
        
        while (addCvvDot() != false){
            
        }
        securityCodeLabel.textColor = UIColor.black
    }
    
    func addCvvDot() -> Bool {
        
        let label = self.securityCodeLabel
        //Check for max length including the spacers we added
        if label?.text?.characters.count == self.viewModel.secCodeLenght() {
            return false
        }
        
        label?.text?.append("•")
        return true
        
    }
}

open class SecurityCodeViewModel: NSObject {
    var paymentMethod : PaymentMethod!
    var cardInfo : CardInformationForm!
    
    var callback: ((_ cardInformation: CardInformation, _ securityCode: String) -> Void)?
    
    public init(paymentMethod : PaymentMethod, cardInfo : CardInformationForm){
        self.paymentMethod = paymentMethod
        self.cardInfo = cardInfo
    }
    
    public func showFrontCard() -> Bool {
        return !paymentMethod.secCodeInBack()
    }
    
    func secCodeInBack() -> Bool {
        return paymentMethod.secCodeInBack()
    }
    func secCodeLenght() -> Int {
        return paymentMethod.secCodeLenght()
    }
    
    func executeCallback(secCode : String!) {
        callback!(cardInfo as! CardInformation, secCode)
    }
    
    func getCardHeight() -> CGFloat {
        return getCardWidth() / 12 * 7
    }
    
    func getCardWidth() -> CGFloat {
        
        return (UIScreen.main.bounds.width - 100)
    }
    func getCardX() -> CGFloat {
        return ((UIScreen.main.bounds.width - getCardWidth())/2)
    }
    
    func getCardY() -> CGFloat {
        let y = (UIScreen.main.bounds.height - getCardHeight() - 375) / 2
        return y>10 ? y : 10
    }
    
    func getCardBounds() -> CGRect {
        return CGRect(x: getCardX(), y: getCardY(), width: getCardWidth(), height: getCardHeight())
    }
    
}

