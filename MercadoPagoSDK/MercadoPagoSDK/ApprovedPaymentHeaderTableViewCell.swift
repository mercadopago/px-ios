//
//  ApprovedPaymentTableViewCell.swift
//  MercadoPagoSDK
//
//  Created by Maria cristina rodriguez on 9/5/16.
//  Copyright © 2016 MercadoPago. All rights reserved.
//

import UIKit

class ApprovedPaymentHeaderTableViewCell: UITableViewCell, CongratsFillmentDelegate {

    
    @IBOutlet weak var subtitle: MPLabel!
    override func awakeFromNib() {
        super.awakeFromNib()
        
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
        var subtitle : String = ""
        if (payment.payer != nil) {
            subtitle = payment.payer!.email ?? ""
        }
        
        self.subtitle.text = subtitle
        return self
    }
    
    func getCellHeight(payment: Payment, paymentMethod: PaymentMethod) -> CGFloat {
        return 200
    }
    
}
