//
//  PXThemeProperty.swift
//  MercadoPagoSDK
//
//  Created by Juan sebastian Sanzone on 10/1/18.
//  Copyright © 2018 MercadoPago. All rights reserved.
//

import Foundation

@objcMembers
open class PXThemeProperty: NSObject {
    let backgroundColor: UIColor
    let tintColor: UIColor
    let selectedColor: UIColor
    public init (backgroundColor: UIColor, tintColor: UIColor, selectedColor: UIColor) {
        self.backgroundColor = backgroundColor
        self.tintColor = tintColor
        if selectedColor == .clear {
            self.selectedColor = backgroundColor
        } else {
            self.selectedColor = selectedColor
        }
    }

    open func getBackgroundColor() -> UIColor {
        return backgroundColor
    }

    open func getTintColor() -> UIColor {
        return tintColor
    }
}
