//
//  PXPaymentErrorHandler.swift
//  MercadoPagoSDK
//
//  Created by Eden Torres on 26/06/2018.
//  Copyright © 2018 MercadoPago. All rights reserved.
//

import Foundation

@objc enum PXESCErrorReason: Int {
    case INVALID_ESC
    case INVALID_FINGERPRINT
    case UNEXPECTED_TOKENIZATION_ERROR
    case ESC_CAP
    case REJECTED_PAYMENT
    // TODO: DELETE
    case DEFAULT_REASON

    func rawReason() -> String {
        switch self {
        case .INVALID_ESC: return  "invalid_esc"
        case .INVALID_FINGERPRINT: return  "invalid_fingerprint"
        case .UNEXPECTED_TOKENIZATION_ERROR: return  "unexpected_tokenization_error"
        case .ESC_CAP: return  "esc_cap"
        case .REJECTED_PAYMENT: return  "rejected_payment"
        case .DEFAULT_REASON: return  "defualt"
        }
    }
}

@objc internal protocol PXPaymentErrorHandlerProtocol: NSObjectProtocol {
    func escError(reason: PXESCErrorReason)
    func exitCheckout()
    @objc optional func identificationError()
}
