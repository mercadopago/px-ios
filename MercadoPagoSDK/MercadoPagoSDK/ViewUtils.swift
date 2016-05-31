//
//  ViewUtil.swift
//  MercadoPagoSDK
//
//  Created by Maria cristina rodriguez on 21/4/16.
//  Copyright © 2016 MercadoPago. All rights reserved.
//

import Foundation
import UIKit

class ViewUtils {
    
    class func getTableCellSeparatorLineView(x : CGFloat, y : CGFloat, width : CGFloat, height : CGFloat) -> UIView {
        let separatorLineView = UIView(frame: CGRect(x: x, y: y, width: width, height: height))
        separatorLineView.layer.zPosition = 1
        separatorLineView.backgroundColor = UIColor().grayTableSeparator()
        return separatorLineView
    }
    
    class func addStatusBar(view : UIView, color : UIColor) {
        let addStatusBar = UIView(frame: CGRectMake(0, 0, view.bounds.width, 20))
        addStatusBar.backgroundColor = color
        view.addSubview(addStatusBar)
    }
    
    class func addScaledImage(image : UIImage, inView view: UIView){
        let imageView = UIImageView()
        imageView.frame = view.bounds
        imageView.contentMode = .ScaleAspectFill
        imageView.image = image
        view.addSubview(imageView)
    }

    class func loadImageFromUrl(url : String, inView : UIView, loadingBackgroundColor : UIColor = UIColor().UIColorFromRGB(0x5ABEE7), loadingIndicatorColor : UIColor = UIColor().backgroundColor()){
        LoadingOverlay.shared.showOverlay(inView, backgroundColor: loadingBackgroundColor, indicatorColor: loadingIndicatorColor)
        dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), {
            let url = NSURL(string: url)
            if url != nil {
                let data = NSData(contentsOfURL: url!)
                if data != nil {
                    dispatch_async(dispatch_get_main_queue(), {
                        let image = UIImage(data: data!)
                        if image != nil {
                            ViewUtils.addScaledImage(image!, inView: inView)
                        }
                        });
                   


                }
            }
            LoadingOverlay.shared.hideOverlayView()
        })
    }
    
    class func drawBottomLine(x : CGFloat = 0, y : CGFloat, width : CGFloat, inView view: UIView){
        let overLinewView = UIView(frame: CGRect(x: x, y: y, width: width, height: 1))
        overLinewView.backgroundColor = UIColor().UIColorFromRGB(0xDEDEDE)
        view.addSubview(overLinewView)
    }
    

    
}
