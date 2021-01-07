//
//  CustomPXDynamicComponent.swift
//  ExampleSwift
//
//  Created by Jonathan Scaramal on 28/10/2020.
//  Copyright © 2020 Juan Sebastian Sanzone. All rights reserved.
//
import Foundation

import UIKit

#if PX_PRIVATE_POD
    import MercadoPagoSDKV4
#else
    import MercadoPagoSDK
#endif

public class CustomPXDynamicComponent: UIView {

    var view: UIView!
    required public init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        loadViewFromNib()
    }

    override init(frame: CGRect) {
        super.init(frame: frame)
        loadViewFromNib()
    }

    func loadViewFromNib() {
        let bundle = Bundle(for: type(of: self))
        let nib = UINib(nibName: "CustomPXDynamicComponentView", bundle: bundle)
        let view = nib.instantiate(withOwner: self, options: nil).first as! UIView
        view.frame = bounds
        view.autoresizingMask = [
            UIViewAutoresizing.flexibleWidth,
            UIViewAutoresizing.flexibleHeight
        ]
        addSubview(view)
        self.view = view
    }
    
//    public func getView() -> UIView {
//        return self.view
//    }
//
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

        return self.view
    }
    
}

// MARK: Dynamic View Controller Protocol
extension CustomPXDynamicComponent: PXDynamicViewControllerProtocol {
//    static public func getReviewConfirmDynamicViewControllerConfiguration() -> TestComponent {
//        let test = TestComponent()
//        return test
//    }
    public func viewController(store: PXCheckoutStore) -> UIViewController? {
        let viewController = UIViewController()
        viewController.view.backgroundColor = .blue
        let button = UIButton(type: .custom)
        button.translatesAutoresizingMaskIntoConstraints = false
        button.setTitle("Dismiss View Controller", for: .normal)
//        button.add(for: .touchUpInside) {
//            viewController.dismiss(animated: true, completion: nil)
//        }
        
        viewController.view.addSubview(button)

        NSLayoutConstraint(item: button, attribute: NSLayoutConstraint.Attribute.centerX, relatedBy: NSLayoutConstraint.Relation.equal, toItem: viewController.view, attribute: NSLayoutConstraint.Attribute.centerX, multiplier: 1.0, constant: 0).isActive = true

        NSLayoutConstraint(item: button, attribute: NSLayoutConstraint.Attribute.centerY, relatedBy: NSLayoutConstraint.Relation.equal, toItem: viewController.view, attribute: NSLayoutConstraint.Attribute.centerY, multiplier: 1.0, constant: 0).isActive = true

        return viewController
    }

    public func position(store: PXCheckoutStore) -> PXDynamicViewControllerPosition {
        return PXDynamicViewControllerPosition.DID_TAP_ONETAP_HEADER//.DID_ENTER_REVIEW_AND_CONFIRM
    }

    public func navigationHandler(navigationHandler: PXPluginNavigationHandler) {

    }
}
