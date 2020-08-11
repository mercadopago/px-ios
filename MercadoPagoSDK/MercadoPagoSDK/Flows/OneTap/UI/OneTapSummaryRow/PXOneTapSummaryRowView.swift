//
//  PXOneTapSummaryRowView.swift
//  MercadoPagoSDK
//
//  Created by AUGUSTO COLLERONE ALFONSO on 18/12/2018.
//

import UIKit

class PXOneTapSummaryRowView: UIView {

    typealias Handler = () -> Void

    enum RowType {
        case discount
        case charges
        case generic
    }

    static let DEFAULT_HEIGHT: CGFloat = 16
    static let TOTAL_ROW_DEFAULT_HEIGHT: CGFloat = 52
    static let MARGIN: CGFloat = 8
    private var data: PXOneTapSummaryRowData
    private var titleLabel: UILabel?
    private var iconImageView: UIImageView?
    private var valueLabel: UILabel?
    private var discountIcon: UIImageView?
    private var verStackView: UIStackView?
    var overviewBrief: UILabel?
    var heightConstraint = NSLayoutConstraint()
    var valueLabelTopConstraint = NSLayoutConstraint()
    var valueLabelCenterYConstraint = NSLayoutConstraint()

    init(data: PXOneTapSummaryRowData) {
        self.data = data
        super.init(frame: CGRect.zero)
        render()
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    open func getData() -> PXOneTapSummaryRowData {
        return data
    }

    func getTotalHeightNeeded() -> CGFloat {
        return getRowHeight() + getRowMargin()
    }

    open func getRowMargin() -> CGFloat {
        return data.isTotal ? PXLayout.ZERO_MARGIN : PXLayout.XXS_MARGIN
    }

    open func getRowHeight() -> CGFloat {
        if data.isTotal {
            return !UIDevice.isSmallDevice() ? PXOneTapSummaryRowView.TOTAL_ROW_DEFAULT_HEIGHT : PXOneTapSummaryRowView.TOTAL_ROW_DEFAULT_HEIGHT - 4
        } else {
            return data.rowHasBrief() ? PXOneTapSummaryRowView.DEFAULT_HEIGHT * 3 : PXOneTapSummaryRowView.DEFAULT_HEIGHT
        }
    }

    func update(_ newData: PXOneTapSummaryRowData) {
        self.data = newData
        self.updateUI(animated: true)
    }

    private func updateUI(animated: Bool = false) {
        if animated {
            titleLabel?.fadeTransition(0.5)
            iconImageView?.fadeTransition(0.5)
            valueLabel?.fadeTransition(0.5)
        }

        titleLabel?.alpha = data.alpha
        valueLabel?.alpha = data.alpha
        if data.discountOverview == nil {
            clearDiscountIcon()
            clearOverviewBrief()

            titleLabel?.text = data.title
            titleLabel?.textColor = data.highlightedColor
            titleLabel?.font = data.isTotal ? UIFont.ml_regularSystemFont(ofSize: PXLayout.S_FONT) : UIFont.ml_regularSystemFont(ofSize: PXLayout.XXS_FONT)

            if iconImageView == nil, data.image != nil {
                buildAndAddIconImageView()
            }
            iconImageView?.image = data.image
            iconImageView?.isHidden = data.image == nil

            valueLabel?.text = data.value
            valueLabel?.textColor = data.highlightedColor
            valueLabel?.font = data.isTotal ? UIFont.ml_semiboldSystemFont(ofSize: PXLayout.S_FONT) : UIFont.ml_regularSystemFont(ofSize: PXLayout.XXS_FONT)
        } else {
            clearIconImageView()
            titleLabel?.attributedText = data.getDescriptionText()
            if verStackView == nil {
                buildDiscountRow()
            } else if let verStackView = verStackView {
                if data.rowHasBrief(), let overviewBrief = overviewBrief {
                    overviewBrief.attributedText = data.getBriefText()
                } else {
                    if let url = data.getIconUrl(), discountIcon?.image == nil {
                        let icon = buildDiscountIcon()
                        discountIcon?.setRemoteImage(imageUrl: url)
                        let horStackview = verStackView.subviews.first as? UIStackView
                        let iconContainer = horStackview?.subviews.last
                        iconContainer?.addSubview(icon)
                        if let iconContainer = iconContainer {
                            NSLayoutConstraint.activate([
                                icon.leadingAnchor.constraint(equalTo: iconContainer.leadingAnchor, constant: 7),
                                icon.bottomAnchor.constraint(equalTo: iconContainer.bottomAnchor, constant: 1),
                                icon.heightAnchor.constraint(equalToConstant: 16),
                                icon.widthAnchor.constraint(equalToConstant: 16)
                            ])
                        }
                    }
                    if data.rowHasBrief(), overviewBrief == nil {
                        buildAndAddBrief()
                    } else if !data.rowHasBrief() {
                        // discounts row with brief to discounts row without brief
                        clearOverviewBrief()
                    }
                }
            }

            if let url = data.getIconUrl() {
                discountIcon?.setRemoteImage(imageUrl: url)
            }
            if let valueLabel = valueLabel {
                valueLabel.attributedText = data.getAmountText()
                valueLabelCenterYConstraint.isActive = false
                valueLabelTopConstraint = valueLabel.topAnchor.constraint(equalTo: topAnchor)
                valueLabelTopConstraint.isActive = true
            }
        }
        setAccessibility(data)
    }

    private func render() {
        removeAllSubviews()
        let rowHeight = getRowHeight()
        let titleFont = data.isTotal ? UIFont.ml_regularSystemFont(ofSize: PXLayout.S_FONT) : UIFont.ml_regularSystemFont(ofSize: PXLayout.XXS_FONT)
        let valueFont = data.isTotal ? UIFont.ml_semiboldSystemFont(ofSize: PXLayout.S_FONT) : UIFont.ml_regularSystemFont(ofSize: PXLayout.XXS_FONT)
        let shouldAnimate = data.isTotal ? false : true

        if data.isTotal {
            self.backgroundColor = ThemeManager.shared.navigationBar().backgroundColor
        }

        self.translatesAutoresizingMaskIntoConstraints = false
        self.pxShouldAnimatedOneTapRow = shouldAnimate

        let titleLabel = UILabel()
        self.titleLabel = titleLabel
        titleLabel.textAlignment = .left

        let valueLabel = UILabel()
        self.valueLabel = valueLabel
        valueLabel.translatesAutoresizingMaskIntoConstraints = false
        valueLabel.textAlignment = .right
        addSubview(valueLabel)
        PXLayout.pinRight(view: valueLabel, withMargin: PXLayout.L_MARGIN).isActive = true

        if data.discountOverview == nil {
            titleLabel.translatesAutoresizingMaskIntoConstraints = false
            titleLabel.text = data.title
            titleLabel.font = titleFont
            addSubview(titleLabel)
            PXLayout.pinLeft(view: titleLabel, withMargin: PXLayout.L_MARGIN).isActive = true
            PXLayout.centerVertically(view: titleLabel).isActive = true

            buildAndAddIconImageView()

            valueLabel.text = data.value
            valueLabel.font = valueFont
            valueLabelCenterYConstraint = PXLayout.centerVertically(view: valueLabel)
        } else {
            buildDiscountRow()
        }

        heightConstraint = PXLayout.setHeight(owner: self, height: rowHeight)
        isAccessibilityElement = true
        let rowValue = valueLabel.text?.replacingOccurrences(of: "$", with: "") ?? ""
        accessibilityLabel = "\(titleLabel.text ?? "")" + "\(rowValue)" + "pesos".localized
        updateUI()
    }
}

// MARK: Publics
extension PXOneTapSummaryRowView {
    func briefHasOneLine() -> Bool {
        guard let brief = overviewBrief else { return false }
        return brief.intrinsicContentSize.height < PXOneTapSummaryRowView.DEFAULT_HEIGHT ? true : false
    }

