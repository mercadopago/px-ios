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
        title.font = Utils.getFont(size: title.font.pointSize)
        title.text = ""

    }

    func fillCell(instruction: Instruction) {
        if instruction.hasSubtitle() {
            let attributedTitle = NSMutableAttributedString(string: instruction.subtitle!, attributes: [NSAttributedStringKey.font: Utils.getFont(size: 22)])
            self.title.attributedText = attributedTitle
        }
    }
}
