//
//  PXText.swift
//  MercadoPagoSDK
//
//  Created by AUGUSTO COLLERONE ALFONSO on 19/11/2019.
//

import Foundation

public class PXText: Codable {
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

    init(message: String?, backgroundColor: String?, textColor: String?, weight: String?) {
        self.message = message
        self.backgroundColor = backgroundColor
        self.textColor = textColor
        self.weight = weight
    }

    func setDefaultBackgroundColor(_ color: UIColor) {
        self.defaultBackgroundColor = color
    }

    func setDefaultTextColor(_ color: UIColor) {
        self.defaultTextColor = color
    }

    internal func getAttributedString(fontSize: CGFloat = PXLayout.XS_FONT, textColor: UIColor? = nil, backgroundColor: UIColor? = nil) -> NSAttributedString? {
        guard let message = message else {return nil}

        var attributes: [NSAttributedString.Key: AnyObject] = [:]

        // Add text color attribute or default
        if let defaultTextColor = self.textColor, defaultTextColor.isNotEmpty {
            attributes[.foregroundColor] = UIColor.fromHex(defaultTextColor)
        } else {
            attributes[.foregroundColor] = defaultTextColor
        }
        // Override text color
        if let overrideTextColor = textColor {
            attributes[.foregroundColor] = overrideTextColor
        }

        // Add background color attribute or default
        if let defaultBackgroundColor = self.backgroundColor, defaultBackgroundColor.isNotEmpty {
            attributes[.backgroundColor] = UIColor.fromHex(defaultBackgroundColor)
        } else {
            attributes[.backgroundColor] = defaultBackgroundColor
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
