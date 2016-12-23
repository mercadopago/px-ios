//
//  InstructionsTwoLabelsViewCell.swift
//  MercadoPagoSDK
//
//  Created by Maria cristina rodriguez on 17/2/16.
//  Copyright © 2016 MercadoPago. All rights reserved.
//

import UIKit

class InstructionsTwoLabelsViewCell: UITableViewCell, InstructionsFillmentDelegate {

    @IBOutlet weak var infoTitle: MPLabel!
    @IBOutlet weak var firstReferenceTitle: MPLabel!
    @IBOutlet weak var firstReferenceValue: MPLabel!
    @IBOutlet weak var secondReferenceTitle: MPLabel!
    @IBOutlet weak var secondReferenceValue: MPLabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
    }
    
    func fillCell(_ instruction : Instruction) -> UITableViewCell {
        
        if instruction.info != nil && instruction.info.count > 0 {
            self.infoTitle.text = instruction.info[0]
        }
        
        if instruction.references != nil && instruction.references.count > 0 {
            
            MPCellValidator.fillInstructionReference(instruction.references[0], label: firstReferenceTitle, referenceValueLabel: firstReferenceValue)
        
            if instruction.references.count > 1 {
                    MPCellValidator.fillInstructionReference(instruction.references[1], label: secondReferenceTitle, referenceValueLabel: secondReferenceValue)
            }
        }
        
        return self
    }
    
    func getCellHeight(_ instruction : Instruction, forFontSize: CGFloat) -> CGFloat {
        return 166
    }
    
}
