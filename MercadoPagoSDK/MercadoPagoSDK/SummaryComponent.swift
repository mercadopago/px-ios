//
//  SummaryComponent.swift
//  MercadoPagoSDK
//
//  Created by Demian Tejo on 9/7/17.
//  Copyright © 2017 MercadoPago. All rights reserved.
//

import UIKit

class SummaryComponent: UIView, PXComponent {
    let DETAILS_HEIGHT : CGFloat = 24.0
    let TOTAL_HEIGHT : CGFloat = 24.0
    let PAYER_COST_HEIGHT : CGFloat = 50.0
    var requiredHeight : CGFloat = 0.0
    init(frame: CGRect, summary: Summary, paymentData: PaymentData, totalAmount: Double) {
        super.init(frame: frame)
        self.addDetailsViews(typeDetailDictionary: summary.details)
        if let payerCost = paymentData.payerCost {
            self.addTotalView(totalAmount: payerCost.totalAmount)
        }else{
            var amount = totalAmount
            if let discount = paymentData.discount {
                amount = discount.newAmount()
            }
            self.addTotalView(totalAmount: amount)
        }
        if let disclaimer = summary.disclaimer {
            self.addDisclaimerView(text: disclaimer, color: summary.disclaimerColor)
        }

     
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    func getHeight() -> CGFloat{
        return requiredHeight
    }
    func getWeight() -> CGFloat{
        return self.frame.size.width
    }
    
    func addDetailsViews(typeDetailDictionary : [SummaryType:SummaryDetail]){
        for type in iterateEnum(SummaryType.self) {
            let frame = CGRect(x: 0.0, y: requiredHeight, width: self.frame.size.width, height: DETAILS_HEIGHT)
            if let detail = typeDetailDictionary[type] {
                var value : Double = detail.getTotalAmount()
                if type == SummaryType.DISCOUNT{
                    value = value * (-1)
                }
                let titleValueView = TitleValueView(frame: frame, titleText: detail.title, valueDouble: value, colorTitle: detail.titleColor, colorValue: detail.amountColor, upperSeparatorLine: false, valueEnable: true)
                self.addSubview(titleValueView)
                requiredHeight = requiredHeight + titleValueView.getHeight()
            }
        }
    }
    
    func addTotalView(totalAmount: Double) {
        let frame = CGRect(x: 0.0, y: requiredHeight, width: self.frame.size.width, height: DETAILS_HEIGHT)
        let titleValueView = TitleValueView(frame: frame, titleText: "Total".localized , valueDouble: totalAmount, upperSeparatorLine: true, valueEnable: true)
        requiredHeight = requiredHeight + titleValueView.getHeight()
        self.addSubview(titleValueView)
    }
    
    func addDisclaimerView(text: String, color: UIColor) {
        self.addSubview(DisclaimerView(frame: CGRect(x: 0, y: requiredHeight, width: self.frame.size.width, height: 50), disclaimerText: text, colorText: color, disclaimerFontSize: 12.0))
    }
    func iterateEnum<T: Hashable>(_: T.Type) -> AnyIterator<T> {
        var i = 0
        return AnyIterator {
            let next = withUnsafeBytes(of: &i) { $0.load(as: T.self) }
            if next.hashValue != i { return nil }
            i += 1
            return next
        }
    }
}
