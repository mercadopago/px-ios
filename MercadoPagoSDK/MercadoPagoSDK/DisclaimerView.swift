//
//  DisclaimerView.swift
//  MercadoPagoSDK
//
//  Created by Demian Tejo on 9/11/17.
//  Copyright © 2017 MercadoPago. All rights reserved.
//

import UIKit

class DisclaimerView: UIView, PXComponent {

    private let VERTICAL_MARGIN : CGFloat = 2.0
    private let HORIZONTAL_MARGIN : CGFloat = 24.0
    static private let FONT_SIZE : CGFloat = 14.0
    private var textColor : CGColor!

    public init(frame: CGRect, disclaimerText: String, colorText: UIColor =  UIColor.px_grayDark(), disclaimerFontSize:CGFloat = FONT_SIZE) {
        super.init(frame: frame)
        let disclaimerLabel = UILabel(frame:CGRect(x: HORIZONTAL_MARGIN, y: VERTICAL_MARGIN, width: frame.size.width - 2*HORIZONTAL_MARGIN , height: frame.size.height - 2 * VERTICAL_MARGIN))
        disclaimerLabel.textAlignment = .center
        disclaimerLabel.textColor = colorText
        disclaimerLabel.font = Utils.getFont(size: disclaimerFontSize)
        disclaimerLabel.text = disclaimerText
        self.addSubview(disclaimerLabel)
    }
        
    required init?(coder aDecoder: NSCoder) {
            fatalError("init(coder:) has not been implemented")
    }
        
    func getHeight() -> CGFloat {
        return self.frame.size.height
    }
    func getWeight() -> CGFloat{
        return self.frame.size.width
    }

    
    
}
    

