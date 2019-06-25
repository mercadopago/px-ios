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
    private var warningBadgeIcon: UIView!

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
    func render(withCard: CardUI, cardData: CardData, isDisabled: Bool) {
        containerView.layer.masksToBounds = false
        containerView.removeAllSubviews()
        containerView.layer.cornerRadius = cornerRadius
        containerView.backgroundColor = .clear
        cardHeader = MLCardDrawerController(withCard, cardData, isDisabled)
        cardHeader?.view.frame = CGRect(origin: CGPoint.zero, size: PXCardSliderSizeManager.getItemContainerSize())
        cardHeader?.animated(false)
        cardHeader?.show()

        if let headerView = cardHeader?.view {
            containerView.addSubview(headerView)
            PXLayout.centerHorizontally(view: headerView).isActive = true
            PXLayout.centerVertically(view: headerView).isActive = true
        }
        addWarningBadge(isDisabled)
    }

    func renderEmptyCard() {
        containerView.layer.masksToBounds = false
        containerView.removeAllSubviews()
        containerView.layer.cornerRadius = cornerRadius
        containerView.backgroundColor = .clear
        cardHeader = MLCardDrawerController(EmptyCard(), PXCardDataFactory(), false)
        cardHeader?.view.frame = CGRect(origin: CGPoint.zero, size: PXCardSliderSizeManager.getItemContainerSize())
        cardHeader?.animated(false)
        cardHeader?.show()
        if let headerView = cardHeader?.view {
            containerView.addSubview(headerView)
            EmptyCard.render(containerView: containerView)
            PXLayout.centerHorizontally(view: headerView).isActive = true
            PXLayout.centerVertically(view: headerView).isActive = true
        }
    }

    func renderAccountMoneyCard(balanceText: String, isDisabled: Bool) {
        containerView.layer.masksToBounds = false
        containerView.backgroundColor = .clear
        containerView.removeAllSubviews()
        containerView.layer.cornerRadius = cornerRadius
        cardHeader = MLCardDrawerController(AccountMoneyCard(), PXCardDataFactory(), isDisabled)
        cardHeader?.view.frame = CGRect(origin: CGPoint.zero, size: PXCardSliderSizeManager.getItemContainerSize())
        cardHeader?.animated(false)
        cardHeader?.show()

        if let headerView = cardHeader?.view {
            containerView.addSubview(headerView)
            AccountMoneyCard.render(containerView: containerView, balanceText: balanceText, isDisabled: isDisabled)
            PXLayout.centerHorizontally(view: headerView).isActive = true
            PXLayout.centerVertically(view: headerView).isActive = true
        }
        addWarningBadge(isDisabled)
    }

    func addWarningBadge(_ isDisabled: Bool) {
        if isDisabled {
            let image = ResourceManager.shared.getImage("warning_badge")
            warningBadgeIcon = UIImageView(image: image)
            containerView.insertSubview(warningBadgeIcon, at: 10)
            PXLayout.setHeight(owner: warningBadgeIcon, height: 60).isActive = true
            PXLayout.setWidth(owner: warningBadgeIcon, width: 60).isActive = true
            PXLayout.pinTop(view: warningBadgeIcon, withMargin: -28).isActive = true
            PXLayout.pinRight(view: warningBadgeIcon, withMargin: PXLayout.S_MARGIN).isActive = true
        }
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
