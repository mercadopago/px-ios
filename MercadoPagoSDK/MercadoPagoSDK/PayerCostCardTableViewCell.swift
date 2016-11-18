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
    @IBOutlet weak var cardView: UIView!
    var cardFront : CardFrontView?
    
    func loadCard(){
        cardFront = CardFrontView(frame: self.cardView.bounds)
        cardFront?.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        cardView.addSubview(cardFront!)
        cell.backgroundColor = MercadoPagoContext.getPrimaryColor()
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
    
}
