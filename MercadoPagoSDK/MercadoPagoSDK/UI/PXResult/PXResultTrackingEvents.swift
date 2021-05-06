//
//  PXNewResultTrackingEvents.swift
//  MercadoPagoSDKV4
//
//  Created by Matheus Leandro Martins on 06/05/21.
//

enum PXResultTrackingEvents: TrackingEvents {
    case didTapOnAllDiscounts
    case didtapOnDownload
    case didTapOnReceipt
    case didTapOnScore
    case didTapOnDeeplink([String:Any])
    case didTapOnCrossSelling
    case didShowRemedyError([String:Any])
    
    var name: String {
        switch self {
        case .didTapOnAllDiscounts: return "/px_checkout/result/success/tap_see_all_discounts"
        case .didtapOnDownload: return "/px_checkout/result/success/tap_download_app"
        case .didTapOnReceipt: return "/px_checkout/result/success/tap_view_receipt"
        case .didTapOnScore: return "/px_checkout/result/success/tap_score"
        case .didTapOnDeeplink(_): return "/px_checkout/result/success/deep_link"
        case .didTapOnCrossSelling: return "/px_checkout/result/success/tap_cross_selling"
        case .didShowRemedyError(_): return "/px_checkout/result/error/primary_action"
        }
    }
    
    var properties: [String : Any] {
        switch self {
        case .didTapOnAllDiscounts, .didtapOnDownload, .didTapOnReceipt, .didTapOnScore, .didTapOnCrossSelling: return [:]
        case .didTapOnDeeplink(let properties): return properties
        case .didShowRemedyError(let properties): return properties
        }
    }
}
