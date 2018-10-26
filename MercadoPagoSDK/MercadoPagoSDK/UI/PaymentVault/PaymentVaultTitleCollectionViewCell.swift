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

    override func awakeFromNib() {
        super.awakeFromNib()
        self.title.font = Utils.getFont(size: title.font.pointSize)
        self.backgroundColor = ThemeManager.shared.getMainColor()
    }

    func fillCell(titleText: String) {
        title.text = titleText
    }

    internal func updateTitleFontSize(toSize: CGFloat) {
        self.title.font = Utils.getFont(size: toSize)
    }
}
