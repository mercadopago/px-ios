//
//  PXCardSliderPagerCell.swift
//
//  Created by Juan sebastian Sanzone on 12/10/18.
//

import UIKit
import MLCardDrawer

class PXCardSliderPagerCell: FSPagerViewCell {
    static let identifier = "PXCardSliderPagerCell"
    static func getCell() -> UINib {
        return UINib(nibName: PXCardSliderPagerCell.identifier, bundle: ResourceManager.shared.getBundle())
    }

    private lazy var cornerRadius: CGFloat = 11
    private var cardHeader: MLCardDrawerController?

    @IBOutlet weak var containerView: UIView!

    private var consumerCreditCard: ConsumerCreditsCard?
    weak var delegate: PXTermsAndConditionViewDelegate?

    override func prepareForReuse() {
        super.prepareForReuse()
        cardHeader?.view.removeFromSuperview()
        containerView.removeAllSubviews()
        containerView.layer.masksToBounds = false
    }
}

// MARK: Publics.
extension PXCardSliderPagerCell {
    func render(withCard: CardUI, cardData: CardData, isDisabled: Bool, cardSize: CGSize, bottomMessage: String? = nil) {
        containerView.layer.masksToBounds = false
        containerView.removeAllSubviews()
        containerView.layer.cornerRadius = cornerRadius
        containerView.backgroundColor = .clear
        cardHeader = MLCardDrawerController(withCard, cardData, isDisabled)
        cardHeader?.view.frame = CGRect(origin: CGPoint.zero, size: cardSize)
        cardHeader?.animated(false)
        cardHeader?.show()

        if let headerView = cardHeader?.view {
            containerView.addSubview(headerView)
            PXLayout.centerHorizontally(view: headerView).isActive = true
            PXLayout.centerVertically(view: headerView).isActive = true
        }
        addBottomMessageView(message: bottomMessage)
    }

    func renderEmptyCard(title: PXText? = nil, cardSize: CGSize) {
        containerView.layer.masksToBounds = false
        containerView.removeAllSubviews()
        containerView.layer.cornerRadius = cornerRadius
        containerView.backgroundColor = .clear
        let emptyCard = EmptyCard(title: title)
        cardHeader = MLCardDrawerController(emptyCard, PXCardDataFactory(), false)
        cardHeader?.view.frame = CGRect(origin: CGPoint.zero, size: cardSize)
        cardHeader?.animated(false)
        cardHeader?.show()
        if let headerView = cardHeader?.view {
            containerView.addSubview(headerView)
            emptyCard.render(containerView: containerView)
            PXLayout.centerHorizontally(view: headerView).isActive = true
            PXLayout.centerVertically(view: headerView).isActive = true
        }
    }

    func renderAccountMoneyCard(isDisabled: Bool, cardSize: CGSize, bottomMessage: String? = nil) {
        containerView.layer.masksToBounds = false
        containerView.backgroundColor = .clear
        containerView.removeAllSubviews()
        containerView.layer.cornerRadius = cornerRadius
        cardHeader = MLCardDrawerController(AccountMoneyCard(), PXCardDataFactory(), isDisabled)
        cardHeader?.view.frame = CGRect(origin: CGPoint.zero, size: cardSize)
        cardHeader?.animated(false)
        cardHeader?.show()

        if let headerView = cardHeader?.view {
            containerView.addSubview(headerView)
            AccountMoneyCard.render(containerView: containerView, isDisabled: isDisabled, size: cardSize)
            PXLayout.centerHorizontally(view: headerView).isActive = true
            PXLayout.centerVertically(view: headerView).isActive = true
        }
        addBottomMessageView(message: bottomMessage)
    }

    func renderConsumerCreditsCard(creditsViewModel: CreditsViewModel, isDisabled: Bool, cardSize: CGSize, bottomMessage: String? = nil) {
        consumerCreditCard = ConsumerCreditsCard(creditsViewModel, isDisabled: isDisabled)
        guard let consumerCreditCard = consumerCreditCard else { return }

        containerView.layer.masksToBounds = false
        containerView.backgroundColor = .clear
        containerView.removeAllSubviews()
        containerView.layer.cornerRadius = cornerRadius

        cardHeader = MLCardDrawerController(consumerCreditCard, PXCardDataFactory(), isDisabled)
        cardHeader?.view.frame = CGRect(origin: CGPoint.zero, size: cardSize)

        cardHeader?.animated(false)
        cardHeader?.show()

        if let headerView = cardHeader?.view {
            containerView.addSubview(headerView)
            consumerCreditCard.render(containerView: containerView, creditsViewModel: creditsViewModel, isDisabled: isDisabled, size: cardSize)
            consumerCreditCard.delegate = self
            PXLayout.centerHorizontally(view: headerView).isActive = true
            PXLayout.centerVertically(view: headerView).isActive = true
        }
        addBottomMessageView(message: bottomMessage)
    }

    func addBottomMessageView(message: String?) {
        guard let message = message else {return}
        let messageView = UIView()
        messageView.translatesAutoresizingMaskIntoConstraints = false
        messageView.backgroundColor = ThemeManager.shared.noTaxAndDiscountLabelTintColor()

        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.text = message
        label.numberOfLines = 1
        label.textAlignment = .center
        label.textColor = .white
        label.font = Utils.getSemiBoldFont(size: PXLayout.XXXS_FONT)

        messageView.addSubview(label)

        NSLayoutConstraint.activate([
            label.leadingAnchor.constraint(equalTo: messageView.leadingAnchor),
            label.trailingAnchor.constraint(equalTo: messageView.trailingAnchor),
            label.topAnchor.constraint(equalTo: messageView.topAnchor),
            label.bottomAnchor.constraint(equalTo: messageView.bottomAnchor)
            ])

        self.containerView.clipsToBounds = true
        self.containerView.addSubview(messageView)

        NSLayoutConstraint.activate([
            messageView.leadingAnchor.constraint(equalTo: self.containerView.leadingAnchor),
            messageView.trailingAnchor.constraint(equalTo: self.containerView.trailingAnchor),
            messageView.heightAnchor.constraint(equalToConstant: 24),
            messageView.bottomAnchor.constraint(equalTo: self.containerView.bottomAnchor)
            ])

        self.layoutIfNeeded()
    }

    func flipToBack() {
        if !(cardHeader?.cardUI is AccountMoneyCard) {
            cardHeader?.showSecurityCode()
        }
    }

    func flipToFront() {
        cardHeader?.animated(true)
        cardHeader?.show()
        cardHeader?.animated(false)
    }
}

extension PXCardSliderPagerCell: PXTermsAndConditionViewDelegate {
    func shouldOpenTermsCondition(_ title: String, url: URL) {
        delegate?.shouldOpenTermsCondition(title, url: url)
    }
}
