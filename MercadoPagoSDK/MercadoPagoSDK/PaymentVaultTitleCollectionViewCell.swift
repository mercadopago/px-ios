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
        self.title.font = Utils.getFont(size: toSize)
    }

    @IBOutlet weak var title: MPLabel!

    override func awakeFromNib() {
        super.awakeFromNib()
        self.title.font = Utils.getFont(size: title.font.pointSize)
        self.backgroundColor = UIColor.primaryColor()
        fillCell()
    }

    func fillCell() {
        title.text = "¿Cómo quieres pagar?".localized
        title.textColor = UIColor.systemFontColor()

    }

}
