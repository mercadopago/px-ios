//
//  Array+Extension.swift
//  MercadoPagoSDK
//
//  Created by Maria cristina rodriguez on 11/30/16.
//  Copyright © 2016 MercadoPago. All rights reserved.
//

import UIKit

extension Array {
    static public func safeAppend(_ array: Array?, _ newElement: Element) -> Array {
        if var array = array {
            array.append(newElement)
            return array
        } else {
            return [newElement]
        }
    }
}
