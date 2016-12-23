//
//  PreferenceDescriptionCellTableViewCell.swift
//  MercadoPagoSDK
//
//  Created by Maria cristina rodriguez on 4/2/16.
//  Copyright © 2016 MercadoPago. All rights reserved.
//

import UIKit

open class PurchaseDetailTableViewCell: UITableViewCell {

    static let ROW_HEIGHT = CGFloat(52)
    
    static var separatorLine : UIView?
    
    @IBOutlet weak var purchaseDetailTitle: MPLabel!
    
    @IBOutlet weak var purchaseDetailAmount: MPLabel!
    
    @IBOutlet weak var noRateLabel: MPLabel!
    
    
    override open func awakeFromNib() {
        super.awakeFromNib()
        
    }

    override open func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
    }
    
    internal func fillCell(_ title : String, amount : Double, currency : Currency, payerCost : PayerCost? = nil){
        
        //Deafult values for cells
        self.purchaseDetailTitle.attributedText = NSAttributedString(string: title.localized)
        self.noRateLabel.attributedText = NSAttributedString(string : "")
        self.removeFromSuperview()
        var separatorLineHeight = CGFloat(54)
        
        if payerCost != nil {
            let purchaseAmount = getInstallmentsAmount(payerCost: payerCost!)
            self.purchaseDetailAmount.attributedText = purchaseAmount
            if PurchaseDetailTableViewCell.separatorLine != nil {
                PurchaseDetailTableViewCell.separatorLine!.removeFromSuperview()
            }
            if !payerCost!.hasInstallmentsRate() {
                self.noRateLabel.attributedText = NSAttributedString(string : "Sin interés".localized)
                separatorLineHeight += 26
            }
            let separatorLine = ViewUtils.getTableCellSeparatorLineView(21, y: separatorLineHeight, width: self.frame.width - 42, height: 1)
            self.addSubview(separatorLine)
        } else {
            self.purchaseDetailAmount.attributedText = Utils.getAttributedAmount(amount, thousandSeparator: currency.thousandsSeparator, decimalSeparator: currency.decimalSeparator, currencySymbol: currency.symbol, color : UIColor.grayDark(), fontSize : 18, centsFontSize: 12, baselineOffset : 5)
            let separatorLine = ViewUtils.getTableCellSeparatorLineView(21, y: separatorLineHeight, width: self.frame.width - 42, height: 1)
            self.addSubview(separatorLine)
        }
        
        
        
    }
    
    public static func getCellHeight(payerCost : PayerCost? = nil) -> CGFloat {
        if payerCost != nil && !payerCost!.hasInstallmentsRate() {
            return ROW_HEIGHT + 30
        }
        return ROW_HEIGHT
    }
    
    private func getInstallmentsAmount(payerCost : PayerCost) -> NSAttributedString {
        return Utils.getTransactionInstallmentsDescription(payerCost.installments.description, installmentAmount: payerCost.installmentAmount, color: UIColor.grayBaseText(), fontSize : 24, baselineOffset : 8)

    }
    
}
