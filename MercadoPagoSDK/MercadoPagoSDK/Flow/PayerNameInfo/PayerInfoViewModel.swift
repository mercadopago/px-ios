//
//  PayerInfoViewModel.swift
//  MercadoPagoSDK
//
//  Created by Demian Tejo on 9/29/17.
//  Copyright © 2017 MercadoPago. All rights reserved.
//

import UIKit

class PayerInfoViewModel: NSObject {
    
    open var dropDownOptions: [String]!
    open var masks: [TextMaskFormater]!
    
    init(dropDownOptions: [String], masks: [TextMaskFormater]) {
        self.dropDownOptions = dropDownOptions
        self.masks = masks
    }
    
}
