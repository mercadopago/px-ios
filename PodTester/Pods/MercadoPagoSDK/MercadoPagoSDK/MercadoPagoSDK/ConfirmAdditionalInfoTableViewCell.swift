//
//  ConfirmAdditionalInfoTableViewCell.swift
//  MercadoPagoSDK
//
//  Created by Eden Torres on 2/2/17.
//  Copyright © 2017 MercadoPago. All rights reserved.
//

import UIKit

class ConfirmAdditionalInfoTableViewCell: UITableViewCell {
    static let ROW_HEIGHT = CGFloat(45)
    @IBOutlet weak var TEALabel: UILabel!
    @IBOutlet weak var CFT: UILabel!
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }
    
    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
        
        // Configure the view for the selected state
    }
    func fillCell(payerCost: PayerCost?){
        if let payerCost = payerCost {
            //CFT.font = Utils.getFont(size: CFT.font.pointSize)
            //TEALabel.font = Utils.getFont(size: TEALabel.font.pointSize)
            
            CFT.textColor = UIColor.px_grayDark()
            TEALabel.textColor = UIColor.px_grayDark()
            
            if let CFTValue = payerCost.getCFTValue() {
                CFT.text = "CFT " + CFTValue
            } else {
                CFT.text = ""
            }
            if let TEAValue = payerCost.getTEAValeu() {
                TEALabel.text = "TEA " + TEAValue
            } else {
                TEALabel.text = ""
            }
        }
    }
    
}
