//
//  PayerInfoViewController.swift
//  MercadoPagoSDK
//
//  Created by Demian Tejo on 9/29/17.
//  Copyright © 2017 MercadoPago. All rights reserved.
//

import UIKit

class PayerInfoViewController: MercadoPagoUIViewController {

    
    let KEYBOARD_HEIGHT : CGFloat = 216.0
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
       
    }

}
