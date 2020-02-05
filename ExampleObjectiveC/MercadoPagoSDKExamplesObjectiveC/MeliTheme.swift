//
//  MeliTheme.swift
//  MercadoPagoSDK
//
//  Created by Juan sebastian Sanzone on 15/1/18.
//  Copyright © 2018 MercadoPago. All rights reserved.
//

import Foundation

@objc final class MeliTheme: NSObject, PXTheme {

    let primaryColor: UIColor = #colorLiteral(red: 1, green: 0.9176470588, blue: 0.4705882353, alpha: 1)

    public func navigationBar() -> PXThemeProperty {
        return PXThemeProperty(backgroundColor: primaryColor, tintColor: #colorLiteral(red: 0.2, green: 0.2, blue: 0.2, alpha: 1))
    }

    public func loadingComponent() -> PXThemeProperty {
        return PXThemeProperty(backgroundColor: primaryColor, tintColor: #colorLiteral(red: 0.2039215686, green: 0.5137254902, blue: 0.9803921569, alpha: 1))
    }

    public func highlightBackgroundColor() -> UIColor {
        return primaryColor
    }

    public func detailedBackgroundColor() -> UIColor {
        return #colorLiteral(red: 1, green: 1, blue: 1, alpha: 1)
    }

    public func statusBarStyle() -> UIStatusBarStyle {
        return .default
    }
}
