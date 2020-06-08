//
//  PXPulseView.swift
//  MercadoPagoSDK
//
//  Created by Esteban Adrian Boffa on 28/05/2020.
//

import Foundation

final class PXPulseView: UIView {

    init() {
        super.init(frame: .zero)
        translatesAutoresizingMaskIntoConstraints = false
        backgroundColor = .clear
        layer.cornerRadius = 16
        layer.borderColor = MLBusinessAppDataService().getAppIdentifier() == .mp ? UIColor(red: 0, green: 158, blue: 227).withAlphaComponent(0.3).cgColor : UIColor(red: 52, green: 131, blue: 250).withAlphaComponent(0.3).cgColor
        layer.borderWidth = 8.5
        setupAnimations()
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

// MARK: Animations
extension PXPulseView {
    func setupAnimations() {
        addPulseAnimation()
        addOpacityAnimation()
    }

    private func addPulseAnimation() {
        let pulseAnimation: CABasicAnimation = CABasicAnimation(keyPath: "transform.scale")
        pulseAnimation.duration = 1
        pulseAnimation.fromValue = 1.3
        pulseAnimation.toValue = 1.6
        pulseAnimation.timingFunction = CAMediaTimingFunction(name: CAMediaTimingFunctionName.easeInEaseOut)
        pulseAnimation.autoreverses = true
        pulseAnimation.repeatCount = .greatestFiniteMagnitude
        layer.add(pulseAnimation, forKey: "scale")
    }

    private func addOpacityAnimation() {
        let opacityAnimation = CABasicAnimation(keyPath: "opacity")
        opacityAnimation.duration = 1
        opacityAnimation.fromValue = 0
        opacityAnimation.toValue = 1
        opacityAnimation.timingFunction = CAMediaTimingFunction(name: .easeOut)
        opacityAnimation.autoreverses = true
        opacityAnimation.repeatCount = .greatestFiniteMagnitude
        layer.add(opacityAnimation, forKey: "opacity")
    }
}
