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
    weak var cardSliderPagerCellDelegate: PXCardSliderPagerCellDelegate?
    @IBOutlet weak var containerView: UIView!

    private var bottomMessageFixed: Bool = false

    override func prepareForReuse() {
        super.prepareForReuse()
        cardHeader?.view.removeFromSuperview()
        setupContainerView()
    }
}

protocol PXCardSliderPagerCellDelegate: NSObjectProtocol {
    func addNewCard()
    func addNewOfflineMethod()
    func switchDidChange(_ selectedOption: String)
}

// MARK: Publics.
extension PXCardSliderPagerCell {
    
    private func setupContainerView(_ masksToBounds: Bool = false) {
        containerView.layer.masksToBounds = masksToBounds
        containerView.removeAllSubviews()
        containerView.backgroundColor = .clear
        containerView.layer.cornerRadius = cornerRadius
    }
    
    private func setupCardHeader(cardDrawerController: MLCardDrawerController?, cardSize: CGSize) {
        cardHeader = cardDrawerController
        cardHeader?.view.frame = CGRect(origin: CGPoint.zero, size: cardSize)
        cardHeader?.animated(false)
        cardHeader?.show()
    }
    
    private func setupSwitchInfoView(model: PXCardSliderViewModel) {
        if let comboSwitch = model.getComboSwitch() {
            comboSwitch.setSwitchDidChangeCallback() { [weak self] selectedOption in
                model.trackCard(state: selectedOption)
                model.setSelectedApplication(id: selectedOption)
                self?.cardSliderPagerCellDelegate?.switchDidChange(selectedOption)
            }
            cardHeader?.setCustomView(comboSwitch)
        }
    }
    
    func render(model: PXCardSliderViewModel, cardSize: CGSize, accessibilityData: AccessibilityCardData, clearCardData: Bool = false, delegate: PXCardSliderPagerCellDelegate?) {
        
        guard let selectedApplication = model.getSelectedApplication(), let cardUI = model.getCardUI() else { return }
        
        cardSliderPagerCellDelegate = delegate
        let cardData = clearCardData ? PXCardDataFactory() : selectedApplication.cardData ?? PXCardDataFactory()
        let isDisabled = selectedApplication.status.isDisabled()
        let bottomMessage = selectedApplication.bottomMessage
        
        setupContainerView()
        setupCardHeader(cardDrawerController: MLCardDrawerController(cardUI, cardData, isDisabled), cardSize: cardSize)

        if let headerView = cardHeader?.view {
            containerView.addSubview(headerView)
            if let accountMoneyCard = cardUI as? AccountMoneyCard {
                accountMoneyCard.render(containerView: containerView, isDisabled: isDisabled, size: cardSize)
            } else if let hybridAMCard = cardUI as? HybridAMCard {
                hybridAMCard.render(containerView: containerView, isDisabled: isDisabled, size: cardSize)
            }
            PXLayout.centerHorizontally(view: headerView).isActive = true
            PXLayout.centerVertically(view: headerView).isActive = true
        }
                    
        addBottomMessageView(message: bottomMessage)
        accessibilityLabel = getAccessibilityMessage(accessibilityData)
        
        setupSwitchInfoView(model: model)
    }

