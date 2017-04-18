//
//  InstallmentTableViewCell.swift
//  MercadoPagoSDK
//
//  Created by Matias Gualino on 7/1/15.
//  Copyright (c) 2015 com.mercadopago. All rights reserved.
//

import Foundation
import UIKit

open class InstallmentTableViewCell : UITableViewCell {
    @IBOutlet fileprivate weak var installmentsLabel : MPLabel!
    
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
    
    open func fillWithPayerCost(_ payerCost : PayerCost, amount: Double) {
        installmentsLabel.text = payerCost.recommendedMessage
    }
}
