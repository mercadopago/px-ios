//
//  PaymentVaultTitleCollectionViewCell.swift
//  MercadoPagoSDK
//
//  Created by Maria cristina rodriguez on 11/17/16.
//  Copyright © 2016 MercadoPago. All rights reserved.
//

import UIKit

class PaymentVaultTitleCollectionViewCell: UICollectionViewCell, TitleCellScrollable {

    @IBOutlet weak var title: PXNavigationHeaderLabel!

    var customTitle : String?
    
    override func awakeFromNib() {
        super.awakeFromNib()
        self.title.font = Utils.getFont(size: title.font.pointSize)
        self.backgroundColor = ThemeManager.shared.getMainColor()
        fillCell()
    }

    func fillCell() {
        if (self.customTitle != nil) {
            title.text = self.customTitle
        } else {
            title.text = "¿Cómo quieres pagar?".localized
        }
    }

    internal func updateTitleFontSize(toSize: CGFloat) {
        self.title.font = Utils.getFont(size: toSize)
    }
}
