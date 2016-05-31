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

    override func setSelected(selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
    }
    
    func fillCell(payerCost : PayerCost) {
        let mpLightGrayColor = UIColor(netHex: 0x999999)
        let totalAttributes: [String:AnyObject] = [NSFontAttributeName : UIFont(name: MercadoPago.DEFAULT_FONT_NAME, size: 20)!,NSForegroundColorAttributeName:mpLightGrayColor]
        let noRateAttributes = [NSForegroundColorAttributeName : UIColor(red: 67, green: 176,blue: 0), NSFontAttributeName : UIFont(name:MercadoPago.DEFAULT_FONT_NAME, size: 13)!]
        
        let additionalText = NSMutableAttributedString(string : "")
        if payerCost.installmentRate > 0 && payerCost.installments > 1 {
            let totalAmountStr = NSMutableAttributedString(string:" ( ", attributes: totalAttributes)
            let totalAmount = Utils.getAttributedAmount(payerCost.totalAmount, thousandSeparator: ".", decimalSeparator: ",", currencySymbol: "$" , color:mpLightGrayColor)
            totalAmountStr.appendAttributedString(totalAmount)
            totalAmountStr.appendAttributedString(NSMutableAttributedString(string:" ) ", attributes: totalAttributes))
            additionalText.appendAttributedString(totalAmountStr)
        } else {
            if payerCost.installments > 1 {
                additionalText.appendAttributedString(NSAttributedString(string: " Sin interes".localized, attributes: noRateAttributes))
            }
        }
        
        self.installmentsDescription.attributedText =  Utils.getTransactionInstallmentsDescription(payerCost.installments.description, installmentAmount: payerCost.installmentAmount, additionalString: additionalText)
        
    }
}
