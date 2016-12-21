//
//  ConfirmPaymentTableViewCell.swift
//  MercadoPagoSDK
//
//  Created by Maria cristina rodriguez on 11/2/16.
//  Copyright © 2016 MercadoPago. All rights reserved.
//

import UIKit

class ConfirmPaymentTableViewCell: UITableViewCell {

    public static let ROW_HEIGHT = CGFloat(110)
    
    @IBOutlet weak var confirmPaymentButton: MPButton!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        self.confirmPaymentButton.layer.cornerRadius = 4
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
    }
    
    
}
