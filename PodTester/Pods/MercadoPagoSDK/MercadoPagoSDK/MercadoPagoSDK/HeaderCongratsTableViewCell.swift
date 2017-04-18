//
//  HeaderCongratsTableViewCell.swift
//  MercadoPagoSDK
//
//  Created by Eden Torres on 10/25/16.
//  Copyright © 2016 MercadoPago. All rights reserved.
//

import UIKit

class HeaderCongratsTableViewCell: UITableViewCell, TimerDelegate {
    
    @IBOutlet weak var messageError: UILabel!
    @IBOutlet weak var view: UIView!
    @IBOutlet weak var icon: UIImageView!
    @IBOutlet weak var title: UILabel!
    var timerLabel : MPLabel?
    
    @IBOutlet weak var subtitle: UILabel!
    override func awakeFromNib() {
        super.awakeFromNib()
        self.selectionStyle = .none
        // Initialization code
        
        title.font = Utils.getFont(size: title.font.pointSize)
        messageError.text = ""
        messageError.font = Utils.getFont(size: messageError.font.pointSize)
        subtitle.text = ""
    }
    
    func fillCell(paymentResult: PaymentResult, paymentMethod: PaymentMethod?, color: UIColor){
        
        view.backgroundColor = color
        
		if paymentResult.status == "approved" {
			icon.image = MercadoPagoCheckoutViewModel.paymentResultScreenPreference.getHeaderApprovedIcon()
            title.text = MercadoPagoCheckoutViewModel.paymentResultScreenPreference.getApprovedTitle()
            subtitle.text = MercadoPagoCheckoutViewModel.paymentResultScreenPreference.getApprovedSubtitle()
            
        } else if paymentResult.status == "in_process" {
            icon.image = MercadoPagoCheckoutViewModel.paymentResultScreenPreference.getHeaderPendingIcon()
            title.text = MercadoPagoCheckoutViewModel.paymentResultScreenPreference.getPendingTitle()
            subtitle.text = MercadoPagoCheckoutViewModel.paymentResultScreenPreference.getPendingSubtitle()
            
        } else if paymentResult.statusDetail == "cc_rejected_call_for_authorize" {
            icon.image = MercadoPago.getImage("MPSDK_payment_result_c4a")
            var titleWithParams:String = ""
            if let paymentMethodName = paymentMethod?.name {
                titleWithParams = ("Debes autorizar ante %p el pago de %t a MercadoPago".localized as NSString).replacingOccurrences(of: "%p", with: "\(paymentMethodName)")
            }
            let currency = MercadoPagoContext.getCurrency()
            let currencySymbol = currency.getCurrencySymbolOrDefault()
            let thousandSeparator = String(currency.getThousandsSeparatorOrDefault()) ?? "."
            let decimalSeparator = String(currency.getDecimalSeparatorOrDefault()) ?? "."
            
            let amountRange = titleWithParams.range(of: "%t")
            
            if amountRange != nil {
                let attributedTitle = NSMutableAttributedString(string: (titleWithParams.substring(to: (amountRange?.lowerBound)!)), attributes: [NSFontAttributeName: Utils.getFont(size: 22)])
                let attributedAmount = Utils.getAttributedAmount(paymentResult.paymentData!.payerCost!.totalAmount, thousandSeparator: thousandSeparator, decimalSeparator: decimalSeparator, currencySymbol: currencySymbol, color: UIColor.px_white())
                attributedTitle.append(attributedAmount)
                let endingTitle = NSAttributedString(string: (titleWithParams.substring(from: (amountRange?.upperBound)!)), attributes: [NSFontAttributeName: Utils.getFont(size: 22)])
                attributedTitle.append(endingTitle)
                self.title.attributedText = attributedTitle
            }
     
        } else {
            icon.image = MercadoPagoCheckoutViewModel.paymentResultScreenPreference.getHeaderRejectedIcon()
            var title = (paymentResult.statusDetail + "_title")
            if !title.existsLocalized() {
                if !String.isNullOrEmpty(MercadoPagoCheckoutViewModel.paymentResultScreenPreference.getRejectedTitle()) {
                    self.title.text = MercadoPagoCheckoutViewModel.paymentResultScreenPreference.getRejectedTitle()
                    subtitle.text = MercadoPagoCheckoutViewModel.paymentResultScreenPreference.getRejectedSubtitle()
                } else {
                    self.title.text = "Uy, no pudimos procesar el pago".localized
                }
            
            } else {
                if let paymentMethodName = paymentMethod?.name {
                    let titleWithParams = (title.localized as NSString).replacingOccurrences(of: "%0", with: "\(paymentMethodName)")
                    self.title.text = titleWithParams
                }
            }
            
            if CountdownTimer.getInstance().hasTimer() {
                self.timerLabel = MPLabel(frame: CGRect(x: UIScreen.main.bounds.size.width - 66, y: 10, width: 56, height: 20))
                self.timerLabel!.backgroundColor = color
                self.timerLabel!.textColor = UIColor.px_white()
                self.timerLabel!.textAlignment = .right
                CountdownTimer.getInstance().delegate = self
                self.addSubview(timerLabel!)
            }
            
            messageError.text = MercadoPagoCheckoutViewModel.paymentResultScreenPreference.getRejectedIconSubtext()
        }
    }
    
    func fillCell(instructionsInfo: InstructionsInfo, color: UIColor) {
        
        view.backgroundColor = color
        
        icon.image = MercadoPago.getImage("MPSDK_payment_result_off")
        let currency = instructionsInfo.amountInfo.currency!
        let currencySymbol = currency.getCurrencySymbolOrDefault()
        let thousandSeparator = String(currency.getThousandsSeparatorOrDefault()) ?? "."
        let decimalSeparator = String(currency.getDecimalSeparatorOrDefault()) ?? "."
        
        let arr = String(instructionsInfo.amountInfo.amount).characters.split(separator: ".").map(String.init)
        let amountStr = Utils.getAmountFormatted(arr[0], thousandSeparator: thousandSeparator, decimalSeparator: decimalSeparator)
        let centsStr = Utils.getCentsFormatted(String(instructionsInfo.amountInfo.amount), decimalSeparator: decimalSeparator)
        let amountRange = instructionsInfo.instructions[0].title.range(of: currencySymbol + " " + amountStr + decimalSeparator + centsStr)
        
        if amountRange != nil {
            let attributedTitle = NSMutableAttributedString(string: (instructionsInfo.instructions[0].title.substring(to: (amountRange?.lowerBound)!)), attributes: [NSFontAttributeName: Utils.getFont(size: 22)])
            let attributedAmount = Utils.getAttributedAmount(instructionsInfo.amountInfo.amount, thousandSeparator: thousandSeparator, decimalSeparator: decimalSeparator, currencySymbol: currencySymbol, color: UIColor.px_white())
            attributedTitle.append(attributedAmount)
            let endingTitle = NSAttributedString(string: (instructionsInfo.instructions[0].title.substring(from: (amountRange?.upperBound)!)), attributes: [NSFontAttributeName: Utils.getFont(size: 22)])
            attributedTitle.append(endingTitle)
            
            self.title.attributedText = attributedTitle
        }
        
    }
    
    
    func updateTimer() {
        if self.timerLabel != nil {
            self.timerLabel!.text = CountdownTimer.getInstance().getCurrentTiming()
        }
        
    }
}
