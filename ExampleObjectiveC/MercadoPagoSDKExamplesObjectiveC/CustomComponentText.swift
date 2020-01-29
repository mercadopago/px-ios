//
//  CustomComponentText.swift
//  MercadoPagoSDKExamplesObjectiveC
//
//  Created by Demian Tejo on 6/5/18.
//  Copyright © 2018 MercadoPago. All rights reserved.
//

import UIKit

@objcMembers class CustomComponentText: NSObject {
    let HEIGHT: CGFloat = 80.0
    func render() -> UIView {
        let view = UIView()
        view.translatesAutoresizingMaskIntoConstraints = false
        let screenSize = UIScreen.main.bounds
        NSLayoutConstraint(item: view, attribute: .width, relatedBy: .equal, toItem: nil, attribute: .notAnAttribute, multiplier: 1, constant: screenSize.width).isActive = true
        NSLayoutConstraint(item: view, attribute: .height, relatedBy: .equal, toItem: nil, attribute: .notAnAttribute, multiplier: 1, constant: 80).isActive = true
        let textLabel = UILabel()
        textLabel.lineBreakMode = .byWordWrapping
        textLabel.numberOfLines = 0
        textLabel.textAlignment = .left
        textLabel.text = "Important view test. I'm a custom important view by BusinessResult."
        textLabel.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(textLabel)
        NSLayoutConstraint(item: textLabel, attribute: NSLayoutConstraint.Attribute.width, relatedBy: NSLayoutConstraint.Relation.equal, toItem: view, attribute: NSLayoutConstraint.Attribute.width, multiplier: 80 / 100, constant: 0).isActive = true
        NSLayoutConstraint(item: textLabel, attribute: NSLayoutConstraint.Attribute.height, relatedBy: NSLayoutConstraint.Relation.equal, toItem: view, attribute: NSLayoutConstraint.Attribute.height, multiplier: 90 / 100, constant: 0).isActive = true
        NSLayoutConstraint(item: textLabel, attribute: NSLayoutConstraint.Attribute.centerX, relatedBy: NSLayoutConstraint.Relation.equal, toItem: view, attribute: NSLayoutConstraint.Attribute.centerX, multiplier: 1.0, constant: 0).isActive = true
        NSLayoutConstraint(item: textLabel, attribute: NSLayoutConstraint.Attribute.centerY, relatedBy: NSLayoutConstraint.Relation.equal, toItem: view, attribute: NSLayoutConstraint.Attribute.centerY, multiplier: 1.0, constant: 0).isActive = true
        return view
    }

}
