//
//  MPTheme.swift
//  MercadoPagoSDK
//
//  Created by Juan sebastian Sanzone on 1/5/18.
//  Copyright © 2018 MercadoPago. All rights reserved.
//

import Foundation

@objc final class MPTheme: NSObject, PXTheme {

    let primaryColor: UIColor = #colorLiteral(red: 0, green: 0.6117647059, blue: 0.9333333333, alpha: 1)

    public func navigationBar() -> PXThemeProperty {
        return PXThemeProperty(backgroundColor: primaryColor, tintColor: #colorLiteral(red: 1, green: 1, blue: 1, alpha: 1))
    }

    public func loadingComponent() -> PXThemeProperty {
        return PXThemeProperty(backgroundColor: primaryColor, tintColor: .white)
    }

    public func highlightBackgroundColor() -> UIColor {
        return #colorLiteral(red: 1, green: 1, blue: 1, alpha: 1)
    }

    public func detailedBackgroundColor() -> UIColor {
        return #colorLiteral(red: 0.9493724704, green: 0.9581322074, blue: 0.9801041484, alpha: 1)
    }

    func highlightNavigationTintColor() -> UIColor? {
        return primaryColor
    }

    public func statusBarStyle() -> UIStatusBarStyle {
        return .lightContent
    }
}
