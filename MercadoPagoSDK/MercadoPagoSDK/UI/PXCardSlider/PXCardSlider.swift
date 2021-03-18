//
//  PXCardSlider.swift
//
//  Created by Juan sebastian Sanzone on 12/10/18.
//

import UIKit

public protocol ChangeCardAccessibilityProtocol: NSObjectProtocol {
    func scrollTo(direction: UIAccessibilityScrollDirection)
}

protocol PXCardSliderDelegate: class {
    func indexDidChange(index: Int)
}

typealias AccessibilityCardData = (paymentMethodId: String, paymentTypeId: String, issuerName: String, description: String, cardName: String, index: Int, numberOfPages: Int)

final class PXCardSlider: NSObject {
    private var pagerView = FSPagerView(frame: .zero)
    private var pageControl = ISPageControl(frame: .zero, numberOfPages: 0)
    
    private var model: [PXCardSliderViewModel] = [] {
        didSet {
            self.pagerView.reloadData()
            self.pagerView.layoutIfNeeded()
            self.pageControl.numberOfPages = self.model.count
        }
    }
    
    private weak var delegate: PXCardSliderProtocol?
    private var selectedIndex: Int = 0 {
        didSet {
            teste?.indexDidChange(index: selectedIndex)
        }
    }
    private let cardSliderCornerRadius: CGFloat = 11
    weak var termsAndCondDelegate: PXTermsAndConditionViewDelegate?
    weak var teste: PXCardSliderDelegate?

    override init() {
        super.init()
        pagerView.accessibilityDelegate = self
    }
}

// MARK: DataSource
extension PXCardSlider: FSPagerViewDataSource {
    func numberOfItems(in pagerView: FSPagerView) -> Int {
        return model.count
    }

    func pagerView(_ pagerView: FSPagerView, cellForItemAt index: Int) -> FSPagerViewCell {
        if model.indices.contains(index) {
            let targetModel = model[index]
            var accessibilityData = AccessibilityCardData(paymentMethodId: "", paymentTypeId: "", issuerName: "", description: "", cardName: "", index: 0, numberOfPages: 1)
            
            guard let selectedApplication = targetModel.selectedApplication else { return FSPagerViewCell() }

            if let payerPaymentMethod = selectedApplication.payerPaymentMethod {
                accessibilityData = AccessibilityCardData(paymentMethodId: selectedApplication.paymentMethodId, paymentTypeId: selectedApplication.paymentTypeId ?? "", issuerName: payerPaymentMethod.issuer?.name ?? "", description: payerPaymentMethod._description ?? "", cardName: selectedApplication.cardData?.name ?? "", index: index,  numberOfPages: pageControl.numberOfPages)
            }

            if selectedApplication.cardData != nil,
               let cell = pagerView.dequeueReusableCell(withReuseIdentifier: PXCardSliderPagerCell.identifier, at: index) as? PXCardSliderPagerCell {
                if targetModel.creditsViewModel != nil,
                   targetModel.cardUI is ConsumerCreditsCard {
                    cell.delegate = self
                    cell.renderConsumerCreditsCard(model: targetModel, cardSize: pagerView.itemSize, accessibilityData: accessibilityData)
                } else {
                    // AccountMoney, Hybrid and Other cards.
                    if let _ = targetModel.cardUI as? AccountMoneyCard {
                        cell.render(model: targetModel, cardSize: pagerView.itemSize, accessibilityData: accessibilityData, clearCardData: true, delegate: self)
                    } else if let _ = targetModel.cardUI as? HybridAMCard {
                        cell.render(model: targetModel, cardSize: pagerView.itemSize, accessibilityData: accessibilityData, clearCardData: true, delegate: self)
                    } else {
                        cell.render(model: targetModel, cardSize: pagerView.itemSize, accessibilityData: accessibilityData, delegate: self)
                    }
                }
                return cell
            } else {
                // Add new card scenario.
                if let cell = pagerView.dequeueReusableCell(withReuseIdentifier: PXCardSliderPagerCell.identifier, at: index) as? PXCardSliderPagerCell {

                    var newCardData: PXAddNewMethodData?
                    var newOfflineData: PXAddNewMethodData?
                    if let emptyCard = targetModel.cardUI as? EmptyCard {
                        newCardData = emptyCard.newCardData
                        newOfflineData = emptyCard.newOfflineData
                    }
                    cell.renderEmptyCard(newCardData: newCardData, newOfflineData: newOfflineData, cardSize: pagerView.itemSize, delegate: self)
                    return cell
                }
            }
        }
        return FSPagerViewCell()
    }

