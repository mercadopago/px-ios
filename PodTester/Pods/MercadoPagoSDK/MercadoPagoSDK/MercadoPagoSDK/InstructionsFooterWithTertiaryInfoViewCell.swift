//
//  FooterWithTertiaryInfoViewCell.swift
//  MercadoPagoSDK
//
//  Created by Maria cristina rodriguez on 18/2/16.
//  Copyright © 2016 MercadoPago. All rights reserved.
//

import UIKit

class InstructionsFooterWithTertiaryInfoViewCell: UITableViewCell, InstructionsFillmentDelegate {

    @IBOutlet weak var clockIcon: UIImageView!
    
    @IBOutlet weak var secondaryInfoTitle: MPLabel!
    @IBOutlet weak var secondaryInfoSubtitle: MPLabel!
    @IBOutlet weak var secondayInfoComment: MPLabel!
    @IBOutlet weak var acreditationMessage: MPLabel!
    override func awakeFromNib() {
        super.awakeFromNib()
        let tintedImage = self.clockIcon.image?.withRenderingMode(.alwaysTemplate)
        self.clockIcon.image = tintedImage
        self.clockIcon.tintColor = UIColor.UIColorFromRGB(0xB29054)
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
    func fillCell(_ instruction: Instruction) -> UITableViewCell {
        if instruction.secondaryInfo != nil && instruction.secondaryInfo!.count > 0 {
            self.secondaryInfoTitle.text = instruction.secondaryInfo![0]
        }
        
        if instruction.tertiaryInfo != nil && instruction.tertiaryInfo!.count > 0 {
            self.secondaryInfoSubtitle.text = instruction.tertiaryInfo![0]
            
            if instruction.tertiaryInfo!.count > 1 {
                self.secondayInfoComment.text = instruction.tertiaryInfo![1]
            } else {
                self.secondayInfoComment.text = ""
            }
        }

        self.acreditationMessage.text = instruction.accreditationMessage
        return self
    }
    
    func getCellHeight(_ instruction : Instruction, forFontSize: CGFloat) -> CGFloat {
        return 180
    }
}
