//
//  InstructionsWithButtonViewCell.swift
//  MercadoPagoSDK
//
//  Created by Maria cristina rodriguez on 18/2/16.
//  Copyright © 2016 MercadoPago. All rights reserved.
//

import UIKit
fileprivate func < <T : Comparable>(lhs: T?, rhs: T?) -> Bool {
  switch (lhs, rhs) {
  case let (l?, r?):
    return l < r
  case (nil, _?):
    return true
  default:
    return false
  }
}

fileprivate func > <T : Comparable>(lhs: T?, rhs: T?) -> Bool {
  switch (lhs, rhs) {
  case let (l?, r?):
    return l > r
  default:
    return rhs < lhs
  }
}


class InstructionsWithButtonViewCell: UITableViewCell, InstructionsFillmentDelegate {

    @IBOutlet weak var button: MPButton!
    @IBOutlet weak var referenceLabelFirst: MPLabel!
    
    @IBOutlet weak var referenceValueFirst: MPLabel!
    @IBOutlet weak var referenceLabelSecond: MPLabel!
    
    @IBOutlet weak var referenceValueSecond: MPLabel!
    @IBOutlet weak var referenceLabelThird: MPLabel!
    @IBOutlet weak var referenceValueThird: MPLabel!
    
    
    override func awakeFromNib() {
        super.awakeFromNib()
        self.button.layer.borderWidth = 1.0
        self.button.layer.cornerRadius = 5
        self.button.layer.borderColor = UIColor.primaryColor().cgColor
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
    }
    
    func fillCell(_ instruction : Instruction) -> UITableViewCell {
        if instruction.references != nil && instruction.references.count > 0 {

            MPCellValidator.fillInstructionReference(instruction.references[0], label: self.referenceLabelFirst, referenceValueLabel: self.referenceValueFirst)
            
            if instruction.references.count > 1 {
                MPCellValidator.fillInstructionReference(instruction.references[1], label: self.referenceLabelSecond, referenceValueLabel: self.referenceValueSecond)
            }
            
            if instruction.references.count > 2 {
                MPCellValidator.fillInstructionReference(instruction.references[2], label: self.referenceLabelThird, referenceValueLabel: self.referenceValueThird)
            }
            
            if instruction.actions != nil && instruction.actions?.count > 0 {
                if instruction.actions![0].tag == ActionTag.LINK.rawValue {
                    self.button.actionLink = instruction.actions![0].url
                    self.button.addTarget(self, action: #selector(InstructionsWithButtonViewCell.openUrl), for: .touchUpInside)
                }
            } else {
                self.button.isHidden = true
            }
        }
        return self
    }
    
    func getCellHeight(_ instruction : Instruction, forFontSize : CGFloat) -> CGFloat {
        return 276
    }
    
    internal func openUrl(){
        UIApplication.shared.openURL(URL(string: self.button.actionLink!)!)
    }
}
