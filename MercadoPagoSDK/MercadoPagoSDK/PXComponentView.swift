//
//  PXComponentView.swift
//  MercadoPagoSDK
//
//  Created by AUGUSTO COLLERONE ALFONSO on 12/13/17.
//  Copyright © 2017 MercadoPago. All rights reserved.
//

import Foundation

public class PXComponentView: UIView {
    
    private var topGuideView = UIView()
    private var bottomGuideView = UIView()
    private var contentView = UIView()
    
    init() {
        super.init(frame: CGRect(x: 0, y: 0, width: 0, height: 0))
        initComponent()
    }

    func initComponent() {
        self.translatesAutoresizingMaskIntoConstraints = false
        topGuideView.translatesAutoresizingMaskIntoConstraints = false
        bottomGuideView.translatesAutoresizingMaskIntoConstraints = false
        contentView.translatesAutoresizingMaskIntoConstraints = false
        super.addSubview(topGuideView)
        super.addSubview(bottomGuideView)
        super.addSubview(contentView)
        PXLayout.pinTop(view: topGuideView).isActive = true
        PXLayout.pinBottom(view: bottomGuideView).isActive = true
        PXLayout.matchHeight(ofView: topGuideView, toView: bottomGuideView).isActive = true
        PXLayout.centerHorizontally(view: contentView).isActive = true
        PXLayout.centerHorizontally(view: topGuideView).isActive = true
        PXLayout.centerHorizontally(view: bottomGuideView).isActive = true
        PXLayout.put(view: contentView, onBottomOf: topGuideView).isActive = true
        PXLayout.put(view: contentView, aboveOf: bottomGuideView).isActive = true
        PXLayout.matchWidth(ofView: contentView).isActive = true
        PXLayout.matchWidth(ofView: topGuideView).isActive = true
        PXLayout.matchWidth(ofView: bottomGuideView).isActive = true
    }

    func prepareForRender() {
        for view in self.subviews {
            view.removeFromSuperview()
        }
        for constraint in self.constraints {
            constraint.isActive = false
        }
        initComponent()
    }
  
    required public init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override public func addSubview(_ view: UIView) {
        view.translatesAutoresizingMaskIntoConstraints = false
        self.contentView.addSubview(view)
    }

    public func addSubviewToBottom(_ view: UIView, withMargin margin: CGFloat = 0) {
        view.translatesAutoresizingMaskIntoConstraints = false
        self.contentView.addSubview(view)
        putOnBottomOfLastView(view: view, withMargin: margin)?.isActive = true
    }
    
    override func addSeparatorLineToTop(height: CGFloat, horizontalMarginPercentage: CGFloat, color: UIColor = .pxMediumLightGray) {
        self.topGuideView.addSeparatorLineToTop(height: height, horizontalMarginPercentage: horizontalMarginPercentage, color: color)
    }
    
    override func addSeparatorLineToBottom(height: CGFloat, horizontalMarginPercentage: CGFloat, color: UIColor = .pxMediumLightGray) {
        self.bottomGuideView.addSeparatorLineToBottom(height: height, horizontalMarginPercentage: horizontalMarginPercentage, color: color)
    }
    
    override func addLine(yCoordinate: CGFloat, height: CGFloat, horizontalMarginPercentage: CGFloat, color: UIColor) {
        super.addLine(yCoordinate: yCoordinate, height: height, horizontalMarginPercentage: horizontalMarginPercentage, color: color)
    }
    
    //Pin first content view subview to top
    public func pinFirstSubviewToTop(withMargin margin: CGFloat = 0 ) -> NSLayoutConstraint? {
        guard let firstView = self.contentView.subviews.first else {
            return nil
        }
        return PXLayout.pinTop(view: firstView, to: self.contentView, withMargin: margin)
    }
    
    //Pin last content view subview to bottom
    public func pinLastSubviewToBottom(withMargin margin: CGFloat = 0 ) -> NSLayoutConstraint? {
        guard let lastView = self.contentView.subviews.last else {
            return nil
        }
        return PXLayout.pinBottom(view: lastView, to: self.contentView, withMargin: margin)
    }
    
    //Put view on bottom of content view last subview
    public func putOnBottomOfLastView(view: UIView, withMargin margin: CGFloat = 0) -> NSLayoutConstraint? {
        if !self.contentView.subviews.contains(view) {
            return nil
        }
        for actualView in self.contentView.subviews.reversed() {
            if actualView != view {
                return PXLayout.put(view: view, onBottomOf: actualView, withMargin: margin)
            }
        }
        return nil
    }
    
    func getSubviews() -> [UIView] {
        return self.contentView.subviews
    }
  
    var heightConstraint : NSLayoutConstraint?
    func fixHeight(height : CGFloat){
        if let heightConstraint = self.heightConstraint {
            heightConstraint.constant = height
        } else {
            self.heightConstraint = PXLayout.setHeight(owner: self, height: height)
            self.heightConstraint?.isActive = true
        }
        self.layoutIfNeeded()
    }
}
