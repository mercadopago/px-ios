//
//  ConfirmEmailTableViewCell.swift
//  MercadoPagoSDK
//
//  Created by Eden Torres on 10/26/16.
//  Copyright © 2016 MercadoPago. All rights reserved.
//

import UIKit

class ConfirmEmailTableViewCell: UITableViewCell {
    
    @IBOutlet weak var label: UILabel!
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }
    func fillCell(payment: Payment, instruction: Instruction?) -> Void {
        if let instruction = instruction?.secondaryInfo?[0] {
            label.text = instruction
        } else if payment.status == "approved"{
            label.text = ("Te enviaremos este comprobante a %0".localized as NSString).replacingOccurrences(of: "%0", with: "\(payment.payer.email!)")
        } else {
            label.text = "También enviamos el código a tu email".localized
        }
    }
}
