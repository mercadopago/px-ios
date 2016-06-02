//
//  ExitButtonTableViewCell.swift
//  MercadoPagoSDK
//
//  Created by Maria cristina rodriguez on 10/5/16.
//  Copyright © 2016 MercadoPago. All rights reserved.
//

import UIKit

class ExitButtonTableViewCell: CallbackCancelTableViewCell {

    static let ROW_HEIGHT = CGFloat(60)
    
    @IBOutlet weak var exitButton: MPButton!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        self.exitButton.addTarget(self, action: "invokeDefaultCallback", forControlEvents: .TouchUpInside)
    }

    override func setSelected(selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
    }
    
}
