//
//  PXResultDescritionRemedyView.swift
//  MercadoPagoSDK
//
//  Created by Eric Ertl on 30/03/2020.
//

import Foundation

struct PXResultDescritionRemedyViewData {
    let title: String
}

class PXResultDescritionRemedyView: UIView {
    private let data: PXResultDescritionRemedyViewData

    init(data: PXResultDescritionRemedyViewData) {
        self.data = data
        super.init(frame: .zero)
        render()
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    let CONTENT_WIDTH_PERCENT: CGFloat = 84.0
    let TITLE_FONT_SIZE: CGFloat = PXLayout.XS_FONT

    private func render() {
        removeAllSubviews()
        //Title Label
        let titleLabel = buildTitleLabel(with: data.title)
        addSubview(titleLabel)
        let screenWidth = PXLayout.getScreenWidth(applyingMarginFactor: CONTENT_WIDTH_PERCENT)
        let height = UILabel.requiredHeight(forText: data.title, withFont: titleLabel.font, inWidth: screenWidth)
        NSLayoutConstraint.activate([
            titleLabel.topAnchor.constraint(equalTo: topAnchor, constant: PXLayout.L_MARGIN),
            titleLabel.widthAnchor.constraint(equalTo: widthAnchor, multiplier: CONTENT_WIDTH_PERCENT  / 100),
            titleLabel.heightAnchor.constraint(equalToConstant: height),
            titleLabel.centerXAnchor.constraint(equalTo: centerXAnchor),
            titleLabel.bottomAnchor.constraint(equalTo: bottomAnchor, constant: PXLayout.L_MARGIN)
        ])

        self.layoutIfNeeded()
    }

    private func buildTitleLabel(with text: String) -> UILabel {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.textAlignment = .left
        label.textColor = #colorLiteral(red: 0.1725280285, green: 0.1725597382, blue: 0.1725237072, alpha: 1)
        label.numberOfLines = 0
        label.text = text
        label.font = UIFont.ml_semiboldSystemFont(ofSize: TITLE_FONT_SIZE) ?? Utils.getSemiBoldFont(size: TITLE_FONT_SIZE)
        label.lineBreakMode = .byWordWrapping
        label.lineBreakMode = .byTruncatingTail
        return label
    }
}
