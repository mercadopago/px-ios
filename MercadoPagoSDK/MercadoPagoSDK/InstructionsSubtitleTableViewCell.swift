//
//  InstructionsSubtitleTableViewCell.swift
//  MercadoPagoSDK
//
//  Created by Eden Torres on 11/6/16.
//  Copyright © 2016 MercadoPago. All rights reserved.
//

import UIKit

class InstructionsSubtitleTableViewCell: UITableViewCell {
    @IBOutlet weak var title: UILabel!

    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        title.font = Utils.getFont(size: title.font.pointSize)

    }
    
    func fillCell(instruction: Instruction) {
        if let subtitle = instruction.subtitle  {
            let attributedTitle = NSMutableAttributedString(string: subtitle, attributes: [NSFontAttributeName: Utils.getFont(size: 22)])
            self.title.attributedText = attributedTitle
        }
    }
}
