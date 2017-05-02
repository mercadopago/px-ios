//
//  ConfirmInstallmentsTableViewCell.swift
//  MercadoPagoSDK
//
//  Created by Eden Torres on 2/6/17.
//  Copyright © 2017 MercadoPago. All rights reserved.
//

import UIKit

class ConfirmInstallmentsTableViewCell: UITableViewCell {

    @IBOutlet weak var TEALabel: UILabel!
    @IBOutlet weak var CFT: UILabel!
    @IBOutlet weak var Confirm: UIButton!
    @IBOutlet weak var interest: UILabel!
    @IBOutlet weak var installments: UILabel!
    @IBOutlet weak var total: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }
    func fillCell(payerCost: PayerCost) {
        let currency = MercadoPagoContext.getCurrency()

        let attributedAmount = Utils.getAttributedAmount(payerCost.totalAmount, currency: currency, color : UIColor.px_grayBaseText(), fontSize : 16, baselineOffset : 4)
        let attributedAmountFinal = NSMutableAttributedString(string : "(")
        attributedAmountFinal.append(attributedAmount)
        attributedAmountFinal.append(NSAttributedString(string : ")"))
        self.total.attributedText = attributedAmountFinal
        
        self.installments.attributedText = Utils.getTransactionInstallmentsDescription(String(payerCost.installments), currency: currency, installmentAmount: payerCost.installmentAmount, additionalString: NSAttributedString(string : ""), color: UIColor.black, fontSize : 24, centsFontSize: 12, baselineOffset: 9)
        
        self.interest.text = ""
        self.interest.font = Utils.getFont(size: self.interest.font.pointSize)
        if !payerCost.hasInstallmentsRate() && payerCost.installments != 1 {
            self.interest.attributedText = NSAttributedString(string : "Sin interés".localized)
        }
        
        CFT.font = Utils.getLightFont(size: CFT.font.pointSize)
        CFT.textColor = UIColor.px_grayDark()
        TEALabel.font = Utils.getLightFont(size: TEALabel.font.pointSize)
        TEALabel.textColor = UIColor.px_grayDark()
        
        if let CFTValue = payerCost.getCFTValue() {
            CFT.text = "CFT " + CFTValue
        } else {
            CFT.text = ""
        }
        if let TEAValue = payerCost.getTEAValue() {
            TEALabel.text = "TEA " + TEAValue
        } else {
            TEALabel.text = ""
        }
        
        self.Confirm.backgroundColor = UIColor.primaryColor()
        self.Confirm.layer.cornerRadius = 4
        self.Confirm.titleLabel?.font = Utils.getFont(size: 16)
        self.Confirm.setTitle("Continuar".localized,for: .normal)
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
}
