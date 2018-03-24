//
//  TestComponent.swift
//  MercadoPagoSDKExamplesObjectiveC
//
//  Created by Demian Tejo on 19/12/17.
//  Copyright © 2017 MercadoPago. All rights reserved.
//

import UIKit
import MercadoPagoSDK

@objc public class TestComponent: NSObject, PXCustomComponentizable {
    
    static public func getPaymentResultPreference() -> PaymentResultScreenPreference {
        //let top = TestComponent()
        //let bottom = TestComponent()
        let preference = PaymentResultScreenPreference()
        preference.disableApprovedReceipt()
        preference.setApprovedHeaderIcon(stringURL: "https://i.pinimg.com/736x/16/6a/54/166a54b720bf9763dbce64e4cb52fa17--phoenix-band-nail-fashion.jpg")
        preference.setPendingHeaderIcon(stringURL: "https://i.pinimg.com/736x/16/6a/54/166a54b720bf9763dbce64e4cb52fa17--phoenix-band-nail-fashion.jpg")
       // preference.setApprovedTopCustomComponent(top)
        //        preference.setApprovedBottomCustomComponent(bottom)
        return preference
    }

    public func render(store: PXCheckoutStore, theme: PXTheme) -> UIView? {
        let frame = CGRect(x: 0, y: 0, width: 500, height: 100)
        let view = UIView(frame: frame)
        view.translatesAutoresizingMaskIntoConstraints = false
        view.backgroundColor = .white
        let label = UILabel(frame: frame)
        label.translatesAutoresizingMaskIntoConstraints = false
        label.text = "Custom Component"
        label.font = label.font.withSize(20)
        label.adjustsFontSizeToFitWidth = true
        label.textAlignment = .center
        label.textColor = .black
        view.addSubview(label)
        
        NSLayoutConstraint(item: label, attribute: NSLayoutAttribute.centerX, relatedBy: NSLayoutRelation.equal, toItem: view, attribute: NSLayoutAttribute.centerX, multiplier: 1.0, constant: 0).isActive = true
        
        NSLayoutConstraint(item: label, attribute: NSLayoutAttribute.centerY, relatedBy: NSLayoutRelation.equal, toItem: view, attribute: NSLayoutAttribute.centerY, multiplier: 1.0, constant: 0).isActive = true
        
        return view
    }
    
    static public func getReviewScreenPreference() -> ReviewScreenPreference {
        let top = TestComponent()
        let bottom = TestComponent()
        let preference = ReviewScreenPreference()
        preference.setTopComponent(top)
        preference.setBottomComponent(bottom)
        // preference.disableItems()
        // preference.disableChangeMethodOption()
        
        // preference.setSummaryProductTitle(productTitle: "Product title from ReviewScreenPreference")
        // preference.setAmountTitle(title: "Amount title from RSP")
        
        //preference.setDisclaimerText(text: "Disclamer text from RSP")
        
        //preference.setAmountTitle(title: "Pepito")
        //preference.addSummaryProductDetail(amount: 10)
        
        //preference.setQuantityLabel(title: "La cantidad")
        
        preference.addSummaryProductDetail(amount: 31)
        preference.addSummaryDiscountDetail(amount: 1)
        preference.addSummaryArrearsDetail(amount: 10)
        preference.addSummaryTaxesDetail(amount: 10)
        preference.addSummaryShippingDetail(amount: 10)
        
        return preference
    }
}
