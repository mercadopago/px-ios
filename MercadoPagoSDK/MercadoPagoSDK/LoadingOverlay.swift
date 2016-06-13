//
//  LoadingOverlay.swift
//  MercadoPagoSDK
//
//  Created by Maria cristina rodriguez on 29/4/16.
//  Copyright © 2016 MercadoPago. All rights reserved.
//

import UIKit

public class LoadingOverlay {
    
    var container = UIView()
    var screenContainer = UIView()
    var activityIndicator = UIActivityIndicatorView()
    
    class var shared: LoadingOverlay {
        struct Static {
            static let instance: LoadingOverlay = LoadingOverlay()
        }
        return Static.instance
    }

    init(){
        
    }
    
    public func getLoadingOverlay(view : UIView, backgroundColor : UIColor, indicatorColor : UIColor) -> UIView {
        
        
        
        self.activityIndicator.frame = CGRectMake(30,30, 20, 20)
        self.activityIndicator.activityIndicatorViewStyle = .WhiteLarge
        self.activityIndicator.color = indicatorColor
        self.activityIndicator.hidden = false
        
        self.container.frame = CGRectMake(0, 0, 80, 80)
        self.container.backgroundColor = UIColor.clearColor()
        self.container.alpha = 1
        self.container.center = CGPoint(x: view.bounds.width / 2, y: view.bounds.height / 2 )
        self.container.layer.cornerRadius = 10.0
        self.container.addSubview(self.activityIndicator)
        
        self.screenContainer.frame = CGRect(x : view.bounds.minX, y : view.bounds.minY, width : view.bounds.width, height : view.bounds.height)
        self.screenContainer.backgroundColor = backgroundColor.colorWithAlphaComponent(0.8)
        self.screenContainer.addSubview(self.container)
        
        self.activityIndicator.startAnimating()
        return self.screenContainer
    }
    
    public func showOverlay(view: UIView, backgroundColor : UIColor, indicatorColor : UIColor) {
        let overlay = self.getLoadingOverlay(view, backgroundColor : backgroundColor, indicatorColor: indicatorColor)
        view.addSubview(overlay)
        view.bringSubviewToFront(overlay)
    }
    
    public func hideOverlayView() {
        activityIndicator.stopAnimating()
        screenContainer.removeFromSuperview()
    }
}
