import UIKit

internal extension UIFont {
    static func registerFont(fontName: String, fontExtension: String) {
        guard
            let bundlePath = Bundle.main.path(forResource: "Fonts", ofType: "bundle"),
            let bundle = Bundle(path: bundlePath),
            let fontURL = bundle.url(forResource: fontName, withExtension: fontExtension),
            let fontDataProvider = CGDataProvider(url: fontURL as CFURL),
            let font = CGFont(fontDataProvider),
            CTFontManagerRegisterGraphicsFont(font, nil) else { return }
    }

    func size(_ string: String) -> CGSize {
        return (string as NSString).size(withAttributes: [.font: self])
    }
}
