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
        self.contentView.backgroundColor = UIColor.px_grayBackgroundColor()
        self.noRateLabel.text = ""
        self.noRateLabel.font = Utils.getFont(size: self.noRateLabel.font.pointSize)
        self.totalAmountLabel.attributedText = NSAttributedString(string : "")
    }
    
    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
    }
    
    func fillCell(paymentData: PaymentData, amount : Double, reviewScreenPreference: ReviewScreenPreference = ReviewScreenPreference()) {
        
        fillIcon()
        
        fillPayerCostAndTotal(paymentData: paymentData, amount: amount)
        
        fillPaymentMethodDescription(paymentData: paymentData)
        
        fillCFT(payerCost: paymentData.payerCost)
        
        fillChangePaymentMethodButton(reviewScreenPreference: reviewScreenPreference)
        
        fillSeparatorLine(payerCost: paymentData.payerCost)
        
    }
    
    func fillIcon() {
        self.paymentMethodIcon.image = MercadoPago.getImage("MPSDK_review_iconoTarjeta")
    }
    
    func fillPaymentMethodDescription(paymentData: PaymentData) {
        let paymentMethodDescription = NSMutableAttributedString(string: paymentData.paymentMethod.name.localized, attributes: [NSFontAttributeName: Utils.getFont(size: self.noRateLabel.font.pointSize)])
        if !String.isNullOrEmpty(paymentData.token?.lastFourDigits) {
            paymentMethodDescription.append(NSAttributedString(string : " terminada en ".localized + (paymentData.token?.lastFourDigits)!, attributes: [NSFontAttributeName: Utils.getFont(size: self.noRateLabel.font.pointSize)]))
        }
        self.paymentMethodDescription.attributedText = paymentMethodDescription
    }
    
    func fillPayerCostAndTotal(paymentData: PaymentData, amount: Double) {
        let currency = MercadoPagoContext.getCurrency()
        if let payerCost = paymentData.payerCost {
            self.paymentDescription.attributedText = Utils.getTransactionInstallmentsDescription(String(payerCost.installments),currency:currency, installmentAmount: payerCost.installmentAmount, additionalString: NSAttributedString(string : ""), color: UIColor.black, fontSize : 24, centsFontSize: 12, baselineOffset: 9)
            let attributedAmount = Utils.getAttributedAmount(amount, currency: currency, color : UIColor.px_grayBaseText(), fontSize : 16, baselineOffset : 4)
            
            if payerCost.installments > 1 {
                let attributedAmountFinal = NSMutableAttributedString(string : "(")
                attributedAmountFinal.append(attributedAmount)
                attributedAmountFinal.append(NSAttributedString(string : ")"))
                self.totalAmountLabel.attributedText = attributedAmountFinal
                self.totalAmountLabel.attributedText = attributedAmountFinal
            }
        } else {
            self.paymentDescription.attributedText = Utils.getAttributedAmount(amount, thousandSeparator: currency.thousandsSeparator, decimalSeparator: currency.decimalSeparator, currencySymbol: currency.symbol, color: UIColor.black, fontSize: 24, centsFontSize: 12, baselineOffset: 9)
            self.totalAmountLabel.text = ""
        }
        
        if paymentData.payerCost != nil && !paymentData.payerCost!.hasInstallmentsRate() && paymentData.payerCost?.installments != 1 {
            
            if MercadoPagoCheckout.showPayerCostDescription() {
                
                if MercadoPagoCheckout.showBankInterestWarning() {
                    self.noRateLabel.attributedText = NSAttributedString(string : "(" + "No incluye intereses bancarios".localized + ")")
                    self.noRateLabel.textColor = UIColor.px_grayDark()
                } else {
                    self.noRateLabel.attributedText = NSAttributedString(string : "Sin interés".localized)
                }
            } else {
                
                if MercadoPagoCheckout.showBankInterestWarning() {
                    self.noRateLabel.attributedText = NSAttributedString(string : "(" + "No incluye intereses bancarios".localized + ")")
                    self.noRateLabel.textColor = UIColor.px_grayDark()
                } else {
                    self.noRateLabel.attributedText = NSAttributedString(string : "")
                }
            }   
        }
    }
    
    func fillChangePaymentMethodButton(reviewScreenPreference: ReviewScreenPreference) {
        if reviewScreenPreference.isChangeMethodOptionEnabled() {
            self.selectOtherPaymentMethodButton.setTitle("Cambiar medio de pago".localized, for: .normal)
            self.selectOtherPaymentMethodButton.titleLabel?.font = Utils.getFont(size: self.noRateLabel.font.pointSize)
            self.selectOtherPaymentMethodButton.setTitleColor(UIColor.primaryColor(), for: UIControlState.normal)
        } else {
            self.selectOtherPaymentMethodButton.isHidden = true;
        }
    }
    
    func fillSeparatorLine(payerCost: PayerCost? = nil) {
        let separatorLine = ViewUtils.getTableCellSeparatorLineView(0, y: PaymentMethodSelectedTableViewCell.getCellHeight(payerCost: payerCost) - 1, width: UIScreen.main.bounds.width, height: 1)
        self.addSubview(separatorLine)
    }
    
    func fillCFT(payerCost: PayerCost? = nil) {
        CFT.font = Utils.getLightFont(size: CFT.font.pointSize)
        CFT.textColor = UIColor.px_grayDark()
        TEALabel.font = Utils.getLightFont(size: TEALabel.font.pointSize)
        TEALabel.textColor = UIColor.px_grayDark()
        
        if needsDisplayAdditionalCost(payerCost: payerCost) {
            CFT.text = "CFT " + (payerCost?.getCFTValue())!
            TEALabel.text = "TEA " + (payerCost?.getTEAValue())!
        }else{
            CFT.text = ""
            TEALabel.text = ""
            self.changePaymentMethodCFTConstraint.constant = 10
        }
    }
    
    func needsDisplayAdditionalCost(payerCost : PayerCost? = nil) -> Bool {
        return needsDisplayCFT(payerCost : payerCost) && needsDisplayTEA(payerCost : payerCost)
    }
    
    func needsDisplayCFT(payerCost : PayerCost? = nil) -> Bool{
        guard let payerCost = payerCost else {
            return false
        }
        if payerCost.getCFTValue() != nil && payerCost.installments != 1 {
            return true
        }
        return false
    }
    
    func needsDisplayTEA(payerCost : PayerCost? = nil) -> Bool{
        guard let payerCost = payerCost else {
            return false
        }
        if payerCost.getTEAValue() != nil && payerCost.installments != 1 {
            return true
        }
        return false
    }
    
    public static func getCellHeight(payerCost : PayerCost? = nil, reviewScreenPreference: ReviewScreenPreference = ReviewScreenPreference()) -> CGFloat {
        
        var cellHeight = DEFAULT_ROW_HEIGHT
        
        if payerCost != nil && !payerCost!.hasInstallmentsRate() && payerCost?.installments != 1 {
            cellHeight += 20
        }
        
        if reviewScreenPreference.isChangeMethodOptionEnabled() {
            cellHeight -= 64
        }
        
        if payerCost?.installments != 1, let _ = payerCost?.getCFTValue() {
            cellHeight += 88
        }
        
        return cellHeight
    }
    
}
