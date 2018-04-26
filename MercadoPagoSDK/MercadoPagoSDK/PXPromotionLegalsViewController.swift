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
        let promotionCellView = buildPromotionCellView()
        self.contentView.addSubviewToBottom(promotionCellView)
        PXLayout.matchWidth(ofView: promotionCellView).isActive = true
        PXLayout.centerHorizontally(view: promotionCellView).isActive = true
        PXLayout.setHeight(owner: promotionCellView, height: 190).isActive = true

        //CFT
        if self.viewModel.shouldShowCFT() {
            let containerView = UIView()
            containerView.translatesAutoresizingMaskIntoConstraints = false
            containerView.backgroundColor = UIColor.UIColorFromRGB(0xf7f7f7)
            let cftView = buildCFTView()
            cftView.addSeparatorLineToBottom(height: 1, horizontalMarginPercentage: 90, color: UIColor.UIColorFromRGB(0xe3e0e0))
            containerView.addSubview(cftView)
            PXLayout.matchWidth(ofView: cftView).isActive = true
            PXLayout.centerHorizontally(view: cftView).isActive = true
            PXLayout.pinBottom(view: cftView).isActive = true
            self.contentView.addSubviewToBottom(containerView)
            PXLayout.centerHorizontally(view: containerView).isActive = true
            PXLayout.matchWidth(ofView: containerView).isActive = true
            PXLayout.setHeight(owner: containerView, height: 70).isActive = true
        }
        //Legals
        if let legalsText = self.viewModel.getLegalsText() {
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
extension PXPromotionLegalsViewController {
    fileprivate func buildPromotionCellView() -> UIView {
        let component = self.viewModel.getPromotionCellComponent()
        let view = component.render()
        return view
    }

    fileprivate func buildCFTView() -> UIView {
        let value = self.viewModel.getCFTValue()
        let view = PXCFTComponentView(withCFTValue: value, titleColor: UIColor.UIColorFromRGB(0x616161), backgroundColor: UIColor.UIColorFromRGB(0xf7f7f7))
        return view
    }

    fileprivate func buildLegalTextView(text: String) -> UIView {
        let legalsTextView = UITextView()
        legalsTextView.translatesAutoresizingMaskIntoConstraints = false
        legalsTextView.text = text
        legalsTextView.font = Utils.getFont(size: PXLayout.XXXS_FONT)
        legalsTextView.textColor = UIColor.UIColorFromRGB(0x999999)
        legalsTextView.backgroundColor = UIColor.UIColorFromRGB(0xf7f7f7)
        legalsTextView.isScrollEnabled = false
        return legalsTextView

//
//        let legalsLabel = UILabel()
//        legalsLabel.translatesAutoresizingMaskIntoConstraints = false
//        legalsLabel.text = text
//        legalsLabel.backgroundColor = UIColor.UIColorFromRGB(0xf7f7f7)
//        legalsLabel.textColor = UIColor.UIColorFromRGB(0x999999)
//        legalsLabel.numberOfLines = 0
//        legalsLabel.font = Utils.getFont(size: PXLayout.XXXS_FONT)
//        return legalsLabel
    }
}

