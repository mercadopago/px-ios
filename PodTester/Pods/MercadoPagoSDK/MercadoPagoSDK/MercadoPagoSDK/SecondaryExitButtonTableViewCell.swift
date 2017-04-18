//
//  SecondaryExitButtonTableViewCell.swift
//  MercadoPagoSDK
//
//  Created by Eden Torres on 2/21/17.
//  Copyright © 2017 MercadoPago. All rights reserved.
//

import UIKit

class SecondaryExitButtonTableViewCell: CallbackCancelTableViewCell {
    
    @IBOutlet weak var button: UIButton!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        button.layer.cornerRadius = 3
        self.button.titleLabel?.font = Utils.getFont(size: 16)
    }
    
    open func fillCell(paymentResult: PaymentResult){
        if paymentResult.statusDetail.contains("cc_rejected_bad_filled"){
            status = MPStepBuilder.CongratsState.cancel_RECOVER
            self.button.setTitle("Ingresalo nuevamente".localized, for: UIControlState.normal)
        }
        if paymentResult.status == "approved"{
            self.button.setTitle(MercadoPagoCheckoutViewModel.paymentResultScreenPreference.getApprovedSecondaryButtonText(), for: .normal)
            self.button.addTarget(self, action: #selector(approvedCallback), for: .touchUpInside)
        } else if paymentResult.status == "rejected" {
            self.button.setTitle(MercadoPagoCheckoutViewModel.paymentResultScreenPreference.getRejectedSecondaryButtonText(), for: .normal)
                self.button.addTarget(self, action: #selector(rejectedCallback), for: .touchUpInside)
        } else {
            self.button.setTitle(MercadoPagoCheckoutViewModel.paymentResultScreenPreference.getPendingSecondaryButtonText(), for: .normal)
                self.button.addTarget(self, action: #selector(pendingCallback), for: .touchUpInside)
        }
        
    }
    
    func rejectedCallback(){
        if let paymentResult = paymentResult, let customCallback = MercadoPagoCheckoutViewModel.paymentResultScreenPreference.getRejectedSecondaryButtonCallback(){
            customCallback(paymentResult)
        } else {
            invokeCallback()
        }
    }
    func pendingCallback(){
        if let paymentResult = paymentResult, let customCallback = MercadoPagoCheckoutViewModel.paymentResultScreenPreference.getPendingSecondaryButtonCallback(){
            customCallback(paymentResult)
        } else {
            invokeCallback()
        }
    }
    func approvedCallback(){
        if let paymentResult = paymentResult, let customCallback = MercadoPagoCheckoutViewModel.paymentResultScreenPreference.getApprovedSecondaryButtonCallback(){
            customCallback(paymentResult)
        } else {
            invokeCallback()
        }
    }
    
    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
        
        // Configure the view for the selected state
    }
    
}
