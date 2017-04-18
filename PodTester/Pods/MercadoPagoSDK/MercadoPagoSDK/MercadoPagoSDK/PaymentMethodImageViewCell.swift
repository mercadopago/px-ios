//
//  PaymentMethodImageViewCellTableViewCell.swift
//  MercadoPagoSDK
//
//  Created by Maria cristina rodriguez on 22/2/16.
//  Copyright © 2016 MercadoPago. All rights reserved.
//

import UIKit

class PaymentMethodImageViewCell: UITableViewCell {

    static let ROW_HEIGHT = CGFloat(66)
    
    @IBOutlet weak var paymentMethodImage: UIImageView!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        self.addSubview(ViewUtils.getTableCellSeparatorLineView(0, y: 0, width: self.frame.width, height: 1))
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
    }
    
}
