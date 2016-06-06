//
//  PaymentDescriptionFooterTableViewCell.swift
//  MercadoPagoSDK
//
//  Created by Maria cristina rodriguez on 9/3/16.
//  Copyright © 2016 MercadoPago. All rights reserved.
//

import UIKit

class PaymentDescriptionFooterTableViewCell: UITableViewCell {
    
    @IBOutlet weak var paymentTotalDescription: MPLabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
    }

    override func setSelected(selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
    }
    
    func setAmount(amount : Double, currency : Currency?, additionalText : String = ""){
        let fontAttrs : [String : AnyObject] = [NSFontAttributeName: UIFont(name: MercadoPago.DEFAULT_FONT_NAME, size: 20)!]
        var thousandSeparator = "."
        var decimalSeparator = ","
        var currencySymbol = "$"
        if currency != nil {
            thousandSeparator = String(currency!.getThousandsSeparatorOrDefault())
            decimalSeparator = String(currency!.getDecimalSeparatorOrDefault())
            currencySymbol = String(currency!.getCurrencySymbolOrDefault())
        }
        let total = NSMutableAttributedString(string: "Total a pagar ".localized, attributes: fontAttrs)
        let attributedAmount = Utils.getAttributedAmount(amount, thousandSeparator: thousandSeparator, decimalSeparator: decimalSeparator, currencySymbol: currencySymbol, color : UIColor().UIColorFromRGB(0x666666), fontSize: 18, baselineOffset : 4)
        total.appendAttributedString(attributedAmount)
        self.paymentTotalDescription.attributedText = total
    }
    
}
