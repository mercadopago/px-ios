//
//  PXBankDealsViewController.swift
//  MercadoPagoSDK
//
//  Created by AUGUSTO COLLERONE ALFONSO on 7/5/18.
//  Copyright © 2018 MercadoPago. All rights reserved.
//

import UIKit

class PXPromotionCollectionCell: UICollectionViewCell {

    override init(frame: CGRect) {
        super.init(frame: frame)
    }

    override func prepareForReuse() {
        for miniView in self.contentView.subviews {
            miniView.removeFromSuperview()
        }
    }
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

}

class PXBankDealsViewController: MercadoPagoUIViewController, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout, UICollectionViewDelegate {

    fileprivate let MARGINS: CGFloat = PXLayout.S_MARGIN
    fileprivate let CELL_HEIGHT: CGFloat = 128
    fileprivate let REUSE_IDENTIFIER = "bankDealCell"

    fileprivate var viewModel: PXBankDealsViewModel!

    init(viewModel: PXBankDealsViewModel) {
        super.init(nibName: nil, bundle: nil)
        self.viewModel = viewModel
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func viewDidLoad() {
        let flowLayout = UICollectionViewFlowLayout()
        flowLayout.minimumInteritemSpacing = MARGINS
        flowLayout.minimumLineSpacing = MARGINS
        let collectionView = UICollectionView(frame: self.view.bounds, collectionViewLayout: flowLayout)
        collectionView.register(PXPromotionCollectionCell.self, forCellWithReuseIdentifier: REUSE_IDENTIFIER)
        collectionView.delegate = self
        collectionView.dataSource = self
        collectionView.backgroundColor = .white
        self.view.addSubview(collectionView)
        PXLayout.matchWidth(ofView: collectionView).isActive = true
        //        PXLayout.matchHeight(ofView: collectionView).isActive = true
        PXLayout.centerHorizontally(view: collectionView).isActive = true
        //        PXLayout.centerVertically(view: collectionView).isActive = true
        PXLayout.pinTop(view: collectionView, withMargin: 100).isActive = true
        PXLayout.pinBottom(view: collectionView, withMargin: 100).isActive = true
    }

    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return self.viewModel.bankDeals.count
    }

    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: REUSE_IDENTIFIER, for: indexPath) as! PXPromotionCollectionCell
        let promotionCellView = self.buildPromotionCellView(for: indexPath)
        cell.contentView.addSubview(promotionCellView)
        PXLayout.centerHorizontally(view: promotionCellView).isActive = true
        PXLayout.centerVertically(view: promotionCellView).isActive = true
        PXLayout.matchWidth(ofView: promotionCellView).isActive = true
        PXLayout.setHeight(owner: promotionCellView, height: CELL_HEIGHT).isActive = true
        return cell
    }

    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        return getCellSize()
    }

    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, insetForSectionAt section: Int) -> UIEdgeInsets {
        return UIEdgeInsets(top: MARGINS, left: MARGINS, bottom: MARGINS, right: MARGINS)
    }

    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        let bankDeal = self.viewModel.bankDeals[indexPath.row]
        let viewModel = PXPromotionLegalsViewModel(bankDeal: bankDeal)
        let viewController = PXBankDealDetailsViewController(viewModel: viewModel)
        self.navigationController?.pushViewController(viewController, animated: true)
    }

    func getCellSize() -> CGSize {
        let screenWidth = PXLayout.getScreenWidth()
        let width: CGFloat = screenWidth/2 - MARGINS*2
        return CGSize(width: width, height: CELL_HEIGHT)
    }
}

// MARK: Component Builders
extension PXBankDealsViewController {
    fileprivate func buildPromotionCellView(for indexPath: IndexPath) -> UIView {
        let component = self.viewModel.getPromotionCellComponentForIndexPath(indexPath)
        let view = component.render()
        return view
    }
}

