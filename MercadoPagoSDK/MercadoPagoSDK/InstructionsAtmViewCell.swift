//
//  InstructionsAtmViewCell.swift
//  MercadoPagoSDK
//
//  Created by Maria cristina rodriguez on 21/4/16.
//  Copyright © 2016 MercadoPago. All rights reserved.
//

import UIKit

class InstructionsAtmViewCell: UITableViewCell, InstructionsFillmentDelegate {

    @IBOutlet weak var instructionInfoTitle: MPLabel!
    
    @IBOutlet weak var atmStepOne: MPLabel!
    
    @IBOutlet weak var atmStepTwo: MPLabel!
    @IBOutlet weak var atmStepThree: MPLabel!
    
    @IBOutlet weak var atmInstructionSubtitle: MPLabel!
    
    @IBOutlet weak var firstReferenceLabel: MPLabel!
    @IBOutlet weak var firstReferenceValue: MPLabel!
    
    @IBOutlet weak var secondReferenceLabel: MPLabel!
    @IBOutlet weak var secondReferenceValue: MPLabel!
    
    @IBOutlet weak var thirdReferenceLabel: MPLabel!
    @IBOutlet weak var thirdReferenceValue: MPLabel!
    
    @IBOutlet weak var fourthReferenceLabel: MPLabel!
    @IBOutlet weak var fourthReferenceValue: MPLabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

    }
    
    func fillCell(instruction : Instruction) -> UITableViewCell {
        
        if instruction.info != nil && instruction.info.count > 0 {
        self.instructionInfoTitle.text = instruction.info[0]
            self.atmStepOne.text = instruction.info[2]
            self.atmStepTwo.text = instruction.info[3]
            self.atmStepThree.text = instruction.info[4]
            self.atmInstructionSubtitle.text = instruction.info[6]
        }
        
        if instruction.references != nil && instruction.references.count > 0 {
            MPCellValidator.fillInstructionReference(instruction.references[0], label: firstReferenceLabel, referenceValueLabel: firstReferenceValue)
            
            MPCellValidator.fillInstructionReference(instruction.references[1], label: secondReferenceLabel, referenceValueLabel: secondReferenceValue)
            
            MPCellValidator.fillInstructionReference(instruction.references[2], label: thirdReferenceLabel, referenceValueLabel: thirdReferenceValue)
            
            MPCellValidator.fillInstructionReference(instruction.references[3], label: fourthReferenceLabel, referenceValueLabel: fourthReferenceValue)
            
        }
        return self
    }
    
    func getCellHeight(instruction : Instruction, forFontSize: CGFloat) -> CGFloat {
        return 388
    }
    
}
