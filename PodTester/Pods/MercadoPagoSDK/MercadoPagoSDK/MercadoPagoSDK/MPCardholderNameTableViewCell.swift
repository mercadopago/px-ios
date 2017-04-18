//
//  MPCardholderNameTableViewCell.swift
//  MercadoPagoSDK
//
//  Created by Matias Gualino on 30/12/14.
//  Copyright (c) 2014 com.mercadopago. All rights reserved.
//

import Foundation
import UIKit

open class MPCardholderNameTableViewCell : ErrorTableViewCell {
    @IBOutlet weak fileprivate var cardholderNameLabel: MPLabel!
    @IBOutlet weak open var cardholderNameTextField: MPTextField!
	
	open override func focus() {
		if !self.cardholderNameTextField.isFirstResponder {
			self.cardholderNameTextField.becomeFirstResponder()
		}
	}
	
    override public init(style: UITableViewCellStyle, reuseIdentifier: String!) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
    }
    
    override open func awakeFromNib() {
        super.awakeFromNib()
		self.cardholderNameLabel.text = "Nombre y apellido impreso en la tarjeta".localized
    }
    
    
    required public init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    
    open func getCardholderName() -> String! {
		return self.cardholderNameTextField.text != nil ? self.cardholderNameTextField.text!.uppercased() : nil
    }
    
    open func setTextFieldDelegate(_ delegate : UITextFieldDelegate) {
        self.cardholderNameTextField.delegate = delegate
    }
}
