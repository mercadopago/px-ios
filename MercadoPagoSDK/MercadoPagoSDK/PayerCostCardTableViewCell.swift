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
        self.cell.backgroundColor = UIColor.primaryColor()
    }
    func updateCardSkin(token: CardInformationForm?, paymentMethod: PaymentMethod?) {
        
        if let paymentMethod = paymentMethod{
            
            self.cardFront?.cardLogo.alpha = 1
            if let token = token{
          //  cardFront?.cardNumber.text =  "•••• •••• •••• " + (token.getCardLastForDigits())!
                self.cardFront?.cardLogo.image =  paymentMethod.getImage(bin: token.getCardBin())
                self.cardView.backgroundColor = paymentMethod.getColor(bin: token.getCardBin())
                let fontColor = paymentMethod.getFontColor(bin: token.getCardBin())
                let mask = TextMaskFormater(mask: paymentMethod.getLabelMask(bin: token.getCardBin()), completeEmptySpaces: true, leftToRight: false)
                cardFront?.cardNumber.text = mask.textMasked(token.getCardLastForDigits())
                cardFront?.cardNumber.textColor =  fontColor
            }
            
            cardFront?.cardName.text = ""
            cardFront?.cardExpirationDate.text = ""
            cardFront?.cardNumber.alpha = 0.8
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
