//
//  PurchaseItemAmountTableViewCell.swift
//  MercadoPagoSDK
//
//  Created by Maria cristina rodriguez on 11/2/16.
//  Copyright © 2016 MercadoPago. All rights reserved.
//

import UIKit

class PurchaseSimpleDetailTableViewCell: UITableViewCell {

    static let ROW_HEIGHT = CGFloat(58)
    
    @IBOutlet weak var titleLabel: MPLabel!
    @IBOutlet weak var unitPrice: MPLabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
    }
    
    internal func fillCell(_ title : String, amount : Double, currency : Currency, payerCost : PayerCost? = nil){
        
        //Deafult values for cells
        self.titleLabel.attributedText = NSAttributedString(string: title)
        self.removeFromSuperview()
        
        if payerCost != nil {
            let purchaseAmount = getInstallmentsAmount(payerCost: payerCost!)
            self.unitPrice.attributedText = purchaseAmount
        } else {
            self.unitPrice.attributedText = Utils.getAttributedAmount(amount, thousandSeparator: currency.thousandsSeparator, decimalSeparator: currency.decimalSeparator, currencySymbol: currency.symbol, color : UIColor.grayDark(), fontSize : 18, baselineOffset : 5)
        }
        let separatorLine = ViewUtils.getTableCellSeparatorLineView(21, y: 54, width: self.frame.width - 42, height: 1)
        self.addSubview(separatorLine)
    }
    
    private func getInstallmentsAmount(payerCost : PayerCost) -> NSAttributedString {
        return Utils.getTransactionInstallmentsDescription(payerCost.installments.description, installmentAmount: payerCost.installmentAmount, color: UIColor.grayBaseText(), fontSize : 24, baselineOffset : 8)
        
    }
    
}
