//
//  MockPaymentVaultViewController.swift
//  MercadoPagoSDK
//
//  Created by Maria cristina rodriguez on 22/1/16.
//  Copyright © 2016 MercadoPago. All rights reserved.
//

import Foundation

class MockPaymentVaultViewController: PaymentVaultViewController {
    
    var mpStylesLoaded = false
    var mpStylesCleared = false
    var optionSelected = false
    var paymentMethodIdSelected = ""

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.mpStylesLoaded = true
    }
    
//    override func viewWillDisappear(animated: Bool) {
//        super.viewWillDisappear(animated)
//        self.mpStylesCleared = true
//    }
//    
//    override internal func executeBack(){
//        super.executeBack()
//        
//    }

}

class MockPaymentViewModel : PaymentVaultViewModel {
    
    
}
