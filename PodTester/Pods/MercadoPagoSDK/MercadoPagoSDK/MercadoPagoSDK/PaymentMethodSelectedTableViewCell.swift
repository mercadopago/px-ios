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
    
    @IBOutlet weak var TEALabel: UILabel!
    @IBOutlet weak var CFT: UILabel!
    @IBOutlet weak var noRateLabel: MPLabel!
    
    @IBOutlet weak var changePaymentMethodCFTConstraint: NSLayoutConstraint!
    
    @IBOutlet weak var totalAmountLabel: MPLabel!
    override func awakeFromNib() {
        super.awakeFromNib()

    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

    func fillCell(_ paymentMethod : PaymentMethod, amount : Double, payerCost : PayerCost? = nil, lastFourDigits : String? = "") {
        self.noRateLabel.text = ""
        self.noRateLabel.font = Utils.getFont(size: self.noRateLabel.font.pointSize)
        self.totalAmountLabel.attributedText = NSAttributedString(string : "")
        let currency = MercadoPagoContext.getCurrency()

        self.paymentMethodIcon.image = MercadoPago.getImage("MPSDK_review_iconoTarjeta")
        
        if let payerCost = payerCost {
            self.paymentDescription.attributedText = Utils.getTransactionInstallmentsDescription(String(payerCost.installments),currency:currency, installmentAmount: payerCost.installmentAmount, additionalString: NSAttributedString(string : ""), color: UIColor.black, fontSize : 24, centsFontSize: 12, baselineOffset: 9)
            let attributedAmount = Utils.getAttributedAmount(amount, currency: currency, color : UIColor.px_grayBaseText(), fontSize : 16, baselineOffset : 4)
            let attributedAmountFinal = NSMutableAttributedString(string : "(")
            attributedAmountFinal.append(attributedAmount)
            attributedAmountFinal.append(NSAttributedString(string : ")"))
            self.totalAmountLabel.attributedText = attributedAmountFinal
            self.totalAmountLabel.attributedText = attributedAmountFinal
        } else {
             self.paymentDescription.attributedText = Utils.getAttributedAmount(amount, thousandSeparator: currency.thousandsSeparator, decimalSeparator: currency.decimalSeparator, currencySymbol: currency.symbol, color: UIColor.black, fontSize: 24, centsFontSize: 12, baselineOffset: 9)
            self.totalAmountLabel.text = ""
        }
        let paymentMethodDescription = NSMutableAttributedString(string: paymentMethod.name.localized, attributes: [NSFontAttributeName: Utils.getFont(size: self.noRateLabel.font.pointSize)])
        paymentMethodDescription.append(NSAttributedString(string : " terminada en ".localized + lastFourDigits!, attributes: [NSFontAttributeName: Utils.getFont(size: self.noRateLabel.font.pointSize)]))
        self.paymentMethodDescription.attributedText = paymentMethodDescription
        
        if payerCost != nil && !payerCost!.hasInstallmentsRate() && payerCost?.installments != 1 {
            self.noRateLabel.attributedText = NSAttributedString(string : "Sin interés".localized)
        }

		
		if MercadoPagoCheckoutViewModel.reviewScreenPreference.isChangeMethodOptionEnabled() {
       		self.selectOtherPaymentMethodButton.setTitle("Cambiar medio de pago".localized, for: .normal)
        	self.selectOtherPaymentMethodButton.titleLabel?.font = Utils.getFont(size: self.noRateLabel.font.pointSize)
        	self.selectOtherPaymentMethodButton.setTitleColor(UIColor.primaryColor(), for: UIControlState.normal)
		} else {
			self.selectOtherPaymentMethodButton.isHidden = true;
		}
        
        CFT.font = Utils.getLightFont(size: CFT.font.pointSize)
        CFT.textColor = UIColor.px_grayDark()
        TEALabel.font = Utils.getLightFont(size: TEALabel.font.pointSize)
        TEALabel.textColor = UIColor.px_grayDark()
        
        if let CFTValue = payerCost?.getCFTValue() {
                CFT.text = "CFT " + CFTValue
        } else {
            CFT.text = ""
            self.changePaymentMethodCFTConstraint.constant = 10
        }
        if let TEAValue = payerCost?.getTEAValeu() {
            TEALabel.text = "TEA " + TEAValue
        } else {
            TEALabel.text = ""
        }
        
        let separatorLine = ViewUtils.getTableCellSeparatorLineView(0, y: PaymentMethodSelectedTableViewCell.getCellHeight(payerCost: payerCost) - 1, width: UIScreen.main.bounds.width, height: 1)
        self.addSubview(separatorLine)
        
    }
    
    public static func getCellHeight(payerCost : PayerCost? = nil) -> CGFloat {
		
		var cellHeight = DEFAULT_ROW_HEIGHT
		
        if payerCost != nil && !payerCost!.hasInstallmentsRate() && payerCost?.installments != 1 {
			cellHeight += 20
        }

		if !MercadoPagoCheckoutViewModel.reviewScreenPreference.isChangeMethodOptionEnabled() {
			cellHeight -= 64
		}

        if let dic = payerCost?.getCFTValue() {
            cellHeight += 74
        }

        return cellHeight
    }
    
}
