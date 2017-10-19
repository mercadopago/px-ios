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
		let placeholderImage = "empty_tc"
		if promo != nil && promo!.issuer != nil && promo!.issuer!._id != nil && promo.url != nil {
			let imgURL: URL = URL(string: promo.url!)!
			let request: URLRequest = URLRequest(url: imgURL)
			NSURLConnection.sendAsynchronousRequest(
				request, queue: OperationQueue.main,
				completionHandler: {(_: URLResponse?, data: Data?, error: Error?) -> Void in
					if error == nil {
						self.issuerImageView.image = UIImage(data: data!)
					} else {
						self.issuerImageView.image = UIImage(named: placeholderImage)
					}
			})
		}

		self.sharesSubtitle.text = promo.recommendedMessage

		if promo!.paymentMethods != nil && promo!.paymentMethods!.count > 0 {
			if promo!.paymentMethods!.count == 1 {
				self.paymentMethodsSubtitle.text = promo!.paymentMethods[0].name
			} else {
				var s = ""
				var i = 0
				for pm in promo.paymentMethods {
					s = s + pm.name
					if i == promo.paymentMethods.count - 2 {
						s = s + " y ".localized
					} else if i < promo.paymentMethods.count - 1 {
						s = s + ", "
					}
					i = i + 1
				}
				self.paymentMethodsSubtitle.text = s
			}
		} else {
			self.paymentMethodsSubtitle.text = ""
		}
	}
}
