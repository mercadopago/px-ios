//
//  PXResultViewModel+CustomViews.swift
//  MercadoPagoSDK
//
//  Created by Eden Torres on 1/5/18.
//  Copyright © 2018 MercadoPago. All rights reserved.
//

import Foundation

internal extension PXResultViewModel {
    func buildTopCustomView() -> UIView? {
        return getTopCustomView()
    }

    func buildBottomCustomView() -> UIView? {
        return getBottomCustomView()
    }
}
