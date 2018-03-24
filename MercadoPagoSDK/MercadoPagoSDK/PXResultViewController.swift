//
//  PXResultViewController.swift
//  MercadoPagoSDK
//
//  Created by Demian Tejo on 20/10/17.
//  Copyright © 2017 MercadoPago. All rights reserved.
//

import UIKit
import MercadoPagoPXTracking

class PXResultViewController: PXComponentContainerViewController {
    
    override open var screenName: String { get { return TrackingUtil.SCREEN_NAME_PAYMENT_RESULT } }
    override open var screenId: String { get { return TrackingUtil.SCREEN_ID_PAYMENT_RESULT } }
    
    let viewModel: PXResultViewModelInterface
    var headerView: UIView?
    var receiptView: UIView?
    var topCustomView: UIView?
    var bottomCustomView: UIView?
    var bodyView: UIView?
    var footerView: UIView?
    
    init(viewModel: PXResultViewModelInterface, callback : @escaping ( _ status: PaymentResult.CongratsState) -> Void) {
        self.viewModel = viewModel
        self.viewModel.setCallback(callback: callback)
        super.init()
        self.scrollView.backgroundColor = viewModel.primaryResultColor()
        self.shouldHideNavigationBar = true
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func trackInfo() {
        var metadata = [TrackingUtil.METADATA_PAYMENT_IS_EXPRESS: TrackingUtil.IS_EXPRESS_DEFAULT_VALUE,
                        TrackingUtil.METADATA_PAYMENT_STATUS: self.viewModel.getPaymentStatus(),
                        TrackingUtil.METADATA_PAYMENT_STATUS_DETAIL: self.viewModel.getPaymentStatusDetail(),
                        TrackingUtil.METADATA_PAYMENT_ID: self.viewModel.getPaymentId() ?? ""]
        if let pm = self.viewModel.getPaymentData().getPaymentMethod() {
            metadata[TrackingUtil.METADATA_PAYMENT_METHOD_ID] = pm._id
        }
        if let issuer = self.viewModel.getPaymentData().getIssuer() {
            metadata[TrackingUtil.METADATA_ISSUER_ID] = issuer._id
        }
        
        let finalId = "\(screenId)/\(self.viewModel.getPaymentStatus())"
        
        var name = screenName
        if self.viewModel.isCallForAuth() {
            name = TrackingUtil.SCREEN_NAME_PAYMENT_RESULT_CALL_FOR_AUTH
        }
        
        MPXTracker.sharedInstance.trackScreen(screenId: finalId, screenName: name, properties: metadata)
    }
    
    func renderViews() {
        
        self.contentView.prepareForRender()
        
        //Add Header
        self.headerView = self.buildHeaderView()
        if let headerView = self.headerView {
            contentView.addSubview(headerView)
            PXLayout.pinTop(view: headerView, to: contentView).isActive = true
            PXLayout.matchWidth(ofView: headerView).isActive = true
        }

        //Add Receipt
        self.receiptView = self.buildReceiptView()
        if let receiptView = self.receiptView {
            receiptView.addSeparatorLineToBottom(height: 1)
            contentView.addSubviewToBottom(receiptView)
            PXLayout.matchWidth(ofView: receiptView).isActive = true
            self.view.layoutIfNeeded()
            PXLayout.setHeight(owner: receiptView, height: receiptView.frame.height).isActive = true
        }
  
        //Add Top Custom Component
        self.topCustomView = buildTopCustomView()
        if let topCustomView = self.topCustomView {
            topCustomView.clipsToBounds = true
            contentView.addSubviewToBottom(topCustomView)
            PXLayout.matchWidth(ofView: topCustomView).isActive = true
            self.view.layoutIfNeeded()
            PXLayout.setHeight(owner: topCustomView, height: topCustomView.frame.height).isActive = true
        }
      
        //Add Body
        self.bodyView = self.buildBodyView()
        if let bodyView = self.bodyView {
            contentView.addSubviewToBottom(bodyView)
            PXLayout.matchWidth(ofView: bodyView).isActive = true
            PXLayout.centerHorizontally(view: bodyView).isActive = true
            bodyView.addSeparatorLineToBottom(height: 1)
        }
        
        //Add Bottom Custom Component
        self.bottomCustomView = buildBottomCustomView()
        if let bottomCustomView = self.bottomCustomView{
            bottomCustomView.clipsToBounds = true
            contentView.addSubviewToBottom(bottomCustomView)
            PXLayout.matchWidth(ofView: bottomCustomView).isActive = true
            self.view.layoutIfNeeded()
            PXLayout.setHeight(owner: bottomCustomView, height: bottomCustomView.frame.height).isActive = true
        }
   
        //Add Footer
        self.footerView = self.buildFooterView()
        if let footerView = self.footerView {
            contentView.addSubviewToBottom(footerView)
            PXLayout.matchWidth(ofView: footerView).isActive = true
            PXLayout.centerHorizontally(view: footerView, to: contentView).isActive = true
            self.view.layoutIfNeeded()
            PXLayout.setHeight(owner: footerView, height: footerView.frame.height).isActive = true
        }

        PXLayout.pinLastSubviewToBottom(view: contentView)?.isActive = true
        super.refreshContentViewSize()
        if isEmptySpaceOnScreen() {
            if shouldExpandHeader() {
                expandHeader()
            } else {
                expandBody()
            }
        }
      
        self.scrollView.contentSize = CGSize(width: self.scrollView.frame.width, height: self.contentView.frame.height)
        super.refreshContentViewSize()
    }
    
    func expandHeader() {
        self.view.layoutIfNeeded()
        self.scrollView.layoutIfNeeded()
        if let bodyView = self.bodyView {
            self.view.layoutIfNeeded()
            PXLayout.setHeight(owner: bodyView, height: bodyView.frame.height).isActive = true
        }
        let fixedHeight = totalContentViewHeigth() - self.contentView.frame.height
        guard let headerView = self.headerView else {
            return
        }
        PXLayout.setHeight(owner: headerView, height: headerView.frame.height + fixedHeight).isActive = true
        super.refreshContentViewSize()
    }
    
    func expandBody() {
        if let headerView = self.headerView {
            self.view.layoutIfNeeded()
            PXLayout.setHeight(owner: headerView, height: headerView.frame.height).isActive = true
        }
        let fixedHeight = totalContentViewHeigth() - self.contentView.frame.height
        guard let bodyView = self.bodyView else {
            return
        }
        PXLayout.setHeight(owner: bodyView, height: bodyView.frame.height + fixedHeight).isActive = true
        super.refreshContentViewSize()
    }
    
    func isEmptySpaceOnScreen() -> Bool {
        self.view.layoutIfNeeded()
        return self.contentView.frame.height < totalContentViewHeigth()
    }
    
    func shouldExpandHeader() -> Bool {
        self.view.layoutIfNeeded()
        guard let bodyView = self.bodyView else {
            return true
        }
        return bodyView.frame.height == 0
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        ViewUtils.addStatusBar(self.view, color: viewModel.primaryResultColor())
        self.scrollView.showsVerticalScrollIndicator = false
        self.scrollView.showsHorizontalScrollIndicator = false
        self.view.layoutIfNeeded()
        renderViews()
    }
}

// Components
extension PXResultViewController {
    func buildHeaderView() -> UIView {
        let headerComponent = viewModel.buildHeaderComponent()
        return headerComponent.render()
    }
    
    func buildFooterView() -> UIView {
        let footerComponent = viewModel.buildFooterComponent()
        return footerComponent.render()
    }
    
    func buildReceiptView() -> UIView? {
        let receiptComponent = viewModel.buildReceiptComponent()
        return receiptComponent?.render()
    }

    func buildBodyView() -> UIView? {
        let bodyComponent = viewModel.buildBodyComponent()
        return bodyComponent?.render()
    }
    
    func buildTopCustomView() -> UIView? {
        if let component = self.viewModel.buildTopCustomComponent(), let componentView = component.render(store: PXCheckoutStore.sharedInstance, theme: ThemeManager.shared.getTheme()) {
            return componentView
        }
        let view = UIView()
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }
    
    func buildBottomCustomView() -> UIView? {
        if let component = self.viewModel.buildBottomCustomComponent(), let componentView = component.render(store: PXCheckoutStore.sharedInstance, theme: ThemeManager.shared.getTheme()) {
            return componentView
        }
        let view = UIView()
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }
}
