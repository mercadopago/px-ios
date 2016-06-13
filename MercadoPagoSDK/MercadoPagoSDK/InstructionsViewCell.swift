//
//  InstructionsViewCell.swift
//  MercadoPagoSDK
//
//  Created by Maria cristina rodriguez on 16/2/16.
//  Copyright © 2016 MercadoPago. All rights reserved.
//

import UIKit

class InstructionsViewCell: UITableViewCell, InstructionsFillmentDelegate {

    @IBOutlet weak var infoTitle: MPLabel!
    
    @IBOutlet weak var firstReferenceLabel: MPLabel!
    
    @IBOutlet weak var firstReferenceValue: MPLabel!
    
    @IBOutlet weak var secondReferenceLabel: MPLabel!
    
    @IBOutlet weak var secondReferenceValue: MPLabel!
    
    
    @IBOutlet weak var thirdReferenceLabel: MPLabel!
    
    @IBOutlet weak var thirdReferenceValue: MPLabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
    }
    
    func fillCell(instruction : Instruction) -> UITableViewCell {
        if instruction.info != nil && instruction.info.count > 0 {
            self.infoTitle.text = instruction.info[0]
        }
        
        if instruction.references != nil && instruction.references.count > 0 {
            MPCellValidator.fillInstructionReference(instruction.references[0], label: firstReferenceLabel, referenceValueLabel: firstReferenceValue)
            
            if instruction.references.count > 1 {
                 MPCellValidator.fillInstructionReference(instruction.references[1], label: secondReferenceLabel, referenceValueLabel: secondReferenceValue)
                
                if instruction.references.count > 2 {
                    MPCellValidator.fillInstructionReference(instruction.references[2], label: thirdReferenceLabel, referenceValueLabel: thirdReferenceValue)
                }
            }
            
        }
        return self
    }
    
    func getCellHeight(instruction : Instruction, forFontSize: CGFloat) -> CGFloat {
        return 230
    }
}
