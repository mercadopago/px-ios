//
//  MercadoPagoUIScrollViewController.swift
//  MercadoPagoSDK
//
//  Created by Maria cristina rodriguez on 11/7/16.
//  Copyright © 2016 MercadoPago. All rights reserved.
//

import UIKit

open class MercadoPagoUIScrollViewController: MercadoPagoUIViewController {

    var displayNavBar = false
    var lastContentOffset: CGFloat = 0
    var scrollingDown = false
    var navBarHeight : CGFloat = -18
    
    func didScrollInTable(_ scrollView: UIScrollView) {
        
        if (scrollView.contentOffset.y > navBarHeight + UIApplication.shared.statusBarFrame.size.height) {
            showNavBar()
        } else {
            hideNavBar()
        }
    }
    
    
    override func getNavigationBarTitle() -> String {
        return ""
    }
    


  
}
