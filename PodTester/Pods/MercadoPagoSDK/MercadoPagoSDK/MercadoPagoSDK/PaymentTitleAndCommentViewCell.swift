//
//  PaymentTitleAndCommentViewCell.swift
//  MercadoPagoSDK
//
//  Created by Maria cristina rodriguez on 11/2/16.
//  Copyright © 2016 MercadoPago. All rights reserved.
//

import UIKit

class PaymentTitleAndCommentViewCell: UITableViewCell {

    @IBOutlet weak var paymentTitle: MPLabel!
    
    @IBOutlet weak var paymentComment: MPLabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        self.addSubview(ViewUtils.getTableCellSeparatorLineView(0, y: 0, width: self.frame.width, height: 1))
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
    func fillRowWith(_ paymentTitle : String, paymentComment : String) {
        self.paymentTitle.text = paymentTitle
        self.paymentComment.text = paymentComment
    }
    
}
