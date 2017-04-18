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
        self.selectionStyle = .none
    }
    func fillCell(paymentResult: PaymentResult?, instruction: Instruction?) -> Void {
        label.font = Utils.getFont(size: label.font.pointSize)

        if !Array.isNullOrEmpty(instruction?.secondaryInfo) {
            if let instruction = instruction?.secondaryInfo?[0] {
                label.text = instruction
            } else if paymentResult?.status == "approved"{
                label.text = ("Te enviaremos este comprobante a %0".localized as NSString).replacingOccurrences(of: "%0", with: "\(paymentResult!.payerEmail!)")
            } else {
                label.text = "También enviamos el código a tu email".localized
            }
        }
    }
}
