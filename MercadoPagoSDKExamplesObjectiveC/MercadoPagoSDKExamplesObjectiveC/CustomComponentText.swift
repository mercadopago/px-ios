//
//  CustomComponentText.swift
//  MercadoPagoSDKExamplesObjectiveC
//
//  Created by Demian Tejo on 6/5/18.
//  Copyright © 2018 MercadoPago. All rights reserved.
//

import UIKit
import MercadoPagoSDK

@objc class CustomComponentText: NSObject, PXComponentizable {
    let HEIGHT : CGFloat = 80.0
    func render() -> UIView {
        let view = UIView()
        view.translatesAutoresizingMaskIntoConstraints = false
        let screenSize = UIScreen.main.bounds
        NSLayoutConstraint(item: view, attribute: .width, relatedBy: .equal, toItem: nil, attribute: .notAnAttribute, multiplier: 1, constant: screenSize.width).isActive = true
        NSLayoutConstraint(item: view, attribute: .height, relatedBy: .equal, toItem: nil, attribute: .notAnAttribute, multiplier: 1, constant: 80).isActive = true
        let textLabel = UILabel()
        textLabel.lineBreakMode = .byWordWrapping
        textLabel.numberOfLines = 0
        textLabel.textAlignment = .center
        textLabel.text = "Sumaste 150 Km YPF Serviclub con tu carga. ¡Ya tienes 2.500 km!"
        textLabel.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(textLabel)
        NSLayoutConstraint(item: textLabel, attribute: NSLayoutAttribute.width, relatedBy: NSLayoutRelation.equal, toItem: view, attribute: NSLayoutAttribute.width, multiplier: 80 / 100, constant: 0).isActive = true
        NSLayoutConstraint(item: textLabel, attribute: NSLayoutAttribute.height, relatedBy: NSLayoutRelation.equal, toItem: view, attribute: NSLayoutAttribute.height, multiplier: 90 / 100, constant: 0).isActive = true
        NSLayoutConstraint(item: textLabel, attribute: NSLayoutAttribute.centerX, relatedBy: NSLayoutRelation.equal, toItem: view, attribute: NSLayoutAttribute.centerX, multiplier: 1.0, constant: 0).isActive = true
        NSLayoutConstraint(item: textLabel, attribute: NSLayoutAttribute.centerY, relatedBy: NSLayoutRelation.equal, toItem: view, attribute: NSLayoutAttribute.centerY, multiplier: 1.0, constant: 0).isActive = true
        return view
    }
    

}
