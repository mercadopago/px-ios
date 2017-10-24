//
//  PXInstructionsViewController.swift
//  MercadoPagoSDK
//
//  Created by Demian Tejo on 20/10/17.
//  Copyright © 2017 MercadoPago. All rights reserved.
//

import UIKit

class PXInstructionsViewController: MercadoPagoUIViewController
{

    let STATUS_BAR_HEIGHT : CGFloat = 20.0
    let viewModel : PXInstructionsViewModel
    var scrollView : UIScrollView!
    var headerView = UIView()
    var contentView = UIView()
    var heightComponent : NSLayoutConstraint!
    var lastViewConstraint : NSLayoutConstraint!
    var fooView : UIView!
    var callback : (PaymentResult.CongratsState) -> Void
    
    init(viewModel : PXInstructionsViewModel,  callback : @escaping ( _ status: PaymentResult.CongratsState) -> Void){
        self.viewModel = viewModel
        self.scrollView = UIScrollView()
        self.scrollView.translatesAutoresizingMaskIntoConstraints = false
        self.scrollView.backgroundColor = viewModel.primaryResultColor()
        //Set Content
        contentView.translatesAutoresizingMaskIntoConstraints = false
        self.scrollView.addSubview(contentView)
        MPLayout.pinTop(view: contentView, to: scrollView).isActive = true
        MPLayout.centerHorizontally(view: contentView, to: scrollView).isActive = true
        MPLayout.equalizeWidth(view: contentView, to: scrollView).isActive = true
        MPLayout.equalizeHeight(view: contentView, to: scrollView).isActive = true
        contentView.backgroundColor = .brown
        self.callback = callback
        super.init(nibName: nil, bundle: nil)
        self.view.addSubview(self.scrollView)
        MPLayout.pinLeft(view: scrollView, to: self.view).isActive = true
        MPLayout.pinRight(view: scrollView, to: self.view).isActive = true
        MPLayout.pinTop(view: scrollView, to: self.view, withMargin: STATUS_BAR_HEIGHT).isActive = true
        MPLayout.pinBottom(view: scrollView, to: self.view).isActive = true
    }
    
    
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func renderViews() {
        for view in contentView.subviews {
            view.removeFromSuperview()
        }
        //Add Header
        let dataHeader = self.viewModel.headerComponentData()
        let componentHeader = HeaderComponent(data: dataHeader)
        let rendererHeader = HeaderRenderer()
        headerView = rendererHeader.render(header: componentHeader)
        contentView.addSubview(headerView)
        MPLayout.pinTop(view: headerView, to: contentView).isActive = true
        MPLayout.equalizeWidth(view: headerView, to: contentView).isActive = true
     //   MPLayout.setHeight(owner: headerView, height: 250).isActive = true
        
        
        //Add Foo
        
        let dataFoo = FooterData(titleLabel: "Aceptar", titleButton: "Nada") {
            self.renderViews()
        }
        let componentFoo = FooterComponent(data: dataFoo)
        let rendererFoo = FooterRenderer()
        fooView = rendererFoo.render(footer: componentFoo)
        fooView.translatesAutoresizingMaskIntoConstraints = false
        contentView.addSubview(fooView)
        MPLayout.equalizeWidth(view: fooView, to: contentView).isActive = true
        //    MPLayout.setHeight(owner: fooView, height: 80).isActive = true
        MPLayout.pinBottom(view: fooView, to: contentView).isActive = true
        //     MPLayout.put(view: headerView, overOf: fooView).isActive = true
        
        //Add Body
        let dataBody = BodyData(text: "Aca va el texto del body")
        let componentBody = BodyComponent(data: dataBody)
        let rendererBody = BodyRenderer()
        let bodyView = rendererBody.render(body: componentBody)
        contentView.addSubview(bodyView)
        bodyView.translatesAutoresizingMaskIntoConstraints = false
        MPLayout.equalizeWidth(view: bodyView, to: contentView).isActive = true
        MPLayout.put(view: bodyView, onBottomOf: headerView).isActive = true
        MPLayout.put(view: bodyView, overOf: fooView).isActive = true
        
        
        self.view.layoutIfNeeded()
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        if self.navigationController != nil && self.navigationController?.navigationBar != nil {
            self.navigationController?.setNavigationBarHidden(true, animated: false)
            ViewUtils.addStatusBar(self.view, color: viewModel.primaryResultColor())
        }
        renderViews()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    



}
