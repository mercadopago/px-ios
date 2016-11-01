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
    
    @IBOutlet weak var iconImage: UIImageView!
    
    @IBOutlet weak var comment: MPLabel!
    
    @IBOutlet weak var paymentItemDescription: MPLabel!

    
    override func awakeFromNib() {
        super.awakeFromNib()
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
    }
    
    internal func fillRowWithPaymentMethod(_ paymentMethod : PaymentMethodSearchItem, image : UIImage, paymentItemDescription : String = "") {
        self.iconImage.image = image
        self.comment.text = (paymentMethod.comment!)
        self.paymentItemDescription.text = paymentItemDescription
    }
    
    internal func fillRowWithPaymentMethod(_ paymentMethod : PaymentMethod, paymentMethodSearchItemSelected : PaymentMethodSearchItem) {
        self.iconImage.image = MercadoPago.getImage(paymentMethodSearchItemSelected.idPaymentMethodSearchItem)
        if paymentMethodSearchItemSelected.comment?.characters.count > 0 {
            self.comment.text = paymentMethodSearchItemSelected.comment
        } else {
            self.comment.text = Utils.getAccreditationTitle(paymentMethod)
        }
        
        self.paymentItemDescription.text = paymentMethodSearchItemSelected.description
        
    }
}
