//
//  PayerCostRowTableViewCell.swift
//  MercadoPagoSDK
//
//  Created by Eden Torres on 10/13/16.
//  Copyright © 2016 MercadoPago. All rights reserved.
//

import UIKit

class PayerCostRowTableViewCell: UITableViewCell {
    
    @IBOutlet weak var interestDescription: UILabel!
    @IBOutlet weak var installmentDescription: UILabel!
    
    func fillCell(payerCost : PayerCost) {
        let currency = MercadoPagoContext.getCurrency()
        if (payerCost.hasInstallmentsRate() || payerCost.installments == 1){
            interestDescription.attributedText = Utils.getAttributedAmount(payerCost.totalAmount, currency: currency, color : UIColor.grayLight())
        } else {
            interestDescription.attributedText = NSAttributedString(string : "Sin interés".localized)
        }
        var installmentNumber = String(format:"%i", payerCost.installments)
        installmentNumber = "\(installmentNumber) x "
        let totalAmount = Utils.getAttributedAmount(payerCost.installmentAmount, thousandSeparator: String(currency.thousandsSeparator), decimalSeparator: String(currency.decimalSeparator), currencySymbol: String(currency.symbol), color:UIColor(red: 51, green: 51, blue: 51))
        
        let installmentLabel = NSMutableAttributedString(string: installmentNumber)
        installmentLabel.append(totalAmount)
        installmentDescription.attributedText =  installmentLabel
    }
    
    func addSeparatorLineToTop(width: Double, y: Float){
        let lineFrame = CGRect(origin: CGPoint(x: 0,y :Int(y)), size: CGSize(width: width, height: 0.5))
        let line = UIView(frame: lineFrame)
        line.alpha = 0.6
        line.backgroundColor = UIColor.grayLight()
        addSubview(line)
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
}
