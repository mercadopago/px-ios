//
//  ThemeManager.swift
//  MercadoPagoSDK
//
//  Created by Juan sebastian Sanzone on 10/1/18.
//  Copyright © 2018 MercadoPago. All rights reserved.
//

import Foundation
import MLUI

class ThemeManager {

    static let shared = ThemeManager()

    fileprivate var currentTheme: PXTheme = PXDefaultTheme(withPrimaryColor: #colorLiteral(red:0.57, green:0.05, blue:0.30, alpha:1.0)) {
        didSet {
            initialize()
        }
    }

    fileprivate var currentStylesheet = MLStyleSheetManager.styleSheet
    fileprivate var fontName: String = ".SFUIDisplay-Regular"
    fileprivate var fontLightName: String = ".SFUIDisplay-Light"

    var navigationControllerMemento: NavigationControllerMemento?
}

// MARK: - Public methods
extension ThemeManager {

    func initialize() {
        currentStylesheet = MLStyleSheetManager.styleSheet
        customizeNavigationBar(theme: currentTheme)
        customizeToolBar()
        PXMonospaceLabel.appearance().font = UIFont(name: "Courier-Bold", size: 50.0)
    }

    func setDefaultColor(color: UIColor) {
        let customTheme = PXDefaultTheme(withPrimaryColor: color)
        let customStyleSheet = PXDefaultMLStyleSheet(withPrimaryColor: color)
        MLStyleSheetManager.styleSheet = customStyleSheet
        self.currentTheme = customTheme
    }

    func setTheme(theme: PXTheme) {
        self.currentTheme = theme
        if let externalFont = theme.fontName?() {
            fontName = externalFont
        }
        if let externalLightFont = theme.lightFontName?() {
            fontLightName = externalLightFont
        }
    }

    func getCurrentTheme() -> PXTheme {
        return currentTheme
    }

    func getFontName() -> String {
        return fontName
    }

    func getLightFontName() -> String {
        return fontLightName
    }
}

extension ThemeManager {

    func boldLabelTintColor() -> UIColor {
        return currentStylesheet.blackColor
    }

    func labelTintColor() -> UIColor {
        return currentStylesheet.darkGreyColor
    }

    func midLabelTintColor() -> UIColor {
        return currentStylesheet.midGreyColor
    }

    func lightTintColor() -> UIColor {
        return currentStylesheet.lightGreyColor
    }

    func greyColor() -> UIColor {
        return currentStylesheet.greyColor
    }

    func whiteColor() -> UIColor {
        return currentStylesheet.whiteColor
    }

    func successColor() -> UIColor {
        return currentStylesheet.successColor
    }

    func warningColor() -> UIColor {
        return currentStylesheet.warningColor
    }

    func rejectedColor() -> UIColor {
        return currentStylesheet.errorColor
    }

    func secondaryColor() -> UIColor {
        return currentStylesheet.secondaryColor
    }

    func placeHolderColor() -> UIColor {
        return #colorLiteral(red: 0.8, green: 0.8, blue: 0.8, alpha: 1)
    }

    func iconBackgroundColor() -> UIColor {
        return #colorLiteral(red: 0.9411764706, green: 0.9411764706, blue: 0.9411764706, alpha: 1)
    }

    func noTaxAndDiscountLabelTintColor() -> UIColor {
        return #colorLiteral(red: 0.2235294118, green: 0.7098039216, blue: 0.2901960784, alpha: 1)
    }
}

// MARK: - UI design exceptions
extension ThemeManager: PXTheme {

    func navigationBar() -> PXThemeProperty {
        return currentTheme.navigationBar()
    }

    func loadingComponent() -> PXThemeProperty {
        return currentTheme.loadingComponent()
    }

    func highlightBackgroundColor() -> UIColor {
        return currentTheme.highlightBackgroundColor()
    }

    func detailedBackgroundColor() -> UIColor {
        return currentTheme.detailedBackgroundColor()
    }

    func statusBarStyle() -> UIStatusBarStyle {
        return currentTheme.statusBarStyle()
    }

    func getMainColor() -> UIColor {
        if let theme = currentTheme as? PXDefaultTheme {
            return theme.primaryColor
        }
        return currentTheme.navigationBar().backgroundColor
    }

    func getAccentColor() -> UIColor {
        if let theme = currentTheme as? PXDefaultTheme {
            return theme.primaryColor
        }
        return currentStylesheet.secondaryColor
    }

    func getTintColorForIcons() -> UIColor? {
        if currentTheme is PXDefaultTheme {
            return getMainColor()
        }
        return nil
    }

    func getTitleColorForReviewConfirmNavigation() -> UIColor {

        if currentTheme is PXDefaultTheme {
            return getMainColor()
        }

        if let highlightNavigationTint = currentTheme.highlightNavigationTintColor?() {
            return highlightNavigationTint
        }

        return boldLabelTintColor()
    }

    func modalComponent() -> PXThemeProperty {
        return PXThemeProperty(backgroundColor: currentStylesheet.modalBackgroundColor, tintColor: currentStylesheet.modalTintColor, selectedColor: .clear)
    }
}

// MARK: - UI Theme customization
extension ThemeManager {

    fileprivate func customizeNavigationBar(theme: PXTheme) {
        UINavigationBar.appearance(whenContainedInInstancesOf: [MercadoPagoUIViewController.self]).tintColor = theme.navigationBar().tintColor
        UINavigationBar.appearance(whenContainedInInstancesOf: [MercadoPagoUIViewController.self]).backgroundColor = theme.navigationBar().backgroundColor
        UIBarButtonItem.appearance(whenContainedInInstancesOf: [MercadoPagoUIViewController.self]).tintColor = theme.navigationBar().tintColor
        PXNavigationHeaderLabel.appearance().textColor = theme.navigationBar().tintColor
    }

    fileprivate func customizeToolBar() {
        PXToolbar.appearance().tintColor = getAccentColor()
        PXToolbar.appearance().backgroundColor = lightTintColor()
        PXToolbar.appearance().alpha = 1
    }
}
