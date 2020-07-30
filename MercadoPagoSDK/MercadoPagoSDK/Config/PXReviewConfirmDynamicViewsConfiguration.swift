//
//  PXReviewConfirmDynamicViewsConfiguration.swift
//  MercadoPagoSDK
//
//  Created by AUGUSTO COLLERONE ALFONSO on 19/10/18.
//

import Foundation

@available(*, deprecated, message: "Groups flow will no longer be available")
@objc public protocol PXReviewConfirmDynamicViewsConfiguration: NSObjectProtocol {
    @objc func topCustomViews(store: PXCheckoutStore) -> [UIView]?
    @objc func bottomCustomViews(store: PXCheckoutStore) -> [UIView]?
}
