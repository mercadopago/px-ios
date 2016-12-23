//
//  PaymentVaultTitleCollectionViewCell.swift
//  MercadoPagoSDK
//
//  Created by Maria cristina rodriguez on 11/17/16.
//  Copyright © 2016 MercadoPago. All rights reserved.
//

import UIKit

class PaymentVaultTitleCollectionViewCell: UICollectionViewCell, TitleCellScrollable {
    
    internal func updateTitleFontSize(toSize: CGFloat) {
        self.title.font = UIFont(name:MercadoPago.DEFAULT_FONT_NAME, size: toSize) ?? UIFont.systemFont(ofSize: toSize)
    }


    @IBOutlet weak var title: MPLabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        title.text = "¿Cómo quiéres pagar?".localized
        self.backgroundColor = MercadoPagoContext.getPrimaryColor()
    }
    
    func fillCell(){
        title.text = "¿Cómo quiéres pagar?".localized
        title.textColor = UIColor.systemFontColor()
        
    }

}

