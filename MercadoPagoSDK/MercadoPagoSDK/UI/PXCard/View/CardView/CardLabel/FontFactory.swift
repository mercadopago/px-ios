import Foundation
import UIKit

protocol Font {
    var color: UIColor { get }
    var shadow: Bool { get }
    var gradient: Gradient { get }
}

class FontFactory {
    class func font(_ cardUI: CardUI) -> Font? {

        guard let fontType = cardUI.fontType else {
            return Default(cardUI.cardFontColor)
        }

        switch fontType {
        case "light":
            return Light()
        case "dark":
            return Dark()
        default:
            return Default(cardUI.cardFontColor)
        }
    }
}

struct Default: Font {
    var color: UIColor
    var shadow: Bool
    var gradient: Gradient

    init(_ color: UIColor) {
        self.color = color
        shadow = false
        gradient = Gradient(color)
    }
}

struct Light: Font {
    var color: UIColor = UIColor(red: 255 / 255, green: 255 / 255, blue: 255 / 255, alpha: 0.8)
    var gradient: Gradient = Gradient(top: UIColor(red: 224 / 255, green: 224 / 255, blue: 224 / 255, alpha: 1),
                                      bottom: UIColor(red: 255 / 255, green: 255 / 255, blue: 255 / 255, alpha: 1))
    var shadow: Bool = true
}

struct Dark: Font {
    var color: UIColor = UIColor(red: 102 / 255, green: 102 / 255, blue: 102 / 255, alpha: 1)
    var gradient: Gradient = Gradient(top: UIColor(red: 119 / 255, green: 119 / 255, blue: 119 / 255, alpha: 1),
                                      bottom: UIColor(red: 85 / 255, green: 85 / 255, blue: 85 / 255, alpha: 1))
    var shadow: Bool = false
}
