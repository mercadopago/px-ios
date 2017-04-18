//
//  OfflinePaymentMethodWithDescription.swift
//  MercadoPagoSDK
//
//  Created by Maria cristina rodriguez on 22/4/16.
//  Copyright © 2016 MercadoPago. All rights reserved.
//

import UIKit

class OfflinePaymentMethodWithDescriptionCell: UITableViewCell {

    static let ROW_HEIGHT = CGFloat(80)

    @IBOutlet weak var paymentIcon: UIImageView!
    
    @IBOutlet weak var paymentDescription: MPLabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        self.addSubview(ViewUtils.getTableCellSeparatorLineView(0, y: 0, width: self.frame.width, height: 1))
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
    }
    
    
    func fillRowWith(_ paymentMethodSearchItem : PaymentMethodSearchItem) -> UITableViewCell {
        self.paymentDescription.text = paymentMethodSearchItem._description
        self.paymentIcon.image = MercadoPago.getImage(paymentMethodSearchItem.idPaymentMethodSearchItem)
        return self
    }
    
}
