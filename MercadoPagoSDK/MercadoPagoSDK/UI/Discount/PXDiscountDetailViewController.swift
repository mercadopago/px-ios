//
//  PXDiscountDetailViewController.swift
//  MercadoPagoSDK
//
//  Created by AUGUSTO COLLERONE ALFONSO on 28/5/18.
//  Copyright © 2018 MercadoPago. All rights reserved.
//

import UIKit

final class PXDiscountDetailViewController: MercadoPagoUIViewController {

    private var amountHelper: PXAmountHelper
    private let discountDescription: PXDiscountDescriptionViewModel

    init(amountHelper: PXAmountHelper, discountDescription: PXDiscountDescriptionViewModel) {
        self.amountHelper = amountHelper
        self.discountDescription = discountDescription
        super.init(nibName: nil, bundle: nil)
    }

    override public func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        trackScreen()
    }

    required public init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override public func viewDidLoad() {
        super.viewDidLoad()
        renderViews()
    }
}

// MARK: Getters
extension PXDiscountDetailViewController {
    func getContentView() -> UIView {
        renderViews()
        return view
    }
}

// MARK: RenderViews
private extension PXDiscountDetailViewController {
    func renderViews() {
        // Title
        let title = buildLabel(text: discountDescription.getTitle(), numberOfLines: 2)
        view.addSubview(title)
        NSLayoutConstraint.activate([
            title.topAnchor.constraint(equalTo: view.topAnchor, constant: PXLayout.M_MARGIN),
            title.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: PXLayout.M_MARGIN),
            title.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -PXLayout.M_MARGIN)
        ])

        // Subtitle
        var subtitle: UILabel?
        subtitle = buildLabel(text: discountDescription.getSubtitle(), numberOfLines: 2)
        if let subtitle = subtitle {
            view.addSubview(subtitle)
            NSLayoutConstraint.activate([
                subtitle.topAnchor.constraint(equalTo: title.bottomAnchor, constant: PXLayout.XXS_MARGIN),
                subtitle.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: PXLayout.M_MARGIN),
                subtitle.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -PXLayout.M_MARGIN)
            ])
        }

        // Badge
        var badgeView: UIView?
        if discountDescription.badge != nil {
            badgeView = buildBadgeView()
            if let badgeView = badgeView {
                view.addSubview(badgeView)
                badgeView.centerXAnchor.constraint(equalTo: view.centerXAnchor).isActive = true
                var badgeTopConstraint = NSLayoutConstraint()
                if let subtitle = subtitle {
                    badgeTopConstraint = badgeView.topAnchor.constraint(equalTo: subtitle.bottomAnchor, constant: PXLayout.XXS_MARGIN)
                } else {
                    badgeTopConstraint = badgeView.topAnchor.constraint(equalTo: title.bottomAnchor, constant: PXLayout.XXS_MARGIN)
                }
                badgeTopConstraint.isActive = true
            }
        }

        // Summary
        let summary = buildLabel(text: discountDescription.getSummary(), numberOfLines: 2)
        view.addSubview(summary)
        NSLayoutConstraint.activate([
            summary.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: PXLayout.M_MARGIN),
            summary.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -PXLayout.M_MARGIN)
        ])
        var summaryTopConstraint = NSLayoutConstraint()
        if let badgeView = badgeView {
            summaryTopConstraint = summary.topAnchor.constraint(equalTo: badgeView.bottomAnchor, constant: PXLayout.M_MARGIN)
        } else if let subtitle = subtitle {
            summaryTopConstraint = summary.topAnchor.constraint(equalTo: subtitle.bottomAnchor, constant: PXLayout.M_MARGIN)
        } else {
            summaryTopConstraint = summary.topAnchor.constraint(equalTo: title.bottomAnchor, constant: PXLayout.M_MARGIN)
        }
        summaryTopConstraint.isActive = true

        // Description
        let description = buildLabel(text: discountDescription.getDescription(), numberOfLines: 0)
        view.addSubview(description)
        NSLayoutConstraint.activate([
            description.topAnchor.constraint(equalTo: summary.bottomAnchor, constant: PXLayout.XXXS_MARGIN),
            description.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: PXLayout.M_MARGIN),
            description.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -PXLayout.M_MARGIN)
        ])

        // Legal terms
        let legalTerms = buildLabel(text: discountDescription.getLegalTermsContent(), numberOfLines: 2)
        view.addSubview(legalTerms)
        NSLayoutConstraint.activate([
            legalTerms.topAnchor.constraint(equalTo: description.bottomAnchor, constant: PXLayout.M_MARGIN),
            legalTerms.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: PXLayout.M_MARGIN),
            legalTerms.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -PXLayout.M_MARGIN),
            legalTerms.bottomAnchor.constraint(equalTo: view.bottomAnchor, constant: -PXLayout.M_MARGIN)
        ])
        legalTerms.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(didTapTerms)))
        legalTerms.isUserInteractionEnabled = true
    }
}

