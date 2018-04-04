//
//  UIColor+Additions.swift
//  MercadoPagoSDK
//
//  Created by Matias Gualino on 30/12/14.
//  Copyright (c) 2014 com.mercadopago. All rights reserved.
//

import Foundation
import UIKit

extension UIColor {

    class public func UIColorFromRGB(_ rgbValue: UInt) -> UIColor {
        return UIColor(
            red: CGFloat((rgbValue & 0xFF0000) >> 16) / 255.0,
            green: CGFloat((rgbValue & 0x00FF00) >> 8) / 255.0,
            blue: CGFloat(rgbValue & 0x0000FF) / 255.0,
            alpha: CGFloat(1.0)
        )
    }

    class public func fromHex(_ hexValue: String) -> UIColor {
        var hexInt: UInt32 = 0
        let scanner: Scanner = Scanner(string: hexValue)
        scanner.charactersToBeSkipped = CharacterSet(charactersIn: "#")
        scanner.scanHexInt32(&hexInt)
        return UIColorFromRGB(UInt(hexInt))
    }

    convenience init(red: Int, green: Int, blue: Int) {
        assert(red >= 0 && red <= 255, "Invalid red component")
        assert(green >= 0 && green <= 255, "Invalid green component")
        assert(blue >= 0 && blue <= 255, "Invalid blue component")

        self.init(red: CGFloat(red) / 255.0, green: CGFloat(green) / 255.0, blue: CGFloat(blue) / 255.0, alpha: 1.0)
    }

    convenience init(netHex: Int) {
        self.init(red: (netHex >> 16) & 0xff, green: (netHex >> 8) & 0xff, blue: netHex & 0xff)
    }

    class public func mpDefaultColor() -> UIColor {
        return UIColorFromRGB(0x009EE3)
    }

    class public func errorCellColor() -> UIColor {
        return UIColorFromRGB(0xB34C42)
    }

    class public func greenOkColor() -> UIColor {
        return UIColorFromRGB(0x6FBB2A)
    }

    class public func redFailureColor() -> UIColor {
        return UIColorFromRGB(0xB94A48)
    }

    class public func px_errorValidationTextColor() -> UIColor {
        return UIColorFromRGB(0xB34C42)
    }

    class public func yellowFailureColor() -> UIColor {
        return UIColorFromRGB(0xF5CC00)
    }

    class public func px_blueMercadoPago() -> UIColor {
        return UIColorFromRGB(0x009EE3)
    }
    class public func lightBlue() -> UIColor {
        return UIColorFromRGB(0x3F9FDA)
    }
    class public func px_grayBaseText() -> UIColor {
        return UIColorFromRGB(0x333333)
    }

    class public func px_grayDark() -> UIColor {
        return UIColorFromRGB(0x666666)
    }

    class public func px_grayLight() -> UIColor {
        return UIColorFromRGB(0x999999)
    }

    class public func grayTableSeparator() -> UIColor {
        return UIColorFromRGB(0xEFEFF4)
    }
    class public func px_backgroundColor() -> UIColor {
        return UIColorFromRGB(0xEBEBF0)
    }

    class public func px_white() -> UIColor {
        return UIColorFromRGB(0xFFFFFF)
    }

    class public func installments() -> UIColor {
        return UIColorFromRGB(0x2BA2EC)
    }

    class public func px_redCongrats() -> UIColor {
        return UIColorFromRGB(0xFF6E6E)
    }

    class public func px_greenCongrats() -> UIColor {
        return UIColorFromRGB(0x0DB478)
    }

    class public func grayStatusBar() -> UIColor {
        return UIColorFromRGB(0xE6E6E6)
    }

    class public func mpLightGray() -> UIColor {
        return UIColorFromRGB(0xEEEEEE)
    }

    class public func mpRedPinkErrorMessage() -> UIColor {
        return UIColorFromRGB(0xF04449)
    }

    class public func mpRedErrorMessage() -> UIColor {
        return UIColorFromRGB(0xf04449)
    }
    class public func primaryColor() -> UIColor {
        return ThemeManager.shared.getMainColor()
    }
    class public func mpGreenishTeal() -> UIColor {
        return UIColorFromRGB(0x3bc280)
    }

    class public func cardDefaultColor() -> UIColor {
        return UIColor(netHex: 0xEEEEEE)
    }

    class public func px_grayBackgroundColor() -> UIColor {
        return UIColorFromRGB(0xF7F7F7)
    }

    class public func instructionsHeaderColor() -> UIColor {
        return UIColor(red: 255, green: 161, blue: 90)
    }

    func lighter() -> UIColor {
        return self.adjust(0.25, green: 0.25, blue: 0.25, alpha: 1)
    }

    func adjust(_ red: CGFloat, green: CGFloat, blue: CGFloat, alpha: CGFloat) -> UIColor {
        var r: CGFloat = 0, g: CGFloat = 0, b: CGFloat = 0, a: CGFloat = 0
        self.getRed(&r, green: &g, blue: &b, alpha: &a)
        return UIColor(red: r+red, green: g+green, blue: b+blue, alpha: a+alpha)
    }
}

// COMPONENTS
extension UIColor {
    class var pxWarmGray: UIColor {
        return UIColor(white: 153.0 / 255.0, alpha: 1.0)
    }

    class var pxBrownishGray: UIColor {
        return UIColor(white: 102.0 / 255.0, alpha: 1.0)
    }

    class var pxBlack: UIColor {
        return UIColor(white: 51.0 / 255.0, alpha: 1.0)
    }

    class var pxBlueMp: UIColor {
        return UIColor(red: 0.0, green: 156.0 / 255.0, blue: 238.0 / 255.0, alpha: 1.0)
    }

    class var pxGreenMp: UIColor {
        return UIColor(red: 0.0, green: 198.0 / 255.0, blue: 119.0 / 255.0, alpha: 1.0)
    }

    class var pxRedMp: UIColor {
        return UIColor(red: 255.0 / 255.0, green: 78.0 / 255.0, blue: 85.0 / 255.0, alpha: 1.0)
    }

    class var pxOrangeMp: UIColor {
        return UIColor(red: 255.0 / 255.0, green: 166.0 / 255.0, blue: 68.0 / 255.0, alpha: 1.0)
    }

    class var pxWhite: UIColor {
        return UIColor(white: 255.0 / 255.0, alpha: 1.0)
    }

    class var pxLightGray: UIColor {
        return UIColor(white: 247.0 / 255.0, alpha: 1.0)
    }

    class var pxMediumLightGray: UIColor {
        return UIColor(red: 238.0 / 255.0, green: 238.0 / 255.0, blue: 238.0 / 255.0, alpha: 1.0)
    }
}
