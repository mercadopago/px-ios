//
//  PXText.swift
//  MercadoPagoSDK
//
//  Created by AUGUSTO COLLERONE ALFONSO on 19/11/2019.
//

import Foundation

@objcMembers
public class PXText: NSObject, Codable {

    let message: String?
    let backgroundColor: String?
    let textColor: String?
    let weight: String?
    var defaultTextColor: UIColor = .black
    var defaultBackgroundColor: UIColor = .clear

    enum CodingKeys: String, CodingKey {
        case message
        case backgroundColor = "background_color"
        case textColor = "text_color"
        case weight
    }

    public init(message: String?, backgroundColor: String?, textColor: String?, weight: String?) {
        self.message = message
        self.backgroundColor = backgroundColor
        self.textColor = textColor
        self.weight = weight
    }

    public static func == (lhs: PXText, rhs: PXText) -> Bool {
        return lhs.message == rhs.message && lhs.backgroundColor == rhs.backgroundColor && lhs.textColor == rhs.textColor && lhs.weight == rhs.weight && lhs.defaultTextColor == rhs.defaultTextColor && lhs.defaultBackgroundColor == rhs.defaultBackgroundColor
    }

    internal func getTextColor() -> UIColor {
        guard let color = self.textColor, color.isNotEmpty else {
            return defaultTextColor
        }
        return UIColor.fromHex(color)
    }

    internal func getBackgroundColor() -> UIColor {
        guard let color = self.backgroundColor, color.isNotEmpty else {
            return defaultBackgroundColor
        }
        return UIColor.fromHex(color)
    }

    internal func getAttributedString(fontSize: CGFloat = PXLayout.XS_FONT, textColor: UIColor? = nil, backgroundColor: UIColor? = nil) -> NSAttributedString? {
        guard let message = message else {return nil}

        var attributes: [NSAttributedString.Key: AnyObject] = [:]

        // Add text color attribute or default
        attributes[.foregroundColor] = getTextColor()

        // Override text color
        if let overrideTextColor = textColor {
            attributes[.foregroundColor] = overrideTextColor
        }

        // Add background color attribute or default
        attributes[.backgroundColor] = getBackgroundColor()

        // Override background color
        if let overrideBackgroundColor = backgroundColor {
            attributes[.backgroundColor] = overrideBackgroundColor
        }

        // Add font attribute
        switch weight {
        case "regular":
            attributes[.font] = UIFont.ml_regularSystemFont(ofSize: fontSize)
        case "semi_bold":
            attributes[.font] = UIFont.ml_semiboldSystemFont(ofSize: fontSize)
        case "light":
            attributes[.font] = UIFont.ml_lightSystemFont(ofSize: fontSize)
        case "bold":
            attributes[.font] = UIFont.ml_boldSystemFont(ofSize: fontSize)
        default:
            attributes[.font] = UIFont.ml_regularSystemFont(ofSize: fontSize)
        }

        return NSAttributedString(string: message, attributes: attributes)
    }
}