    func briefNumberOfLines() -> Int {
        guard let brief = overviewBrief else { return 0 }
        return brief.intrinsicContentSize.height < PXOneTapSummaryRowView.DEFAULT_HEIGHT ? 1 : 2
    }

    func updateHeightConstraint() {
        layoutIfNeeded()
        if !data.rowHasBrief() {
            heightConstraint.constant = PXOneTapSummaryRowView.DEFAULT_HEIGHT
        } else if briefNumberOfLines() == 1 {
            heightConstraint.constant = PXOneTapSummaryRowView.DEFAULT_HEIGHT * 2
        } else if briefNumberOfLines() == 2 {
            heightConstraint.constant = PXOneTapSummaryRowView.DEFAULT_HEIGHT * 3
        }
    }
}

// MARK: Discount row
private extension PXOneTapSummaryRowView {
    func buildDiscountRow() {
        // Overview description
        if let titleLabel = titleLabel {
            titleLabel.attributedText = data.getDescriptionText()
            let verStackView = UIStackView()
            self.verStackView = verStackView
            verStackView.translatesAutoresizingMaskIntoConstraints = false
            verStackView.axis = .vertical
            addSubview(verStackView)
            NSLayoutConstraint.activate([
                titleLabel.heightAnchor.constraint(equalToConstant: 16),
                verStackView.topAnchor.constraint(equalTo: topAnchor),
                verStackView.leadingAnchor.constraint(equalTo: leadingAnchor, constant: PXLayout.L_MARGIN),
                verStackView.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -100),
                verStackView.bottomAnchor.constraint(equalTo: bottomAnchor)
            ])

            let horStackview = UIStackView()
            horStackview.translatesAutoresizingMaskIntoConstraints = false
            horStackview.axis = .horizontal
            horStackview.addArrangedSubview(titleLabel)

            // Overview Info icon
            if data.rowHasInfoIcon() {
                let icon = buildDiscountIcon()
                let iconContainer = UIView()
                iconContainer.addSubview(icon)
                NSLayoutConstraint.activate([
                    icon.leadingAnchor.constraint(equalTo: iconContainer.leadingAnchor, constant: 7),
                    icon.bottomAnchor.constraint(equalTo: iconContainer.bottomAnchor, constant: 1),
                    icon.heightAnchor.constraint(equalToConstant: 16),
                    icon.widthAnchor.constraint(equalToConstant: 16)
                ])
                horStackview.addArrangedSubview(iconContainer)
            }
            verStackView.addArrangedSubview(horStackview)

            // Overview brief
            if data.rowHasBrief() {
                buildAndAddBrief()
            }

            // Overview amount
            if let valueLabel = valueLabel {
                valueLabel.attributedText = data.getAmountText()
                valueLabelTopConstraint = valueLabel.topAnchor.constraint(equalTo: topAnchor)
                valueLabelTopConstraint.isActive = true
            }
        }
    }