// MARK: Privates
private extension PXDiscountDetailViewController {
    func buildBadgeView() -> UIView {
        let badgeView = UIView()
        badgeView.translatesAutoresizingMaskIntoConstraints = false
        if let backgroundColor = discountDescription.getBadgeBackgroundColor() {
            badgeView.backgroundColor = UIColor.fromHex(backgroundColor)
        }
        badgeView.heightAnchor.constraint(equalToConstant: 20).isActive = true
        badgeView.layer.cornerRadius = 10

        let icon = buildIcon()
        badgeView.addSubview(icon)
        NSLayoutConstraint.activate([
            icon.heightAnchor.constraint(equalToConstant: 7),
            icon.widthAnchor.constraint(equalToConstant: 9),
            icon.leadingAnchor.constraint(equalTo: badgeView.leadingAnchor, constant: PXLayout.XXS_MARGIN),
            icon.centerYAnchor.constraint(equalTo: badgeView.centerYAnchor)
        ])

        let badgeLabel = buildLabel(text: discountDescription.getBadgeContent(), numberOfLines: 1)
        badgeView.addSubview(badgeLabel)
        NSLayoutConstraint.activate([
            badgeLabel.centerYAnchor.constraint(equalTo: badgeView.centerYAnchor),
            badgeLabel.leftAnchor.constraint(equalTo: icon.rightAnchor, constant: PXLayout.XXXS_MARGIN),
            badgeLabel.trailingAnchor.constraint(equalTo: badgeView.trailingAnchor, constant: -PXLayout.XXS_MARGIN)
        ])
        return badgeView
    }

    func buildLabel(text: NSAttributedString?, numberOfLines: Int) -> UILabel {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.numberOfLines = numberOfLines
        label.attributedText = text
        label.textAlignment = .center
        return label
    }

    func buildIcon() -> UIImageView {
        let icon = UIImageView()
        icon.translatesAutoresizingMaskIntoConstraints = false
        if let url = discountDescription.getBadgeUrl() {
            icon.setRemoteImage(imageUrl: url)
        }
        icon.contentMode = .scaleAspectFit
        icon.clipsToBounds = true
        return icon
    }
}

// MARK: Actions
private extension PXDiscountDetailViewController {
    @objc func didTapTerms() {
        let title = "terms_and_conditions_title".localized
        if let url = URL(string: discountDescription.getLegalTermsUrl()) {
            let webVC = WebViewController(url: url, navigationBarTitle: title, forceAddNavBar: true)
            webVC.title = title
            present(webVC, animated: true)
        }
    }
}

// MARK: Tracking
private extension PXDiscountDetailViewController {
    func trackScreen() {
        var properties: [String: Any] = [:]
        properties["discount"] = amountHelper.getDiscountForTracking()
        trackScreen(path: TrackingPaths.Screens.getDiscountDetailPath(), properties: properties)
    }
}
