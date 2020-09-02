//
//  PXNewCustomView.swift
//  MercadoPagoSDK
//
//  Created by AUGUSTO COLLERONE ALFONSO on 29/08/2019.
//

import UIKit

open class PXNewCustomViewData {
    let firstString: NSAttributedString?
    let secondString: NSAttributedString?
    let thirdString: NSAttributedString?
    let icon: UIImage?
    let iconURL: String?
    let action: PXAction?
    let color: UIColor?

    init(firstString: NSAttributedString?, secondString: NSAttributedString?, thirdString: NSAttributedString?, icon: UIImage?, iconURL: String?, action: PXAction?, color: UIColor?) {
        self.firstString = firstString
        self.secondString = secondString
        self.thirdString = thirdString
        self.icon = icon
        self.iconURL = iconURL
        self.action = action
        self.color = color
    }
}

class PXNewCustomView: UIView {

    //Row Settings
    let ROW_HEIGHT: CGFloat = 80

    //Icon
    let IMAGE_WIDTH: CGFloat = 48.0
    let IMAGE_HEIGHT: CGFloat = 48.0

    var iconView: UIView?

    let data: PXNewCustomViewData

    class func getData() -> PXNewCustomViewData {
        return PXNewCustomViewData(firstString: nil, secondString: nil, thirdString: nil, icon: nil, iconURL: nil, action: nil, color: nil)
    }

    init(data: PXNewCustomViewData, bottomView: UIView? = nil) {
        self.data = data
        super.init(frame: .zero)
        render(with: bottomView)
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    //Attributes
    static let titleAttributes: [NSAttributedString.Key: Any] = [
        NSAttributedString.Key.font: UIFont.ml_semiboldSystemFont(ofSize: PXLayout.XS_FONT),
        NSAttributedString.Key.foregroundColor: UIColor.black.withAlphaComponent(0.8)
    ]

    static let subtitleAttributes: [NSAttributedString.Key: Any] = [
        NSAttributedString.Key.font: UIFont.ml_regularSystemFont(ofSize: PXLayout.XXS_FONT),
        NSAttributedString.Key.foregroundColor: UIColor.black.withAlphaComponent(0.45)
    ]

    func render(with bottomView: UIView?) {
        removeAllSubviews()
        let pxContentView = UIView()
        pxContentView.backgroundColor = .clear
        addSubview(pxContentView)
        PXLayout.pinAllEdges(view: pxContentView, withMargin: PXLayout.ZERO_MARGIN)
        PXLayout.setHeight(owner: pxContentView, height: ROW_HEIGHT, relation: .greaterThanOrEqual).isActive = true

        //Background Color
        if let color = data.color {
            self.backgroundColor = color
        }

        // Icon
        var image: UIImage?
        if let imageURL = data.iconURL, imageURL.isNotEmpty {
            image = PXUIImage(url: imageURL)
        } else {
            image = data.icon
        }
        iconView = PXUIImageView(image: image, size: IMAGE_HEIGHT, borderColor: UIColor.black.withAlphaComponent(0.08).cgColor, shouldAddInsets: true)

        let labelsView = PXComponentView()
        labelsView.clipsToBounds = true
        pxContentView.addSubview(labelsView)

        if let circleImage = iconView {
            pxContentView.addSubview(circleImage)
            PXLayout.pinTop(view: circleImage, withMargin: PXLayout.S_MARGIN)
            PXLayout.pinLeft(view: circleImage, withMargin: PXLayout.L_MARGIN)
            // Put labels view next to the icon
            PXLayout.put(view: labelsView, rightOf: circleImage, withMargin: PXLayout.S_MARGIN)
        } else {
            // Pin labels view next to the left
            PXLayout.pinLeft(view: labelsView, withMargin: PXLayout.L_MARGIN)
        }
        PXLayout.pinRight(view: labelsView, withMargin: PXLayout.L_MARGIN)
        PXLayout.pinTop(view: labelsView, withMargin: PXLayout.S_MARGIN)

        var firstLabel: UILabel?
        if let firstString = data.firstString {
            firstLabel = buildLabel(firstString)
            if firstString.string.contains("$") {
                firstLabel?.accessibilityLabel = firstString.string.replacingOccurrences(of: "$", with: "") + "pesos".localized
            }
            if let label = firstLabel {
                pxContentView.addSubview(label)
                setTopConstraints(targetView: label, labelsView: labelsView, firstLabel: nil, secondLabel: nil, thirdLabel: nil, actionButton: nil)
                NSLayoutConstraint.activate([
                    label.leadingAnchor.constraint(equalTo: labelsView.leadingAnchor),
                    label.trailingAnchor.constraint(equalTo: labelsView.trailingAnchor)
                ])
            }
        }

        var secondLabel: UILabel?
        if let secondString = data.secondString {
            secondLabel = buildLabel(secondString)
            if let label = secondLabel {
                pxContentView.addSubview(label)
                NSLayoutConstraint.activate([
                    label.leadingAnchor.constraint(equalTo: labelsView.leadingAnchor),
                    label.trailingAnchor.constraint(equalTo: labelsView.trailingAnchor)
                ])
                setTopConstraints(targetView: label, labelsView: labelsView, firstLabel: firstLabel, secondLabel: nil, thirdLabel: nil, actionButton: nil)
            }
        }

        var thirdLabel: UILabel?
        if let thirdString = data.thirdString {
            thirdLabel = buildLabel(thirdString)
            if let label = thirdLabel {
                pxContentView.addSubview(label)
                NSLayoutConstraint.activate([
                    label.leadingAnchor.constraint(equalTo: labelsView.leadingAnchor),
                    label.trailingAnchor.constraint(equalTo: labelsView.trailingAnchor)
                ])
                setTopConstraints(targetView: label, labelsView: labelsView, firstLabel: firstLabel, secondLabel: secondLabel, thirdLabel: nil, actionButton: nil)
            }
        }

        var actionButton: UIButton?
        if let action = data.action {
            actionButton = buildButton(action)
            if let button = actionButton {
                pxContentView.addSubview(button)
                NSLayoutConstraint.activate([
                    button.leadingAnchor.constraint(equalTo: labelsView.leadingAnchor),
                    button.trailingAnchor.constraint(equalTo: labelsView.trailingAnchor),
                    button.heightAnchor.constraint(equalToConstant: 20)
                ])
                setTopConstraints(targetView: button, labelsView: labelsView, firstLabel: firstLabel, secondLabel: secondLabel, thirdLabel: thirdLabel, actionButton: nil)
            }
        }

        if let expectationView = bottomView {
            pxContentView.addSubview(expectationView)
            NSLayoutConstraint.activate([
                expectationView.leadingAnchor.constraint(equalTo: pxContentView.leadingAnchor, constant: PXLayout.L_MARGIN),
                expectationView.trailingAnchor.constraint(equalTo: pxContentView.trailingAnchor, constant: -PXLayout.L_MARGIN)
            ])

            if let iconView = iconView {
                expectationView.topAnchor.constraint(equalTo: iconView.bottomAnchor, constant: PXLayout.S_MARGIN).isActive = true
            } else {
                setTopConstraints(targetView: expectationView, labelsView: labelsView, firstLabel: firstLabel, secondLabel: secondLabel, thirdLabel: thirdLabel, actionButton: actionButton)
            }
        }
        PXLayout.pinLastSubviewToBottom(view: pxContentView, withMargin: PXLayout.S_MARGIN)
    }

    @objc func actionTapped() {
        guard let action = data.action else {
            return
        }
        action.action()
    }
}

// MARK: UI Builders
private extension PXNewCustomView {
    func buildLabel(_ string: NSAttributedString) -> UILabel {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.attributedText = string
        label.lineBreakMode = .byWordWrapping
        label.numberOfLines = 2
        return label
    }

