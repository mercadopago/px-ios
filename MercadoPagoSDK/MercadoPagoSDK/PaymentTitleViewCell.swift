//
//  CheckoutPaymentTitleViewCell.swift
//  MercadoPagoSDK
//
//  Created by Maria cristina rodriguez on 20/1/16.
//  Copyright © 2016 MercadoPago. All rights reserved.
//

import UIKit

class PaymentTitleViewCell: UITableViewCell {

    static let ROW_HEIGHT = CGFloat(52)
    
    @IBOutlet weak var paymentTitle: MPLabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        self.addSubview(ViewUtils.getTableCellSeparatorLineView(0, y: 0, width: self.frame.width, height: 1))
    }

    override func setSelected(selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
    }
    
}
