//
//  PaymentOptionDrawable.swift
//  MercadoPagoSDK
//
//  Created by Maria cristina rodriguez on 12/2/16.
//  Copyright © 2016 MercadoPago. All rights reserved.
//

import UIKit

@objc
public protocol PaymentOptionDrawable {

    func getImageDescription() -> String
    
    func getTitle() -> String
    
    func getSubtitle() -> String?
}
