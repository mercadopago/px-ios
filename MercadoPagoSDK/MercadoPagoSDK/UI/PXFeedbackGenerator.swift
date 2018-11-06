//
//  PXFeedbackGenerator.swift
//  MercadoPagoSDK
//
//  Created by AUGUSTO COLLERONE ALFONSO on 23/10/18.
//

import Foundation

struct PXFeedbackGenerator {
    private static func getBatteryLevel() -> Float {
        UIDevice.current.isBatteryMonitoringEnabled = true
        return UIDevice.current.batteryLevel
    }

    private static func getBatteryState() -> UIDeviceBatteryState {
        return UIDevice.current.batteryState
    }

    private static func shouldGiveFeedback() -> Bool {
        return getBatteryLevel() > 0.2 || getBatteryState() == .charging
    }

    // UINotificationFeedbackGenerator
    private static func executeNotificationFeedback(type: UINotificationFeedbackType) {
        if #available(iOS 10.0, *) {
            let generator = UINotificationFeedbackGenerator()
            generator.notificationOccurred(type)
        }
    }

    // UISelectionFeedbackGenerator
    private static func executeSelectionFeedback() {
        if #available(iOS 10.0, *) {
            let generator = UISelectionFeedbackGenerator()
            generator.selectionChanged()
        }
    }

    // UIImpactFeedbackGenerator
    private static func executeImpactFeedback(style: UIImpactFeedbackStyle) {
        if #available(iOS 10.0, *) {
            let generator = UIImpactFeedbackGenerator(style: style)
            generator.impactOccurred()
        }
    }
}

// MARK: Public UINotificationFeedbackGenerator.
extension PXFeedbackGenerator {
    static func successNotificationFeedback() {
        if shouldGiveFeedback() {
            executeNotificationFeedback(type: .success)
        }
    }

    static func warningNotificationFeedback() {
        if shouldGiveFeedback() {
            executeNotificationFeedback(type: .warning)
        }
    }

    static func errorNotificationFeedback() {
        if shouldGiveFeedback() {
            executeNotificationFeedback(type: .error)
        }
    }
}

// MARK: Public UISelectionFeedbackGenerator.
extension PXFeedbackGenerator {
    static func selectionFeedback() {
        if shouldGiveFeedback() {
            executeSelectionFeedback()
        }
    }
}

// MARK: Public UIImpactFeedbackGenerator.
extension PXFeedbackGenerator {
    static func lightImpactFeedback() {
        if shouldGiveFeedback() {
            executeImpactFeedback(style: .light)
        }
    }

    static func mediumImpactFeedback() {
        if shouldGiveFeedback() {
            executeImpactFeedback(style: .medium)
        }
    }

    static func heavyImpactFeedback() {
        if shouldGiveFeedback() {
            executeImpactFeedback(style: .heavy)
        }
    }
}
