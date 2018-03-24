//
//  PXDefaultTheme.swift
//  MercadoPagoSDK
//
//  Created by Juan sebastian Sanzone on 10/1/18.
//  Copyright © 2018 MercadoPago. All rights reserved.
//

import Foundation

class PXDefaultTheme: NSObject {
    var primaryColor: UIColor?

    override init() {
        super.init()
    }

    public init(withPrimaryColor: UIColor) {
        self.primaryColor = withPrimaryColor
    }
}

// MARK: - Theme styles.
extension PXDefaultTheme: PXTheme {

    public func navigationBar() -> PXThemeProperty {
        var themeProperty = PXThemeProperty(backgroundColor: #colorLiteral(red: 0, green: 0.5411764706, blue: 0.8392156863, alpha: 1), tintColor: #colorLiteral(red: 1, green: 1, blue: 1, alpha: 1), selectedColor: .clear)
        if let customColor = primaryColor {
           themeProperty = PXThemeProperty(backgroundColor: customColor, tintColor: #colorLiteral(red: 1, green: 1, blue: 1, alpha: 1), selectedColor: .clear)
        }
        return themeProperty
    }

    public func primaryButton() -> PXThemeProperty {
        var themeProperty = PXThemeProperty(backgroundColor: #colorLiteral(red: 0, green: 0.5411764706, blue: 0.8392156863, alpha: 1), tintColor: #colorLiteral(red: 1, green: 1, blue: 1, alpha: 1), selectedColor: .clear)
        if let customColor = primaryColor {
            themeProperty = PXThemeProperty(backgroundColor: customColor, tintColor: #colorLiteral(red: 1, green: 1, blue: 1, alpha: 1), selectedColor: .clear)
        }
        return themeProperty
    }

    public func secondaryButton() -> PXThemeProperty {
        var themeProperty = PXThemeProperty(backgroundColor: #colorLiteral(red: 1, green: 1, blue: 1, alpha: 1), tintColor:#colorLiteral(red: 0, green: 0.5411764706, blue: 0.8392156863, alpha: 1), selectedColor: .clear)
        if let customColor = primaryColor {
            themeProperty = PXThemeProperty(backgroundColor: #colorLiteral(red: 1, green: 1, blue: 1, alpha: 1), tintColor: customColor, selectedColor: .clear)
        }
        return themeProperty
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
        return #colorLiteral(red: 0.9607843161, green: 0.7058823705, blue: 0.200000003, alpha: 1)
    }

    public func rejectedColor() -> UIColor {
        return #colorLiteral(red: 0.7450980544, green: 0.1568627506, blue: 0.07450980693, alpha: 1)
    }

    public func loadingComponent() -> PXThemeProperty {
        var themeProperty = PXThemeProperty(backgroundColor: #colorLiteral(red: 1, green: 1, blue: 1, alpha: 1), tintColor: #colorLiteral(red: 0, green: 0.5411764706, blue: 0.8392156863, alpha: 1), selectedColor: .clear)
        if let customColor = primaryColor {
            themeProperty = PXThemeProperty(backgroundColor: #colorLiteral(red: 1, green: 1, blue: 1, alpha: 1), tintColor: customColor, selectedColor: .clear)
        }
        return themeProperty
    }

    public func modalComponent() -> PXThemeProperty {
        return PXThemeProperty(backgroundColor: #colorLiteral(red: 0, green: 0, blue: 0, alpha: 0.95), tintColor: #colorLiteral(red: 1, green: 1, blue: 1, alpha: 1), selectedColor: .clear)
    }

    public func highlightBackgroundColor() -> UIColor {
        return #colorLiteral(red: 1, green: 1, blue: 1, alpha: 1)
    }

    public func detailedBackgroundColor() -> UIColor {
        return #colorLiteral(red: 0.968627451, green: 0.968627451, blue: 0.968627451, alpha: 1)
    }
    
    public func circleBackgroundColor() -> UIColor {
        return #colorLiteral(red: 0.9411764706, green: 0.9411764706, blue: 0.9411764706, alpha: 1)
    }

    public func statusBarStyle() -> UIStatusBarStyle {
        return .lightContent
    }
}
