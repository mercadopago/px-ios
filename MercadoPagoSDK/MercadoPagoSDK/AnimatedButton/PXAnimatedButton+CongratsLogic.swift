//
//  PXAnimatedButton+CongratsLogic.swift
//  MercadoPagoSDK
//
//  Created by Eden Torres on 03/07/2018.
//  Copyright © 2018 MercadoPago. All rights reserved.
//

import Foundation

extension PXAnimatedButton {
    static func animateButtonWith(paymentResult: PaymentResult) {
        if paymentResult.isAccepted() {
            PXNotificationManager.Post.animateButtonForSuccess()
        } else if paymentResult.isError() {
            PXNotificationManager.Post.animateButtonForError()
        } else if paymentResult.isWarning() {
            PXNotificationManager.Post.animateButtonForWarning()
        }
    }

    static func animateButtonWith(businessResult: PXBusinessResult) {
        if businessResult.isAccepted() {
            PXNotificationManager.Post.animateButtonForSuccess()
        } else if businessResult.isError() {
            PXNotificationManager.Post.animateButtonForError()
        } else if businessResult.isWarning() {
            PXNotificationManager.Post.animateButtonForWarning()
        }
    }
}
