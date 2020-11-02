//
//  PXOneTapSheetViewController.swift
//  MercadoPagoSDK
//
//  Created by Eric Ertl on 30/10/2020.
//

import Foundation

import MLBusinessComponents

class PXOneTapSheetViewController: SheetViewController {
    private let sizes: [SheetSize]
    private var totalView: UIView?

    init(viewController: UIViewController, whiteViewHeight: CGFloat) {
        self.sizes = PXOneTapSheetViewController.getSizes(whiteViewHeight: whiteViewHeight)
        super.init(rootViewController: viewController, sizes: self.sizes, configuration: PXOneTapSheetViewController.getConfiguration())
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        setupSheetDelegate()
        setupTotalView()
    }

    override func viewWillDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)

        if animated {
            UIView.animate(withDuration: 0.1) {
                self.totalView?.alpha = 0.0
            }
        }
    }

    private func setupSheetDelegate() {
        delegate = self
    }

    private func setupTotalView() {
        let totalView = UIView()
        totalView.translatesAutoresizingMaskIntoConstraints = false
        totalView.backgroundColor = ThemeManager.shared.navigationBar().backgroundColor
        totalView.alpha = 0.0

        view.addSubview(totalView)

        NSLayoutConstraint.activate([
            totalView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            totalView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            totalView.topAnchor.constraint(equalTo: view.topAnchor),
            totalView.heightAnchor.constraint(equalToConstant: PXOneTapSheetViewController.topBarHeight())
        ])

        let totalLabel = UILabel()
        totalLabel.translatesAutoresizingMaskIntoConstraints = false
        totalLabel.attributedText = PXText(message: "TEST", backgroundColor: nil, textColor: nil, weight: "semi_bold").getAttributedString(fontSize: PXLayout.M_FONT, textColor: ThemeManager.shared.navigationBar().getTintColor())
        totalLabel.textAlignment = .right

        totalView.addSubview(totalLabel)

        NSLayoutConstraint.activate([
            totalLabel.trailingAnchor.constraint(equalTo: totalView.trailingAnchor, constant: -14.0),
            totalLabel.bottomAnchor.constraint(greaterThanOrEqualTo: totalView.bottomAnchor)
        ])

        let closeButton = UIButton(type: .custom)
        let closeImage = ResourceManager.shared.getImage("result-close-button")?.imageWithOverlayTint(tintColor: ThemeManager.shared.navigationBar().getTintColor())
        closeButton.setImage(closeImage, for: .normal)
        closeButton.translatesAutoresizingMaskIntoConstraints = false
        closeButton.add(for: .touchUpInside) { [weak self] in
            PXFeedbackGenerator.mediumImpactFeedback()
            self?.presentingViewController?.dismiss(animated: true)
        }

        totalView.addSubview(closeButton)

        NSLayoutConstraint.activate([
            closeButton.leadingAnchor.constraint(equalTo: totalView.leadingAnchor, constant: 2.0),
            closeButton.bottomAnchor.constraint(equalTo: totalView.bottomAnchor),
            closeButton.heightAnchor.constraint(equalToConstant: 44),
            closeButton.widthAnchor.constraint(equalTo: closeButton.heightAnchor),
            closeButton.trailingAnchor.constraint(equalTo: totalLabel.leadingAnchor),
            totalLabel.centerYAnchor.constraint(equalTo: closeButton.centerYAnchor)
        ])

        view.sendSubviewToBack(totalView)
        self.totalView = totalView
    }

    private static func getSizes(whiteViewHeight: CGFloat) -> [SheetSize] {
        return [
            .fixed(whiteViewHeight),
            .fixedFromTop(topBarHeight())
        ]
    }

    private static func topBarHeight() -> CGFloat {
        return PXLayout.NAV_BAR_HEIGHT + PXLayout.getSafeAreaTopInset()
    }

    private static func getConfiguration() -> SheetConfiguration {
        var configuration = SheetConfiguration.default
        configuration.backgroundAlpha = 0.0
        configuration.handle.height = 0.0
        return configuration
    }
}

extension PXOneTapSheetViewController: SheetViewControllerDelegate {
    func sheetViewController(_ sheetViewController: SheetViewController, sheetHeightDidChange height: CGFloat) {
        let highest = view.bounds.height - PXOneTapSheetViewController.topBarHeight()
        let difference = highest - height

        if (difference < 100) {
            totalView?.alpha = 1 - min(max(difference / 100, 0.0), 1.0)
        } else {
            totalView?.alpha = 0.0
        }
    }
}
