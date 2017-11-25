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
    var paymentResultScreenPreference: PaymentResultScreenPreference?

    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        button.layer.cornerRadius = 3
        self.button.titleLabel?.font = Utils.getFont(size: 16)
        self.selectionStyle = .none
    }

    open func fillCell(paymentResult: PaymentResult, paymentResultScreenPreference: PaymentResultScreenPreference) {
        self.paymentResultScreenPreference = paymentResultScreenPreference

        if paymentResult.statusDetail.contains("cc_rejected_bad_filled") {
            status = PaymentResult.CongratsState.cancel_RECOVER
            self.button.setTitle("Ingresalo nuevamente".localized, for: UIControlState.normal)
        }
        if paymentResult.status == "approved"{
            self.button.setTitle(paymentResultScreenPreference.getApprovedSecondaryButtonText(), for: .normal)
            self.button.addTarget(self, action: #selector(approvedCallback), for: .touchUpInside)
        } else if paymentResult.status == "rejected" {
            self.button.setTitle(paymentResultScreenPreference.getRejectedSecondaryButtonText(), for: .normal)
                self.button.addTarget(self, action: #selector(rejectedCallback), for: .touchUpInside)
        } else {
            self.button.setTitle(paymentResultScreenPreference.getPendingSecondaryButtonText(), for: .normal)
                self.button.addTarget(self, action: #selector(pendingCallback), for: .touchUpInside)
        }

    }

    @objc func rejectedCallback() {
        if let paymentResult = paymentResult, let customCallback = paymentResultScreenPreference?.getRejectedSecondaryButtonCallback() {
            customCallback(paymentResult)
        } else {
            invokeCallback()
        }
    }

    @objc func pendingCallback() {
        if let paymentResult = paymentResult, let customCallback = paymentResultScreenPreference?.getPendingSecondaryButtonCallback() {
            customCallback(paymentResult)
        } else {
            invokeCallback()
        }
    }

    @objc func approvedCallback() {
        if let paymentResult = paymentResult, let customCallback = paymentResultScreenPreference?.getApprovedSecondaryButtonCallback() {
            customCallback(paymentResult)
        } else {
            invokeCallback()
        }
    }

}
