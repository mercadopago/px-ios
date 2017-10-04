//
//  PayerInfoViewController.swift
//  MercadoPagoSDK
//
//  Created by Demian Tejo on 9/29/17.
//  Copyright © 2017 MercadoPago. All rights reserved.
//

import UIKit

class PayerInfoViewController: MercadoPagoUIViewController, UITextFieldDelegate, InputComponentListener {
    
    let KEYBOARD_HEIGHT : CGFloat = 216.0
    let ACCESORY_VIEW_HEIGHT : CGFloat = 44.0
    let INPUT_VIEW_HEIGHT : CGFloat = 83.0
    var currentInput : UIView!
    var viewModel : PayerInfoViewModel!
    var callback : ((_ payer: Payer) -> Void)?
    
    
    init(viewModel:PayerInfoViewModel, callback: ((_ payer: Payer) -> Void)? ) {
        super.init(nibName: nil, bundle: nil)
        self.viewModel = viewModel
        self.callback = callback
        NotificationCenter.default.addObserver(self, selector: #selector(PayerInfoViewController.keyboardWasShown(_:)), name: NSNotification.Name.UIKeyboardWillChangeFrame, object: nil)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupView()
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    var identificationComponent: CompositeInputComponent?
    var secondNameComponent: SimpleInputComponent?
    var firstNameComponent: SimpleInputComponent?
    var boletoComponent: BoletoComponent?
    
    func setupView(){
        let screenSize = UIScreen.main.bounds
        let screenWidth = screenSize.width
        let screenHeight = screenSize.height
        var barsHeight = UIApplication.shared.statusBarFrame.height
        barsHeight += self.navigationController?.navigationBar.frame.height != nil ? (self.navigationController?.navigationBar.frame.height)! : CGFloat(0.0)
        var availableHeight = screenHeight - barsHeight
        
        availableHeight = keyboardFrame != nil ? availableHeight - (keyboardFrame?.height)! : availableHeight
        
        if self.identificationComponent == nil && self.boletoComponent == nil {
            let frameDummy = CGRect(x: 0, y: 0, width: screenWidth, height: 0)
           self.identificationComponent = CompositeInputComponent(frame: frameDummy, numeric: true, placeholder: "Número".localized, dropDownPlaceholder: "Tipo".localized, dropDownOptions: self.viewModel.getDropdownOptions(), textFieldDelegate: self)
            self.presentIdentificationComponent()
            availableHeight -= (self.identificationComponent?.getHeight())!
            self.identificationComponent?.frame.origin.y = availableHeight
            self.secondNameComponent = SimpleInputComponent(frame: frameDummy, numeric: false, placeholder: "Apellido".localized, textFieldDelegate: self)
            self.secondNameComponent?.frame.origin.y = availableHeight
            self.firstNameComponent = SimpleInputComponent(frame: frameDummy, numeric: false, placeholder: "Nombre".localized, textFieldDelegate: self)
            self.firstNameComponent?.frame.origin.y = availableHeight
            setupToolbarButtons()
            
            
            let frame = CGRect(x: 0, y: 0, width: screenWidth, height: availableHeight)
            let boletoComponent = BoletoComponent(frame: frame)
            self.boletoComponent = boletoComponent
            self.identificationComponent?.delegate = self
            self.firstNameComponent?.delegate = self
            self.secondNameComponent?.delegate = self
            let type = self.viewModel.identificationTypes[(self.identificationComponent?.optionSelected)!].name
            self.boletoComponent?.setType(text: type!)
            if let currentMask = self.viewModel.currentMask {
               self.identificationComponent?.setText(text: currentMask.textMasked(""))
               let maskComplete = TextMaskFormater(mask: currentMask.mask, completeEmptySpaces: true, leftToRight: false, completeEmptySpacesWith: "*")
               self.boletoComponent?.setNumberPlaceHolder(text: maskComplete.textMasked(""))
            }
            self.view.addSubview(self.boletoComponent!)
            self.view.addSubview(self.firstNameComponent!)
            self.view.addSubview(self.secondNameComponent!)
            self.view.addSubview(self.identificationComponent!)
        } else {
            availableHeight -= (self.identificationComponent?.getHeight())!
            self.identificationComponent?.frame.origin.y = availableHeight
             self.secondNameComponent?.frame.origin.y = availableHeight
            self.firstNameComponent?.frame.origin.y = availableHeight
            self.boletoComponent?.frame.size.height = availableHeight
            self.boletoComponent?.updateView()
        }
    }
    
    var toolbar: UIToolbar?
    
    func setupToolbarButtons() {
        
        if self.toolbar == nil {
            let frame =  CGRect(x: 0, y: 0, width: UIScreen.main.bounds.size.width, height: 44)
            
            let toolbar = UIToolbar(frame: frame)
            
            toolbar.barStyle = UIBarStyle.default
            toolbar.backgroundColor = UIColor.mpLightGray()
            toolbar.alpha = 1
            toolbar.isUserInteractionEnabled = true
            
            let buttonNext = UIBarButtonItem(title: "Continuar".localized, style: .done, target: self, action: #selector(PayerInfoViewController.rightArrowKeyTapped))
            let buttonPrev = UIBarButtonItem(title: "Anterior".localized, style: .plain, target: self, action: #selector(PayerInfoViewController.leftArrowKeyTapped))
            
            let font = Utils.getFont(size: 14)
            buttonNext.setTitleTextAttributes([NSFontAttributeName: font], for: .normal)
            buttonPrev.setTitleTextAttributes([NSFontAttributeName: font], for: .normal)
            
            buttonNext.setTitlePositionAdjustment(UIOffset(horizontal: UIScreen.main.bounds.size.width / 8, vertical: 0), for: UIBarMetrics.default)
            buttonPrev.setTitlePositionAdjustment(UIOffset(horizontal: -UIScreen.main.bounds.size.width / 8, vertical: 0), for: UIBarMetrics.default)
            
            let flexibleSpace = UIBarButtonItem(barButtonSystemItem: .flexibleSpace, target: nil, action: nil)
            
            toolbar.items = [flexibleSpace, buttonPrev, flexibleSpace, buttonNext, flexibleSpace]
        
            self.toolbar = toolbar
        }
        
        if self.identificationComponent != nil {
            self.identificationComponent?.setInputAccessoryView(inputAccessoryView: self.toolbar!)
        }
        if self.secondNameComponent != nil {
            self.secondNameComponent?.setInputAccessoryView(inputAccessoryView: self.toolbar!)
        }
        if self.firstNameComponent != nil {
            self.firstNameComponent?.setInputAccessoryView(inputAccessoryView: self.toolbar!)
        }

    }

    func textChangedIn(component: SimpleInputComponent)  {
        guard let textField = component.inputTextField else {
            return
        }
        if component == self.identificationComponent {
            guard let mask = self.viewModel.currentMask else {
                return
            }
            var textUnmasked = mask.textUnmasked(textField.text)
            
            textField.text! = mask.textMasked(textUnmasked, remasked: true)
            
            let maskComplete = TextMaskFormater(mask: mask.mask, completeEmptySpaces: true, leftToRight: true, completeEmptySpacesWith: "*")
            
            self.boletoComponent?.setNumber(text: maskComplete.textMasked(textUnmasked))
        }else{
            textField.text = textField.text?.uppercased()
            self.boletoComponent?.setName(text: (self.firstNameComponent?.getInputText())!.uppercased() + " " + (self.secondNameComponent?.getInputText())!.uppercased())
        }
        
    }
    
    func rightArrowKeyTapped() {
        if self.currentInput == self.identificationComponent {
            self.presentFirstNameComponent()
        }else if self.currentInput == self.firstNameComponent {
            self.presentSecondNameComponent()
        }else if self.currentInput == self.secondNameComponent {
            self.createPayerAndExecuteCallback()
        }
    }
    
    func leftArrowKeyTapped() {
        if self.currentInput == self.identificationComponent {
            self.navigationController?.popViewController(animated: true)
        }else if self.currentInput == self.firstNameComponent {
            self.presentIdentificationComponent()
        }else if self.currentInput == self.secondNameComponent {
            self.presentFirstNameComponent()
        }
    }
    
    func presentIdentificationComponent(){
        self.view.bringSubview(toFront: self.identificationComponent!)
        self.identificationComponent?.componentBecameFirstResponder()
        self.currentInput = self.identificationComponent
    }
    func presentFirstNameComponent(){
        self.view.bringSubview(toFront: self.firstNameComponent!)
        self.firstNameComponent?.componentBecameFirstResponder()
        self.currentInput = self.firstNameComponent
    }
    func presentSecondNameComponent(){
        self.view.bringSubview(toFront: self.secondNameComponent!)
        self.secondNameComponent?.componentBecameFirstResponder()
        self.currentInput = self.secondNameComponent
    }
    
    func createPayerAndExecuteCallback() {
        let type = self.viewModel.identificationTypes[(self.identificationComponent?.optionSelected)!].name
        let identification = Identification(type: type, number: self.identificationComponent?.getInputText())
        let payer = Individual(_id: nil, email: "", identification: identification, name: (self.firstNameComponent?.getInputText())!, lastName: (self.secondNameComponent?.getInputText())!)
        if let callback = self.callback {
            callback(payer)
        }
    }
    
    func textFieldDidBeginEditing(_ textField: UITextField) {
        print(textField.text)
    }
    var keyboardFrame: CGRect?
    
    func keyboardWasShown(_ notification: NSNotification) {
        let info = notification.userInfo!
        let keyboardFrame: CGRect = (info[UIKeyboardFrameEndUserInfoKey] as! NSValue).cgRectValue
        self.keyboardFrame = keyboardFrame
        setupView()
    }
}
