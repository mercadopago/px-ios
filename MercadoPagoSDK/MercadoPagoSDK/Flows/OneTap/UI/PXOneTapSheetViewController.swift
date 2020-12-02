//
//  PXOneTapSheetViewController.swift
//  MercadoPagoSDK
//
//  Created by Eric Ertl on 30/10/2020.
//

import Foundation

internal protocol PXOneTapSheetViewControllerProtocol: class {
    func didTapOneTapSheetOption(sheetOption: PXOneTapSheetOptionsDto)
}

internal class PXOneTapSheetViewController: UIViewController {
    weak var delegate: PXOneTapSheetViewControllerProtocol?
    private let rowHeight: CGFloat = 80.0
    private let iconSize: CGFloat = 24.0
    private let newCard: PXOneTapNewCardDto

    init(newCard: PXOneTapNewCardDto) {
        self.newCard = newCard
        super.init(nibName: nil, bundle: nil)
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .white
        buildScrollView()
    }

    private func buildScrollView() {
        let scrollView = UIScrollView()
        scrollView.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(scrollView)

        NSLayoutConstraint.activate([
            scrollView.leftAnchor.constraint(equalTo: view.leftAnchor),
            scrollView.rightAnchor.constraint(equalTo: view.rightAnchor),
            scrollView.topAnchor.constraint(equalTo: view.topAnchor),
            scrollView.bottomAnchor.constraint(equalTo: view.bottomAnchor)
        ])

        buildStackView(scrollView: scrollView)
        view.addSubview(scrollView)
    }

    private func buildStackView(scrollView: UIScrollView) {
        let stackView = UIStackView(frame: .zero)
        stackView.translatesAutoresizingMaskIntoConstraints = false
        stackView.axis = .vertical
        stackView.alignment = .fill

        scrollView.addSubview(stackView)

        if let sheetOptions = newCard.sheetOptions {
            for sheetOption in sheetOptions {
                let view = buildOptionView(sheetOption: sheetOption)
                stackView.addArrangedSubview(view)
            }
        }

        NSLayoutConstraint.activate([
            stackView.leadingAnchor.constraint(equalTo: scrollView.leadingAnchor),
            stackView.trailingAnchor.constraint(equalTo: scrollView.trailingAnchor),
            stackView.topAnchor.constraint(equalTo: scrollView.topAnchor),
            stackView.bottomAnchor.constraint(equalTo: scrollView.bottomAnchor),
            stackView.widthAnchor.constraint(equalTo: scrollView.widthAnchor)
        ])
    }

    private func buildOptionView(sheetOption: PXOneTapSheetOptionsDto) -> UIView {
        let view = UIView()
        view.backgroundColor = .white
        view.translatesAutoresizingMaskIntoConstraints = false

        let tap = PXOneTapSheetTapGesture(target: self, action: #selector(self.handleTap(sender:)), sheetOption: sheetOption)
        view.addGestureRecognizer(tap)
        view.isUserInteractionEnabled = true

        let spacerView = UIView()
        spacerView.backgroundColor = UIColor.gray.withAlphaComponent(0.3)
        spacerView.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(spacerView)
        NSLayoutConstraint.activate([
            spacerView.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 8),
            spacerView.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -8),
            spacerView.topAnchor.constraint(equalTo: view.topAnchor),
            spacerView.heightAnchor.constraint(equalToConstant: 1)
        ])

        var image: UIImage?
        if let imageURL = sheetOption.imageUrl, imageURL.isNotEmpty {
            image = PXUIImage(url: imageURL)
        } else {
            image = ResourceManager.shared.getImage("PaymentGeneric")
        }
        let iconImageView = PXUIImageView(image: image, size: iconSize, showAsCircle: false, showBorder: false, shouldAddInsets: true)
        view.addSubview(iconImageView)

        NSLayoutConstraint.activate([
            iconImageView.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 24),
            iconImageView.centerYAnchor.constraint(equalTo: view.centerYAnchor)
        ])

        let label = UILabel()
        label.numberOfLines = 0
        label.translatesAutoresizingMaskIntoConstraints = false
        let attributedText = NSMutableAttributedString()
        if let attributedTitle = sheetOption.title.getAttributedString(fontSize: PXLayout.XS_FONT) {
            attributedText.append(attributedTitle)
        }
        if let attributedSubtitle = sheetOption.subtitle?.getAttributedString(fontSize: PXLayout.XXS_FONT) {
            attributedText.append(NSAttributedString(string: "\n"))
            attributedText.append(attributedSubtitle)
        }
        label.attributedText = attributedText
        view.addSubview(label)
        NSLayoutConstraint.activate([
            label.leadingAnchor.constraint(equalTo: iconImageView.trailingAnchor, constant: 24),
            label.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -24),
            label.heightAnchor.constraint(equalToConstant: rowHeight),
            label.topAnchor.constraint(equalTo: view.topAnchor),
            label.bottomAnchor.constraint(lessThanOrEqualTo: view.bottomAnchor)
        ])
        return view
    }

    @objc private func handleTap(sender: PXOneTapSheetTapGesture) {
        delegate?.didTapOneTapSheetOption(sheetOption: sender.sheetOption)
    }
}

private class PXOneTapSheetTapGesture: UITapGestureRecognizer {
    let sheetOption: PXOneTapSheetOptionsDto

    init(target: Any?, action: Selector?, sheetOption: PXOneTapSheetOptionsDto) {
        self.sheetOption = sheetOption
        super.init(target: target, action: action)
    }
}
