//
//  PayerInfoViewModel.swift
//  MercadoPagoSDK
//
//  Created by Demian Tejo on 9/29/17.
//  Copyright © 2017 MercadoPago. All rights reserved.
//

import UIKit

class PayerInfoViewModel: NSObject {
    open var identificationTypes: [IdentificationType]!
    open var masks: [TextMaskFormater]?
    open var currentMask : TextMaskFormater?
    init(identificationTypes: [IdentificationType], masks: [TextMaskFormater]? = nil) {
        self.identificationTypes = identificationTypes
        self.masks = masks
        if let ms = self.masks {
            self.currentMask = ms[0]
        }
    }
    func getDropdownOptions() -> [String] {
        var options : [String] = []
        for identificationType in self.identificationTypes {
            options.append(identificationType.name!)
        }
        return options
    }

}
