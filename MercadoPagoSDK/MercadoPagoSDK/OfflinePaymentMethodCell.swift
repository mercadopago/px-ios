//
//  PaymentMethodCell.swift
//  MercadoPagoSDK
//
//  Created by Maria cristina rodriguez on 29/1/16.
//  Copyright © 2016 MercadoPago. All rights reserved.
//

import UIKit
fileprivate func < <T : Comparable>(lhs: T?, rhs: T?) -> Bool {
  switch (lhs, rhs) {
  case let (l?, r?):
    return l < r
  case (nil, _?):
    return true
  default:
    return false
  }
}

fileprivate func > <T : Comparable>(lhs: T?, rhs: T?) -> Bool {
  switch (lhs, rhs) {
  case let (l?, r?):
    return l > r
  default:
    return rhs < lhs
  }
}


class OfflinePaymentMethodCell: UITableViewCell {

    static let ROW_HEIGHT = CGFloat(80)
    
    @IBOutlet weak var iconCash: UIImageView!
    @IBOutlet weak var paymentMethodDescription: MPLabel!
   
    @IBOutlet weak var acreditationTimeLabel: MPLabel!

    @IBOutlet weak var changePaymentButton: MPButton!
    
    @IBOutlet weak var accreditationTimeIcon: UIImageView!
    
    
    override func awakeFromNib() {
        super.awakeFromNib()
        var image = MercadoPago.getImage("time")
        image = image?.withRenderingMode(.alwaysTemplate)
        self.accreditationTimeIcon.tintColor = UIColor.grayLight()
        self.accreditationTimeIcon.image = image
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
    }
    
    internal func fillCell(_ paymentMethodMethodSearchItem : PaymentMethodSearchItem, amount : Double, paymentMethod : PaymentMethod, currency : Currency) {
        
        let attributedAmount = Utils.getAttributedAmount(amount, currency: currency, color : UIColor.grayBaseText())
        let attributedTitle = NSMutableAttributedString(string : "Pagáras ".localized)
        attributedTitle.append(attributedAmount)
        
        var currentTitle = ""
        let titleI18N = "ryc_title_" + paymentMethodMethodSearchItem.idPaymentMethodSearchItem
        if (titleI18N.existsLocalized()) {
            currentTitle = titleI18N.localized
        } else {
            currentTitle = "ryc_title_default".localized
        }
        
        attributedTitle.append(NSAttributedString(string : currentTitle))
        
        let complementaryTitle = "ryc_complementary_" + paymentMethodMethodSearchItem.idPaymentMethodSearchItem
        if complementaryTitle.existsLocalized() {
            attributedTitle.append(NSAttributedString(string : complementaryTitle.localized))
        }
        attributedTitle.append(NSAttributedString(string : paymentMethod.name))
        
        self.paymentMethodDescription.attributedText = attributedTitle
        
        self.acreditationTimeLabel.attributedText = NSMutableAttributedString(string: paymentMethodMethodSearchItem.comment!)
    }
    
    
    
  }
