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
    
    convenience init(red: Int, green: Int, blue: Int) {
        assert(red >= 0 && red <= 255, "Invalid red component")
        assert(green >= 0 && green <= 255, "Invalid green component")
        assert(blue >= 0 && blue <= 255, "Invalid blue component")
        
        self.init(red: CGFloat(red) / 255.0, green: CGFloat(green) / 255.0, blue: CGFloat(blue) / 255.0, alpha: 1.0)
    }
    
    convenience init(netHex:Int) {
        self.init(red:(netHex >> 16) & 0xff, green:(netHex >> 8) & 0xff, blue:netHex & 0xff)
    }
    
    
    class public func mpDefaultColor() -> UIColor
    {
        return UIColorFromRGB(0x009EE3)
    }
    
    class public func errorCellColor() -> UIColor
    {
        return UIColorFromRGB(0xB34C42)
    }
    
    class public func greenOkColor() -> UIColor
    {
    return UIColorFromRGB(0x6FBB2A)
    }
    
    class public func redFailureColor() -> UIColor
    {
    return UIColorFromRGB(0xB94A48)
    }
    
    //should say red at the begining?
    class public func errorValidationTextColor() -> UIColor
    {
    return UIColorFromRGB(0xB34C42)
    }
    
    class public func yellowFailureColor() -> UIColor
    {
    return UIColorFromRGB(0xF5CC00)
    }
    
    class public func blueMercadoPagoSDK() -> UIColor
    {
    return UIColorFromRGB(0x009EE3)
    }
    class public func lightBlue() -> UIColor {
        return UIColorFromRGB(0x3F9FDA)
    }
    class public func grayBaseText() -> UIColor
    {
    return UIColorFromRGB(0x333333)
    }
    
    class public func grayDark() -> UIColor
    {
    return UIColorFromRGB(0x666666)
    }
    
    class public func grayLight() -> UIColor
    {
    return UIColorFromRGB(0x999999)
    }
    
    class public func grayLines() -> UIColor
    {
    return UIColorFromRGB(0xCCCCCC)
    }
    
    class public func grayTableSeparator() -> UIColor{
    return UIColorFromRGB(0xEFEFF4)
    }
    class public func backgroundColor() -> UIColor
    {
    return UIColorFromRGB(0xEBEBF0)
    }

    class public func white() -> UIColor
    {
    return UIColorFromRGB(0xFFFFFF)
    }
    
    class public func installments() -> UIColor {
        return UIColorFromRGB(0x2BA2EC)
    }
    
    class public func systemFontColor() -> UIColor{
        return MercadoPagoContext.getTextColor()
    }
    
    class public func primaryColor() -> UIColor {
        return MercadoPagoContext.getPrimaryColor()
    }
    
    class public func complementaryColor() -> UIColor {
        return MercadoPagoContext.getComplementaryColor()
    }
    
    func lighter() -> UIColor {
            return self.adjust(0.25, green: 0.25, blue: 0.25, alpha: 1)
    }
    
    func adjust(_ red: CGFloat, green: CGFloat, blue: CGFloat, alpha:CGFloat) -> UIColor{
            var r: CGFloat = 0, g: CGFloat = 0, b: CGFloat = 0, a: CGFloat = 0
            self.getRed(&r, green: &g, blue: &b, alpha: &a)
            return UIColor(red: r+red, green: g+green, blue: b+blue, alpha: a+alpha)
    }

    
    
}
