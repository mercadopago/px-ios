//
//  CardFrontView.swift
//  MercadoPagoSDK
//
//  Created by Demian Tejo on 1/20/16.
//  Copyright © 2016 MercadoPago. All rights reserved.
//

import Foundation
import UIKit

@IBDesignable open class CardFrontView: UIView, Updatable {
  var view: UIView!

    @IBOutlet var backgroundView: UIView!
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

    public func updateCard(token: CardInformationForm?, paymentMethod: PaymentMethod) {

        self.cardLogo.image =  paymentMethod.getImage()
        self.cardLogo.alpha = 1
        let fontColor = paymentMethod.getFontColor(bin: token?.getCardBin())
        if let token = token {
            //  cardFront?.cardNumber.text =  "•••• •••• •••• " + (token.getCardLastForDigits())!
            let mask = TextMaskFormater(mask: paymentMethod.getLabelMask(bin: token.getCardBin()), completeEmptySpaces: true, leftToRight: false)
            self.cardNumber.text = mask.textMasked(token.getCardLastForDigits())
        }

        cardName.text = ""
        cardExpirationDate.text = ""
        cardNumber.alpha = 0.8
        cardNumber.textColor =  fontColor
        backgroundView.backgroundColor = paymentMethod.getColor(bin: token?.getCardBin())

    }

    public func setCornerRadius(radius: CGFloat) {
        self.layer.cornerRadius = radius
        self.backgroundView.layer.cornerRadius = radius
    }

    func loadViewFromNib() {
        let bundle = Bundle(for: type(of: self))
        let nib = UINib(nibName: "CardFrontView", bundle: bundle)
        let view = nib.instantiate(withOwner: self, options: nil)[0] as! UIView
        view.frame = bounds

        self.addSubview(view)

        cardNumber.numberOfLines = 0
        cardName.numberOfLines = 0
        cardName.font = UIFont.systemFont(ofSize: cardName.font.pointSize)
        cardExpirationDate.numberOfLines = 0
        cardExpirationDate.font = UIFont.systemFont(ofSize: cardExpirationDate.font.pointSize)
        cardCVV.numberOfLines = 0
        cardCVV.font = UIFont.systemFont(ofSize: cardCVV.font.pointSize)
    }

    open func finishLoad() {

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
    class func loadFromNibNamed(_ nibNamed: String, bundle: Bundle? = nil) -> UIView? {
        return UINib(
            nibName: nibNamed,
            bundle: bundle
            ).instantiate(withOwner: nil, options: nil)[0] as? UIView
    }
}

extension String {
    func insert(_ string: String, ind: Int) -> String {
        return  String(self.characters.prefix(ind)) + string + String(self.characters.suffix(self.characters.count-ind))
    }
}
