//
//  PXPromotionsViewController.swift
//  MercadoPagoSDK
//
//  Created by AUGUSTO COLLERONE ALFONSO on 23/4/18.
//  Copyright © 2018 MercadoPago. All rights reserved.
//

import UIKit

class PXPromotionsViewController: PXComponentContainerViewController {

    fileprivate var viewModel: PXPromotionsViewModel!

    init(viewModel: PXPromotionsViewModel) {
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
extension PXPromotionsViewController {

    fileprivate func setupUI() {
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

        // Add Collection View
        for bankDeal in self.viewModel.bankDeals {
            let uiv = UIView()
            PXLayout.setHeight(owner: uiv, height: 50).isActive = true
            PXLayout.setWidth(owner: uiv, width: 50).isActive = true
            uiv.backgroundColor = .red
                
            let image = MercadoPago.getImage("mediosIconoMaster")
            let cellProps = PXPromotionCellProps(image: image, title: "12 cuotas sin interés", subtitle: "Hasta el 30/jun/2017")
            let cellComponent = PXPromotionCell(props: cellProps)
            let cellView = cellComponent.render()
            cellView.translatesAutoresizingMaskIntoConstraints = false
            PXLayout.setWidth(owner: cellView, width: 150).isActive = true
            PXLayout.setHeight(owner: cellView, height: 150).isActive = true
            self.contentView.addSubviewToBottom(cellView)
            PXLayout.centerHorizontally(view: cellView).isActive = true

        }


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
extension PXPromotionsViewController {

}
