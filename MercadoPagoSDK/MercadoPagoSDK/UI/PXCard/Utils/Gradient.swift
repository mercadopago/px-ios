import UIKit

class Gradient: NSObject {
    var top: UIColor
    var bottom: UIColor

    init(top: UIColor, bottom: UIColor) {
        self.top = top
        self.bottom = bottom
    }

    convenience init(_ color: UIColor) {
        self.init(top: color, bottom: color)
    }
}

internal extension Gradient {
    func getGradient(_ frame: CGRect) -> UIColor? {
        let size = frame.size
        UIGraphicsBeginImageContextWithOptions(size, false, 0)

        guard
            let context = UIGraphicsGetCurrentContext(),
            let gradient = CGGradient(colorsSpace: CGColorSpaceCreateDeviceRGB(),
                                      colors: [top.cgColor, bottom.cgColor] as CFArray,
                                      locations: [0.0, 1.0]) else {
            return nil
        }

        context.drawLinearGradient(gradient,
                                   start: CGPoint.zero,
                                   end: CGPoint(x: 0, y: size.height),
                                   options: .drawsBeforeStartLocation)

        guard let gradientImage = UIGraphicsGetImageFromCurrentImageContext() else { return nil }

        return UIColor(patternImage: gradientImage)
    }
}
