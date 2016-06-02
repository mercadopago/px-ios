//
//  PromoTyCDetailTableViewCell.swift
//  MercadoPagoSDK
//
//  Created by Matias Gualino on 22/5/15.
//  Copyright (c) 2015 MercadoPago. All rights reserved.
//

import UIKit

public class PromoTyCDetailTableViewCell: UITableViewCell {

	@IBOutlet weak private var tycLabel: MPLabel!
	
    override public func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override public func setSelected(selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
	
	public func setLabelWithIssuerName(issuer: String, legals: String) {
		let s = NSMutableAttributedString(string: "\(issuer): \(legals)")
		let atts : [String : AnyObject] = [NSFontAttributeName: UIFont(name: MercadoPago.DEFAULT_FONT_NAME, size: 15)!]
		s.addAttributes(atts, range: NSMakeRange(0, issuer.characters.count))
		self.tycLabel.attributedText = s
	}
	
}
