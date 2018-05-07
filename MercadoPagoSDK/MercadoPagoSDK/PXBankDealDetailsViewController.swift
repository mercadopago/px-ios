//
//  PXBankDealDetailsViewController.swift
//  MercadoPagoSDK
//
//  Created by AUGUSTO COLLERONE ALFONSO on 24/4/18.
//  Copyright © 2018 MercadoPago. All rights reserved.
//

import UIKit

class PXBankDealDetailsViewController: PXComponentContainerViewController {

    fileprivate let CELL_CONTENT_HEIGHT: CGFloat = 128
    fileprivate let CELL_HEIGHT: CGFloat = 190

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
extension PXBankDealDetailsViewController {

    fileprivate func setupUI() {
        self.title = "[TRADUCIR] Condiciones"
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
        self.view.isUserInteractionEnabled = true

        //Promotion Cell
        let cellContainer = PXComponentView()
        let promotionCellView = buildPromotionCellView()
        cellContainer.backgroundColor = promotionCellView.backgroundColor
        cellContainer.addSubview(promotionCellView)
        PXLayout.setHeight(owner: promotionCellView, height: CELL_CONTENT_HEIGHT).isActive = true
        PXLayout.matchWidth(ofView: promotionCellView).isActive = true
        PXLayout.centerHorizontally(view: promotionCellView).isActive = true
        PXLayout.centerVertically(view: promotionCellView).isActive = true
        self.contentView.addSubviewToBottom(cellContainer)
        PXLayout.matchWidth(ofView: cellContainer).isActive = true
        PXLayout.centerHorizontally(view: cellContainer).isActive = true
        PXLayout.setHeight(owner: cellContainer, height: CELL_HEIGHT).isActive = true


        //Legals
        if let legalsText = self.viewModel.getLegalsText() {
            let legalsContainer = PXComponentView()
            let legalsTextView = buildLegalTextView(text: legalsText)
            self.contentView.addSubviewToBottom(legalsTextView, withMargin: PXLayout.S_MARGIN)
            PXLayout.matchWidth(ofView: legalsTextView).isActive = true
            PXLayout.centerHorizontally(view: legalsTextView).isActive = true
        }

        self.contentView.layoutIfNeeded()
        super.refreshContentViewSize()
    }
}

// MARK: Component Builders
extension PXBankDealDetailsViewController {
    fileprivate func buildPromotionCellView() -> UIView {
        let component = self.viewModel.getPromotionCellComponent()
        let view = component.render()
        return view
    }

    fileprivate func buildLegalTextView(text: String) -> UIView {
        let legalsTextView = UITextView()
        legalsTextView.translatesAutoresizingMaskIntoConstraints = false
        legalsTextView.text = text
        legalsTextView.font = Utils.getFont(size: PXLayout.XXXS_FONT)
        legalsTextView.textColor = UIColor.UIColorFromRGB(0x999999)
        legalsTextView.backgroundColor = .clear
        legalsTextView.isScrollEnabled = false
        return legalsTextView
    }
}

