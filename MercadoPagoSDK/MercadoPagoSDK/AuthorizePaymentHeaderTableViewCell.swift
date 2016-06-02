//
//  AuthorizePaymentTableViewCell.swift
//  MercadoPagoSDK
//
//  Created by Maria cristina rodriguez on 9/5/16.
//  Copyright © 2016 MercadoPago. All rights reserved.
//

import UIKit

class AuthorizePaymentHeaderTableViewCell: UITableViewCell, CongratsFillmentDelegate {

    static let ROW_HEIGHT = CGFloat(240)
    
    @IBOutlet weak var title: MPLabel!
    
    
    @IBOutlet weak var subtitle: MPLabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        self.title.addCharactersSpacing(-0.4)
        self.layer.shadowOffset = CGSizeMake(0, 1)
        self.layer.shadowColor = UIColor(red: 153, green: 153, blue: 153).CGColor
        self.layer.shadowRadius = 3
        self.layer.shadowOpacity = 0.6

    }

    override func setSelected(selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
        // Configure the view for the selected state
    }
    
    func fillCell(payment: Payment, paymentMethod : PaymentMethod, callback : (Void -> Void)?) -> UITableViewCell {
        let title = NSMutableAttributedString(string: "Debes autorizar ante ".localized + paymentMethod.name + " el pago de ".localized)
        let attributedAmount = Utils.getAttributedAmount(payment.transactionDetails.totalPaidAmount, thousandSeparator: ".", decimalSeparator: ",", currencySymbol: "$", color: UIColor(red: 102, green: 102, blue: 102))
        title.appendAttributedString(attributedAmount)
        title.appendAttributedString(NSMutableAttributedString(string : " a MercadoPago".localized))
        self.title.attributedText = title
        self.title.addLineSpacing(4)
        self.subtitle.text = "El teléfono está al dorso de tu tarjeta".localized
        
        return self
    }
    
    
}