    func renderEmptyCard(newCardData: PXAddNewMethodData?, newOfflineData: PXAddNewMethodData?, cardSize: CGSize, delegate: PXCardSliderPagerCellDelegate) {
        self.cardSliderPagerCellDelegate = delegate

        setupContainerView(true)

        let bigSize = cardSize.height
        let smallSize = (cardSize.height - PXLayout.XS_MARGIN) / 2

        let shouldApplyCompactMode = newCardData != nil && newOfflineData != nil
        let newMethodViewHeight = shouldApplyCompactMode ? smallSize : bigSize

        isAccessibilityElement = false
        if let newCardData = newCardData {
            let icon = ResourceManager.shared.getImage("add_new_card")
            let newCardData = PXAddMethodData(title: newCardData.title, subtitle: newCardData.subtitle, icon: icon, compactMode: shouldApplyCompactMode)
            let newCardView = PXAddMethodView(data: newCardData)
            newCardView.translatesAutoresizingMaskIntoConstraints = false
            newCardView.layer.cornerRadius = cornerRadius
            containerView.addSubview(newCardView)

            let newCardTap = UITapGestureRecognizer(target: self, action: #selector(addNewCardTapped))
            newCardView.addGestureRecognizer(newCardTap)

            NSLayoutConstraint.activate([
                newCardView.leadingAnchor.constraint(equalTo: containerView.leadingAnchor),
                newCardView.trailingAnchor.constraint(equalTo: containerView.trailingAnchor),
                newCardView.topAnchor.constraint(equalTo: containerView.topAnchor),
                newCardView.heightAnchor.constraint(equalToConstant: newMethodViewHeight)
            ])
        }

        if let newOfflineData = newOfflineData {
            let icon = ResourceManager.shared.getImage("add_new_offline")
            let newOfflineData = PXAddMethodData(title: newOfflineData.title, subtitle: newOfflineData.subtitle, icon: icon, compactMode: shouldApplyCompactMode)
            let newOfflineView = PXAddMethodView(data: newOfflineData)
            newOfflineView.translatesAutoresizingMaskIntoConstraints = false
            newOfflineView.layer.cornerRadius = cornerRadius

            let newOfflineMethodTap = UITapGestureRecognizer(target: self, action: #selector(addNewOfflineMethodTapped))
            newOfflineView.addGestureRecognizer(newOfflineMethodTap)

            containerView.addSubview(newOfflineView)

            NSLayoutConstraint.activate([
                newOfflineView.leadingAnchor.constraint(equalTo: containerView.leadingAnchor),
                newOfflineView.trailingAnchor.constraint(equalTo: containerView.trailingAnchor),
                newOfflineView.bottomAnchor.constraint(equalTo: containerView.bottomAnchor),
                newOfflineView.heightAnchor.constraint(equalToConstant: newMethodViewHeight)
            ])
        }
    }

    @objc
    func addNewCardTapped() {
        cardSliderPagerCellDelegate?.addNewCard()
    }

    @objc
    func addNewOfflineMethodTapped() {
        PXFeedbackGenerator.selectionFeedback()
        cardSliderPagerCellDelegate?.addNewOfflineMethod()
    }
    
    func renderConsumerCreditsCard(model: PXCardSliderViewModel, cardSize: CGSize, accessibilityData: AccessibilityCardData) {
        guard let selectedApplication = model.getSelectedApplication() else { return }
        guard let creditsViewModel = model.getCreditsViewModel() else { return }
        let cardData = PXCardDataFactory()
        let isDisabled = selectedApplication.status.isDisabled()
        let bottomMessage = selectedApplication.bottomMessage
        let creditsInstallmentSelected = selectedApplication.selectedPayerCost?.installments
        consumerCreditCard = ConsumerCreditsCard(creditsViewModel, isDisabled: isDisabled)
        guard let consumerCreditCard = consumerCreditCard else { return }

        setupContainerView()
        setupCardHeader(cardDrawerController: MLCardDrawerController(consumerCreditCard, cardData, isDisabled), cardSize: cardSize)

        if let headerView = cardHeader?.view {
            containerView.addSubview(headerView)
            consumerCreditCard.render(containerView: containerView, creditsViewModel: creditsViewModel, isDisabled: isDisabled, size: cardSize, selectedInstallments: creditsInstallmentSelected)
            consumerCreditCard.delegate = self
            PXLayout.centerHorizontally(view: headerView).isActive = true
            PXLayout.centerVertically(view: headerView).isActive = true
        }
        addBottomMessageView(message: bottomMessage)
        accessibilityLabel = getAccessibilityMessage(accessibilityData)
    }

    public func addBottomMessageView(message: PXCardBottomMessage?) {
        guard let message = message else { return }

        let messageView = UIView()
        messageView.translatesAutoresizingMaskIntoConstraints = false
        messageView.backgroundColor = message.text.getBackgroundColor()

        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.attributedText = message.text.getAttributedString(backgroundColor: .clear)
        label.numberOfLines = 1
        label.textAlignment = .center
        label.font = Utils.getSemiBoldFont(size: PXLayout.XXXS_FONT)

        messageView.addSubview(label)

        NSLayoutConstraint.activate([
            label.leadingAnchor.constraint(equalTo: messageView.leadingAnchor),
            label.trailingAnchor.constraint(equalTo: messageView.trailingAnchor),
        ])

        self.bottomMessageFixed = message.fixed

        let constraintsConstant = message.fixed ? 0 : bottomMessageViewHeight

        messageLabelCenterConstraint = label.centerYAnchor.constraint(equalTo: messageView.centerYAnchor, constant: constraintsConstant)
        messageLabelCenterConstraint?.isActive = true

        containerView.clipsToBounds = true
        containerView.addSubview(messageView)

        NSLayoutConstraint.activate([
            messageView.leadingAnchor.constraint(equalTo: containerView.leadingAnchor),
            messageView.trailingAnchor.constraint(equalTo: containerView.trailingAnchor),
            messageView.heightAnchor.constraint(equalToConstant: bottomMessageViewHeight),
        ])

        messageViewBottomConstraint = messageView.bottomAnchor.constraint(equalTo: containerView.bottomAnchor, constant: constraintsConstant)
        messageViewBottomConstraint?.isActive = true
    }

    func showBottomMessageView(_ shouldShow: Bool) {
        guard !bottomMessageFixed else { return }
        UIView.animate(withDuration: 0.5, animations: { [weak self] in
            guard let heightValue = self?.bottomMessageViewHeight else { return }
            self?.messageViewBottomConstraint?.constant = shouldShow ? 0 : heightValue
            self?.messageLabelCenterConstraint?.constant = shouldShow ? 0 : heightValue
            self?.layoutIfNeeded()
        })
    }
}

// MARK: Publics
private extension PXCardSliderPagerCell {
    func getAccessibilityMessage(_ accessibilityData: AccessibilityCardData) -> String {
        isAccessibilityElement = true
        var sliderPosition = ""
        if accessibilityData.numberOfPages > 1 && accessibilityData.index == 0 {
            sliderPosition = ": " + "1" + "de".localized + "\(accessibilityData.numberOfPages)"
        }
        switch accessibilityData.paymentTypeId {
        case PXPaymentTypes.ACCOUNT_MONEY.rawValue:
            return "\(accessibilityData.description)" + "\(sliderPosition)"
        case PXPaymentTypes.CREDIT_CARD.rawValue:
            return "\(accessibilityData.paymentMethodId)" + "\(accessibilityData.issuerName)" + "\(accessibilityData.description)" + "de".localized + "\(accessibilityData.cardName)" + "\(sliderPosition)"
        case PXPaymentTypes.DEBIT_CARD.rawValue:
            return "\(accessibilityData.paymentMethodId.replacingOccurrences(of: "deb", with: ""))" + "Débito".localized + "\(accessibilityData.issuerName)" + "\(accessibilityData.description)" + "de".localized + "\(accessibilityData.cardName)" + "\(sliderPosition)"
        case PXPaymentTypes.DIGITAL_CURRENCY.rawValue:
            return "\(accessibilityData.description)" + "\(sliderPosition)"
        default:
            return "\(sliderPosition)"
        }
    }
}

extension PXCardSliderPagerCell: PXTermsAndConditionViewDelegate {
    func shouldOpenTermsCondition(_ title: String, url: URL) {
        delegate?.shouldOpenTermsCondition(title, url: url)
    }
}

typealias PXAddMethodData = (title: PXText?, subtitle: PXText?, icon: UIImage?, compactMode: Bool)

class PXAddMethodView: UIView {
    //Icon sizes
    let COMPACT_ICON_SIZE: CGFloat = 48.0
    let DEFAULT_ICON_SIZE: CGFloat = 64.0

    let data: PXAddMethodData

    init(data: PXAddMethodData) {
        self.data = data
        super.init(frame: .zero)
        isAccessibilityElement = true
        render()
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    func render() {
        self.removeAllSubviews()
        self.backgroundColor = .white

        let iconImageView = buildCircleImage(with: data.icon)
        addSubview(iconImageView)

        let labelsContainerView = UIStackView()
        labelsContainerView.translatesAutoresizingMaskIntoConstraints = false
        labelsContainerView.axis = .vertical
        labelsContainerView.distribution = .fillEqually

        var titleLabel: UILabel?
        let titleView = UIView()
        if let title = data.title {
            titleLabel = UILabel()
            if let titleLabel = titleLabel {
                titleLabel.numberOfLines = 2
                titleLabel.translatesAutoresizingMaskIntoConstraints = false
                titleLabel.attributedText = title.getAttributedString(fontSize: PXLayout.XS_FONT)
                titleLabel.textAlignment = data.compactMode ? .left : .center
                titleView.addSubview(titleLabel)
                labelsContainerView.addArrangedSubview(titleView)
                NSLayoutConstraint.activate([
                    titleLabel.leadingAnchor.constraint(equalTo: titleView.leadingAnchor),
                    titleLabel.trailingAnchor.constraint(equalTo: titleView.trailingAnchor)
                ])
            }
        }

        if let subtitle = data.subtitle {
            let subtitleLabel = UILabel()
            subtitleLabel.numberOfLines = 2
            subtitleLabel.translatesAutoresizingMaskIntoConstraints = false
            subtitleLabel.attributedText = subtitle.getAttributedString(fontSize: PXLayout.XXS_FONT)
            subtitleLabel.textAlignment = data.compactMode ? .left : .center

            let subtitleView = UIView()
            subtitleView.addSubview(subtitleLabel)
            labelsContainerView.addArrangedSubview(subtitleView)
            NSLayoutConstraint.activate([
                subtitleLabel.leadingAnchor.constraint(equalTo: subtitleView.leadingAnchor),
                subtitleLabel.trailingAnchor.constraint(equalTo: subtitleView.trailingAnchor),
                subtitleLabel.topAnchor.constraint(equalTo: subtitleView.topAnchor)
            ])
            if let titleLabel = titleLabel {
                titleLabel.bottomAnchor.constraint(equalTo: titleView.bottomAnchor).isActive = true
            }
        } else {
            titleLabel?.centerYAnchor.constraint(equalTo: titleView.centerYAnchor).isActive = true
        }

        accessibilityLabel = data.title?.message
        addSubview(labelsContainerView)

        if data.compactMode {
            let chevronImage = ResourceManager.shared.getImage("oneTapArrow_color")
            let chevronImageView = UIImageView(image: chevronImage)
            chevronImageView.translatesAutoresizingMaskIntoConstraints = false
            addSubview(chevronImageView)

            NSLayoutConstraint.activate([
                chevronImageView.centerYAnchor.constraint(equalTo: self.centerYAnchor),
                chevronImageView.trailingAnchor.constraint(equalTo: self.trailingAnchor, constant: -PXLayout.M_MARGIN),
                chevronImageView.heightAnchor.constraint(equalToConstant: 13),
                chevronImageView.widthAnchor.constraint(equalToConstant: 8),
                iconImageView.leadingAnchor.constraint(equalTo: self.leadingAnchor, constant: PXLayout.S_MARGIN),
                iconImageView.centerYAnchor.constraint(equalTo: self.centerYAnchor),
                labelsContainerView.leadingAnchor.constraint(equalTo: iconImageView.trailingAnchor, constant: PXLayout.S_MARGIN),
                labelsContainerView.trailingAnchor.constraint(equalTo: chevronImageView.leadingAnchor, constant: -PXLayout.S_MARGIN),
                labelsContainerView.centerYAnchor.constraint(equalTo: self.centerYAnchor),
                labelsContainerView.heightAnchor.constraint(equalToConstant: 80)
            ])
        } else {
            NSLayoutConstraint.activate([
                iconImageView.topAnchor.constraint(equalTo: self.topAnchor, constant: PXLayout.XL_MARGIN),
                iconImageView.centerXAnchor.constraint(equalTo: self.centerXAnchor),
                labelsContainerView.topAnchor.constraint(equalTo: iconImageView.bottomAnchor, constant: PXLayout.S_MARGIN),
                labelsContainerView.leadingAnchor.constraint(equalTo: self.leadingAnchor, constant: PXLayout.S_MARGIN),
                labelsContainerView.trailingAnchor.constraint(equalTo: self.trailingAnchor, constant: -PXLayout.S_MARGIN),
                labelsContainerView.centerXAnchor.constraint(equalTo: self.centerXAnchor),
                labelsContainerView.heightAnchor.constraint(equalToConstant: 40)
            ])
        }
    }

    func buildCircleImage(with image: UIImage?) -> PXUIImageView {
        let iconSize = data.compactMode ? COMPACT_ICON_SIZE : DEFAULT_ICON_SIZE
        return PXUIImageView(image: image, size: iconSize)
    }
}
