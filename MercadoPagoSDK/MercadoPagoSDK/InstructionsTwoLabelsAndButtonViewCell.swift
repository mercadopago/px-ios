//
//  InstructionsTwoLabelsAndButtonViewCell.swift
//  MercadoPagoSDK
//
//  Created by Maria cristina rodriguez on 18/2/16.
//  Copyright © 2016 MercadoPago. All rights reserved.
//

import UIKit

class InstructionsTwoLabelsAndButtonViewCell: UITableViewCell, InstructionsFillmentDelegate {

    @IBOutlet weak var button: MPButton!
    @IBOutlet weak var infoTitle: MPLabel!
    @IBOutlet weak var referenceLabelFirst: MPLabel!
    @IBOutlet weak var referenceValueFirst: MPLabel!
    
    @IBOutlet weak var referenceLabelSecond: MPLabel!
    @IBOutlet weak var referenceValueSecond: MPLabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        self.button.layer.borderWidth = 1.0
        self.button.layer.cornerRadius = 5
        self.button.layer.borderColor = UIColor().blueMercadoPago().CGColor
    }

    override func setSelected(selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
    func fillCell(instruction: Instruction) -> UITableViewCell {
        
        if instruction.info != nil && instruction.info.count > 0 {
            self.infoTitle.text = instruction.info[0]
        }
        
        if instruction.references != nil && instruction.references.count > 0 {
            
             MPCellValidator.fillInstructionReference(instruction.references[0], label: self.referenceLabelFirst, referenceValueLabel: self.referenceValueFirst)
            
            if (instruction.references.count > 1) {
                MPCellValidator.fillInstructionReference(instruction.references[1], label: self.referenceLabelSecond, referenceValueLabel: self.referenceValueSecond)
            }
        }
        
        if instruction.actions != nil && instruction.actions?.count > 0 {
            if instruction.actions![0].tag == ActionTag.LINK.rawValue {
                self.button.actionLink = instruction.actions![0].url
                self.button.addTarget(self, action: "openUrl", forControlEvents: .TouchUpInside)
            }
        } else {
            self.button.hidden = true
        }
        
        return self
    }
    
    func getCellHeight(instruction : Instruction, forFontSize: CGFloat) -> CGFloat {
        return 258
    }
    
    internal func openUrl(){
        UIApplication.sharedApplication().openURL(NSURL(string: self.button.actionLink!)!)
    }
}
