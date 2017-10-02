//
//  PayerInfoViewController.swift
//  MercadoPagoSDK
//
//  Created by Demian Tejo on 9/29/17.
//  Copyright © 2017 MercadoPago. All rights reserved.
//

import UIKit

class PayerInfoViewController: MercadoPagoUIViewController, UITextFieldDelegate  {

    
    let KEYBOARD_HEIGHT : CGFloat = 216.0
    let ACCESORY_VIEW_HEIGHT : CGFloat = 44.0
    let INPUT_VIEW_HEIGHT : CGFloat = 83.0
    
    var viewModel : PayerInfoViewModel!
    
    init(viewModel:PayerInfoViewModel) {
        super.init(nibName: nil, bundle: nil)
        self.viewModel = viewModel
        NotificationCenter.default.addObserver(self, selector: #selector(PayerInfoViewController.keyboardWasShown(_:)), name: NSNotification.Name.UIKeyboardDidShow, object: nil)
        //setupView()
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidAppear(_ animated: Bool) {
//        self.setupView()
        let textfield = UITextField(frame: CGRect.zero)
        self.view.addSubview(textfield)
        textfield.becomeFirstResponder()
        
        
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    func setupView(){
        let screenSize = UIScreen.main.bounds
        let screenWidth = screenSize.width
        let screenHeight = screenSize.height
        let frame = CGRect(x: 0, y: 0, width: screenWidth, height: 157)
//        CGRect(x: 0, y: 0, width: screenWidth, height: 157.0)
        let boletoComponent = BoletoComponent(frame: frame)
        boletoComponent.layer.borderWidth = 5
        
        if let frame = keyboardFrame {
            let frameDummy = CGRect(x: 0, y: 0, width: screenWidth, height: 0)
            let compositeInputComponent = CompositeInputComponent(frame: frameDummy, numeric: true, dropDownPlaceholder: "Tipo".localized, dropDownOptions: ["CFT", "CNPJ"], textFieldDelegate: self)
            compositeInputComponent.componentBecameFirstResponder()
            compositeInputComponent.frame.origin.y = screenHeight - compositeInputComponent.getHeight() - frame.height - (self.navigationController?.navigationBar.frame.height)! - 20
//            compositeInputComponent.frame.origin.y = frame.minY - compositeInputComponent.getHeight()
            self.view.addSubview(boletoComponent)
            self.view.addSubview(compositeInputComponent)
        }
        
    }
    
    var keyboardFrame: CGRect?
    
    func keyboardWasShown(_ notification: NSNotification) {
        let info = notification.userInfo!
        let keyboardFrame: CGRect = (info[UIKeyboardFrameEndUserInfoKey] as! NSValue).cgRectValue
        print("Height!!!! \(keyboardFrame.height)")
        self.keyboardFrame = keyboardFrame
        setupView()
    }
}
