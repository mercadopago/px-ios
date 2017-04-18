//
//  DecorationPreference.swift
//  MercadoPagoSDK
//
//  Created by Eden Torres on 1/16/17.
//  Copyright © 2017 MercadoPago. All rights reserved.
//

import Foundation

open class DecorationPreference : NSObject{
    var baseColor: UIColor
    var textColor: UIColor = UIColor.white
    var fontName: String
    var fontLightName: String
    
    public init(baseColor: UIColor = UIColor.px_blueMercadoPago(), fontName: String = ".SFUIDisplay-Regular", fontLightName: String = ".SFUIDisplay-Light"){
        self.baseColor = baseColor
        self.fontName = fontName
        self.fontLightName = fontLightName
    }

    public func setBaseColor(color: UIColor){
        baseColor = color
    }
    
    public func setBaseColor(hexColor: String){
        baseColor = UIColor.fromHex(hexColor)
    }
    
    public func enableDarkFont(){
        textColor = UIColor.black
    }
    
    public func enableLightFont(){
        textColor = UIColor.white
    }
    
    public func setCustomFontWith(name: String){
        self.fontName = name
    }
    
    public func setLightCustomFontWith(name: String){
        self.fontLightName = name
    }
    
    public func setMercadoPagoBaseColor(){
        baseColor = UIColor.px_blueMercadoPago()
    }
    
    public func setMercadoPagoFont(){
        fontName = ".SFUIDisplay-Regular"
    }
    
    public func getBaseColor() -> UIColor {
        return baseColor
    }
    
    public func getFontColor() -> UIColor {
        return textColor
    }
    
    public func getLightFontName() -> String {
        return fontLightName
    }
    
    public func getFontName() -> String {
        return fontName
    }
}
