//
//  PaymentMethodSelectedTableViewCell.swift
//  MercadoPagoSDK
//
//  Created by Maria cristina rodriguez on 12/5/16.
//  Copyright © 2016 MercadoPago. All rights reserved.
//

import UIKit

class PaymentMethodSelectedTableViewCell: UITableViewCell {

    static let DEFAULT_ROW_HEIGHT = CGFloat(313)
    
    @IBOutlet weak var paymentMethodIcon: UIImageView!
    
    @IBOutlet weak var paymentDescription: MPLabel!
    
    @IBOutlet weak var paymentMethodDescription: MPLabel!
    
    @IBOutlet weak var selectOtherPaymentMethodButton: MPButton!
    
    @IBOutlet weak var noRateLabel: MPLabel!
    
    @IBOutlet weak var totalAmountLabel: MPLabel!
    override func awakeFromNib() {
        super.awakeFromNib()
        self.contentView.layer.borderColor = UIColor.grayTableSeparator().cgColor
        self.contentView.layer.borderWidth = 1.0

    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

    func fillCell(_ paymentMethod : PaymentMethod, amount : Double, payerCost : PayerCost? = nil, lastFourDigits : String? = "") {
        self.noRateLabel.attributedText = NSAttributedString(string : "")
        self.totalAmountLabel.attributedText = NSAttributedString(string : "")
        let currency = MercadoPagoContext.getCurrency()

        self.paymentMethodIcon.image = MercadoPago.getImage("iconCard")
        self.paymentDescription.attributedText = Utils.getTransactionInstallmentsDescription(String(payerCost!.installments), installmentAmount: payerCost!.installmentAmount, additionalString: NSAttributedString(string : ""), color: UIColor.black, fontSize : 24, baselineOffset: 8)
        let paymentMethodDescription = NSMutableAttributedString(string: paymentMethod.name.localized)
        paymentMethodDescription.append(NSAttributedString(string : " terminada en " + lastFourDigits!))
        self.paymentMethodDescription.attributedText = paymentMethodDescription
        if payerCost != nil && !payerCost!.hasInstallmentsRate() && payerCost?.installments != 1 {
            self.noRateLabel.attributedText = NSAttributedString(string : "Sin interés".localized)
        }
        
        let attributedAmount = Utils.getAttributedAmount(amount, currency: currency, color : UIColor.grayBaseText(), fontSize : 16, baselineOffset : 3)
        let attributedAmountFinal = NSMutableAttributedString(string : "(")
        attributedAmountFinal.append(attributedAmount)
        attributedAmountFinal.append(NSAttributedString(string : ")"))
        self.totalAmountLabel.attributedText = attributedAmountFinal
    }
    
    public static func getCellHeight(payerCost : PayerCost? = nil) -> CGFloat {
        if payerCost != nil && !payerCost!.hasInstallmentsRate() && payerCost?.installments != 1 {
            return DEFAULT_ROW_HEIGHT + 20
        }
        return DEFAULT_ROW_HEIGHT
    }
    
}
