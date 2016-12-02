//
//  PaymentVaultTitleCollectionViewCell.swift
//  MercadoPagoSDK
//
//  Created by Maria cristina rodriguez on 11/17/16.
//  Copyright © 2016 MercadoPago. All rights reserved.
//

import UIKit

class PaymentVaultTitleCollectionViewCell: UICollectionViewCell {

    @IBOutlet weak var title: MPLabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        title.attributedText = NSAttributedString(string: "¿Cómo quiéres pagar?".localized)
        self.backgroundColor = MercadoPagoContext.getPrimaryColor()
    }
    
    func fillCell(){
        title.attributedText = NSAttributedString(string: "¿Cómo quiéres pagar?".localized)
        title.textColor = UIColor.systemFontColor()
        
    }

}
