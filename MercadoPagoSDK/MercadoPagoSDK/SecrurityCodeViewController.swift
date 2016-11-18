//
//  SecrurityCodeViewController.swift
//  MercadoPagoSDK
//
//  Created by Demian Tejo on 11/3/16.
//  Copyright © 2016 MercadoPago. All rights reserved.
//

import UIKit

open class SecrurityCodeViewController: MercadoPagoUIViewController, UITextFieldDelegate{
    
    @IBOutlet weak var securityCodeLabel: UILabel!
    @IBOutlet weak var securityCodeTextField: HoshiTextField!
    @IBOutlet weak var errorLabel: UILabel!
    
    @IBOutlet weak var panelView: UIView!
    var viewModel : SecrurityCodeViewModel!
    var textMaskFormater : TextMaskFormater!
    var cardFront : CardFrontView!
    var cardBack : CardBackView!
    
    override open func viewDidLoad() {
        super.viewDidLoad()
         self.hideNavBar()
        loadMPStyles()
        self.errorLabel.alpha = 0
        self.errorLabel.text = "Revisa este dato".localized
        self.view.backgroundColor = MercadoPagoContext.getPrimaryColor()
        self.cardFront = CardFrontView.init(frame: viewModel.getCardBounds())
        self.cardBack = CardBackView.init(frame: viewModel.getCardBounds())
        if (viewModel.showFrontCard()){
            self.view.addSubview(cardFront)
        }else{
             self.view.addSubview(cardBack)
        }
        self.view.bringSubview(toFront: panelView)
        self.updateCardSkin(token: viewModel.token , paymentMethod: viewModel.paymentMethod)
        
        securityCodeTextField.autocorrectionType = UITextAutocorrectionType.no
        securityCodeTextField.keyboardType = UIKeyboardType.numberPad
        securityCodeTextField.addTarget(self, action: #selector(SecrurityCodeViewController.editingChanged(_:)), for: UIControlEvents.editingChanged)
        securityCodeTextField.delegate = self
    }

    override open func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    public init(paymentMethod : PaymentMethod! ,token : Token!, callback: ((_ token: Token?)->Void)! ){
    
        super.init(nibName: "SecrurityCodeViewController", bundle: MercadoPago.getBundle())
        self.viewModel = SecrurityCodeViewModel(paymentMethod: paymentMethod, token: token, callback: callback)
        
    }
    
    override public init(nibName nibNameOrNil: String?, bundle nibBundleOrNil: Bundle?) {
        super.init(nibName: nibNameOrNil, bundle: nibBundleOrNil)
    }
    
    required public init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }

    
    open override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        securityCodeTextField.becomeFirstResponder()
       
    }
    open override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        self.showNavBar()
    }
    
    override func loadMPStyles(){
        if self.navigationController != nil {
            self.navigationController!.interactivePopGestureRecognizer?.delegate = self
            self.navigationController?.navigationBar.tintColor = UIColor(red: 255, green: 255, blue: 255)
            self.navigationController?.navigationBar.barTintColor = MercadoPagoContext.getPrimaryColor()
            self.navigationController?.navigationBar.removeBottomLine()
            self.navigationController?.navigationBar.isTranslucent = false
            
            self.navigationController?.navigationBar.setValue(true, forKey: "hidesShadow") //saca linea molesta
            displayBackButton()
        }
    }
    
    
    @IBAction func cloneToken(_ sender: AnyObject) {
        guard securityCodeTextField.text?.characters.count == viewModel.secCodeLenght() else {
            showErrorMessage()
            return
        }
        self.viewModel.cloneTokenAndCallback(secCode: securityCodeTextField.text)
    }
    
    func updateCardSkin(token: CardInformationForm?, paymentMethod: PaymentMethod?) {
        if viewModel.showFrontCard() {
            if let paymentMethod = paymentMethod{
                self.cardFront.cardLogo.image =  MercadoPago.getImageFor(paymentMethod)
                self.cardFront.backgroundColor = MercadoPago.getColorFor(paymentMethod)
                self.cardFront.cardLogo.alpha = 1
                let fontColor = MercadoPago.getFontColorFor(paymentMethod)!
                if let token = token{
                    self.textMaskFormater = TextMaskFormater(mask: paymentMethod.getLabelMask(), completeEmptySpaces: true, leftToRight: false)
                    cardFront.cardNumber.text =  self.textMaskFormater.textMasked(token.getCardLastForDigits())
                }
                cardFront.cardName.text = ""
                cardFront.cardExpirationDate.text = ""
                cardFront.cardNumber.alpha = 0.8
                cardFront.cardNumber.textColor =  fontColor
                cardFront.layer.cornerRadius = 11
            }

        }else {
            if let paymentMethod = paymentMethod{
                self.cardBack.backgroundColor = MercadoPago.getColorFor(paymentMethod)
                let fontColor = MercadoPago.getFontColorFor(paymentMethod)!
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
        //securityCodeLabel.text = textField.text
        
    }
    
    open func showErrorMessage(){
        self.errorLabel.alpha = 1
    }
    open func hideErrorMessage(){
        self.errorLabel.alpha = 0
    }

}

open class SecrurityCodeViewModel: NSObject {
    var paymentMethod : PaymentMethod!
    var token : Token!

    public init(paymentMethod : PaymentMethod! ,token : Token!, callback: ((_ token: Token?)->Void)! ){
        self.paymentMethod = paymentMethod
        self.token = token
        self.callback = callback
    }
    
    public func showFrontCard() -> Bool {
        return !paymentMethod.secCodeInBack()
    }
        
    var callback : ((_ token: Token?) -> Void)!
    
    func secCodeInBack() -> Bool {
        return paymentMethod.secCodeInBack()
    }
    func secCodeLenght() -> Int {
        return paymentMethod.secCodeLenght()
    }
    func cloneTokenAndCallback(secCode : String!) {
        MPServicesBuilder.cloneToken(token,securityCode:secCode, success: { (token) in
            self.callback(token)
            }, failure: { (error) in
            self.callback(nil) // VER
        })
    }
    
    func getCardHeight() -> CGFloat {
        return (UIScreen.main.bounds.height*0.27 - 35)
    }
    
    func getCardWidth() -> CGFloat {
        return (UIScreen.main.bounds.width - 144)
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

