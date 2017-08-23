//
//  AvailableCardsDetailView.swift
//  Pods
//
//  Created by Angie Arlanti on 8/28/17.
//
//

import UIKit

class AvailableCardsDetailView: UIView {
    
    static let HEADER_HEIGHT : CGFloat = 135.0
    static let ITEMS_HEIGHT : CGFloat = 50.0
    var scrollCards : UIScrollView!
    var titleLable : UILabel!
    var subtitleLable : UILabel!
    let margin: CGFloat = 5.0
    let titleFontSize: CGFloat = 20
    let baselineOffSet: Int = 6
    
    var paymentMethods: [PaymentMethod]!

    
    init(frame: CGRect, paymentMethods: [PaymentMethod]) {
        super.init(frame: frame)
        self.paymentMethods = paymentMethods

        self.backgroundColor = UIColor.mpLightGray()
        
        setScrollView()
        
        setTitles()
        
    }
    
    func setScrollView(){
        scrollCards = UIScrollView()
        scrollCards.isUserInteractionEnabled = true
        scrollCards.frame = CGRect(x: 0, y: 135, width: self.frame.size.width, height: self.frame.size.height-135)
        scrollCards.contentSize = CGSize(width: self.frame.size.width, height: 50.0 * CGFloat(paymentMethods.count))
        var y: CGFloat = 0
        
        for paymentMethod in paymentMethods {
            
            scrollCards.addSubview(CardAvailableView(frame: CGRect(x: 0, y: y, width: self.frame.size.width, height: AvailableCardsDetailView.ITEMS_HEIGHT), paymentMethod: paymentMethod))
            
            y = y + AvailableCardsDetailView.ITEMS_HEIGHT
        }
        
        self.addSubview(scrollCards)
    }
    
    func setTitles(){
        titleLable = MPCardFormToolbarLabel()
        let width = self.frame.size.width - (2*margin)
        titleLable.frame = CGRect(x: 0, y: margin, width: width, height: 135)
        titleLable.textColor = UIColor.px_grayDark()
        titleLable.text = "No te preocupes, aún puedes terminar tu pago con:".localized
        titleLable.font = titleLable.font.withSize(titleFontSize)
        titleLable.numberOfLines = 2
        titleLable.textAlignment = .center
        titleLable.adjustsFontSizeToFitWidth = true
        self.addSubview(titleLable)
        
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

}
