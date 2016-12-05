//
//  MockCheckoutViewController.swift
//  MercadoPagoSDK
//
//  Created by Maria cristina rodriguez on 22/1/16.
//  Copyright © 2016 MercadoPago. All rights reserved.
//

import Foundation
import UIKit

class MockCheckoutViewController: CheckoutViewController {
    

    var startPaymentVaultInvoked = false
    
    override internal func startPaymentVault(_ animated : Bool = false){
        self.startPaymentVaultInvoked = true
        super.startPaymentVault()
    }
    
}
