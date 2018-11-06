//
//  PXOneTapInstallmentInfoView.swift
//  MercadoPagoSDK
//
//  Created by Juan sebastian Sanzone on 15/10/18.
//

import UIKit

final class PXOneTapInstallmentInfoView: PXComponentView {
    static let DEFAULT_ROW_HEIGHT: CGFloat = 50
    private let titleLabel = UILabel()
    private let colapsedTag: Int = 2
    private var arrowImage: UIImageView = UIImageView()
    private var pagerView = FSPagerView(frame: .zero)
    private var tapEnabled = true

    weak var delegate: PXOneTapInstallmentInfoViewProtocol?
    var model: [PXOneTapInstallmentInfoViewModel]? {
        didSet {
            pagerView.reloadData()
        }
    }
}

// MARK: Privates
extension PXOneTapInstallmentInfoView {
    private func setupTitleLabel() {
        titleLabel.alpha = 0
        titleLabel.translatesAutoresizingMaskIntoConstraints = false
        titleLabel.text = "Selecciona la cuota".localized
        titleLabel.textAlignment = .left
        titleLabel.font = Utils.getFont(size: PXLayout.XS_FONT)
        titleLabel.textColor = ThemeManager.shared.greyColor()
        addSubview(titleLabel)

        PXLayout.matchHeight(ofView: titleLabel).isActive = true
        PXLayout.centerVertically(view: titleLabel).isActive = true
        PXLayout.pinLeft(view: titleLabel, withMargin: PXLayout.L_MARGIN).isActive = true
        PXLayout.pinRight(view: titleLabel, withMargin: PXLayout.L_MARGIN).isActive = true
    }

    private func setupSlider() {
        addSubview(pagerView)
        pagerView.isUserInteractionEnabled = false
        PXLayout.pinTop(view: pagerView).isActive = true
        PXLayout.pinBottom(view: pagerView).isActive = true
        PXLayout.pinLeft(view: pagerView).isActive = true
        PXLayout.pinRight(view: pagerView).isActive = true
        PXLayout.matchWidth(ofView: pagerView).isActive = true
        pagerView.dataSource = self
        pagerView.delegate = self
        pagerView.register(FSPagerViewCell.self, forCellWithReuseIdentifier: "cell")
        pagerView.isInfinite = false
        pagerView.automaticSlidingInterval = 0
        pagerView.bounces = true
        pagerView.interitemSpacing = 0
        pagerView.decelerationDistance = 1
        pagerView.itemSize = CGSize(width: PXCardSliderSizeManager.getItemSize().width, height: PXOneTapInstallmentInfoView.DEFAULT_ROW_HEIGHT)
    }
}

// MARK: DataSource
extension PXOneTapInstallmentInfoView: FSPagerViewDataSource {
    func numberOfItems(in pagerView: FSPagerView) -> Int {
        guard let model = model else { return 0 }
        return model.count
    }

    func pagerView(_ pagerView: FSPagerView, cellForItemAt index: Int) -> FSPagerViewCell {
        let cell = pagerView.dequeueReusableCell(withReuseIdentifier: "cell", at: index)

        guard let model = model else {return FSPagerViewCell()}

        let itemModel = model[index]
        cell.removeAllSubviews()

        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.attributedText = itemModel.text
        label.textAlignment = .left
        cell.addSubview(label)
        PXLayout.pinLeft(view: label, withMargin: PXLayout.S_MARGIN).isActive = true
        PXLayout.pinRight(view: label, withMargin: PXLayout.S_MARGIN).isActive = true
        PXLayout.centerVertically(view: label).isActive = true
        PXLayout.matchHeight(ofView: label).isActive = true
        return cell
    }
}

// MARK: Delegate
extension PXOneTapInstallmentInfoView: FSPagerViewDelegate {
    private func getCurrentIndex() -> Int? {
        if let mModel = model, mModel.count > 0 {
            let scrollOffset = pagerView.scrollOffset
            let floorOffset = floor(scrollOffset)
            return Int(floorOffset)
        } else {
            return nil
        }
    }

    func didEndDecelerating() {
        enableTap()
    }

    func pagerViewDidScroll(_ pagerView: FSPagerView) {
        disableTap()
        if let currentIndex = getCurrentIndex() {
            let newAlpha = 1 - (pagerView.scrollOffset - CGFloat(integerLiteral: currentIndex))
            if newAlpha < 0.5 {
                pagerView.alpha = 1 - newAlpha
            } else {
                pagerView.alpha = newAlpha
            }
        }
    }
}

