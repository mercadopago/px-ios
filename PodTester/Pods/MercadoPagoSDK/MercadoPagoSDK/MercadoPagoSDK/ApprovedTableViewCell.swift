//
//  ApprovedTableViewCell.swift
//  MercadoPagoSDK
//
//  Created by Eden Torres on 10/26/16.
//  Copyright © 2016 MercadoPago. All rights reserved.
//

import UIKit

class ApprovedTableViewCell: UITableViewCell {

    @IBOutlet weak var paymentId: UILabel!
    @IBOutlet weak var installments: UILabel!
    @IBOutlet weak var installmentRate: UILabel!
    @IBOutlet weak var total: UILabel!
    @IBOutlet weak var paymentMethod: UIImageView!
    @IBOutlet weak var lastFourDigits: UILabel!
    @IBOutlet weak var statement: UILabel!
    @IBOutlet weak var comprobante: UILabel!
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        installmentRate.text = " Sin interés".localized
        installmentRate.font = Utils.getFont(size: installmentRate.font.pointSize)
        comprobante.text = "Comprobante".localized
        comprobante.font = Utils.getFont(size: comprobante.font.pointSize)
    }
    func fillCell(payment: Payment){
        paymentId.text = "Nº \(payment._id)"
        paymentId.font = Utils.getFont(size: paymentId.font.pointSize)
        
        let currency = MercadoPagoContext.getCurrency()
        //let installmentNumber = "\(payment.installments) x "
        let installmentNumber = "\(payment.installments) x "
        let totalAmount = Utils.getAttributedAmount(payment.transactionDetails.installmentAmount, thousandSeparator: String(currency.thousandsSeparator), decimalSeparator: String(currency.decimalSeparator), currencySymbol: String(currency.symbol), color:UIColor.black, fontSize: 24, centsFontSize: 11, baselineOffset:11)
        let installmentLabel = NSMutableAttributedString(string: installmentNumber, attributes: [NSFontAttributeName: Utils.getFont(size: 24)])
        installmentLabel.append(totalAmount)
        installments.attributedText =  installmentLabel
        
        if payment.installments != 1{
            if payment.transactionDetails.totalPaidAmount != payment.transactionAmount{
                installmentRate.text = ""
            }
            let attributedTotal = NSMutableAttributedString(attributedString: NSAttributedString(string: "( ", attributes: [NSForegroundColorAttributeName : UIColor.black, NSFontAttributeName: Utils.getFont(size: 16)]))
            attributedTotal.append(Utils.getAttributedAmount(payment.transactionDetails.totalPaidAmount, thousandSeparator: String(currency.thousandsSeparator), decimalSeparator: String(currency.decimalSeparator), currencySymbol: String(currency.symbol), color: UIColor.black, fontSize:16, baselineOffset:4))
            attributedTotal.append(NSAttributedString(string: " )", attributes: [NSForegroundColorAttributeName : UIColor.black, NSFontAttributeName: Utils.getFont(size: 16)]))
            total.attributedText = attributedTotal
        } else {
            total.text = ""
            installmentRate.text = ""
        }
        
        paymentMethod.image = MercadoPago.getImage(payment.paymentMethodId)
        
        lastFourDigits.text = payment.paymentMethodId == "account_money" ? "Dinero en cuenta de MercadoPago".localized : "Terminada en ".localized + String(describing: payment.card.lastFourDigits!)
        lastFourDigits.font = Utils.getFont(size: lastFourDigits.font.pointSize)
        statement.text = ("En tu estado de cuenta verás el cargo como %0".localized as NSString).replacingOccurrences(of: "%0", with: "\(payment.statementDescriptor!)")
        statement.font = Utils.getFont(size: statement.font.pointSize)
        
    }
}
