//
//  PXPromotionLegalsViewController.swift
//  MercadoPagoSDK
//
//  Created by AUGUSTO COLLERONE ALFONSO on 24/4/18.
//  Copyright © 2018 MercadoPago. All rights reserved.
//

import UIKit

class PXPromotionLegalsViewController: PXComponentContainerViewController {

    fileprivate var viewModel: PXPromotionLegalsViewModel!

    init(viewModel: PXPromotionLegalsViewModel) {
        self.viewModel = viewModel
        super.init()
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        setupUI()
        self.scrollView.showsVerticalScrollIndicator = false
        self.scrollView.showsHorizontalScrollIndicator = false
        self.view.layoutIfNeeded()
    }
}

// MARK: UI Methods
extension PXPromotionLegalsViewController {

    fileprivate func setupUI() {
        self.title = "Banco Hiportecario"
        navBarTextColor = ThemeManager.shared.getTitleColorForReviewConfirmNavigation()
        loadMPStyles()
        navigationController?.navigationBar.barTintColor = ThemeManager.shared.getTheme().highlightBackgroundColor()
        navigationItem.leftBarButtonItem?.tintColor = ThemeManager.shared.getTitleColorForReviewConfirmNavigation()
        if contentView.getSubviews().isEmpty {
            renderViews()
        }
    }

    fileprivate func renderViews() {
        self.contentView.prepareForRender()

        //Promotion Cell
        let promotionCellView = buildPromotionCellView()
        self.contentView.addSubviewToBottom(promotionCellView)
        PXLayout.matchWidth(ofView: promotionCellView).isActive = true
        PXLayout.centerHorizontally(view: promotionCellView).isActive = true
        PXLayout.setHeight(owner: promotionCellView, height: 190).isActive = true

//        let bankDeal = self.viewModel.bankDeals[0]
//
//        let image = MercadoPago.getImage("financial_institution_1001")
//        let cellProps = PXPromotionCellProps(image: image, title: "12 cuotas sin interés", subtitle: "Hasta el 30/jun/2017")
//        let cellComponent = PXPromotionCell(props: cellProps)
//        let cellView = cellComponent.render()
//        cellView.layer.borderWidth = 2
//        self.contentView.addSubviewToBottom(cellView, withMargin: 0)
//        PXLayout.matchWidth(ofView: cellView).isActive = true
//        PXLayout.setHeight(owner: cellView, height: 190).isActive = true
//        PXLayout.centerHorizontally(view: cellView).isActive = true


        //CFT
        if 0 == 0 {
            let cftView = PXCFTComponentView(withCFTValue: "82%", titleColor: UIColor.UIColorFromRGB(0x616161), backgroundColor: UIColor.UIColorFromRGB(0xf7f7f7))
            cftView.addSeparatorLineToBottom(height: 1, horizontalMarginPercentage: 90, color: UIColor.UIColorFromRGB(0xe3e0e0))
            self.contentView.addSubviewToBottom(cftView, withMargin: PXLayout.L_MARGIN)
            PXLayout.centerHorizontally(view: cftView).isActive = true
            PXLayout.matchWidth(ofView: cftView).isActive = true
            PXLayout.setHeight(owner: cftView, height: 135).isActive = true
        }
        //Legals
        if let legalsText = self.viewModel.getLegalsText() {
            let legalsTextView = UITextView()
            legalsTextView.translatesAutoresizingMaskIntoConstraints = false
            legalsTextView.text = legalsText
            legalsTextView.font = Utils.getFont(size: PXLayout.XXXS_FONT)
            legalsTextView.textColor = UIColor.UIColorFromRGB(0x999999)
            legalsTextView.backgroundColor = UIColor.UIColorFromRGB(0xf7f7f7)
            legalsTextView.isScrollEnabled = true
            self.contentView.addSubviewToBottom(legalsTextView)
            PXLayout.matchWidth(ofView: legalsTextView).isActive = true
            PXLayout.setHeight(owner: legalsTextView, height: 242).isActive = true
            //        PXLayout.pinBottom(view: legalsTextView).isActive = true
            PXLayout.centerHorizontally(view: legalsTextView).isActive = true
        }



//        // Add Collection View
//        for bankDeal in self.viewModel.bankDeals {
//            let uiv = UIView()
//            PXLayout.setHeight(owner: uiv, height: 50).isActive = true
//            PXLayout.setWidth(owner: uiv, width: 50).isActive = true
//            uiv.backgroundColor = .red
//
//            let image = MercadoPago.getImage("mediosIconoMaster")
//            let cellProps = PXPromotionCellProps(image: image, title: "12 cuotas sin interés", subtitle: "Hasta el 30/jun/2017")
//            let cellComponent = PXPromotionCell(props: cellProps)
//            let cellView = cellComponent.render()
//            cellView.translatesAutoresizingMaskIntoConstraints = false
//            PXLayout.setWidth(owner: cellView, width: 150).isActive = true
//            PXLayout.setHeight(owner: cellView, height: 150).isActive = true
//            self.contentView.addSubviewToBottom(cellView)
//            PXLayout.centerHorizontally(view: cellView).isActive = true
//
//        }


        //        let props = PXCollectionRowProps(view1: cellView, view2: cellView)
        //        let compo = PXCollectionRow(props: props)
        //        let view = compo.render()
        //        contentView.addSubview(view)
        //        PXLayout.matchWidth(ofView: view, withPercentage: 100).isActive = true
        //        PXLayout.centerHorizontally(view: view).isActive = true
        //        PXLayout.setHeight(owner: view, height: 280).isActive = true
    }
}

// MARK: Component Builders
extension PXPromotionLegalsViewController {
    fileprivate func buildPromotionCellView() -> UIView {
        let component = self.viewModel.getPromotionCellComponent()
        let view = component.render()
        return view
    }
}

