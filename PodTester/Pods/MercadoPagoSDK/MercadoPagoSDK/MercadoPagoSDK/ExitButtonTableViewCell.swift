////
////  ExitButtonTableViewCell.swift
////  MercadoPagoSDK
////
////  Created by Maria cristina rodriguez on 10/5/16.
////  Copyright © 2016 MercadoPago. All rights reserved.
////

import UIKit

class ExitButtonTableViewCell: CallbackCancelTableViewCell {

    static let ROW_HEIGHT = CGFloat(60)

    @IBOutlet weak var exitButton: MPButton!

    override func awakeFromNib() {
        super.awakeFromNib()
        self.exitButton.addTarget(self, action: #selector(invokeDefaultCallback), for: .touchUpInside)
        self.exitButton.setTitle("Cancelar Pago".localized, for:UIControlState())
        self.exitButton.setTitleColor(UIColor.primaryColor(), for: UIControlState.normal)
        self.exitButton.titleLabel?.font = Utils.getFont(size: 16)
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
    }

}
