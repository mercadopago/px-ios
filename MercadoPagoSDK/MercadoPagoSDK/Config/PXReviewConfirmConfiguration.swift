//
//  PXReviewConfirmConfiguration.swift
//  MercadoPagoSDK
//
//  Created by Juan sebastian Sanzone on 6/8/18.
//  Copyright © 2018 MercadoPago. All rights reserved.
//

import Foundation

/**
 This object declares custom preferences (customizations) for "Review and Confirm" screen.
 */
@available(*, deprecated, message: "Groups flow will no longer be available")
@objcMembers open class PXReviewConfirmConfiguration: NSObject {
    private var itemsEnabled: Bool = true
    private var topCustomView: UIView?
    private var bottomCustomView: UIView?

    /// :nodoc:
    override init() {}

    // MARK: Init.
    /**
     - parameter itemsEnabled: Determinate if items view should be display or not.
     - parameter topView: Optional custom top view.
     - parameter bottomView: Optional custom bottom view.
     */
    public init(itemsEnabled: Bool, topView: UIView? = nil, bottomView: UIView? = nil) {
        self.itemsEnabled = itemsEnabled
        self.topCustomView = topView
        self.bottomCustomView = bottomView
    }
}

// MARK: - Internal Getters.
extension PXReviewConfirmConfiguration {
    internal func hasItemsEnabled() -> Bool {
        return itemsEnabled
    }

    internal func getTopCustomView() -> UIView? {
        return self.topCustomView
    }

    internal func getBottomCustomView() -> UIView? {
        return self.bottomCustomView
    }
}
