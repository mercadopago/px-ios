//
//  TestComponent.swift
//  MercadoPagoSDKExamplesObjectiveC
//
//  Created by Demian Tejo on 19/12/17.
//  Copyright © 2017 MercadoPago. All rights reserved.
//

import UIKit

@objcMembers public class TestComponent: NSObject {
    public func getView(text: String = "Custom Component", color: UIColor = .white) -> UIView {
        let frame = CGRect(x: 0, y: 0, width: 500, height: 100)
        let view = UIView(frame: frame)
        view.translatesAutoresizingMaskIntoConstraints = false
        view.backgroundColor = color
        let label = UILabel(frame: frame)
        label.translatesAutoresizingMaskIntoConstraints = false
        label.text = text
        label.font = label.font.withSize(20)
        label.adjustsFontSizeToFitWidth = true
        label.textAlignment = .center
        label.textColor = .black
        view.addSubview(label)

        NSLayoutConstraint(item: label, attribute: NSLayoutConstraint.Attribute.centerX, relatedBy: NSLayoutConstraint.Relation.equal, toItem: view, attribute: NSLayoutConstraint.Attribute.centerX, multiplier: 1.0, constant: 0).isActive = true

        NSLayoutConstraint(item: label, attribute: NSLayoutConstraint.Attribute.centerY, relatedBy: NSLayoutConstraint.Relation.equal, toItem: view, attribute: NSLayoutConstraint.Attribute.centerY, multiplier: 1.0, constant: 0).isActive = true

        return view
    }
}

// MARK: Mock configurations (Ex-preferences).
extension TestComponent: PXReviewConfirmDynamicViewsConfiguration {
    static public func getPaymentResultConfiguration() -> PXPaymentResultConfiguration {
        let top = CustomComponentText()
        let bottom = CustomComponentText()
        let paymentConfig = PXPaymentResultConfiguration(topView: top.render(), bottomView: bottom.render())
        return paymentConfig
    }

    static public func getReviewConfirmConfiguration() -> PXReviewConfirmConfiguration {
        let top = TestComponent()
        let bottom = TestComponent()
        let config = PXReviewConfirmConfiguration(itemsEnabled: true, topView: top.getView(), bottomView: bottom.getView())
        return config
    }

    static public func getReviewConfirmDynamicViewsConfiguration() -> TestComponent {
        let test = TestComponent()
        return test
    }

    public func topCustomViews(store: PXCheckoutStore) -> [UIView]? {
        if let pmName = store.getPaymentData().getPaymentMethod()?.name, pmName == "Visa" {
            var views: [UIView] = []
            for i in 1...3 {
                let view = getView(text: "\(pmName) - \(i)", color: .blue)
                views.append(view)
            }
            return views
        }
        return nil
    }

    public func bottomCustomViews(store: PXCheckoutStore) -> [UIView]? {
        if let pmName = store.getPaymentData().getPaymentMethod()?.name, pmName == "Mastercard" {
            var views: [UIView] = []
            for i in 1...3 {
                let view = getView(text: "\(pmName) - \(i)", color: .blue)
                views.append(view)
            }
            return views
        }
        return nil
    }
}

// MARK: Dynamic View Controller Protocol
extension TestComponent: PXDynamicViewControllerProtocol {
    static public func getReviewConfirmDynamicViewControllerConfiguration() -> TestComponent {
        let test = TestComponent()
        return test
    }

    public func viewController(store: PXCheckoutStore) -> UIViewController? {
        let viewController = UIViewController()
        viewController.view.backgroundColor = .blue
        let button = UIButton(type: .custom)
        button.translatesAutoresizingMaskIntoConstraints = false
        button.setTitle("Dismiss View Controller", for: .normal)
        button.add(for: .touchUpInside) {
            viewController.dismiss(animated: true, completion: nil)
        }
        viewController.view.addSubview(button)

        NSLayoutConstraint(item: button, attribute: NSLayoutConstraint.Attribute.centerX, relatedBy: NSLayoutConstraint.Relation.equal, toItem: viewController.view, attribute: NSLayoutConstraint.Attribute.centerX, multiplier: 1.0, constant: 0).isActive = true

        NSLayoutConstraint(item: button, attribute: NSLayoutConstraint.Attribute.centerY, relatedBy: NSLayoutConstraint.Relation.equal, toItem: viewController.view, attribute: NSLayoutConstraint.Attribute.centerY, multiplier: 1.0, constant: 0).isActive = true

        return viewController
    }

    public func position(store: PXCheckoutStore) -> PXDynamicViewControllerPosition {
        return PXDynamicViewControllerPosition.DID_ENTER_REVIEW_AND_CONFIRM
    }

    public func navigationHandler(navigationHandler: PXPluginNavigationHandler) {

    }
}
