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
    
    public func UIColorFromRGB(rgbValue: UInt) -> UIColor {
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
    
    public func errorCellColor() -> UIColor
    {
        return UIColorFromRGB(0xB34C42)
    }
    
    public func greenOkColor() -> UIColor
    {
    return UIColorFromRGB(0x6FBB2A)
    }
    
    public func redFailureColor() -> UIColor
    {
    return UIColorFromRGB(0xB94A48)
    }
    
    //should say red at the begining?
    public func errorValidationTextColor() -> UIColor
    {
    return UIColorFromRGB(0xB34C42)
    }
    
    public func yellowFailureColor() -> UIColor
    {
    return UIColorFromRGB(0xF5CC00)
    }
    
    public func blueMercadoPago() -> UIColor
    {
    return UIColorFromRGB(0x5ABEE7)
    }
    
    public func grayBaseText() -> UIColor
    {
    return UIColorFromRGB(0x333333)
    }
    
    public func grayDark() -> UIColor
    {
    return UIColorFromRGB(0x666666)
    }
    
    public func grayLight() -> UIColor
    {
    return UIColorFromRGB(0x999999)
    }
    
    public func grayLines() -> UIColor
    {
    return UIColorFromRGB(0xCCCCCC)
    }
    
    public func grayTableSeparator() -> UIColor{
    return UIColorFromRGB(0xEFEFF4)
    }
    public func backgroundColor() -> UIColor
    {
    return UIColorFromRGB(0xEBEBF0)
    }

    public func white() -> UIColor
    {
    return UIColorFromRGB(0xFFFFFF)
    }
    
    public func installments() -> UIColor {
        return UIColorFromRGB(0x2BA2EC)
    }
}