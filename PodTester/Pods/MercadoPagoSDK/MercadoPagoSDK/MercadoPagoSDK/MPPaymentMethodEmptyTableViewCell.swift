//
//  MPPaymentMethodEmptyTableViewCell.swift
//  MercadoPagoSDK
//
//  Created by Matias Gualino on 27/1/15.
//  Copyright (c) 2015 com.mercadopago. All rights reserved.
//

import UIKit

open class MPPaymentMethodEmptyTableViewCell: UITableViewCell {

    @IBOutlet weak fileprivate var cardTextLabel : MPTextField!
    @IBOutlet weak var titleLabel: MPLabel!
    
    override public init(style: UITableViewCellStyle, reuseIdentifier: String!) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
    }
    
    override open func awakeFromNib() {
        super.awakeFromNib()
		cardTextLabel.text = "Selecciona un medio de pago...".localized
		titleLabel.text = "Medio de pago".localized
    }
    
    required public init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
}
