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

    private lazy var bottomMessageViewHeight: CGFloat = 24
    private lazy var cornerRadius: CGFloat = 11
    private var cardHeader: MLCardDrawerController?
    private weak var messageViewBottomConstraint: NSLayoutConstraint?
    private weak var messageLabelCenterConstraint: NSLayoutConstraint?
    private var consumerCreditCard: ConsumerCreditsCard?

    weak var delegate: PXTermsAndConditionViewDelegate?
    @IBOutlet weak var containerView: UIView!

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

    func renderConsumerCreditsCard(creditsViewModel: PXCreditsViewModel, isDisabled: Bool, cardSize: CGSize, bottomMessage: String? = nil) {
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
        guard let message = message else { return }

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
        ])

        messageLabelCenterConstraint = label.centerYAnchor.constraint(equalTo: messageView.centerYAnchor, constant: bottomMessageViewHeight)
        messageLabelCenterConstraint?.isActive = true

        containerView.clipsToBounds = true
        containerView.addSubview(messageView)

        NSLayoutConstraint.activate([
            messageView.leadingAnchor.constraint(equalTo: containerView.leadingAnchor),
            messageView.trailingAnchor.constraint(equalTo: containerView.trailingAnchor),
            messageView.heightAnchor.constraint(equalToConstant: bottomMessageViewHeight),
        ])

        messageViewBottomConstraint = messageView.bottomAnchor.constraint(equalTo: containerView.bottomAnchor, constant: bottomMessageViewHeight)
        messageViewBottomConstraint?.isActive = true
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

    func showBottomMessageView(_ shouldShow: Bool) {
        UIView.animate(withDuration: 0.5, animations: { [weak self] in
            guard let heightValue = self?.bottomMessageViewHeight else { return }
            self?.messageViewBottomConstraint?.constant = shouldShow ? 0 : heightValue
            self?.messageLabelCenterConstraint?.constant = shouldShow ? 0 : heightValue
            self?.layoutIfNeeded()
        })
    }
}

extension PXCardSliderPagerCell: PXTermsAndConditionViewDelegate {
    func shouldOpenTermsCondition(_ title: String, url: URL) {
        delegate?.shouldOpenTermsCondition(title, url: url)
    }
}
