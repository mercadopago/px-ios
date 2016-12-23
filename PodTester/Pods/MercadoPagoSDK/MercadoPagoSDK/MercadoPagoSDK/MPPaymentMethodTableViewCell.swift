//
//  MPPaymentMethodTableViewCell.swift
//  MercadoPagoSDK
//
//  Created by Matias Gualino on 7/1/15.
//  Copyright (c) 2015 com.mercadopago. All rights reserved.
//

import Foundation
import UIKit

open class MPPaymentMethodTableViewCell : UITableViewCell {
	@IBOutlet weak fileprivate var paymentMethodTitleLabel : MPLabel!
    @IBOutlet weak fileprivate var cardTextLabel : MPTextField!
    @IBOutlet weak fileprivate var cardIcon : UIImageView!
    
    override public init(style: UITableViewCellStyle, reuseIdentifier: String!) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
    }
    
    override open func awakeFromNib() {
        super.awakeFromNib()
		self.paymentMethodTitleLabel.text = "Medio de pago".localized
    }
    
    required public init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
	
	fileprivate func setEmptyPaymentMethod() {
		self.cardTextLabel.text = "Selecciona un medio de pago...".localized
		self.cardIcon.image = MercadoPago.getImage("empty_tc")
	}
	
    open func fillWithCard(_ card : Card?) {
        if card == nil || card!.paymentMethod == nil {
			setEmptyPaymentMethod()
        } else {
            self.cardTextLabel.text = card!.paymentMethod!.name + " " + "terminada en".localized + " " + card!.lastFourDigits!
            self.cardIcon.image = MercadoPago.getImage(card!.paymentMethod!._id)
        }
    }
    
    open func fillWithCardTokenAndPaymentMethod(_ card : CardToken?, paymentMethod : PaymentMethod?) {
        if card == nil || paymentMethod == nil {
			setEmptyPaymentMethod()
        } else {
            let range = card!.cardNumber!.characters.index(card!.cardNumber!.characters.endIndex, offsetBy: -4) ..< card!.cardNumber!.endIndex
            let lastFourDigits : String = card!.cardNumber!.substring(with: range)
            self.cardTextLabel.text = paymentMethod!.name + " " + "terminada en".localized + " " + lastFourDigits
            self.cardIcon.image = MercadoPago.getImage(paymentMethod!._id)
        }
    }
    
    open func fillWithPaymentMethod(_ paymentMethod : PaymentMethod?) {
        if paymentMethod == nil {
			setEmptyPaymentMethod()
        } else {
           self.cardTextLabel.text = paymentMethod!.name
            self.cardIcon.image = MercadoPago.getImage(paymentMethod!._id)
        }
    }
    
}
