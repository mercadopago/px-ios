//
//  IssuerTableViewCell.swift
//  MercadoPagoSDK
//
//  Created by Matias Gualino on 9/1/15.
//  Copyright (c) 2015 com.mercadopago. All rights reserved.
//

import UIKit

open class IssuerTableViewCell: UITableViewCell {
    @IBOutlet fileprivate weak var issuerLabel : MPLabel!
    
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
 
    open func fillWithIssuer(_ issuer : Issuer) {
        issuerLabel.text = issuer.name == "default" ? "Otro banco".localized : issuer.name
    }
    
}
