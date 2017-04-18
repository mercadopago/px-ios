//
//  RecoverPaymentBodyTableViewCell.swift
//  MercadoPagoSDK
//
//  Created by Demian Tejo on 9/7/16.
//  Copyright © 2016 MercadoPago. All rights reserved.
//

import UIKit

class RecoverPaymentBodyTableViewCell: CallbackCancelTableViewCell, CongratsFillmentDelegate {

    @IBOutlet weak var tryAgainButton: MPButton!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        self.tryAgainButton.layer.cornerRadius = 5
        self.tryAgainButton.layer.borderWidth = 1
        self.tryAgainButton.layer.borderColor = UIColor.primaryColor().cgColor
        self.tryAgainButton.addTarget(self, action: Selector("invokeDefaultCallback"), for: .touchUpInside)
        
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
