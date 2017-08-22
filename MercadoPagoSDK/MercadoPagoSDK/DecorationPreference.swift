//
//  DecorationPreference.swift
//  MercadoPagoSDK
//
//  Created by Eden Torres on 1/16/17.
//  Copyright © 2017 MercadoPago. All rights reserved.
//

import Foundation

open class DecorationPreference: NSObject {

    static var DEFAULT_FONT_REGULAR_NAME = ".SFUIDisplay-Regular"
    static var DEFAULT_FONT_LIGHT_NAME = ".SFUIDisplay-Light"

    var baseColor: UIColor
    var textColor: UIColor = UIColor.white
    var fontName: String = DecorationPreference.DEFAULT_FONT_REGULAR_NAME
    var fontLightName: String = DecorationPreference.DEFAULT_FONT_LIGHT_NAME

    public init(baseColor: UIColor = UIColor.px_blueMercadoPago()) {
        self.baseColor = baseColor
    }

    public func setBaseColor(color: UIColor) {
        baseColor = color
    }

    public func setBaseColor(hexColor: String) {
        baseColor = UIColor.fromHex(hexColor)
    }

    public func enableDarkFont() {
        textColor = UIColor.black
    }

    public func enableLightFont() {
        textColor = UIColor.white
    }

    public func setCustomFontWith(name: String) {
        self.fontName = name
    }

    public func setLightCustomFontWith(name: String) {
        self.fontLightName = name
    }

    public func setMercadoPagoBaseColor() {
        baseColor = UIColor.px_blueMercadoPago()
    }

    public func setMercadoPagoFont() {
        fontName = DecorationPreference.DEFAULT_FONT_REGULAR_NAME
    }

    public func setMercadoPagoLightFont() {
        fontLightName = DecorationPreference.DEFAULT_FONT_LIGHT_NAME
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

    open class func fromJSON(_ json: NSDictionary) -> DecorationPreference {
        let decorationPreference = DecorationPreference()

        if let baseColor = json["base_color"] as? String {
            decorationPreference.baseColor = UIColor.fromHex(baseColor)
        } else {
            decorationPreference.setMercadoPagoBaseColor()
        }

        if let darkFontEnable = json["dark_font_enable"] as? Bool {
            if darkFontEnable {
                decorationPreference.enableDarkFont()
            }
            else {
                decorationPreference.enableLightFont()
            }

        } else {
            decorationPreference.enableLightFont()
        }

        return decorationPreference
    }
}
