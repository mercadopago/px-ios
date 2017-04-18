//
//  PaymentSearchRowTableViewCell.swift
//  MercadoPagoSDK
//
//  Created by Maria cristina rodriguez on 15/1/16.
//  Copyright © 2016 MercadoPago. All rights reserved.
//

import UIKit

class PaymentSearchCell: UITableViewCell {
    
    static let ROW_HEIGHT = CGFloat(52)
    
    @IBOutlet weak var paymentTitle: MPLabel!
    
    @IBOutlet weak var paymentIcon: UIImageView!

    
    override init(style: UITableViewCellStyle, reuseIdentifier: String!) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
    }

    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    override func
        awakeFromNib() {
        super.awakeFromNib()
    }
    
    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
    }
    
    func fillRowWithPayment(_ paymentSearchItem : PaymentMethodSearchItem, iconImage: UIImage, tintColor : Bool){
        self.paymentTitle.text = paymentSearchItem._description
        if tintColor {
            let tintedImage = iconImage.withRenderingMode(UIImageRenderingMode.alwaysTemplate)
            self.paymentIcon.image = tintedImage
            self.paymentIcon.tintColor = MercadoPagoContext.getPrimaryColor()
        } else {
            self.paymentIcon.image = iconImage
            self.paymentTitle.isHidden = true
        }
    }
}
