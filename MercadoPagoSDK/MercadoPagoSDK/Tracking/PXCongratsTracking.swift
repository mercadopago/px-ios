//
//  PXCongratsTracking.swift
//  MercadoPagoSDK
//
//  Created by Esteban Adrian Boffa on 24/09/2019.
//

import Foundation

protocol PXCongratsTrackingDataProtocol: NSObjectProtocol {
    func hasBottomView() -> Bool
    func hasTopView() -> Bool
    func hasImportantView() -> Bool
    func hasExpenseSplitView() -> Bool
    func getScoreLevel() -> Int?
    func getDiscountsCount() -> Int
    func getCampaignsIds() -> String?
    func getCampaignId() -> String?
}

protocol PXViewModelTrackingDataProtocol {
    func getTrackingPath() -> String
    func getFlowBehaviourResult() -> PXResultKey
    func getTrackingProperties() -> [String: Any]
}

final class PXCongratsTracking {
    enum TrackingKeys: String {
        case hasBottomView  = "has_bottom_view"
        case hasTopView = "has_top_view"
        case hasImportantView = "has_important_view"
        case hasExpenseSplitView = "has_money_split_view"
        case scoreLevel = "score_level"
        case discountsCount  = "discounts_count"
        case campaignsIds = "campaigns_ids"
        case campaignId = "campaign_id"
    }

    class func getProperties(dataProtocol: PXCongratsTrackingDataProtocol, properties: [String: Any]) -> [String: Any] {
        var congratsProperties = properties
        congratsProperties[TrackingKeys.hasBottomView.rawValue] = dataProtocol.hasBottomView()
        congratsProperties[TrackingKeys.hasTopView.rawValue] = dataProtocol.hasTopView()
        congratsProperties[TrackingKeys.hasImportantView.rawValue] = dataProtocol.hasImportantView()
        congratsProperties[TrackingKeys.hasExpenseSplitView.rawValue] = dataProtocol.hasExpenseSplitView()
        congratsProperties[TrackingKeys.scoreLevel.rawValue] = dataProtocol.getScoreLevel()
        congratsProperties[TrackingKeys.discountsCount.rawValue] = dataProtocol.getDiscountsCount()
        congratsProperties[TrackingKeys.campaignsIds.rawValue] = dataProtocol.getCampaignsIds()
        congratsProperties[TrackingKeys.campaignId.rawValue] = dataProtocol.getCampaignId()
        return congratsProperties
    }

    class func getDeeplinkProperties(type: String, deeplink: String) -> [String: Any] {
        var properties: [String: Any] = [:]
        properties["type"] = type
        properties["deep_link"] = deeplink
        return properties
    }

    class func trackTapDiscountItemEvent(_ index: Int, _ trackId: String?) {
        var properties: [String: Any] = [:]
        properties["index"] = index
        properties["campaign_id"] = trackId
        MPXTracker.sharedInstance.trackEvent(path: TrackingPaths.Events.Congrats.getSuccessTapDiscountItemPath(), properties: properties)
    }
}
