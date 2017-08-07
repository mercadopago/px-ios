//
//  AdditionalStepTitleTableViewCell.swift
//  MercadoPagoSDK
//
//  Created by Eden Torres on 10/13/16.
//  Copyright © 2016 MercadoPago. All rights reserved.
//

import UIKit

class AdditionalStepTitleTableViewCell: UITableViewCell, TitleCellScrollable {

    internal func updateTitleFontSize(toSize: CGFloat) {
        self.title.font = Utils.getFont(size: toSize)
    }

    @IBOutlet weak var cell: UIView!
    @IBOutlet weak var title: UILabel!
    func setTitle(string: String!) {
        title.text = string
        title.font = Utils.getFont(size: title.font.pointSize)
        title.textColor = UIColor.systemFontColor()
        cell.backgroundColor = UIColor.primaryColor()
    }
    override func awakeFromNib() {
        super.awakeFromNib()
		self.selectionStyle = UITableViewCellSelectionStyle.none
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