    func buildAndAddBrief() {
        let brief = UILabel()
        overviewBrief = brief
        brief.translatesAutoresizingMaskIntoConstraints = false
        brief.textAlignment = .left
        brief.numberOfLines = 2
        brief.attributedText = data.getBriefText()

        let containerView = UIView()
        containerView.addSubview(brief)
        if let verStackView = verStackView {
            verStackView.addArrangedSubview(containerView)
        }
        NSLayoutConstraint.activate([
            brief.leadingAnchor.constraint(equalTo: containerView.leadingAnchor),
            brief.trailingAnchor.constraint(equalTo: containerView.trailingAnchor),
            brief.topAnchor.constraint(equalTo: containerView.topAnchor, constant: 5)
        ])
    }

    func buildDiscountIcon() -> UIImageView {
        let icon = UIImageView()
        discountIcon = icon
        icon.translatesAutoresizingMaskIntoConstraints = false
        icon.contentMode = .scaleAspectFit
        icon.backgroundColor = .clear
        icon.clipsToBounds = true
        return icon
    }

    func clearDiscountIcon() {
        discountIcon?.removeFromSuperview()
        discountIcon = nil
    }

    func clearIconImageView() {
        iconImageView?.removeFromSuperview()
        iconImageView = nil
    }

    func clearOverviewBrief() {
        overviewBrief = nil
        if let verStackView = verStackView, verStackView.subviews.count == 2 {
            verStackView.subviews.last?.removeFromSuperview()
        }
    }

    func buildAndAddIconImageView() {
        let imageView: UIImageView = UIImageView()
        self.iconImageView = imageView
        let imageSize: CGFloat = 16
        imageView.contentMode = .scaleAspectFit
        addSubview(imageView)
        PXLayout.setWidth(owner: imageView, width: imageSize).isActive = true
        PXLayout.setHeight(owner: imageView, height: imageSize).isActive = true
        PXLayout.centerVertically(view: imageView, to: titleLabel).isActive = true
        if let titleLabel = titleLabel {
            PXLayout.put(view: imageView, rightOf: titleLabel, withMargin: PXLayout.XXXS_MARGIN).isActive = true
        }
    }
}

// MARK: Accessibility
private extension PXOneTapSummaryRowView {
    func setAccessibility(_ data: PXOneTapSummaryRowData) {
        let rowValue = data.value.replacingOccurrences(of: "$", with: "").replacingOccurrences(of: ".", with: "") + "pesos".localized
        if verStackView == nil {
            accessibilityLabel = "\(data.title)" + "\(rowValue)"
        } else if let title = data.getDescriptionText() {
                var accessibilityString = "\(title.string.replacingOccurrences(of: "(", with: "").replacingOccurrences(of: ")", with: "").replacingOccurrences(of: ":", with: ""))"
                if accessibilityString.contains("$") {
                    accessibilityString = accessibilityString.replacingOccurrences(of: "$", with: "") + "pesos".localized
                }
                accessibilityLabel = accessibilityString + rowValue
            } else {
                accessibilityLabel = "\(data.title)" + "\(rowValue)"
        }
    }
}
