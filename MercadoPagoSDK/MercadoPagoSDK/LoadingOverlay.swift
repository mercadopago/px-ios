//
//  LoadingOverlay.swift
//  MercadoPagoSDK
//
//  Created by Maria cristina rodriguez on 29/4/16.
//  Copyright © 2016 MercadoPago. All rights reserved.
//

import UIKit

open class LoadingOverlay {
    
    //var loadingContainer : MPLoadingView!
    var screenContainer = UIView()
    
    class var shared: LoadingOverlay {
        struct Static {
            static let instance: LoadingOverlay = LoadingOverlay()
        }
        return Static.instance
    }

    init(){
        
    }
    
    open func showOverlay(_ view: UIView, backgroundColor : UIColor) {
        let color =  UIColor.white()
        
        //self.loadingContainer = MPLoadingView(backgroundColor: color)!
        let loadingImage = MercadoPago.getImage("mpui-loading_default")
        //self.loadingContainer.spinner = UIImageView(image: loadingImage)
//        self.spinner = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@]];
//        [self.spinner setFrame: CGRectMake(50, 50, 100, 100)];
//        //[MercadoPago getImage:@"mpui-loading_default"];
//        [self addSubview:self.spinner];
//        [self.spinner setTranslatesAutoresizingMaskIntoConstraints:NO];
        
        //view.addSubview(self.loadingContainer)
        //view.bringSubview(toFront: self.loadingContainer)
    }
    
    open func hideOverlayView() {
       // self.loadingContainer.removeFromSuperview()
    }
}
