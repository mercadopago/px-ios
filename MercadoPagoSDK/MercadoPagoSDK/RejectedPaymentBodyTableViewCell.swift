//
//  ApprovedPaymentBodyTableViewCell.swift
//  MercadoPagoSDK
//
//  Created by Maria cristina rodriguez on 9/5/16.
//  Copyright © 2016 MercadoPago. All rights reserved.
//

import UIKit

class RejectedPaymentBodyTableViewCell: CallbackCancelTableViewCell, CongratsFillmentDelegate {

    static let ROW_HEIGHT = CGFloat(122)
    
    @IBOutlet weak var payAgainButton: MPButton!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        self.payAgainButton.layer.cornerRadius = 5
        self.payAgainButton.layer.borderWidth = 1
        self.payAgainButton.layer.borderColor = UIColor().blueMercadoPago().CGColor
        self.payAgainButton.addTarget(self, action: "invokeDefaultCallback", forControlEvents: .TouchUpInside)
        ViewUtils.drawBottomLine(20, y: 122, width : self.bounds.width-40, inView: self)
        
    }

    override func setSelected(selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
    }
    
    func fillCell(payment: Payment, paymentMethod : PaymentMethod, callback : (Void -> Void)?) -> UITableViewCell {
        self.defaultCallback = callback
        return self
    }

    
}
