//
//  PayerCostCardTableViewCell.swift
//  MercadoPagoSDK
//
//  Created by Eden Torres on 10/13/16.
//  Copyright © 2016 MercadoPago. All rights reserved.
//

import UIKit

class PayerCostCardTableViewCell: UITableViewCell {
    
    @IBOutlet weak var cell: UIView!
    var cardView: UIView!
    var cardFront : CardFrontView!
    
    func loadCard(){
        self.cardView = UIView()
        
        let cardHeight = getCardHeight()
        let cardWidht = getCardWidth()
        let xMargin = (UIScreen.main.bounds.size.width  - cardWidht) / 2
        let yMargin = (UIScreen.main.bounds.size.width*0.5 - cardHeight ) / 2
        
        let rectBackground = CGRect(x: xMargin, y: yMargin, width: cardWidht, height: cardHeight)
        let rect = CGRect(x: 0, y: 0, width: cardWidht, height: cardHeight)
        self.cardView.frame = rectBackground
        
        self.cardView.layer.cornerRadius = 8
        self.cardView.layer.masksToBounds = true
        self.addSubview(self.cardView)

        cardFront = CardFrontView(frame: rect)
        cardFront?.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        cardView.addSubview(cardFront!)
        self.cell.backgroundColor = MercadoPagoContext.getPrimaryColor()
    }
    func updateCardSkin(token: CardInformationForm?, paymentMethod: PaymentMethod?) {
        
        if let paymentMethod = paymentMethod{
            
            self.cardFront?.cardLogo.image =  MercadoPago.getImageFor(paymentMethod)
            self.cardView.backgroundColor = MercadoPago.getColorFor(paymentMethod)
            self.cardFront?.cardLogo.alpha = 1
            let fontColor = MercadoPago.getFontColorFor(paymentMethod)!
            if let token = token{
          //  cardFront?.cardNumber.text =  "•••• •••• •••• " + (token.getCardLastForDigits())!
                let mask = TextMaskFormater(mask: paymentMethod.getLabelMask(), completeEmptySpaces: true, leftToRight: false)
                cardFront?.cardNumber.text = mask.textMasked(token.getCardLastForDigits())
            }
            
            cardFront?.cardName.text = ""
            cardFront?.cardExpirationDate.text = ""
            cardFront?.cardNumber.alpha = 0.8
            cardFront?.cardNumber.textColor =  fontColor
        }
    }
    func fadeCard(){
        UIView.animate(withDuration: 0.80) {
            self.cardView?.alpha = 0
        }
        
    }
    func showCard(){
        UIView.animate(withDuration: 1.50) {
            self.cardView?.alpha = 1
        }
        
    }
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    func getCardWidth() -> CGFloat {
        let widthTotal = UIScreen.main.bounds.size.width * 0.70
        if widthTotal < 512 {
            if ((0.63 * widthTotal) < (UIScreen.main.bounds.size.width*0.50 - 10)){
                return widthTotal * 0.8
            }else{
                return (UIScreen.main.bounds.size.width*0.50 - 10) / 0.63 * 0.8
            }
            
        }else{
            return 512 * 0.8
        }
        
    }
    
    func getCardHeight() -> CGFloat {
        return ( getCardWidth() * 0.63 )
    }
}
