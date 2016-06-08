//
//  SimpleInstructionWithButtonViewCell.swift
//  MercadoPagoSDK
//
//  Created by Maria cristina rodriguez on 18/2/16.
//  Copyright © 2016 MercadoPago. All rights reserved.
//

import UIKit

class SimpleInstructionWithButtonViewCell: UITableViewCell, InstructionsFillmentDelegate {

    
    @IBOutlet weak var title: MPLabel!
    @IBOutlet weak var referenceLabel: MPLabel!
    @IBOutlet weak var button: MPLabel!
    @IBOutlet weak var referenceValue: MPLabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        self.button.layer.borderWidth = 1.0
        self.button.layer.cornerRadius = 5
        self.button.layer.borderColor = UIColor().blueMercadoPago().CGColor
    }

    override func setSelected(selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
    }
    
    func fillCell(instruction : Instruction) -> UITableViewCell {
        if instruction.info != nil && instruction.info.count > 0 {
            self.title.text  = instruction.info[0]
        }
        
        if instruction.references != nil && instruction.references.count > 0 {
            MPCellValidator.fillInstructionReference(instruction.references[0], label: self.referenceLabel, referenceValueLabel: self.referenceValue)
        }
        return self
    }
    
    func getCellHeight(instruction : Instruction, forFontSize: CGFloat) -> CGFloat {
        return 208
    }
}
