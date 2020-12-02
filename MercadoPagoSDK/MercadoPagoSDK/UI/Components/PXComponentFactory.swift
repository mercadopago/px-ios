//
//  PXComponentFactory.swift
//  MercadoPagoSDK
//
//  Created by Juan sebastian Sanzone on 7/5/18.
//  Copyright © 2018 MercadoPago. All rights reserved.
//

import Foundation
import MLUI

struct PXComponentFactory {

    struct Modal {
        @discardableResult
        static func show(viewController: UIViewController, title: String?) -> MLModal {
            if let modalTitle = title {
                return MLModal.show(with: viewController, title: modalTitle)
            } else {
                return MLModal.show(with: viewController)
            }
        }

        @discardableResult
        static func show(viewController: UIViewController, title: String? = "", dismissBlock: @escaping (() -> Void)) -> MLModal {
            return MLModal.show(with: viewController, title: title, actionTitle: "", actionBlock: {}, secondaryActionTitle: "", secondaryActionBlock: {}, dismiss: dismissBlock, enableScroll: false)
        }

        @discardableResult
        static func show(viewController: UIViewController, title: String? = "", actionTitle: String? = "", actionBlock: @escaping () -> Void = {}, secondaryActionTitle: String? = "", secondaryActionBlock: @escaping () -> Void = {}, dismissBlock: @escaping (() -> Void) = {}, enableScroll: Bool = false) -> MLModal {
            return MLModal.show(with: viewController, title: title, actionTitle: actionTitle, actionBlock: actionBlock, secondaryActionTitle: secondaryActionTitle, secondaryActionBlock: secondaryActionBlock, dismiss: dismissBlock, enableScroll: enableScroll)
        }
    }

    struct Loading {
        static func instance() -> PXLoadingComponent {
            return PXLoadingComponent.shared
        }
    }

    struct Spinner {
        static func new(color1: UIColor, color2: UIColor) -> MLSpinner {
            let spinnerConfig = MLSpinnerConfig(size: .big, primaryColor: color1, secondaryColor: color2)
            return MLSpinner(config: spinnerConfig, text: nil)
        }
    }

    struct SnackBar {
        static func showShortDurationMessage(message: String, type: MLSnackbarType, dismissBlock: @escaping (() -> Void)) {
            UIAccessibility.post(notification: .announcement, argument: message)
            MLSnackbar.show(withTitle: message, type: type, duration: .short) { (_) in
                dismissBlock()
            }
        }

        static func showLongDurationMessage(message: String, dismissBlock: @escaping (() -> Void)) {
            MLSnackbar.show(withTitle: message, type: .error(), duration: .long) { (_) in
                dismissBlock()
            }
        }

        static func showSnackbar(title: String, actionTitle: String?, type: MLSnackbarType, duration: MLSnackbarDuration, action: (() -> Void)?, dismissBlock: @escaping (() -> Void)) -> MLSnackbar {
            MLSnackbar.show(withTitle: title, actionTitle: actionTitle, actionBlock: action, type: type, duration: duration, dismiss: { (_) in
                dismissBlock()
            })
        }

        static func showPersistentMessage(message: String) {
            MLSnackbar.show(withTitle: message, type: .default(), duration: .indefinitely)
        }
    }
}
