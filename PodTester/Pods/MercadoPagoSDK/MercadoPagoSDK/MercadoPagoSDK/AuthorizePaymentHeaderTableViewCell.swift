//
//  AuthorizePaymentTableViewCell.swift
//  MercadoPagoSDK
//
//  Created by Maria cristina rodriguez on 9/5/16.
//  Copyright © 2016 MercadoPago. All rights reserved.
//

import UIKit

class AuthorizePaymentHeaderTableViewCell: UITableViewCell, CongratsFillmentDelegate {

    static let ROW_HEIGHT = CGFloat(240)
    
    @IBOutlet weak var title: MPLabel!
    
    
    @IBOutlet weak var subtitle: MPLabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        self.title.addCharactersSpacing(-0.4)
        self.layer.shadowOffset = CGSize(width: 0, height: 1)
        self.layer.shadowColor = UIColor(red: 153, green: 153, blue: 153).cgColor
        self.layer.shadowRadius = 3
        self.layer.shadowOpacity = 0.6

    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
        // Configure the view for the selected state
    }
    
    func fillCell(_ payment: Payment, paymentMethod : PaymentMethod, callback : ((Void) -> Void)?) -> UITableViewCell {
        self.title.attributedText = self.getTitle(payment, paymentMethod: paymentMethod)
        self.title.addLineSpacing(4)
        self.subtitle.text = "El teléfono está al dorso de tu tarjeta".localized
        
        return self
    }
    
    func getCellHeight(_ payment : Payment, paymentMethod : PaymentMethod) -> CGFloat {
        
        var constraintSize = CGSize()
        let screenSize: CGRect = UIScreen.main.bounds
        constraintSize.width = screenSize.width - 46
        
        let attributesTitle = [NSFontAttributeName: UIFont(name: MercadoPago.DEFAULT_FONT_NAME, size: 22) ?? UIFont.systemFont(ofSize: 22)]
        
        let title = String(getTitle(payment, paymentMethod: paymentMethod).mutableString)
        
        let frameTitle = (title as NSString).boundingRect(with: constraintSize, options: NSStringDrawingOptions.usesLineFragmentOrigin, attributes: attributesTitle, context: nil)
        
        let stringSizeTitle = frameTitle.size
        
        let attributesSubtitle = [NSFontAttributeName: UIFont(name: MercadoPago.DEFAULT_FONT_NAME, size: 14) ?? UIFont.systemFont(ofSize: 14)]
        let subtitle = "El teléfono está al dorso de tu tarjeta".localized
        
        let frameSubtitle = (subtitle as NSString).boundingRect(with: constraintSize, options: NSStringDrawingOptions.usesLineFragmentOrigin, attributes: attributesSubtitle, context: nil)
        
        let stringSizeSubtitle = frameSubtitle.size
        return 150 + stringSizeTitle.height + stringSizeSubtitle.height
    }

    fileprivate func getTitle(_ payment : Payment, paymentMethod : PaymentMethod) -> NSMutableAttributedString {
        if paymentMethod._id == nil || paymentMethod._id == nil || paymentMethod.name == nil || paymentMethod.name.isEmpty {
            return NSMutableAttributedString(string: "Debes autorizar el pago ante tu tarjeta".localized)
        }
        
        let currency = MercadoPagoContext.getCurrency()

        let title = NSMutableAttributedString(string: ("Debes autorizar ante %1$s el pago de ".localized as NSString).replacingOccurrences(of: "%1$s", with: paymentMethod.name))
        let attributedAmount = Utils.getAttributedAmount(payment.transactionDetails.totalPaidAmount, thousandSeparator: String(currency.thousandsSeparator), decimalSeparator: String(currency.decimalSeparator), currencySymbol: String(currency.symbol), color: UIColor(red: 102, green: 102, blue: 102))
        title.append(attributedAmount)
        title.append(NSMutableAttributedString(string : " a MercadoPago".localized))
        return title
    }
    
    
}
