//
//  ApprovedPaymentBodyTableViewCell.swift
//  MercadoPagoSDK
//
//  Created by Maria cristina rodriguez on 9/5/16.
//  Copyright © 2016 MercadoPago. All rights reserved.
//

import UIKit

class RejectedPaymentBodyTableViewCell: CallbackCancelTableViewCell, CongratsFillmentDelegate {
    
    @IBOutlet weak var payAgainButton: MPButton!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        self.payAgainButton.layer.cornerRadius = 5
        self.payAgainButton.layer.borderWidth = 1
        self.payAgainButton.layer.borderColor = UIColor.primaryColor().cgColor
        self.payAgainButton.addTarget(self, action: #selector(invokeDefaultCallback), for: .touchUpInside)
        
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
    }
    
    func fillCell(_ payment: Payment, paymentMethod : PaymentMethod, callback : ((Void) -> Void)?) -> UITableViewCell {
        self.defaultCallback = callback
        return self
    }

    func getCellHeight(_ payment: Payment, paymentMethod: PaymentMethod) -> CGFloat {
        return 120
    }
    
}
