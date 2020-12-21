//
//  AddCardFlowModel.swift
//  MercadoPagoSDK
//
//  Created by Diego Flores Domenech on 6/9/18.
//  Copyright © 2018 MercadoPago. All rights reserved.
//

import UIKit

class AddCardFlowModel: NSObject, PXFlowModel {
    enum Steps: Int {
        case start
        case finish
    }

    func nextStep() -> AddCardFlowModel.Steps {
        return .finish
    }
}
