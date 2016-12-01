//
//  UILabel+Additions.swift
//  MercadoPagoSDK
//
//  Created by Demian Tejo on 29/10/16.
//  Copyright © 2016 MercadoPago. All rights reserved.
//

import Foundation
import  UIKit
extension UILabel{
    
    func requiredHeight() -> CGFloat{
        
        let label:UILabel = UILabel(frame: CGRect(x: 0, y: 0, width: self.frame.width, height: CGFloat.greatestFiniteMagnitude))
        label.numberOfLines = 0
        label.lineBreakMode = NSLineBreakMode.byWordWrapping
        label.font = self.font
        
        label.text = self.text
        
        label.sizeToFit()
        
        return label.frame.height
    }
}
