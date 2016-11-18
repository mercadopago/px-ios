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
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        self.contentView.layer.borderColor = UIColor.grayTableSeparator().cgColor
        self.contentView.layer.borderWidth = 1.0
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
    }
    
    func fillCell(item : Item, currency : Currency){
        self.layoutIfNeeded()
        if let image = ViewUtils.loadImageFromUrl(item.pictureUrl) {
            self.itemImage.image = image
            self.itemImage.layer.cornerRadius = self.itemImage.frame.height / 2
            self.itemImage.clipsToBounds = true
        }
        
        self.itemTitle.attributedText = NSAttributedString(string: item.title)
        if item._description != nil && item._description!.characters.count > 0 {
          self.itemDescription.attributedText = NSAttributedString(string: item._description!)
        } else {
            self.itemDescription.attributedText = NSAttributedString(string: "")
        }
        self.itemQuantity.attributedText = NSAttributedString(string: "Cantidad : " + String(item.quantity))
        let unitPrice = Utils.getAttributedAmount(item.unitPrice, thousandSeparator: currency.thousandsSeparator, decimalSeparator: currency.decimalSeparator, currencySymbol: currency.symbol, color : UIColor.grayDark(), fontSize : 18, baselineOffset: 5)
        let unitPriceTitle = NSMutableAttributedString(string: "Precio Unitario : ")
        unitPriceTitle.append(unitPrice)
        self.itemUnitPrice.attributedText = unitPriceTitle
    }
    
    static func getCellHeight(item : Item) -> CGFloat {
        
        let description = item.description
        if String.isNullOrEmpty(description) {
            return CGFloat(270)
        }
        
        return CGFloat(300);

    }
    
}