    func buildButton(_ action: PXAction) -> UIButton {
        let button = UIButton()
        button.translatesAutoresizingMaskIntoConstraints = false
        button.contentHorizontalAlignment = .left
        button.setTitle(action.label, for: .normal)
        button.titleLabel?.font = Utils.getFont(size: PXLayout.XXS_FONT)
        button.setTitleColor(ThemeManager.shared.secondaryColor(), for: .normal)
        button.add(for: .touchUpInside, action.action)
        return button
    }

    func setTopConstraints(targetView: UIView, labelsView: UIView, firstLabel: UILabel? = nil, secondLabel: UILabel? = nil, thirdLabel: UILabel?, actionButton: UIButton? = nil) {

        var topConstraint: NSLayoutConstraint
        if let actionButton = actionButton {
            topConstraint = targetView.topAnchor.constraint(equalTo: actionButton.topAnchor, constant: PXLayout.XXXS_MARGIN)
        } else if let thirdLabel = thirdLabel {
            topConstraint = targetView.topAnchor.constraint(equalTo: thirdLabel.bottomAnchor, constant: PXLayout.XXXS_MARGIN)
        } else if let secondLabel = secondLabel {
            topConstraint = targetView.topAnchor.constraint(equalTo: secondLabel.bottomAnchor, constant: PXLayout.XXXS_MARGIN)
        } else if let firstLabel = firstLabel {
            topConstraint = targetView.topAnchor.constraint(equalTo: firstLabel.bottomAnchor, constant: PXLayout.XXXS_MARGIN)
        } else {
            topConstraint = targetView.topAnchor.constraint(equalTo: labelsView.topAnchor)
        }
        topConstraint.isActive = true
    }
}
