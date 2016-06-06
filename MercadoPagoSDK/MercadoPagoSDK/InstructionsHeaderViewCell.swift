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
        let tintedImage = instructionsHeaderIcon.image!.imageWithRenderingMode(UIImageRenderingMode.AlwaysTemplate)
        self.instructionsHeaderIcon.image = tintedImage
        self.instructionsHeaderIcon.tintColor = UIColor().UIColorFromRGB(0xEFC701)
    }

    override func setSelected(selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
    }

    func getCellHeight(title : String) -> CGFloat {
        var constraintSize = CGSize()
        let screenSize: CGRect = UIScreen.mainScreen().bounds
        constraintSize.width = screenSize.width - 46
        
        let attributes = [NSFontAttributeName: UIFont(name: MercadoPago.DEFAULT_FONT_NAME, size: 24)!]
        
        let frame = (title as NSString).boundingRectWithSize(constraintSize, options: NSStringDrawingOptions.UsesLineFragmentOrigin, attributes: attributes, context: nil)
        
        let stringSize = frame.size
        return 128 + stringSize.height
    }
    
    func fillCell(title : String, amount : Double, currency : Currency?) -> UITableViewCell {
        // Assign default values in case there are none in Currency
        var currencySymbol = "$"
        var thousandSeparator = "."
        var decimalSeparator = ","
        
        if let currency = currency {
            currencySymbol = currency.getCurrencySymbolOrDefault()
            thousandSeparator = String(currency.getThousandsSeparatorOrDefault())
            decimalSeparator = String(currency.getDecimalSeparatorOrDefault())
        }
        
        let amountFromDouble = String(amount).stringByReplacingOccurrencesOfString(".", withString: decimalSeparator)
        let amountStr = Utils.getAmountFormatted(amountFromDouble, thousandSeparator: thousandSeparator, decimalSeparator: decimalSeparator)
        let centsStr = Utils.getCentsFormatted(String(amount), decimalSeparator: decimalSeparator)
        let amountRange = title.rangeOfString(currencySymbol + " " + amountStr + decimalSeparator + centsStr)
        
        if amountRange != nil {
            let attributedTitle = NSMutableAttributedString(string: title.substringToIndex((amountRange?.startIndex)!))
            let attributedAmount = Utils.getAttributedAmount(amountFromDouble, thousandSeparator: thousandSeparator, decimalSeparator: decimalSeparator, currencySymbol: currencySymbol, color: UIColor().UIColorFromRGB(0x666666))
            attributedTitle.appendAttributedString(attributedAmount)
            let endingTitle = NSAttributedString(string: title.substringFromIndex((amountRange?.endIndex)!))
            attributedTitle.appendAttributedString(endingTitle)

            self.headerTitle.attributedText = attributedTitle
            
            self.headerTitle.addCharactersSpacing(-0.4)
            self.headerTitle.addLineSpacing(4)
        } else {
            self.headerTitle.text = title
        }
        
        
        self.layer.shadowOffset = CGSizeMake(0, 1)
        self.layer.shadowColor = UIColor(red: 153, green: 153, blue: 153).CGColor
        self.layer.shadowRadius = 3
        self.layer.shadowOpacity = 0.6
        return self
    }
    
}
