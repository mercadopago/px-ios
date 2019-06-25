import UIKit

@IBDesignable class CircleView: UIView {

    let shapeLayer = CAShapeLayer()

    @IBInspectable var fillColor: UIColor = .clear {
        didSet {
            shapeLayer.fillColor = fillColor.cgColor
        }
    }

    @IBInspectable var strokeColor: UIColor = .clear {
        didSet {
            shapeLayer.strokeColor = strokeColor.cgColor
        }
    }

    @IBInspectable var lineWidth: CGFloat = 0 {
        didSet {
            shapeLayer.lineWidth = lineWidth
        }
    }

    override func draw(_ rect: CGRect) {
        shapeLayer.path = UIBezierPath(ovalIn: bounds).cgPath
        layer.addSublayer(shapeLayer)
    }
}
