//
//  HeaderCongratsTableViewCell.swift
//  MercadoPagoSDK
//
//  Created by Eden Torres on 10/25/16.
//  Copyright © 2016 MercadoPago. All rights reserved.
//

import UIKit

class HeaderCongratsTableViewCell: UITableViewCell {
    
    @IBOutlet weak var messageError: UILabel!
    @IBOutlet weak var view: UIView!
    @IBOutlet weak var icon: UIImageView!
    @IBOutlet weak var title: UILabel!
    
    func fillCell(payment: Payment, paymentMethod: PaymentMethod?, color: UIColor, instruction: Instruction?){
        messageError.text = ""
        view.backgroundColor = color
        if payment.status == "approved" {
            icon.image = MercadoPago.getImage("iconoAcreditado")
            title.text = "¡Listo, se acreditó tu pago!".localized
        } else if payment.status == "in_process" {
            icon.image = MercadoPago.getImage("congrats_iconPending")
            title.text = "Estamos procesando el pago".localized
        } else if payment.statusDetail == "cc_rejected_call_for_authorize" {
            icon.image = MercadoPago.getImage("congrats_iconoAutorizarTel")
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
                let attributedTitle = NSMutableAttributedString(string: (titleWithParams.substring(to: (amountRange?.lowerBound)!)))
                let attributedAmount = Utils.getAttributedAmount(payment.transactionAmount, thousandSeparator: thousandSeparator, decimalSeparator: decimalSeparator, currencySymbol: currencySymbol, color: UIColor.white())
                attributedTitle.append(attributedAmount)
                let endingTitle = NSAttributedString(string: (titleWithParams.substring(from: (amountRange?.upperBound)!)))
                attributedTitle.append(endingTitle)
                self.title.attributedText = attributedTitle
            }
            
        } else if payment.status == "pending"{
            icon.image = MercadoPago.getImage("iconoPagoOffline")
            
            let currency = MercadoPagoContext.getCurrency()
            let currencySymbol = currency.getCurrencySymbolOrDefault()
            let thousandSeparator = String(currency.getThousandsSeparatorOrDefault()) ?? "."
            let decimalSeparator = String(currency.getDecimalSeparatorOrDefault()) ?? "."
            
            let arr = String(payment.transactionAmount).characters.split(separator: ".").map(String.init)
            let amountStr = Utils.getAmountFormatted(arr[0], thousandSeparator: thousandSeparator, decimalSeparator: decimalSeparator)
            let centsStr = Utils.getCentsFormatted(String(payment.transactionAmount), decimalSeparator: decimalSeparator)
            let amountRange = instruction?.title.range(of: currencySymbol + " " + amountStr + decimalSeparator + centsStr)
            
            if amountRange != nil {
                let attributedTitle = NSMutableAttributedString(string: (instruction?.title.substring(to: (amountRange?.lowerBound)!))!)
                let attributedAmount = Utils.getAttributedAmount(payment.transactionAmount, thousandSeparator: thousandSeparator, decimalSeparator: decimalSeparator, currencySymbol: currencySymbol, color: UIColor.white())
                attributedTitle.append(attributedAmount)
                let endingTitle = NSAttributedString(string: (instruction?.title.substring(from: (amountRange?.upperBound)!))!)
                attributedTitle.append(endingTitle)
                
                self.title.attributedText = attributedTitle
            }
        } else {
            icon.image = MercadoPago.getImage("congrats_iconoTcError")
            var title = (payment.statusDetail + "_title")
            if !title.existsLocalized() {
                title = "Uy, no pudimos procesar el pago".localized
            }
            
            if let paymentMethodName = paymentMethod?.name {
                let titleWithParams = (title.localized as NSString).replacingOccurrences(of: "%0", with: "\(paymentMethodName)")
                self.title.text = titleWithParams
            }
            messageError.text = "Algo salió mal… ".localized
        }
    }
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }
}
