//
//  PXNewResultTrackingEvents.swift
//  MercadoPagoSDKV4
//
//  Created by Matheus Leandro Martins on 06/05/21.
//

enum PXResultTrackingEvents: TrackingEvents {
    // MARK: - Events
    case didTapOnAllDiscounts
    case didtapOnDownload
    case didTapOnReceipt
    case didTapOnScore
    case didTapOnDeeplink([String:Any])
    case didTapOnCrossSelling
    case didShowRemedyError([String:Any])
    
    // MARK: - ScreenEvents
    case checkoutPaymentApproved([String:Any])
    case checkoutPaymentInProcess([String:Any])
    case checkoutPaymentRejected([String:Any])
    
    case congratsPaymentApproved([String:Any])
    case congratsPaymentInProcess([String:Any])
    case congratsPaymentRejected([String:Any])
    
    var name: String {
        switch self {
        case .didTapOnAllDiscounts: return "/px_checkout/result/success/tap_see_all_discounts"
        case .didtapOnDownload: return "/px_checkout/result/success/tap_download_app"
        case .didTapOnReceipt: return "/px_checkout/result/success/tap_view_receipt"
        case .didTapOnScore: return "/px_checkout/result/success/tap_score"
        case .didTapOnDeeplink(_): return "/px_checkout/result/success/deep_link"
        case .didTapOnCrossSelling: return "/px_checkout/result/success/tap_cross_selling"
        case .didShowRemedyError(_): return "/px_checkout/result/error/primary_action"
        case .checkoutPaymentApproved(_): return "/px_checkout/result/success"
        case .checkoutPaymentInProcess(_): return "/px_checkout/result/further_action_needed"
        case .checkoutPaymentRejected(_): return "/px_checkout/result/error"
        case .congratsPaymentApproved(_): return "/payment_congrats/result/success"
        case .congratsPaymentInProcess(_): return "/payment_congrats/result/further_action_needed"
        case .congratsPaymentRejected(_): return "/payment_congrats/result/error"
        }
    }
    
    var properties: [String : Any] {
        switch self {
        case .didTapOnAllDiscounts, .didtapOnDownload, .didTapOnReceipt, .didTapOnScore, .didTapOnCrossSelling: return [:]
        case .didTapOnDeeplink(let properties), .didShowRemedyError(let properties), .checkoutPaymentApproved(let properties),
             .checkoutPaymentInProcess(let properties), .checkoutPaymentRejected(let properties),
             .congratsPaymentApproved(let properties), .congratsPaymentInProcess(let properties),
             .congratsPaymentRejected(let properties): return properties
        }
    }
}
