//
//  PXText.swift
//  MercadoPagoSDK
//
//  Created by AUGUSTO COLLERONE ALFONSO on 19/11/2019.
//

import Foundation

public struct PXText: Codable {
    let message: String?
    let backgroundColor: String?
    let textColor: String?
    let weight: String?

    enum CodingKeys: String, CodingKey {
        case message
        case backgroundColor = "background_color"
        case textColor = "text_color"
        case weight
    }

    internal func getAttributedString(fontSize: CGFloat = PXLayout.XS_FONT, textColor: UIColor? = nil, backgroundColor: UIColor? = nil, alpha: CGFloat? = nil) -> NSAttributedString? {
        guard let message = message else {return nil}

        var attributes: [NSAttributedString.Key: AnyObject] = [:]

        // Add text color attribute
        if let defaultTextColor = self.textColor {
            attributes[.foregroundColor] = UIColor.fromHex(defaultTextColor)
        }
        // Override text color
        if let overrideTextColor = textColor {
            attributes[.foregroundColor] = overrideTextColor
        }

        // Add background color attribute
        if let defaultBackgroundColor = self.backgroundColor {
            attributes[.backgroundColor] = UIColor.fromHex(defaultBackgroundColor)
        }
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
        default:
            attributes[.font] = UIFont.ml_regularSystemFont(ofSize: fontSize)
        }

        return NSAttributedString(string: message, attributes: attributes)
    }
}
