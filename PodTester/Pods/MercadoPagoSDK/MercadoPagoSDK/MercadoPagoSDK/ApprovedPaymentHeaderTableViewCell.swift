//
//  ApprovedPaymentTableViewCell.swift
//  MercadoPagoSDK
//
//  Created by Maria cristina rodriguez on 9/5/16.
//  Copyright © 2016 MercadoPago. All rights reserved.
//

import UIKit

class ApprovedPaymentHeaderTableViewCell: UITableViewCell, CongratsFillmentDelegate {

    
    @IBOutlet weak var headerDescription: MPLabel!
    @IBOutlet weak var subtitle: MPLabel!
    override func awakeFromNib() {
        super.awakeFromNib()
        
        self.layer.shadowOffset = CGSize(width: 0, height: 1)
        self.layer.shadowColor = UIColor(red: 153, green: 153, blue: 153).cgColor
        self.layer.shadowRadius = 3
        self.layer.shadowOpacity = 0.6

    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

    }
    
    func fillCell(_ payment: Payment, paymentMethod : PaymentMethod, callback : ((Void) -> Void)?) -> UITableViewCell {
        if (payment.payer != nil && payment.payer!.email != nil && payment.payer!.email.isNotEmpty) {
            self.subtitle.text = payment.payer!.email
        } else {
            self.subtitle.text = ""
            self.headerDescription.text = ""
        }
        return self
    }
    
    func getCellHeight(_ payment: Payment, paymentMethod: PaymentMethod) -> CGFloat {
        return 200
    }
    
}
