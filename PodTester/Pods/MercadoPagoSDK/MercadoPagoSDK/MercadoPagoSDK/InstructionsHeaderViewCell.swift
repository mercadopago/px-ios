//
//  CongratsHeaderViewCell.swift
//  MercadoPagoSDK
//
//  Created by Maria cristina rodriguez on 16/2/16.
//  Copyright © 2016 MercadoPago. All rights reserved.
//

import UIKit

class InstructionsHeaderViewCell: UITableViewCell {


    @IBOutlet weak var headerTitle: MPLabel!
    @IBOutlet weak var instructionsHeaderIcon: UIImageView!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        let tintedImage = instructionsHeaderIcon.image!.withRenderingMode(UIImageRenderingMode.alwaysTemplate)
        self.instructionsHeaderIcon.image = tintedImage
        self.instructionsHeaderIcon.tintColor = UIColor.UIColorFromRGB(0xEFC701)
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
    }

    func getCellHeight(_ title : String) -> Float {
        var constraintSize = CGSize()
        let screenSize: CGRect = UIScreen.main.bounds
        constraintSize.width = screenSize.width - 46
        
        let attributes = [NSFontAttributeName: UIFont(name: MercadoPago.DEFAULT_FONT_NAME, size: 24) ?? UIFont.systemFont(ofSize: 24)]
        
        let frame = (title as NSString).boundingRect(with: constraintSize, options: NSStringDrawingOptions.usesLineFragmentOrigin, attributes: attributes, context: nil)
        
        let stringSize = frame.size
        return Float(128) + Float(stringSize.height)
    }
    
    func fillCell(_ title : String, amount : Double, currency : Currency?) -> UITableViewCell {
        // Assign default values in case there are none in Currency
        var currencySymbol = "$"
        var thousandSeparator = "."
        var decimalSeparator = ","
        
        if let currency = currency {
            currencySymbol = currency.getCurrencySymbolOrDefault()
            thousandSeparator = String(currency.getThousandsSeparatorOrDefault())
            decimalSeparator = String(currency.getDecimalSeparatorOrDefault())
        }
        
        let amountFromDouble = String(amount).replacingOccurrences(of: ".", with: decimalSeparator)
        let amountStr = Utils.getAmountFormatted(amountFromDouble, thousandSeparator: thousandSeparator, decimalSeparator: decimalSeparator)
        let centsStr = Utils.getCentsFormatted(String(amount), decimalSeparator: decimalSeparator)
        let amountRange = title.range(of: currencySymbol + " " + amountStr + decimalSeparator + centsStr)
        
        if amountRange != nil {
            let attributedTitle = NSMutableAttributedString(string: title.substring(to: (amountRange?.lowerBound)!))
            let attributedAmount = Utils.getAttributedAmount(amountFromDouble, thousandSeparator: thousandSeparator, decimalSeparator: decimalSeparator, currencySymbol: currencySymbol, color: UIColor.UIColorFromRGB(0x666666))
            attributedTitle.append(attributedAmount)
            let endingTitle = NSAttributedString(string: title.substring(from: (amountRange?.upperBound)!))
            attributedTitle.append(endingTitle)

            self.headerTitle.attributedText = attributedTitle
            
            self.headerTitle.addCharactersSpacing(-0.4)
            self.headerTitle.addLineSpacing(4)
        } else {
            self.headerTitle.text = title
        }
        
        
        self.layer.shadowOffset = CGSize(width: 0, height: 1)
        self.layer.shadowColor = UIColor(red: 153, green: 153, blue: 153).cgColor
        self.layer.shadowRadius = 3
        self.layer.shadowOpacity = 0.6
        return self
    }
    
}
