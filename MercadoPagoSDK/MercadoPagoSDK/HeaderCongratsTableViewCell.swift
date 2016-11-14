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
    
    func fillCell(payment: Payment, paymentMethod: PaymentMethod?, color: UIColor, titleInstruction: String?){
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
            let currency = MercadoPagoContext.getCurrency()
//            let totalAmount = Utils.getAttributedAmount(payment.transactionDetails.totalPaidAmount, thousandSeparator: String(currency.thousandsSeparator), decimalSeparator: String(currency.decimalSeparator), currencySymbol: String(currency.symbol), color:UIColor.white(), fontSize: 22, baselineOffset:11)
            
            var titleWithParams:String = ""
            if let paymentMethodName = paymentMethod?.name {
                titleWithParams = ("Debes autorizar ante %p el pago de %t a MercadoPago".localized as NSString).replacingOccurrences(of: "%p", with: "\(paymentMethodName)")
            }
            
            let amount = Utils.getAmountFormatted(String(payment.transactionDetails.totalPaidAmount), thousandSeparator : String(currency.thousandsSeparator), decimalSeparator: ".")
            titleWithParams = (titleWithParams.replacingOccurrences(of: "%t", with: "\(currency.symbol!) \(amount)"))
            self.title.text = titleWithParams
            
        } else if payment.status == "pending"{
            icon.image = MercadoPago.getImage("iconoPagoOffline")
            title.text = titleInstruction
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
