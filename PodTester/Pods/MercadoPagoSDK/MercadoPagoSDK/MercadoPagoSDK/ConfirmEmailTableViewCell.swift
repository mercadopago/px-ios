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
        label.font = Utils.getFont(size: label.font.pointSize)
        label.text = "También enviamos el código a tu email".localized
    }
    func fillCell(paymentResult: PaymentResult?) -> Void {
        if paymentResult?.status == "approved" {
            label.text = ("Te enviaremos este comprobante a %0".localized as NSString).replacingOccurrences(of: "%0", with: "\(paymentResult!.payerEmail!)")
            
        }
    }
    
    func fillCell(instruction: Instruction?) -> Void {
        if !Array.isNullOrEmpty(instruction?.secondaryInfo) {
            if let instruction = instruction?.secondaryInfo?[0] {
                label.text = instruction
            }
        }
    }
}
