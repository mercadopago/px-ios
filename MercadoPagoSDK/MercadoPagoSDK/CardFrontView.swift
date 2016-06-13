//
//  CardFrontView.swift
//  MercadoPagoSDK
//
//  Created by Demian Tejo on 1/20/16.
//  Copyright © 2016 MercadoPago. All rights reserved.
//

import Foundation
import UIKit

@IBDesignable public class CardFrontView : UIView {
  var view:UIView!;
    
    @IBOutlet weak var cardLogo: UIImageView!
    @IBOutlet weak var cardExpirationDate: MPLabel!
    @IBOutlet weak var cardName: MPLabel!
   @IBOutlet weak var cardNumber: UILabel!
    @IBOutlet weak var cardCVV: UILabel!
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        loadViewFromNib ()
    }
    
    required public init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        
        loadViewFromNib ()
    }
    func loadViewFromNib() {
        let bundle = NSBundle(forClass: self.dynamicType)
        let nib = UINib(nibName: "CardFrontView", bundle: bundle)
        let view = nib.instantiateWithOwner(self, options: nil)[0] as! UIView
        view.frame = bounds
 //       view.autoresizingMask = [.FlexibleWidth, .FlexibleHeight]
        self.addSubview(view);
        /*
        cardNumber.adjustsFontSizeToFitWidth = true
        cardNumber.numberOfLines = 0
        cardName.adjustsFontSizeToFitWidth = true
        cardName.numberOfLines = 0
        cardExpirationDate.adjustsFontSizeToFitWidth = true
        cardExpirationDate.numberOfLines = 0
        */
        
        cardNumber.numberOfLines = 0
        cardName.numberOfLines = 0
        cardExpirationDate.numberOfLines = 0
        cardCVV.numberOfLines = 0
    }
    
    public func finishLoad(){
     
     // var context = NSStringDrawingContext().actualScaleFactor
        
   //     let actualFontSize : CGFloat = self.cardNumber.font.pointSize * ;

        
     //   let size = cardNumber.sizeThatFits(CGSize(width: cardNumber.bounds.width, height: cardNumber.bounds.height))
        cardNumber.adjustsFontSizeToFitWidth = false
        cardName.adjustsFontSizeToFitWidth = false
        cardCVV.adjustsFontSizeToFitWidth = false
        cardExpirationDate.adjustsFontSizeToFitWidth = false

    }
       
    
}

extension UIView {
    class func loadFromNibNamed(nibNamed: String, bundle : NSBundle? = nil) -> UIView? {
        return UINib(
            nibName: nibNamed,
            bundle: bundle
            ).instantiateWithOwner(nil, options: nil)[0] as? UIView
    }
}

extension String {
    func insert(string:String,ind:Int) -> String {
        return  String(self.characters.prefix(ind)) + string + String(self.characters.suffix(self.characters.count-ind))
    }
}
