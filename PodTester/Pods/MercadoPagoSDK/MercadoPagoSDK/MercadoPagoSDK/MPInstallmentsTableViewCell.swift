//
//  MPInstallmentsTableViewCell.swift
//  MercadoPagoSDK
//
//  Created by Matias Gualino on 7/1/15.
//  Copyright (c) 2015 com.mercadopago. All rights reserved.
//

import Foundation
import UIKit

open class MPInstallmentsTableViewCell : UITableViewCell {
    @IBOutlet weak fileprivate var rowTitle : MPLabel!
    @IBOutlet weak fileprivate var installmentsLabel : MPLabel!
    
    override public init(style: UITableViewCellStyle, reuseIdentifier: String!) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
    }
    
    override open func awakeFromNib() {
        super.awakeFromNib()
		self.rowTitle.text = "Cuotas".localized
    }
    
    required public init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    open func fillWithPayerCost(_ payerCost : PayerCost?, amount: Double) {
        if payerCost == nil {
            installmentsLabel.text = "Selecciona la cantidad de cuotas".localized
            installmentsLabel.textColor = UIColor.black
        } else {
            installmentsLabel.text = payerCost!.recommendedMessage
            installmentsLabel.textColor = UIColor.installments()
        }
    }
}
