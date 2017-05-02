//
//  PurchaseItemAmountTableViewCell.swift
//  MercadoPagoSDK
//
//  Created by Maria cristina rodriguez on 11/2/16.
//  Copyright © 2016 MercadoPago. All rights reserved.
//

import UIKit

class PurchaseSimpleDetailTableViewCell: UITableViewCell {

    static let PRODUCT_ROW_HEIGHT = CGFloat(30)
    static let TOTAL_ROW_HEIGHT = CGFloat(58)
    
    @IBOutlet weak var titleLabel: MPLabel!
    @IBOutlet weak var unitPrice: MPLabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        unitPrice.text = ""
        titleLabel.text = ""
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
    }
    
    internal func fillCell(_ title : String, amount : Double, currency : Currency, payerCost : PayerCost? = nil, addSeparatorLine : Bool = true, titleColor: UIColor = UIColor.px_grayDark(), amountColor: UIColor = UIColor.px_grayDark(), amountEnable: Bool = true, height: CGFloat){
        
        fillDescription(title: title, color: titleColor)
        
        self.removeFromSuperview()
        
        if amountEnable {
            fillAmount(amount: amount, color: amountColor, payerCost: payerCost, currency: currency)
        }
        
        addSeperatorLine(addLine: addSeparatorLine, height: height)
    }
    
    internal func fillCell(summaryRow: SummaryRow, currency : Currency, payerCost : PayerCost? = nil){
        
        fillCell(summaryRow.customDescription, amount: summaryRow.customAmount, currency: currency, addSeparatorLine: summaryRow.separatorLine, titleColor: summaryRow.colorDescription, amountColor: summaryRow.colorAmount, amountEnable: summaryRow.isAmountEnable(), height: PurchaseSimpleDetailTableViewCell.PRODUCT_ROW_HEIGHT)
    }
    
    func fillDescription(title: String, color: UIColor) {
        self.titleLabel.text = title
        self.titleLabel.font = Utils.getFont(size: titleLabel.font.pointSize)
        self.titleLabel.textColor = color
    }
    
    func fillAmount(amount: Double, color: UIColor, payerCost: PayerCost?, currency: Currency) {
        var absoluteAmount = amount
        var isNegative = false
        if absoluteAmount < 0 {
            absoluteAmount = absoluteAmount * -1
            isNegative = true
        }
        if payerCost != nil {
            let purchaseAmount = getInstallmentsAmount(payerCost: payerCost!)
            self.unitPrice.attributedText = purchaseAmount
        } else {
            self.unitPrice.attributedText = Utils.getAttributedAmount(absoluteAmount, thousandSeparator: currency.thousandsSeparator, decimalSeparator: currency.decimalSeparator, currencySymbol: currency.symbol, color : color , fontSize : 18, baselineOffset : 5, negativeAmount: isNegative)
        }
    }
    
    func addSeperatorLine(addLine: Bool, height: CGFloat) {
        if addLine {
            let separatorLine = ViewUtils.getTableCellSeparatorLineView(21, y: height - 1, width: self.frame.width - 42, height: 1)
            self.addSubview(separatorLine)
        }
    }
    
    private func getInstallmentsAmount(payerCost : PayerCost) -> NSAttributedString {
        return Utils.getTransactionInstallmentsDescription(payerCost.installments.description,currency: MercadoPagoContext.getCurrency(), installmentAmount: payerCost.installmentAmount, color: UIColor.px_grayBaseText(), fontSize : 24, baselineOffset : 8)
        
    }
    
}
