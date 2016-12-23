//
//  PaymentIDTableViewCell.swift
//  MercadoPagoSDK
//
//  Created by Matias Gualino on 13/3/15.
//  Copyright (c) 2015 com.mercadopago. All rights reserved.
//

import UIKit

open class PaymentIDTableViewCell: UITableViewCell {

    @IBOutlet weak var lblID: MPLabel!
    @IBOutlet weak var lblTitle: MPLabel!
	
	override public init(style: UITableViewCellStyle, reuseIdentifier: String!) {
		super.init(style: style, reuseIdentifier: reuseIdentifier)
	}
	
	required public init?(coder aDecoder: NSCoder) {
		super.init(coder: aDecoder)
	}

	override open func awakeFromNib() {
        super.awakeFromNib()
		self.lblTitle.text = "Operación".localized
    }

    override open func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
}