    func getSelectedCell() -> PXCardSliderPagerCell? {
        return pagerView.cellForItem(at: getSelectedIndex()) as? PXCardSliderPagerCell
    }

    func showBottomMessageIfNeeded(index: Int, targetIndex: Int) {
        if let currentCell = pagerView.cellForItem(at: index) as? PXCardSliderPagerCell {
            currentCell.showBottomMessageView(index == targetIndex)
        }
    }
}

// MARK: Add new methods delegate
extension PXCardSlider: PXCardSliderPagerCellDelegate {
    func addNewCard() {
        delegate?.addNewCardDidTap()
    }

    func addNewOfflineMethod() {
        delegate?.addNewOfflineDidTap()
    }

    func switchDidChange(_ selectedOption: String) {
        if model.indices.contains(selectedIndex) {
            let modelData = model[selectedIndex]
            delegate?.newCardDidSelected(targetModel: modelData)
        }
    }
}

// MARK: Delegate
extension PXCardSlider: FSPagerViewDelegate {
    func pagerViewDidScroll(_ pagerView: FSPagerView) {
        delegate?.didScroll(offset: pagerView.literalScrollOffset)
    }

    func pagerViewDidEndDecelerating(_ pagerView: FSPagerView) {
        delegate?.didEndDecelerating()
    }

    func pagerViewDidEndScrollAnimation(_ pagerView: FSPagerView) {
        delegate?.didEndScrollAnimation()
    }

    func pagerViewWillEndDragging(_ pagerView: FSPagerView, targetIndex: Int) {
        pageControl.currentPage = targetIndex
        for cellIndex in 0...model.count {
            showBottomMessageIfNeeded(index: cellIndex, targetIndex: targetIndex)
        }

        if selectedIndex != targetIndex {
            PXFeedbackGenerator.selectionFeedback()
            selectedIndex = targetIndex
            if model.indices.contains(targetIndex) {
                let modelData = model[targetIndex]
                delegate?.newCardDidSelected(targetModel: modelData)
            }
        }
    }

    func pagerView(_ pagerView: FSPagerView, didSelectItemAt index: Int) {
        if model.indices.contains(index) {
            let modelData = model[index]
            if let selectedApplication = modelData.selectedApplication {
                delegate?.cardDidTap(status: selectedApplication.status)
            }
        }
    }
}

// MARK: Publics
extension PXCardSlider {
    func render(containerView: UIView, cardSliderProtocol: PXCardSliderProtocol? = nil) {
        setupSlider(containerView)
        setupPager(containerView)
        delegate = cardSliderProtocol
    }

    func update(_ newModel: [PXCardSliderViewModel]) {
        model = newModel
    }

    func show(duration: Double = 0.5) {
        UIView.animate(withDuration: duration) { [weak self] in
            self?.pagerView.alpha = 1
            self?.pageControl.alpha = 1
        }
    }

    func hide(duration: Double = 0.5) {
        UIView.animate(withDuration: duration) { [weak self] in
            self?.pagerView.alpha = 0
            self?.pageControl.alpha = 0
        }
    }

    func getItemSize(_ containerView: UIView) -> CGSize {
        let targetWidth: CGFloat = containerView.bounds.width - PXCardSliderSizeManager.cardDeltaDecrease
        return PXCardSliderSizeManager.getGoldenRatioSize(targetWidth)
    }

    func getSelectedIndex() -> Int {
        return selectedIndex
    }
    
