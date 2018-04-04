//
//  PXHeaderRenderer.swift
//  TestAutolayout
//
//  Created by Demian Tejo on 10/18/17.
//  Copyright © 2017 Demian Tejo. All rights reserved.
//

import UIKit

class PXHeaderRenderer: NSObject {

    //Image
    let IMAGE_WIDTH: CGFloat = 90.0
    let IMAGE_HEIGHT: CGFloat = 90.0

    let BADGE_IMAGE_SIZE: CGFloat = 30.0
    let BADGE_HORIZONTAL_OFFSET: CGFloat = -6.0
    let BADGE_VERTICAL_OFFSET: CGFloat = 0.0

    //Image Title
    let STATUS_TITLE_HEIGHT: CGFloat = 18.0
    static let LABEL_FONT_SIZE: CGFloat = PXLayout.XS_FONT

    //Text
    static let TITLE_FONT_SIZE: CGFloat = PXLayout.XXXL_FONT

    let CONTENT_WIDTH_PERCENT: CGFloat = 86.0

    func render(_ header: PXHeaderComponent ) -> PXHeaderView {
        let headerView = PXHeaderView()
        headerView.backgroundColor = header.props.backgroundColor
        headerView.translatesAutoresizingMaskIntoConstraints = false

        //Image
        headerView.circleImage = buildCircleImage(with: header.props.productImage)
        headerView.addSubview(headerView.circleImage!)
        PXLayout.centerHorizontally(view: headerView.circleImage!, to: headerView.circleImage!.superview!).isActive = true
        PXLayout.pinTop(view: headerView.circleImage!, withMargin: PXLayout.XXXL_MARGIN).isActive = true

        //Badge Image
        headerView.badgeImage = buildBudgeImage(with: header.props.statusImage)
        headerView.addSubview(headerView.badgeImage!)
        PXLayout.pinRight(view: headerView.badgeImage!, to: headerView.circleImage!, withMargin: BADGE_HORIZONTAL_OFFSET).isActive = true
        PXLayout.pinBottom(view: headerView.badgeImage!, to: headerView.circleImage!, withMargin: BADGE_VERTICAL_OFFSET).isActive = true

        //Status Label
        headerView.statusLabel = buildStatusLabel(with: header.props.labelText, in: headerView, onBottomOf: headerView.circleImage!)
        PXLayout.centerHorizontally(view: headerView.statusLabel!, to: headerView.statusLabel!.superview!).isActive = true
        PXLayout.matchWidth(ofView: headerView.statusLabel!, toView: headerView.statusLabel!.superview!, withPercentage: CONTENT_WIDTH_PERCENT).isActive = true

        //Message Label
        headerView.messageLabel = buildMessageLabel(with: header.props.title)
        headerView.addSubview(headerView.messageLabel!)
        PXLayout.centerHorizontally(view: headerView.messageLabel!, to: headerView.messageLabel!.superview!).isActive = true
        PXLayout.put(view: headerView.messageLabel!, onBottomOf: headerView.statusLabel!, withMargin: PXLayout.M_MARGIN).isActive = true
        PXLayout.matchWidth(ofView: headerView.messageLabel!, toView: headerView.messageLabel!.superview!, withPercentage: CONTENT_WIDTH_PERCENT).isActive = true
        PXLayout.pinBottom(view: headerView.messageLabel!, to: headerView.messageLabel!.superview!, withMargin: PXLayout.XL_MARGIN).isActive = true

        return headerView
    }

    func buildCircleImage(with image: UIImage?) -> UIImageView {
        let circleImage = UIImageView(frame: CGRect(x: 0, y: 0, width: IMAGE_WIDTH, height: IMAGE_HEIGHT))
        circleImage.layer.masksToBounds = false
        circleImage.layer.cornerRadius = circleImage.frame.height/2
        circleImage.clipsToBounds = true
        circleImage.translatesAutoresizingMaskIntoConstraints = false
        circleImage.image = image
        circleImage.contentMode = .scaleAspectFill
        circleImage.backgroundColor = .clear
        PXLayout.setHeight(owner: circleImage, height: IMAGE_WIDTH).isActive = true
        PXLayout.setWidth(owner: circleImage, width: IMAGE_HEIGHT).isActive = true
        return circleImage
    }

    func buildBudgeImage(with image: UIImage?) -> UIImageView {
        let badgeImage = UIImageView()
        badgeImage.translatesAutoresizingMaskIntoConstraints = false
        badgeImage.image = image
        PXLayout.setHeight(owner: badgeImage, height: BADGE_IMAGE_SIZE).isActive = true
        PXLayout.setWidth(owner: badgeImage, width: BADGE_IMAGE_SIZE).isActive = true
        return badgeImage
    }
    func buildStatusLabel(with text: NSAttributedString?, in superView: UIView, onBottomOf upperView: UIView) -> UILabel {
        let statusLabel = UILabel()
        let font = Utils.getFont(size: PXHeaderRenderer.LABEL_FONT_SIZE)
        statusLabel.translatesAutoresizingMaskIntoConstraints = false
        statusLabel.textAlignment = .center
        statusLabel.textColor = .white
        statusLabel.font = font
        superView.addSubview(statusLabel)
        if text != nil {
            PXLayout.put(view: statusLabel, onBottomOf: upperView, withMargin: PXLayout.S_MARGIN).isActive = true
            statusLabel.attributedText = text
            PXLayout.setHeight(owner: statusLabel, height: STATUS_TITLE_HEIGHT).isActive = true
        } else {
            PXLayout.put(view: statusLabel, onBottomOf: upperView).isActive = true
            PXLayout.setHeight(owner: statusLabel, height: 0).isActive = true
        }
        return statusLabel
    }

    func buildMessageLabel(with text: NSAttributedString) -> UILabel {
        let messageLabel = UILabel()
        let font = Utils.getFont(size: PXHeaderRenderer.TITLE_FONT_SIZE)
        messageLabel.textAlignment = .center
        messageLabel.translatesAutoresizingMaskIntoConstraints = false
        messageLabel.attributedText = text
        messageLabel.textColor = .white
        messageLabel.lineBreakMode = .byWordWrapping
        messageLabel.numberOfLines = 0
        messageLabel.font = font
        let screenWidth = PXLayout.getScreenWidth(applyingMarginFactor: CONTENT_WIDTH_PERCENT)
        let height = UILabel.requiredHeight(forAttributedText: text, withFont: font, inWidth: screenWidth)
        PXLayout.setHeight(owner: messageLabel, height: height).isActive = true
        return messageLabel
    }
}

public class PXHeaderView: PXComponentView {
    public var circleImage: UIImageView?
    public var badgeImage: UIImageView?
    public var statusLabel: UILabel?
    public var messageLabel: UILabel?
}
