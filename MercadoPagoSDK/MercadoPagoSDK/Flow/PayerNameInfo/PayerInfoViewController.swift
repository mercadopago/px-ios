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
        self.setupView()
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    func setupView(){
        let screenSize = UIScreen.main.bounds
        let screenWidth = screenSize.width
        let screenHeight = screenSize.height
        let boletoComponent = BoletoComponent(frame: CGRect(x: 0, y: 0, width: screenWidth, height: 157.0))
        
        let frameDummy = CGRect(x: 0, y: 157.0, width: screenWidth, height: 0)
        let compositeInputComponent = CompositeInputComponent(frame: frameDummy, numeric: true, dropDownPlaceholder: "Tipo".localized, dropDownOptions: ["CFT", "CNPJ"], textFieldDelegate: self)
        self.view.addSubview(boletoComponent)
        self.view.addSubview(compositeInputComponent)
    }

}
