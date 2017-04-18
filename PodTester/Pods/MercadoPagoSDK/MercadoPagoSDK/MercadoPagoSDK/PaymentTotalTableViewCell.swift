//
//  PaymentTotalTableViewCell.swift
//  MercadoPagoSDK
//
//  Created by Matias Gualino on 13/3/15.
//  Copyright (c) 2015 com.mercadopago. All rights reserved.
//

import UIKit

open class PaymentTotalTableViewCell: UITableViewCell {

    @IBOutlet weak var lblTotal: MPLabel!
    @IBOutlet weak var lblTitle: MPLabel!
	
	override public init(style: UITableViewCellStyle, reuseIdentifier: String!) {
		super.init(style: style, reuseIdentifier: reuseIdentifier)
	}

	required public init?(coder aDecoder: NSCoder) {
		super.init(coder: aDecoder)
	}
	
    override open func awakeFromNib() {
        super.awakeFromNib()
		self.lblTotal.text = "Total".localized
    }

    override open func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
}
