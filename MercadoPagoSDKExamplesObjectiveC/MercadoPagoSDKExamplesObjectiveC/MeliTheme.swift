//
//  MeliTheme.swift
//  MercadoPagoSDK
//
//  Created by Juan sebastian Sanzone on 15/1/18.
//  Copyright © 2018 MercadoPago. All rights reserved.
//

import Foundation
import MercadoPagoSDK

@objc class MeliTheme: NSObject, PXTheme {

    public func navigationBar() -> PXThemeProperty {
        return PXThemeProperty(backgroundColor: #colorLiteral(red: 1, green: 0.9176470588, blue: 0.4705882353, alpha: 1), tintColor: #colorLiteral(red: 0.2, green: 0.2, blue: 0.2, alpha: 1), selectedColor: .clear)
    }

    public func primaryButton() -> PXThemeProperty {
        return PXThemeProperty(backgroundColor: #colorLiteral(red: 0.2039215686, green: 0.5137254902, blue: 0.9803921569, alpha: 1), tintColor: #colorLiteral(red: 1, green: 1, blue: 1, alpha: 1), selectedColor: #colorLiteral(red: 0.1628948748, green: 0.4370952249, blue: 0.8369542956, alpha: 1))
    }

    public func secondaryButton() -> PXThemeProperty {
        return PXThemeProperty(backgroundColor: #colorLiteral(red: 1, green: 1, blue: 1, alpha: 1), tintColor: #colorLiteral(red: 0.2039215686, green: 0.5137254902, blue: 0.9803921569, alpha: 1), selectedColor: .clear)
    }

    public func labelTintColor() -> UIColor {
        return #colorLiteral(red: 0.4, green: 0.4, blue: 0.4, alpha: 1)
    }

    public func lightLabelTintColor() -> UIColor {
        return #colorLiteral(red: 0.6, green: 0.6, blue: 0.6, alpha: 1)
    }

    public func boldLabelTintColor() -> UIColor {
        return #colorLiteral(red: 0.2, green: 0.2, blue: 0.2, alpha: 1)
    }

    public func noTaxAndDiscountLabelTintColor() -> UIColor {
        return #colorLiteral(red: 0.2235294118, green: 0.7098039216, blue: 0.2901960784, alpha: 1)
    }

    public func successColor() -> UIColor {
        return #colorLiteral(red: 0.3921568627, green: 0.7725490196, blue: 0.4549019608, alpha: 1)
    }

    public func warningColor() -> UIColor {
        return #colorLiteral(red: 0.9843137255, green: 0.6705882353, blue: 0.3764705882, alpha: 1)
    }

    public func rejectedColor() -> UIColor {
        return #colorLiteral(red: 0.9764705882, green: 0.3764705882, blue: 0.3803921569, alpha: 1)
    }

    public func loadingComponent() -> PXThemeProperty {
        return PXThemeProperty(backgroundColor: #colorLiteral(red: 1, green: 0.9176470588, blue: 0.4705882353, alpha: 1), tintColor: #colorLiteral(red: 0.2039215686, green: 0.5137254902, blue: 0.9803921569, alpha: 1), selectedColor: .clear)
    }

    public func modalComponent() -> PXThemeProperty {
        return PXThemeProperty(backgroundColor: #colorLiteral(red: 1, green: 0.8588235294, blue: 0.08235294118, alpha: 1), tintColor: #colorLiteral(red: 0.2, green: 0.2, blue: 0.2, alpha: 1), selectedColor: .clear)
    }

    public func highlightBackgroundColor() -> UIColor {
        return #colorLiteral(red: 1, green: 0.9176470588, blue: 0.4705882353, alpha: 1)
    }

    public func detailedBackgroundColor() -> UIColor {
        return #colorLiteral(red: 1, green: 1, blue: 1, alpha: 1)
    }

    public func circleBackgroundColor() -> UIColor {
        return #colorLiteral(red: 0.9411764706, green: 0.9411764706, blue: 0.9411764706, alpha: 1)
    }

    public func statusBarStyle() -> UIStatusBarStyle {
        return .default
    }
}
