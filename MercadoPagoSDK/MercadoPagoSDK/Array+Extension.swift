//
//  Array+Extension.swift
//  MercadoPagoSDK
//
//  Created by Maria cristina rodriguez on 11/30/16.
//  Copyright © 2016 MercadoPago. All rights reserved.
//

import UIKit

extension Array {

    static public func isNullOrEmpty(_ value: Array?) -> Bool {
        return value == nil || value?.count == 0
    }

    public mutating func safeRemoveLast(_ suffix: Int) {
        if suffix > self.count {
            self.removeAll()
        } else {
            self.removeLast(suffix)
        }
    }

    public mutating func safeRemoveFirst(_ suffix: Int) {
        if suffix > self.count {
            self.removeAll()
        } else {
            self.removeFirst(suffix)
        }
    }
    
    static public func safeAppend(_ array: Array?, _ newElement: Element) -> Array {
        if var array = array {
            array.append(newElement)
            return array
        } else {
            return [newElement]
        }
    }
}
