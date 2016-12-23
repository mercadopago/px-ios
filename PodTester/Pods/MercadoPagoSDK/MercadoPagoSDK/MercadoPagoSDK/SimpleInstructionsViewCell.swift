//
//  SimpleInstructionViewCellTableViewCell.swift
//  MercadoPagoSDK
//
//  Created by Maria cristina rodriguez on 17/2/16.
//  Copyright © 2016 MercadoPago. All rights reserved.
//

import UIKit

class SimpleInstructionsViewCell: UITableViewCell, InstructionsFillmentDelegate {

    @IBOutlet weak var infoTitle: MPLabel!
    @IBOutlet weak var referenceValue: MPLabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
    func fillCell(_ instruction : Instruction) -> UITableViewCell {
        
        if instruction.info != nil && instruction.info.count > 0 {
            self.infoTitle.text = instruction.info[0]
        }
        
        if instruction.references != nil && instruction.references.count > 0 {
            self.referenceValue.text = instruction.references[0].getFullReferenceValue()
        }
        
        return self
    }
    
    func getCellHeight(_ instruction : Instruction, forFontSize: CGFloat) -> CGFloat {
        
        var constraintSize = CGSize()
        let screenSize: CGRect = UIScreen.main.bounds
        constraintSize.width = screenSize.width - 30
        
        let attributes = [NSFontAttributeName: UIFont(name: MercadoPago.DEFAULT_FONT_NAME, size: 22) ?? UIFont.systemFont(ofSize: 22)]
        
        let frame = (instruction.references[0].getFullReferenceValue() as NSString).boundingRect(with: constraintSize, options: NSStringDrawingOptions.usesLineFragmentOrigin, attributes: attributes, context: nil)
        
        let stringSize = frame.size
        return 85 + stringSize.height
    }
    
}
