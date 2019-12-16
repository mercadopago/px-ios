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

    internal func getAttributedString(fontSize: CGFloat = PXLayout.XS_FONT, textColor: UIColor? = nil, backgroundColor: UIColor? = nil) -> NSAttributedString? {
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
            attributes[.font] = Utils.getFont(size: fontSize)
        case "semi_bold":
            attributes[.font] = Utils.getSemiBoldFont(size: fontSize)
        case "light":
            attributes[.font] = Utils.getLightFont(size: fontSize)
        default:
            attributes[.font] = Utils.getFont(size: fontSize)
        }

        return NSAttributedString(string: message, attributes: attributes)
    }
}
