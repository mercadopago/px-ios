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
        NotificationCenter.default.addObserver(self, selector: #selector(PayerInfoViewController.keyboardWasShown(_:)), name: NSNotification.Name.UIKeyboardDidChangeFrame, object: nil)
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
    
    var compositeInputComponent: CompositeInputComponent?
    var boletoComponent: BoletoComponent?
    
    func setupView(){
        let screenSize = UIScreen.main.bounds
        let screenWidth = screenSize.width
        let screenHeight = screenSize.height
        var barsHeight = UIApplication.shared.statusBarFrame.height
        let cero: CGFloat = 0.0
        barsHeight += self.navigationController?.navigationBar.frame.height != nil ? (self.navigationController?.navigationBar.frame.height)! : CGFloat(0.0)
        var availableHeight = screenHeight - barsHeight
        
        availableHeight = keyboardFrame != nil ? availableHeight - (keyboardFrame?.height)! : availableHeight
        
        if self.compositeInputComponent == nil && self.boletoComponent == nil {
            let frameDummy = CGRect(x: 0, y: 0, width: screenWidth, height: 0)
            let compositeInputComponent = CompositeInputComponent(frame: frameDummy, numeric: true, placeholder: "Número".localized, dropDownPlaceholder: "Tipo".localized, dropDownOptions: ["CFT", "CNPJ"], textFieldDelegate: self)
            compositeInputComponent.componentBecameFirstResponder()
            availableHeight -= compositeInputComponent.getHeight()
            compositeInputComponent.frame.origin.y = availableHeight
            self.compositeInputComponent = compositeInputComponent
            
            let frame = CGRect(x: 0, y: 0, width: screenWidth, height: availableHeight)
            let boletoComponent = BoletoComponent(frame: frame)
            boletoComponent.layer.borderWidth = 5
            self.boletoComponent = boletoComponent
            
            self.view.addSubview(self.boletoComponent!)
            self.view.addSubview(self.compositeInputComponent!)
        } else {
            availableHeight -= (self.compositeInputComponent?.getHeight())!
            self.compositeInputComponent?.frame.origin.y = availableHeight
            self.boletoComponent?.frame.size.height = availableHeight
        }
    }
    
    var keyboardFrame: CGRect?
    
    func keyboardWasShown(_ notification: NSNotification) {
        let info = notification.userInfo!
        let keyboardFrame: CGRect = (info[UIKeyboardFrameEndUserInfoKey] as! NSValue).cgRectValue
        self.keyboardFrame = keyboardFrame
        setupView()
    }
}
