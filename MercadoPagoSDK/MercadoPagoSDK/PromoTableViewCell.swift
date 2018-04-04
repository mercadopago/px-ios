//
//  PromoTableViewCell.swift
//  MercadoPagoSDK
//
//  Created by Matias Gualino on 22/5/15.
//  Copyright (c) 2015 MercadoPago. All rights reserved.
//

import UIKit

open class PromoTableViewCell: UITableViewCell {

	@IBOutlet weak open var issuerImageView: UIImageView!
	@IBOutlet weak open var sharesSubtitle: MPLabel!
	@IBOutlet weak open var paymentMethodsSubtitle: MPLabel!

	override public init(style: UITableViewCellStyle, reuseIdentifier: String!) {
		super.init(style: style, reuseIdentifier: reuseIdentifier)
	}

	override open func awakeFromNib() {
		super.awakeFromNib()
	}

	required public init?(coder aDecoder: NSCoder) {
		super.init(coder: aDecoder)
	}

	open func setPromoInfo(_ promo: BankDeal!) {
		let placeholderImage = UIImage(named: "empty_tc")

		if promo != nil && promo!.issuer != nil && promo!.issuer!.issuerId != nil && !String.isNullOrEmpty(promo.url) {

            Utils().loadImageWithCache(withUrl: promo.url, targetImage: self.issuerImageView, placeHolderImage: placeholderImage, fallbackImage: nil)
		}

		self.sharesSubtitle.text = promo.recommendedMessage

		if promo!.paymentMethods != nil && promo!.paymentMethods!.count > 0 {
			if promo!.paymentMethods!.count == 1 {
				self.paymentMethodsSubtitle.text = promo!.paymentMethods[0].name
			} else {
				var s = ""
				var i = 0
				for pm in promo.paymentMethods {
					s += pm.name
					if i == promo.paymentMethods.count - 2 {
						s += " y ".localized
					} else if i < promo.paymentMethods.count - 1 {
						s += ", "
					}
					i += 1
				}
				self.paymentMethodsSubtitle.text = s
			}
		} else {
			self.paymentMethodsSubtitle.text = ""
		}
	}
}
