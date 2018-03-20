//
//  PXComponentContainerViewController.swift
//  MercadoPagoSDK
//
//  Created by Demian Tejo on 11/8/17.
//  Copyright © 2017 MercadoPago. All rights reserved.
//

import UIKit

class PXComponentContainerViewController: MercadoPagoUIViewController {
    
    fileprivate lazy var elasticHeader = UIView()
    fileprivate lazy var customNavigationTitle: String = ""
    fileprivate lazy var NAVIGATION_BAR_DELTA_Y: CGFloat = 29.5
    
    var scrollView: UIScrollView!
    var contentView = PXComponentView()
    var heightComponent: NSLayoutConstraint!
    var lastViewConstraint: NSLayoutConstraint!
    
    init() {
        self.scrollView = UIScrollView()
        self.scrollView.backgroundColor = .white
        self.scrollView.translatesAutoresizingMaskIntoConstraints = false
        self.scrollView.delaysContentTouches = true
        self.scrollView.canCancelContentTouches = false
        self.scrollView.isUserInteractionEnabled = true
        contentView.translatesAutoresizingMaskIntoConstraints = false
        self.scrollView.addSubview(contentView)
        
        PXLayout.pinTop(view: contentView, to: scrollView).isActive = true
        PXLayout.centerHorizontally(view: contentView, to: scrollView).isActive = true
        PXLayout.matchWidth(ofView: contentView, toView: scrollView).isActive = true
        contentView.backgroundColor = .pxWhite
        super.init(nibName: nil, bundle: nil)
        self.view.addSubview(self.scrollView)
        
        PXLayout.pinLeft(view: scrollView, to: self.view).isActive = true
        PXLayout.pinRight(view: scrollView, to: self.view).isActive = true
        PXLayout.pinTop(view: scrollView, to: self.view).isActive = true
        
        let bottomDeltaMargin: CGFloat = PXLayout.getSafeAreaBottomInset()
        
        PXLayout.pinBottom(view: scrollView, to: self.view, withMargin: -bottomDeltaMargin).isActive = true
        scrollView.bounces = false
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        handleNavigationBarEffect(scrollView)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

// MARK: Elastic header.
extension PXComponentContainerViewController: UIScrollViewDelegate {
    
    func addElasticHeader(headerBackgroundColor: UIColor?, navigationCustomTitle:String, navigationDeltaY:CGFloat?=nil) {
        elasticHeader.removeFromSuperview()
        scrollView.delegate = self
        customNavigationTitle = navigationCustomTitle
        elasticHeader.backgroundColor = headerBackgroundColor
        if let customDeltaY =  navigationDeltaY {
            NAVIGATION_BAR_DELTA_Y = customDeltaY
        }
        view.insertSubview(elasticHeader, aboveSubview: contentView)
        scrollView.bounces = true
    }
    
    func refreshContentViewSize() {
        var height : CGFloat = 0
        for view in contentView.getSubviews() {
            height = height + view.frame.height
        }
        contentView.fixHeight(height: height)
        scrollView.contentSize = CGSize(width: PXLayout.getScreenWidth(), height: height)
        self.view.layoutIfNeeded()
    }
    
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        handleNavigationBarEffect(scrollView)
        elasticHeader.frame = CGRect(x: 0, y: 0, width: contentView.frame.width, height: -scrollView.contentOffset.y)
    }
    
    fileprivate func handleNavigationBarEffect(_ targetScrollView: UIScrollView) {
        if targetScrollView.contentOffset.y >= NAVIGATION_BAR_DELTA_Y {
            title = customNavigationTitle
            navigationItem.title = title
        } else {
            let fadeTextAnimation = CATransition()
            fadeTextAnimation.duration = 0.5
            fadeTextAnimation.type = kCATransitionFade
            navigationController?.navigationBar.layer.add(fadeTextAnimation, forKey: "fadeText")
            title = ""
        }
    }
}

