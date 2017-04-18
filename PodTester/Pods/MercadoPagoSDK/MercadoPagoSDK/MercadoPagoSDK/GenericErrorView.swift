//
//  GenericErrorView.swift
//  MercadoPagoSDK
//
//  Created by Matias Gualino on 7/4/15.
//  Copyright (c) 2015 MercadoPago. All rights reserved.
//

import Foundation
import UIKit

open class GenericErrorView : UIView {
    
    let kErrorOffset : CGFloat = 4
    let kArrowHeight : CGFloat = 8
    let kLabelXOffset : CGFloat = 12
    
    var backgroundImageView : UIImageView!
    var errorLabel : MPLabel!
    var minimumHeight : CGFloat = 0
    var bundle : Bundle? = MercadoPago.getBundle()
    
    public override init(frame: CGRect) {
        super.init(frame: frame)
        self.minimumHeight = 40
        
        self.backgroundImageView = UIImageView(frame: CGRect(x: -1, y: -1 * kArrowHeight, width: self.frame.size.width + 1, height: self.frame.size.height + kArrowHeight))
        self.backgroundImageView.image = MercadoPago.getImage("ErrorBackground.png")!.stretchableImage(withLeftCapWidth: 0, topCapHeight: 20)
        self.backgroundImageView.autoresizingMask = [UIViewAutoresizing.flexibleHeight, UIViewAutoresizing.flexibleWidth]
        self.backgroundImageView.contentMode = UIViewContentMode.scaleToFill
        self.backgroundImageView.layer.cornerRadius = 0
        self.backgroundImageView.layer.masksToBounds = false
        self.addSubview(self.backgroundImageView)
        
        self.errorLabel = MPLabel(frame: CGRect(x: kLabelXOffset, y: 0, width: self.frame.size.width - 2*kLabelXOffset, height: self.frame.size.height))
        self.errorLabel.numberOfLines = 0
        self.errorLabel.textColor = UIColor.errorCellColor()
        self.errorLabel.font = UIFont(name: "HelveticaNeue-Light", size: 13)
        self.errorLabel.autoresizingMask = UIViewAutoresizing.flexibleHeight
        self.errorLabel.backgroundColor = UIColor.clear
        self.addSubview(self.errorLabel)

    }

	required public init?(coder aDecoder: NSCoder) {
		super.init(coder: aDecoder)
	}
 
    open func setErrorMessage(_ errorMessage: String) {
        let maxSize : CGSize = CGSize(width: self.errorLabel.frame.size.width, height: CGFloat.greatestFiniteMagnitude)
        
        let textRect : CGRect = (errorMessage as NSString).boundingRect(with: maxSize, options: NSStringDrawingOptions.usesLineFragmentOrigin, attributes: [NSFontAttributeName: self.errorLabel.font], context: nil)
        
        let newSize : CGSize = textRect.size
        
        var viewHeight : CGFloat = newSize.height + 2*kErrorOffset
        if viewHeight < self.minimumHeight {
            viewHeight = self.minimumHeight
        } else {
            viewHeight = self.minimumHeight + 2*kErrorOffset
        }
        
        self.frame = CGRect(x: self.frame.origin.x, y: self.frame.origin.y, width: self.frame.size.width, height: viewHeight)
        self.errorLabel.text = errorMessage
        self.errorLabel.frame = CGRect(x: self.errorLabel.frame.origin.x, y: (self.frame.size.height - newSize.height)/2, width: self.errorLabel.frame.size.width, height: newSize.height)
    }
    
}
