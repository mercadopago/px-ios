//
//  ApprovedPaymentBodyTableViewCell.swift
//  MercadoPagoSDK
//
//  Created by Maria cristina rodriguez on 9/5/16.
//  Copyright © 2016 MercadoPago. All rights reserved.
//

import UIKit

class ApprovedPaymentBodyTableViewCell: CallbackCancelTableViewCell, CongratsFillmentDelegate {

    static let ROW_HEIGHT = CGFloat(200)
    
    @IBOutlet weak var creditCardIcon: UIImageView!
    
    @IBOutlet weak var creditCardLabel: MPLabel!
    @IBOutlet weak var amountDescription: UILabel!
    @IBOutlet weak var cancelButton: MPButton!
    
    @IBOutlet weak var voucherId: MPLabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        let overLinewView = UIView(frame: CGRect(x: 0, y: 120, width: self.bounds.width, height: 1))
        overLinewView.backgroundColor = UIColor().UIColorFromRGB(0xDEDEDE)
        self.addSubview(overLinewView)

    }

    override func setSelected(selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
    }
    
    func fillCell(payment: Payment, paymentMethod : PaymentMethod, callback : (Void -> Void)?) -> UITableViewCell {
        self.creditCardIcon.image = MercadoPago.getImage(payment.paymentMethodId)
        self.voucherId.text = "Comprobante".localized + " " + String(payment._id)
        let greenLabelColor = UIColor(red: 67, green: 176,blue: 0)
        
        self.creditCardLabel.text = "terminada en ".localized + payment.card.lastFourDigits!
        let additionalTextAttributes = [NSForegroundColorAttributeName : greenLabelColor, NSFontAttributeName : UIFont(name:MercadoPago.DEFAULT_FONT_NAME, size: 22)!]
        let noRateTextAttributes = [NSForegroundColorAttributeName : greenLabelColor, NSFontAttributeName : UIFont(name:MercadoPago.DEFAULT_FONT_NAME, size: 13)!]
        let additionalString = NSMutableAttributedString(string: " ")
        
        if payment.feesDetails != nil && payment.feesDetails.count > 0 {
            let financingFee = payment.feesDetails.filter({ return $0.isFinancingFeeType()})
            if financingFee.count > 0 {
                additionalString.appendAttributedString(NSAttributedString(string : "( ", attributes: additionalTextAttributes))
                additionalString.appendAttributedString(Utils.getAttributedAmount(payment.transactionDetails.totalPaidAmount, thousandSeparator: ".", decimalSeparator: ",", currencySymbol: "$", color: greenLabelColor, fontSize : 22))
                additionalString.appendAttributedString(NSAttributedString(string : " )", attributes: additionalTextAttributes))
            } else {
                if payment.installments != 1 {
                    additionalString.appendAttributedString(NSAttributedString(string: "Sin interes".localized, attributes : noRateTextAttributes))
                }
            }
        }
        
        self.amountDescription.attributedText = Utils.getTransactionInstallmentsDescription(String(payment.installments), installmentAmount: payment.transactionDetails.installmentAmount, additionalString: additionalString)
        return self
    }
    
}
