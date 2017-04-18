//
//  AuthorizePaymentBodyTableViewCell.swift
//  MercadoPagoSDK
//
//  Created by Maria cristina rodriguez on 9/5/16.
//  Copyright © 2016 MercadoPago. All rights reserved.
//

import UIKit

class AuthorizePaymentBodyTableViewCell: CallbackCancelTableViewCell, CongratsFillmentDelegate {

    static let ROW_HEIGHT = CGFloat(150)
    var authCallback : ((Void) -> Void)?
    
    @IBOutlet weak var completeCardButton: MPButton!
    @IBOutlet weak var cancelButton: MPButton!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        self.cancelButton.titleLabel?.text = "Elegí otro medio de pago".localized
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
    }
   
    func fillCell(_ payment: Payment, paymentMethod : PaymentMethod,callback : ((Void) -> Void)?) -> UITableViewCell {
        self.defaultCallback = callback
        self.cancelButton.addTarget(self, action: #selector(invokeDefaultCallback), for: .touchUpInside)
        self.completeCardButton.setTitle( ("Ya hablé con %1$s y me autorizó".localized as NSString).replacingOccurrences(of: "%1$s", with: paymentMethod.name), for: UIControlState())
        self.completeCardButton.addTarget(self, action: #selector(AuthorizePaymentBodyTableViewCell.invokeAuthCallback), for: .touchUpInside)
        return self
    }
    
    func getCellHeight(_ payment: Payment, paymentMethod: PaymentMethod) -> CGFloat {
        return 150
    }
    
    func invokeAuthCallback(){
        if self.authCallback != nil {
            self.authCallback!()
        }
    }


}
