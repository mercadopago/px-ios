import Foundation
import UIKit

@objc internal enum Location: Int {
    case front, back, none
}

@objc internal protocol CardUI {
    var cardPattern: [Int] { get }
    var bankImage: UIImage? { get }
    var placeholderName: String { get }
    var placeholderExpiration: String { get }
    var cardFontColor: UIColor { get }
    var cardLogoImage: UIImage? { get }
    var cardBackgroundColor: UIColor { get }
    var securityCodeLocation: Location { get }
    var defaultUI: Bool { get }
    var securityCodePattern: Int { get }
    @objc optional var fontType: String { get }
}
