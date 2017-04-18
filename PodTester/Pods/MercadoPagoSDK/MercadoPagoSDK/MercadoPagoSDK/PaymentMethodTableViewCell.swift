//
//  PaymentMethodTableViewCell.swift
//  MercadoPagoSDK
//
//  Created by Matias Gualino on 31/12/14.
//  Copyright (c) 2014 com.mercadopago. All rights reserved.
//

import Foundation
import UIKit

open class PaymentMethodTableViewCell : UITableViewCell {
    @IBOutlet fileprivate weak var paymentMethodLabel : MPLabel!
    @IBOutlet fileprivate var paymentMethodImage : UIImageView!
    
    override public init(style: UITableViewCellStyle, reuseIdentifier: String!) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
    }
    
    override open func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }
    
    required public init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    open func setLabel(_ label : String) {
        self.paymentMethodLabel.text = label
    }

    open func setImageWithName(_ imageName : String) {
        self.paymentMethodImage.image = MercadoPago.getImage(imageName)
    }
}