    func newCardDidSelected(_ index: Int) {
        if model.indices.contains(pageControl.currentPage) {
            let modelData = model[pageControl.currentPage]
            delegate?.newCardDidSelected(targetModel: modelData)
        }
    }
    
    enum PXCardSliderError: Error {
        case outOfBounds
    }
    
    func canScrollTo(index: Int) -> Bool {
        guard let dataSource = pagerView.dataSource else {
            return false
        }
        
        return (0 ..< dataSource.numberOfItems(in: pagerView)).contains(index)
    }

    func goToItemAt(index: Int, animated: Bool) throws {
        guard canScrollTo(index: index) else {
            throw PXCardSliderError.outOfBounds
        }
        pagerView.scrollToItem(at: index, animated: animated)
        pageControl.currentPage = index
        selectedIndex = index
        UIAccessibility.post(notification: .pageScrolled, argument: "\(index + 1)" + "de".localized + "\(pageControl.numberOfPages)")
    }
}

// MARK: Privates
extension PXCardSlider {
    private func setupSlider(_ containerView: UIView) {
        containerView.addSubview(pagerView)
        pagerView.accessibilityIdentifier = "card_carrousel"
        PXLayout.setHeight(owner: pagerView, height: getItemSize(containerView).height).isActive = true
        PXLayout.pinLeft(view: pagerView).isActive = true
        PXLayout.pinRight(view: pagerView).isActive = true
        PXLayout.matchWidth(ofView: pagerView).isActive = true
        PXLayout.pinTop(view: pagerView).isActive = true
        pagerView.dataSource = self
        pagerView.delegate = self
        pagerView.register(PXCardSliderPagerCell.getCell(), forCellWithReuseIdentifier: PXCardSliderPagerCell.identifier)
        pagerView.register(FSPagerViewCell.self, forCellWithReuseIdentifier: "cell")
        pagerView.isInfinite = false
        pagerView.automaticSlidingInterval = 0
        pagerView.bounces = true
        pagerView.interitemSpacing = PXCardSliderSizeManager.interItemSpace
        pagerView.decelerationDistance = 1
        pagerView.itemSize = getItemSize(containerView)
    }

    private func setupPager(_ containerView: UIView) {
        let pagerYMargin: CGFloat = PXLayout.S_MARGIN
        let pagerHeight: CGFloat = 10
        pageControl.radius = 3
        pageControl.padding = 6
        pageControl.contentHorizontalAlignment = .center
        pageControl.numberOfPages = model.count
        pageControl.currentPage = 0
        pageControl.currentPageTintColor = ThemeManager.shared.getAccentColor()
        containerView.addSubview(pageControl)
        PXLayout.pinRight(view: pageControl).isActive = true
        PXLayout.pinLeft(view: pageControl).isActive = true
        PXLayout.centerHorizontally(view: pageControl).isActive = true
        PXLayout.pinBottom(view: pageControl, to: pagerView, withMargin: -pagerYMargin).isActive = true
        PXLayout.setHeight(owner: pageControl, height: pagerHeight).isActive = true
        pageControl.layoutIfNeeded()
    }
}

extension PXCardSlider: PXTermsAndConditionViewDelegate {
    func shouldOpenTermsCondition(_ title: String, url: URL) {
        termsAndCondDelegate?.shouldOpenTermsCondition(title, url: url)
    }
}

// MARK: ChangeCardAccessibilityProtocol
extension PXCardSlider: ChangeCardAccessibilityProtocol {
    func scrollTo(direction: UIAccessibilityScrollDirection) {
        if direction == UIAccessibilityScrollDirection.left, pageControl.currentPage < pageControl.numberOfPages - 1 {
            try? goToItemAt(index: pageControl.currentPage + 1, animated: true)
        }
        else if direction == UIAccessibilityScrollDirection.right, pageControl.currentPage > 0 {
            try? goToItemAt(index: pageControl.currentPage - 1, animated: true)
        }
        newCardDidSelected(pageControl.currentPage)
    }
}
