//
//  CallFourAuthTableViewCell.swift
//  MercadoPagoSDK
//
//  Created by Eden Torres on 10/31/16.
//  Copyright © 2016 MercadoPago. All rights reserved.
//

import UIKit

class CallForAuthTableViewCell: CallbackCancelTableViewCell {

    @IBOutlet weak var button: UIButton!
    @IBOutlet weak var title: UILabel!
    @IBOutlet weak var subtitle: UILabel!
    override func awakeFromNib() {
        super.awakeFromNib()
        self.button.addTarget(self, action: #selector(invokeCallback), for: .touchUpInside)
        self.button.titleLabel?.numberOfLines = 0
        self.button.titleLabel?.textAlignment = NSTextAlignment.center
        self.button.titleLabel?.font = Utils.getFont(size: 16)
        self.selectionStyle = .none

        // Initialization code
    }
    func fillCell(paymentMehtod: PaymentMethod?) {
        if let paymentMethodName = paymentMehtod!.name {
            let message = ("Ya hable con %0 y me autorizó".localized as NSString).replacingOccurrences(of: "%0", with: "\(paymentMethodName)")
            self.button.setTitle(message, for: UIControlState.normal)
        }
        title.text = "¿Qué puedo hacer?".localized
        subtitle.text = "El teléfono está al dorso de tu tarjeta.".localized
        self.title.font = Utils.getFont(size: self.title.font.pointSize)
        self.subtitle.font = Utils.getFont(size: self.subtitle.font.pointSize)
    }
}
