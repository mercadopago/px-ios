//
//  CardNotAvailableView.swift
//  MercadoPagoSDK
//
//  Created by Angie Arlanti on 8/29/17.
//  Copyright © 2017 MercadoPago. All rights reserved.
//

import UIKit

class CardNotAvailableErrorView: UIView {
    
    let margin: CGFloat = 10
    var height: CGFloat!
    var errorMessageWidth: CGFloat!
    var moreInfoWidth: CGFloat!
    var errorMessageLabel: MPLabel!
    var errorMessage: String!
    var moreInfoMessage: String!
    var moreInfoLabel: MPLabel!
    var paymentMethods: [PaymentMethod]!
    var navigationController: UINavigationController!
    
    init(frame: CGRect, paymentMethods: [PaymentMethod],navigationController: UINavigationController) {
        super.init(frame: frame)
        self.backgroundColor = UIColor.mpRedPinkErrorMessage()
        self.paymentMethods = paymentMethods
        self.navigationController = navigationController
        
        height = self.frame.height - 2 * margin
        errorMessage = "No puedes pagar con esta tarjeta".localized
        moreInfoMessage = "MAS INFO".localized
        
        let errorMessageCount:CGFloat = CGFloat(errorMessage.characters.count)
        let moreInfoMessageCount:CGFloat = CGFloat(moreInfoMessage.characters.count)
        
        let totalCount:CGFloat = errorMessageCount + moreInfoMessageCount
        
        let errorMessageLabelPercentage:CGFloat = (errorMessageCount)/totalCount
        let moreInfoLabelPercentage:CGFloat = (moreInfoMessageCount)/totalCount
        
        errorMessageWidth = (self.frame.width - (3 * margin)) * errorMessageLabelPercentage
        moreInfoWidth = (self.frame.width - (3 * margin)) * moreInfoLabelPercentage
        setErrorMessage()
        setMoreInfoButton()
    
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func setErrorMessage (){
        self.errorMessageLabel = MPLabel(frame: CGRect(x: margin, y: margin, width: errorMessageWidth, height: height))
        self.errorMessageLabel!.text = errorMessage
        self.errorMessageLabel.textColor = .white
        self.errorMessageLabel!.adjustsFontSizeToFitWidth = true
        self.addSubview(errorMessageLabel)
    }
    
    func setMoreInfoButton(){
        
        let x = errorMessageWidth + 2 * margin
        self.moreInfoLabel = MPLabel(frame: CGRect(x: x, y: margin, width: moreInfoWidth, height: height))
        self.moreInfoLabel.text = moreInfoMessage
        self.moreInfoLabel.textColor = .white
        self.moreInfoLabel.adjustsFontSizeToFitWidth = true
        
        let tap = UITapGestureRecognizer(target: self, action: #selector(CardNotAvailableErrorView.handleTap))
        self.moreInfoLabel.isUserInteractionEnabled = true
        self.moreInfoLabel.addGestureRecognizer(tap)
        
        self.addSubview(moreInfoLabel)
        
    }

    func handleTap (){
        let availableCardsDetail =  AvailableCardsViewController(paymentMethods: self.paymentMethods!)
        
        self.navigationController?.present(availableCardsDetail, animated: true, completion: {})
        
    }
}
