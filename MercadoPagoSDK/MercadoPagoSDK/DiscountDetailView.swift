//
//  DiscountDetailView.swift
//  MercadoPagoSDK
//
//  Created by Demian Tejo on 12/26/16.
//  Copyright © 2016 MercadoPago. All rights reserved.
//

import UIKit

class DiscountDetailView: UIView {

    @IBOutlet weak var viewTitle: UILabel!
    @IBOutlet weak var productTitle: UILabel!
    @IBOutlet weak var productAmount: UILabel!
    @IBOutlet weak var discountTitle: UILabel!
    @IBOutlet weak var discountAmount: UILabel!
    @IBOutlet weak var totalTitle: UILabel!
    @IBOutlet weak var totalAmount: UILabel!

    let fontSize: CGFloat = 18.0
    let baselineOffSet: Int = 6
    let fontColor = ThemeManager.shared.getTheme().modalComponent().tintColor
    let discountFontColor = ThemeManager.shared.getTheme().noTaxAndDiscountLabelTintColor()

    var coupon: DiscountCoupon!
    var amount: Double!

    init(frame: CGRect, coupon: DiscountCoupon, amount: Double) {
        super.init(frame: frame)
        self.coupon = coupon
        self.amount = amount
        loadViewFromNib ()
    }

    required public init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        loadViewFromNib ()
    }

    func loadViewFromNib() {
        let currency = MercadoPagoContext.getCurrency()
        let bundle = Bundle(for: type(of: self))
        let nib = UINib(nibName: "DiscountDetailView", bundle: bundle)
        let view = nib.instantiate(withOwner: self, options: nil)[0] as! UIView
        view.frame = bounds
        view.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        self.addSubview(view)
        self.viewTitle.text = coupon.getDescription()
        if let concept = coupon.concept {
            self.discountTitle.text = concept
        }

        self.totalTitle.text = "Total".localized
        self.productTitle.text = "Producto".localized
        self.viewTitle.textColor = fontColor
        self.productTitle.textColor = fontColor
        self.discountTitle.textColor = discountFontColor
        self.totalTitle.textColor = fontColor
        self.productAmount.attributedText = Utils.getAttributedAmount(amount, currency: currency, color: fontColor, fontSize: fontSize, baselineOffset: baselineOffSet)
        self.discountAmount.attributedText = Utils.getAttributedAmount(Double(coupon.coupon_amount)!, currency: currency, color: discountFontColor, fontSize: fontSize, baselineOffset: baselineOffSet, negativeAmount: true)
        self.totalAmount.attributedText = Utils.getAttributedAmount( amount - Double(coupon.coupon_amount)!, currency: currency, color: fontColor, fontSize: fontSize, baselineOffset: baselineOffSet)
    }
}
