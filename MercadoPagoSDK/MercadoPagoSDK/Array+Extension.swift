//
//  Array+Extension.swift
//  MercadoPagoSDK
//
//  Created by Maria cristina rodriguez on 11/30/16.
//  Copyright © 2016 MercadoPago. All rights reserved.
//

import UIKit


extension Array {
    
    static public func isNullOrEmpty(_ value: Array?) -> Bool
    {
        return value == nil || value?.count == 0
    }
}
