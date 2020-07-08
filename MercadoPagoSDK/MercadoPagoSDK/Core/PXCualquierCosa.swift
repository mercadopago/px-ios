//
//  PXCualquierCosa.swift
//  MercadoPagoSDK
//
//  Created by Franco Risma on 08/07/2020.
//

import UIKit
import Foundation

@objcMembers
public class PXCualquierCosa: NSObject {
    
    let br : PXBusinessResult!
    let pd : PXPaymentData!
    let ah : PXAmountHelper!
    let pad : PXPointsAndDiscounts?
    
    public override init() {
        br = PXBusinessResult(receiptId: "123", status: .REJECTED, title: "Compraste Cigarrillos", subtitle: "Este es el subtitle", icon: nil, mainAction: nil, secondaryAction: nil, helpMessage: "Este es el help Message", showPaymentMethod: true, statementDescription: nil, imageUrl: nil, topCustomView: CustomComponentText(labelText: "Top view").render(), bottomCustomView: CustomComponentText(labelText: "Bottom view").render(), paymentStatus: "Payment Status", paymentStatusDetail: "Payment Detail", paymentMethodId: "PaymentMethodId", paymentTypeId: "PaymentTypeId", importantView: CustomComponentText(labelText: "Important view").render())
        pd = PXPaymentData()
        
        let preference = PXCheckoutPreference(id: "asdasd", items: [PXItem(title: "Vasos", quantity: 1, unitPrice: 3)], payer: PXPayer(email: "asd@asd.com"), paymentPreference: nil, siteId: "MLA", expirationDateTo: nil, expirationDateFrom: nil, site: nil, differentialPricing: nil, marketplace: nil, branchId: nil, collectorId: "123123123123")
        let paymentConfigServices = PXPaymentConfigurationServices()
        
        ah = PXAmountHelper(preference: preference, paymentData: pd, chargeRules: nil, paymentConfigurationService: paymentConfigServices, splitAccountMoney: nil)
        pad = nil
    }
}

@objcMembers class CustomComponentText: NSObject {
    let HEIGHT: CGFloat = 80.0
    let labelText: String
    
    required init(labelText: String? = nil) {
        self.labelText = labelText ?? "Important view test. I'm a custom important view by BusinessResult."
    }
    
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
        textLabel.text = labelText
        textLabel.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(textLabel)
        NSLayoutConstraint(item: textLabel, attribute: NSLayoutConstraint.Attribute.width, relatedBy: NSLayoutConstraint.Relation.equal, toItem: view, attribute: NSLayoutConstraint.Attribute.width, multiplier: 80 / 100, constant: 0).isActive = true
        NSLayoutConstraint(item: textLabel, attribute: NSLayoutConstraint.Attribute.height, relatedBy: NSLayoutConstraint.Relation.equal, toItem: view, attribute: NSLayoutConstraint.Attribute.height, multiplier: 90 / 100, constant: 0).isActive = true
        NSLayoutConstraint(item: textLabel, attribute: NSLayoutConstraint.Attribute.centerX, relatedBy: NSLayoutConstraint.Relation.equal, toItem: view, attribute: NSLayoutConstraint.Attribute.centerX, multiplier: 1.0, constant: 0).isActive = true
        NSLayoutConstraint(item: textLabel, attribute: NSLayoutConstraint.Attribute.centerY, relatedBy: NSLayoutConstraint.Relation.equal, toItem: view, attribute: NSLayoutConstraint.Attribute.centerY, multiplier: 1.0, constant: 0).isActive = true
        return view
    }

}
