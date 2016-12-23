//
//  FooterWithSecondaryInfoViewCell.swift
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


class InstructionsFooterWithSecondaryInfoViewCell: UITableViewCell, InstructionsFillmentDelegate {

    
    @IBOutlet weak var secondaryInfoTitle: MPLabel!
    @IBOutlet weak var clockIcon: UIImageView!
    @IBOutlet weak var secondaryInfoSubtitle: MPLabel!
 
    @IBOutlet weak var acreditationMessage: MPLabel!
    override func awakeFromNib() {
        super.awakeFromNib()
        let tintedImage = self.clockIcon.image?.withRenderingMode(.alwaysTemplate)
        self.clockIcon.image = tintedImage
        self.clockIcon.tintColor = UIColor.UIColorFromRGB(0xB29054)
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
    }
    
    func fillCell(_ instruction: Instruction) -> UITableViewCell {
        if instruction.secondaryInfo !=  nil && instruction.secondaryInfo!.count > 0 {
            
            self.secondaryInfoTitle.text = instruction.secondaryInfo![0]
            
            if instruction.secondaryInfo?.count > 1 {
                self.secondaryInfoSubtitle.text = instruction.secondaryInfo![1]
            }
        }
        
        self.acreditationMessage.text = instruction.accreditationMessage
        return self
        
    }
    
    func getCellHeight(_ instruction : Instruction, forFontSize: CGFloat) -> CGFloat {
        return 120
    }
    
}
