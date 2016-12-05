//
//  PayerCostTitleTableViewCell.swift
//  MercadoPagoSDK
//
//  Created by Eden Torres on 10/13/16.
//  Copyright © 2016 MercadoPago. All rights reserved.
//

import UIKit

class PayerCostTitleTableViewCell: UITableViewCell {

    @IBOutlet weak var cell: UIView!
    @IBOutlet weak var title: UILabel!
    func setTitle(string: String!){
        title.text = string
        title.textColor = UIColor.systemFontColor()
        cell.backgroundColor = MercadoPagoContext.getPrimaryColor()
    }
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
}
