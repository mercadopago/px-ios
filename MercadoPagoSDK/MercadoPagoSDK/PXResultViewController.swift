//
//  PXResultViewController.swift
//  MercadoPagoSDK
//
//  Created by Demian Tejo on 20/10/17.
//  Copyright © 2017 MercadoPago. All rights reserved.
//

import UIKit

class PXResultViewController: PXComponentContainerViewController {

    let viewModel: PXResultViewModel
    var headerView: UIView!
    var receiptView: UIView!
    var topCustomView: UIView!
    var bottomCustomView: UIView!
    var bodyView: UIView!
    var footerView: UIView!

    init(viewModel: PXResultViewModel, callback : @escaping ( _ status: PaymentResult.CongratsState) -> Void) {
        self.viewModel = viewModel
        self.viewModel.callback = callback
        super.init()
        self.scrollView.backgroundColor = viewModel.primaryResultColor()
        self.shouldHideNavigationBar = true
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    func renderViews() {
        for view in contentView.subviews {
            view.removeFromSuperview()
        }
        for constraint in contentView.constraints {
            constraint.isActive = false
        }
        //Add Header
        headerView = self.buildHeaderView()
        contentView.addSubview(headerView)
        PXLayout.pinTop(view: headerView, to: contentView).isActive = true
        PXLayout.matchWidth(ofView: headerView).isActive = true

        //Add Receipt
        receiptView = self.buildReceiptView()
        contentView.addSubview(receiptView)
        receiptView.translatesAutoresizingMaskIntoConstraints = false
        PXLayout.put(view: receiptView, onBottomOf: headerView).isActive = true
        PXLayout.matchWidth(ofView: receiptView).isActive = true

        //Add Top Custom Component
        topCustomView = buildTopCustomView()
        contentView.addSubview(topCustomView)
        PXLayout.put(view: topCustomView, onBottomOf: receiptView).isActive = true
        PXLayout.matchWidth(ofView: topCustomView).isActive = true

        //Add Footer
        footerView = self.buildFooterView()
        contentView.addSubview(footerView)
        PXLayout.matchWidth(ofView: footerView).isActive = true
        PXLayout.pinBottom(view: footerView, to: contentView).isActive = true
        PXLayout.centerHorizontally(view: footerView, to: contentView).isActive = true
        self.view.layoutIfNeeded()
        PXLayout.setHeight(owner: footerView, height: footerView.frame.height).isActive = true

        //Add Body
        bodyView = self.buildBodyView()
        contentView.addSubview(bodyView)
        bodyView.translatesAutoresizingMaskIntoConstraints = false
        PXLayout.matchWidth(ofView: bodyView).isActive = true
        PXLayout.put(view: bodyView, onBottomOf: topCustomView).isActive = true
        PXLayout.centerHorizontally(view: bodyView).isActive = true
        self.view.layoutIfNeeded()

        //Add Bottom Custom Component
        bottomCustomView = buildBottomCustomView()
        contentView.addSubview(bottomCustomView)
        PXLayout.put(view: bottomCustomView, onBottomOf: bodyView).isActive = true
        PXLayout.put(view: bottomCustomView, aboveOf: footerView).isActive = true
        PXLayout.matchWidth(ofView: bottomCustomView).isActive = true

        if isEmptySpaceOnScreen() {
            if shouldExpandHeader() {
                expandHeader()
            } else {
                expandBody()
            }
        }
        bodyView.addSeparatorLineToBottom(horizontalMargin: 0, width: bodyView.frame.width, height: 1)

        self.view.layoutIfNeeded()
        self.contentView.layoutIfNeeded()
        self.view.layoutIfNeeded()
        self.scrollView.contentSize = CGSize(width: self.scrollView.frame.width, height: self.contentView.frame.height)
    }

    func expandHeader() {
        PXLayout.matchHeight(ofView: self.contentView, toView: self.scrollView).isActive = true
        PXLayout.setHeight(owner: self.bodyView, height: 0.0).isActive = true
        PXLayout.setHeight(owner: self.receiptView, height: 0.0).isActive = true
    }

    func expandBody() {
        self.view.layoutIfNeeded()
        self.scrollView.layoutIfNeeded()
        let headerHeight = self.headerView.frame.height
        let footerHeight = self.footerView.frame.height
        let receiptHeight = self.receiptView.frame.height
        let topCustomViewHeight = self.topCustomView.frame.height
        let bottomCustomViewHeight = self.bottomCustomView.frame.height
        let restHeight = totalContentViewHeigth() - footerHeight - headerHeight - receiptHeight - topCustomViewHeight - bottomCustomViewHeight
        PXLayout.setHeight(owner: bodyView, height: restHeight).isActive = true
    }

    func isEmptySpaceOnScreen() -> Bool {
        self.view.layoutIfNeeded()
        return self.contentView.frame.height < totalContentViewHeigth()
    }

    func shouldExpandHeader() -> Bool {
        self.view.layoutIfNeeded()
        return bodyView.frame.height == 0
    }

    override func viewDidLoad() {
        super.viewDidLoad()
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        ViewUtils.addStatusBar(self.view, color: viewModel.primaryResultColor())
        self.view.layoutIfNeeded()
        renderViews()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
}

// Components 
extension PXResultViewController {
    func buildHeaderView() -> UIView {
        let headerProps = self.viewModel.getHeaderComponentProps()
        let headerComponent = PXHeaderComponent(props: headerProps)
        return headerComponent.render()
    }
    func buildFooterView() -> UIView {
        let footerProps = self.viewModel.getFooterComponentProps()
        let footerComponent = PXFooterComponent(props: footerProps)
        return footerComponent.render()
    }

    func buildReceiptView() -> UIView {
        let receiptProps = self.viewModel.getReceiptComponentProps()
        let receiptComponent = PXReceiptComponent(props: receiptProps)
        return receiptComponent.render()
    }

    func buildBodyView() -> UIView {
        let bodyProps = self.viewModel.getBodyComponentProps()
        let bodyComponent = PXBodyComponent(props: bodyProps)
        return bodyComponent.render()
    }

    func buildTopCustomView() -> UIView {
        if let component = self.viewModel.getTopCustomComponent() {
            return component.render()
        }
        let view = UIView()
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }

    func buildBottomCustomView() -> UIView {
        if let component = self.viewModel.getBottomCustomComponent() {
            return component.render()
        }
        let view = UIView()
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }
}