// MARK: Publics
extension PXOneTapInstallmentInfoView {
    func getActiveRowIndex() -> Int {
        return pagerView.currentIndex
    }

    func disableTap() {
        tapEnabled = false
    }

    func enableTap() {
        tapEnabled = true
    }

    func render() {
        removeAllSubviews()
        setupSlider()
        setupFadeImages()
        setupChevron()
        setupTitleLabel()
        PXLayout.setHeight(owner: self, height: PXOneTapInstallmentInfoView.DEFAULT_ROW_HEIGHT).isActive = true
        addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(toggleInstallments)))
    }

    func setupChevron() {
        addSubview(arrowImage)
        arrowImage.contentMode = UIViewContentMode.scaleAspectFit
        arrowImage.image = ResourceManager.shared.getImage("oneTapDownArrow")
        PXLayout.centerVertically(view: arrowImage).isActive = true
        PXLayout.setWidth(owner: arrowImage, width: 14).isActive = true
        PXLayout.setHeight(owner: arrowImage, height: 14).isActive = true
        PXLayout.pinRight(view: arrowImage, withMargin: PXLayout.M_MARGIN + PXLayout.XXXS_MARGIN).isActive = true
        arrowImage.tag = colapsedTag

        if let targetModel = model?.first, !targetModel.shouldShow {
            hideArrow()
        }
    }

    func setupFadeImages() {
        let leftImage = ResourceManager.shared.getImage("one-tap-installments-info-left")
        let leftImageView = UIImageView(image: leftImage)
        leftImageView.translatesAutoresizingMaskIntoConstraints = false
        addSubview(leftImageView)
        PXLayout.pinTop(view: leftImageView).isActive = true
        PXLayout.pinBottom(view: leftImageView).isActive = true
        PXLayout.pinLeft(view: leftImageView).isActive = true
        PXLayout.setWidth(owner: leftImageView, width: 16).isActive = true

        let rightImage = ResourceManager.shared.getImage("one-tap-installments-info-right")
        let rightImageView = UIImageView(image: rightImage)
        rightImageView.translatesAutoresizingMaskIntoConstraints = false
        addSubview(rightImageView)
        PXLayout.pinTop(view: rightImageView).isActive = true
        PXLayout.pinBottom(view: rightImageView).isActive = true
        PXLayout.pinRight(view: rightImageView).isActive = true
        PXLayout.setWidth(owner: rightImageView, width: 60).isActive = true
    }

    func showArrow(duration: Double = 0.5) {
        animateArrow(alpha: 1, duration: duration)
    }

    func hideArrow(duration: Double = 0.5) {
        animateArrow(alpha: 0, duration: duration)
    }

    func animateArrow(alpha: CGFloat, duration: Double) {
        var pxAnimator = PXAnimator(duration: duration, dampingRatio: 1)
        pxAnimator.addAnimation(animation: { [weak self] in
            self?.arrowImage.alpha = alpha
        })

        pxAnimator.animate()
    }

    func setSliderOffset(offset: CGPoint) {
        pagerView.scrollToOffset(offset, animated: false)
    }

    @objc func toggleInstallments() {
        if let currentIndex = getCurrentIndex(), let currentModel = model, tapEnabled, currentModel.indices.contains(currentIndex), currentModel[currentIndex].shouldShow  {
            if let installmentData = currentModel[currentIndex].installmentData {
                if arrowImage.tag != colapsedTag {
                    delegate?.hideInstallments()
                    UIView.animate(withDuration: 0.3) { [weak self] in
                        self?.arrowImage.transform = CGAffineTransform.identity
                        self?.pagerView.alpha = 1
                        self?.titleLabel.alpha = 0
                    }
                    arrowImage.tag = colapsedTag
                } else {
                    delegate?.showInstallments(installmentData: installmentData, selectedPayerCost: currentModel[currentIndex].selectedPayerCost)
                    UIView.animate(withDuration: 0.3) { [weak self] in
                        self?.arrowImage.transform = CGAffineTransform(rotationAngle: CGFloat(Double.pi))
                        self?.pagerView.alpha = 0
                        self?.titleLabel.alpha = 1
                    }
                    arrowImage.tag = 1
                }
            }
        }
    }
}
