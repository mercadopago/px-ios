//
//  MPSecurityCodeTableViewCell.swift
//  MercadoPagoSDK
//
//  Created by Matias Gualino on 30/12/14.
//  Copyright (c) 2014 com.mercadopago. All rights reserved.
//

import Foundation
import UIKit

open class MPSecurityCodeTableViewCell : ErrorTableViewCell {
    @IBOutlet weak fileprivate var securityCodeLabel: MPLabel!
    @IBOutlet weak fileprivate var securityCodeInfoLabel: MPLabel!
    @IBOutlet weak open var securityCodeTextField: MPTextField!
    @IBOutlet weak fileprivate var securityCodeImageView: UIImageView!
    
    override public init(style: UITableViewCellStyle, reuseIdentifier: String!) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
    }
    
    override open func awakeFromNib() {
        super.awakeFromNib()
		self.securityCodeLabel.text = "security_code".localized
    }
    
    required public init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    open func getSecurityCode() -> String! {
        return self.securityCodeTextField.text
    }
    
    open func fillWithPaymentMethod(_ pm : PaymentMethod) {
        self.securityCodeImageView.image = MercadoPago.getImage("imgTc_" + pm._id)
        if pm._id == "amex" {
			var amexCvvLength = 4
			if pm.settings != nil && pm.settings.count > 0 {
				amexCvvLength = pm.settings[0].securityCode!.length
			}
			
            self.securityCodeInfoLabel.text = ("cod_seg_desc_amex".localized as NSString).replacingOccurrences(of: "%1$s", with: "\(amexCvvLength)")
        } else {
			var cvvLength = 3
			if pm.settings != nil && pm.settings.count > 0 {
				cvvLength = pm.settings[0].securityCode!.length
			}
			
            self.securityCodeInfoLabel.text = ("cod_seg_desc".localized as NSString).replacingOccurrences(of: "%1$s", with: "\(cvvLength)")
        }
        
    }
    
}
