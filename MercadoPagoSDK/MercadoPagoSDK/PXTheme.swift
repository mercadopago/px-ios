//
//  PXTheme.swift
//  MercadoPagoSDK
//
//  Created by Juan sebastian Sanzone on 9/1/18.
//  Copyright © 2018 MercadoPago. All rights reserved.
//

import Foundation

@objc public protocol PXTheme {
    func navigationBar() -> PXThemeProperty
    func loadingComponent() -> PXThemeProperty

    func highlightBackgroundColor() -> UIColor
    func detailedBackgroundColor() -> UIColor

    func statusBarStyle() -> UIStatusBarStyle

    @objc optional func highlightNavigationTintColor() -> UIColor?

    @objc optional func fontName() -> String?
    @objc optional func lightFontName() -> String?
    @objc optional func semiBoldFontName() -> String?
}
