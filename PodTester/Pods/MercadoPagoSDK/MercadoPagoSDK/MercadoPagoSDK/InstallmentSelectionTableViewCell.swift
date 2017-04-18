//
//  InstallmentSelectionTableViewCell.swift
//  MercadoPagoSDK
//
//  Created by Maria cristina rodriguez on 12/5/16.
//  Copyright © 2016 MercadoPago. All rights reserved.
//

import UIKit

class InstallmentSelectionTableViewCell: UITableViewCell {

    @IBOutlet weak var installmentsDescription: MPLabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
    }
    
    func fillCell(_ payerCost : PayerCost) {
        let mpLightGrayColor = UIColor(netHex: 0x999999)
        let totalAttributes: [String:AnyObject] = [NSFontAttributeName : Utils.getFont(size: 23),NSForegroundColorAttributeName:mpLightGrayColor]
        let noRateAttributes = [NSForegroundColorAttributeName : UIColor(red: 67, green: 176,blue: 0), NSFontAttributeName : Utils.getFont(size: 13)]
        
        let additionalText = NSMutableAttributedString(string : "")
        if payerCost.installmentRate > 0 && payerCost.installments > 1 {
            let totalAmountStr = NSMutableAttributedString(string:" ( ", attributes: totalAttributes)
            let currency = MercadoPagoContext.getCurrency()
            let totalAmount = Utils.getAttributedAmount(payerCost.totalAmount, thousandSeparator: String(currency.thousandsSeparator), decimalSeparator: String(currency.decimalSeparator), currencySymbol: String(currency.symbol), color:mpLightGrayColor)
            totalAmountStr.append(totalAmount)
            totalAmountStr.append(NSMutableAttributedString(string:" ) ", attributes: totalAttributes))
            additionalText.append(totalAmountStr)
        } else {
            if payerCost.installments > 1 {
                additionalText.append(NSAttributedString(string: " Sin interés".localized, attributes: noRateAttributes))
            }
        }
        
        self.installmentsDescription.attributedText =  Utils.getTransactionInstallmentsDescription(payerCost.installments.description, installmentAmount: payerCost.installmentAmount, additionalString: additionalText)
        
    }
}
