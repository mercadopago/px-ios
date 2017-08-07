//
//  PurchaseDetailImageTableViewCell.swift
//  MercadoPagoSDK
//
//  Created by Maria cristina rodriguez on 11/2/16.
//  Copyright © 2016 MercadoPago. All rights reserved.
//

import UIKit

class PurchaseItemDetailTableViewCell: UITableViewCell {

    @IBOutlet weak var itemTitle: MPLabel!
    @IBOutlet weak var itemImage: UIImageView!

    @IBOutlet weak var itemDescription: MPLabel!

    @IBOutlet weak var itemQuantity: MPLabel!

    @IBOutlet weak var itemUnitPrice: MPLabel!

    @IBOutlet weak var titleDescriptionConstraint: NSLayoutConstraint!
    override func awakeFromNib() {
        super.awakeFromNib()

        self.contentView.layer.borderColor = UIColor.grayTableSeparator().cgColor
        self.contentView.layer.borderWidth = 1.0
        self.itemImage.image = MercadoPago.getImage("MPSDK_review_iconoCarrito")
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
    }

    func fillCell(item: Item, currency: Currency) {
        self.layoutIfNeeded()
        if let pictureUrl = item.pictureUrl {
            if let image = ViewUtils.loadImageFromUrl(pictureUrl) {
                self.itemImage.image = image
                self.itemImage.layer.cornerRadius = self.itemImage.frame.height / 2
                self.itemImage.clipsToBounds = true
            }
        }

        self.itemTitle.text = item.title
        self.itemTitle.font = Utils.getFont(size: itemTitle.font.pointSize)
        self.itemDescription.font =  Utils.getFont(size: itemDescription.font.pointSize)

        if item._description != nil && item._description!.characters.count > 0 {
            self.itemDescription.text = item._description!
        } else {
            self.itemDescription.text = ""
            self.titleDescriptionConstraint.constant = 0
        }

        self.itemQuantity.text = "Cantidad : ".localized + String(item.quantity)
        self.itemQuantity.font = Utils.getFont(size: itemQuantity.font.pointSize)
        let unitPrice = Utils.getAttributedAmount(item.unitPrice, thousandSeparator: currency.thousandsSeparator, decimalSeparator: currency.decimalSeparator, currencySymbol: currency.symbol, color : UIColor.px_grayDark(), fontSize : 18, baselineOffset: 5)
        let unitPriceTitle = NSMutableAttributedString(string: "Precio Unitario : ".localized, attributes: [NSFontAttributeName: Utils.getFont(size: self.itemQuantity.font.pointSize)])
        unitPriceTitle.append(unitPrice)
        self.itemUnitPrice.attributedText = unitPriceTitle
    }

    static func getCellHeight(item: Item) -> CGFloat {
        if String.isNullOrEmpty(item._description) {
            return CGFloat(280)
        }
        return CGFloat(300)

    }

}
