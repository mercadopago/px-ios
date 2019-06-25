import Foundation
import UIKit

class Animator {
    static let duration = 0.6

    class func overlay(on view: CardView,
                       cardUI: CardUI,
                       views: [UIView],
                       complete: @escaping () -> Void) {

        UIView.animate(withDuration: 0.1, delay: 0.3, options: .curveEaseOut, animations: {
            views.forEach({ $0.alpha = 0.3 })
        }, completion: nil)

        let ovalSize = CGSize(width: view.frame.width * 2, height: view.frame.height * 2)
        let ovalOrigin = CGPoint(x: -view.frame.width * 2, y: -view.frame.height * 2)
        var toPath = UIBezierPath(ovalIn: CGRect(origin: CGPoint.zero, size: ovalSize)).cgPath
        var fromPath = UIBezierPath(ovalIn: CGRect(origin: ovalOrigin, size: ovalSize)).cgPath

        let ellipseLayer = CAShapeLayer()
        ellipseLayer.bounds = view.animation.layer.frame
        ellipseLayer.fillColor = cardUI.cardBackgroundColor.cgColor

        if cardUI.defaultUI {
            swap(&toPath, &fromPath)
            ellipseLayer.fillColor = view.animation.layer.backgroundColor
            complete()
        }

        view.animation.layer.addSublayer(ellipseLayer)
        ellipseLayer.path = fromPath

        CATransaction.begin()
        CATransaction.setAnimationDuration(0.7)
        let timingFunction = CAMediaTimingFunction(name: CAMediaTimingFunctionName.easeIn)
        CATransaction.setAnimationTimingFunction(timingFunction)
        CATransaction.setCompletionBlock {
            ellipseLayer.removeFromSuperlayer()
            complete()
            UIView.animate(withDuration: 0.1, delay: 0, options: .curveEaseOut, animations: {
                views.forEach({ $0.alpha = 1 })
            }, completion: nil)
        }

        let pathAnimation = CABasicAnimation(keyPath: "path")
        pathAnimation.toValue = toPath
        pathAnimation.isRemovedOnCompletion = false
        pathAnimation.fillMode = CAMediaTimingFillMode.forwards
        ellipseLayer.add(pathAnimation, forKey: nil)

        CATransaction.commit()
    }

    class func flip(_ origin: UIView,
                    _ destination: UIView,
                    _ options: UIView.AnimationOptions) {

        UIView.transition(from: origin,
                          to: destination,
                          duration: Animator.duration,
                          options: options,
                          completion: nil)
    }
}
