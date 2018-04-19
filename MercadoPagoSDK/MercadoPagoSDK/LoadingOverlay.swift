//
//  LoadingOverlay.swift
//  MercadoPagoSDK
//
//  Created by Maria cristina rodriguez on 29/4/16.
//  Copyright © 2016 MercadoPago. All rights reserved.
//

import UIKit

@objcMembers
open class LoadingOverlay {

    var container = UIView()
    var activityIndicator = UIActivityIndicatorView()
    var loadingContainer: MPSDKLoadingView!
    var screenContainer = UIView()

    class var shared: LoadingOverlay {
        struct Static {
            static let instance: LoadingOverlay = LoadingOverlay()
        }
        return Static.instance
    }

    init() {

    }

    open func getDefaultLoadingOverlay(_ view: UIView, backgroundColor: UIColor, indicatorColor: UIColor) -> UIView {

        self.activityIndicator.frame = CGRect(x: 30, y: 30, width: 20, height: 20)
        self.activityIndicator.activityIndicatorViewStyle = .whiteLarge
        self.activityIndicator.color = indicatorColor
        self.activityIndicator.isHidden = false

        self.container.frame = CGRect(x: 0, y: 0, width: 80, height: 80)
        self.container.backgroundColor = UIColor.clear
        self.container.alpha = 1
        self.container.center = CGPoint(x: view.frame.width / 2, y: view.frame.height / 2 )
        self.container.layer.cornerRadius = 10.0
        self.container.addSubview(self.activityIndicator)

        self.screenContainer.frame = CGRect(x: 0, y: 0, width: view.frame.width, height: view.frame.height)
        self.screenContainer.backgroundColor = backgroundColor.withAlphaComponent(0.8)

        self.screenContainer.addSubview(self.container)

        self.activityIndicator.startAnimating()
        return self.screenContainer
    }

    open func showOverlay(_ view: UIView, backgroundColor: UIColor, indicatorColor: UIColor = UIColor.white) -> UIView {
        let loadingOverlay: UIView?

        self.loadingContainer = MPSDKLoadingView(loading: ThemeManager.shared.getTheme().loadingComponent().tintColor)!

        view.addSubview(self.loadingContainer)
        view.bringSubview(toFront: self.loadingContainer)
        loadingOverlay = self.loadingContainer
        loadingOverlay?.backgroundColor = ThemeManager.shared.getTheme().loadingComponent().backgroundColor

        return loadingOverlay!
    }

    open func hideOverlayView() {
        if self.loadingContainer != nil {
            self.loadingContainer.removeFromSuperview()
        }
    }
}
