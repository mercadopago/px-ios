//
//  PXItemRenderer.swift
//  MercadoPagoSDK
//
//  Created by Eden Torres on 3/1/18.
//  Copyright © 2018 MercadoPago. All rights reserved.
//

import Foundation

struct PXItemRenderer {
    let CONTENT_WIDTH_PERCENT: CGFloat = 86.0
    //Image
    static let IMAGE_WIDTH: CGFloat = 48.0
    static let IMAGE_HEIGHT: CGFloat = 48.0

    let margin = PXLayout.S_MARGIN
    
    // Font sizes
    static let TITLE_FONT_SIZE = PXLayout.M_FONT
    static let DESCRIPTION_FONT_SIZE = PXLayout.XXS_FONT
    static let QUANTITY_FONT_SIZE = PXLayout.XS_FONT
    static let AMOUNT_FONT_SIZE = PXLayout.XS_FONT
    
    func expressRender(_ itemComponent: PXItemComponent) -> PXExpressItemContainerView {
        let itemView = PXExpressItemContainerView()
        itemView.backgroundColor = itemComponent.props.backgroundColor
        itemView.translatesAutoresizingMaskIntoConstraints = false
        
        let (imageUrl, imageObj) = buildItemImageUrl(imageURL: itemComponent.props.imageURL, collectorImage: itemComponent.props.reviewScreenPreference.getCollectorIcon())
        
        itemView.itemImage = UIImageView()
        
        // Item icon
        if let itemImage = itemView.itemImage {
            
            if let url = imageUrl  {
                buildCircle(targetImageView: itemImage)
                itemImage.backgroundColor = ThemeManager.shared.getPlaceHolderColor()
                Utils().loadImageWithCache(withUrl: url, targetImage: itemImage, placeHolderImage: nil)
            } else {
                itemImage.image = imageObj
            }
            
            itemView.addSubview(itemImage)
            PXLayout.pinLeft(view: itemImage, withMargin: margin).isActive = true
            PXLayout.setHeight(owner: itemImage, height: PXItemRenderer.IMAGE_HEIGHT).isActive = true
            PXLayout.setWidth(owner: itemImage, width: PXItemRenderer.IMAGE_WIDTH).isActive = true
            PXLayout.pinTop(view: itemImage, withMargin: margin).isActive = true
            PXLayout.pinBottom(view: itemImage, withMargin: margin).isActive = true
        }
        
        // Title
        let title = UILabel()
        title.translatesAutoresizingMaskIntoConstraints = false
        itemView.itemTitle = title
        itemView.addSubview(title)
        title.attributedText = itemComponent.getTitle()?.toAttributedString()
        title.font = Utils.getFont(size: PXLayout.XS_FONT)
        title.textColor = itemComponent.props.boldLabelColor
        title.textAlignment = .left
        title.numberOfLines = 0
        PXLayout.pinTop(view: itemView.itemTitle!, withMargin: margin).isActive = true
        PXLayout.put(view: itemView.itemTitle!, rightOf: itemView.itemImage!, withMargin: margin).isActive = true
        PXLayout.pinRight(view: itemView.itemTitle!, withMargin: margin).isActive = true
        PXLayout.setHeight(owner: itemView.itemTitle!, height: 20).isActive = true
        
        
        // Item description
        let detailLabel = UILabel()
        detailLabel.translatesAutoresizingMaskIntoConstraints = false
        itemView.addSubview(detailLabel)
        itemView.itemDescription = detailLabel
        detailLabel.attributedText = itemComponent.getDescription()?.toAttributedString()
        detailLabel.font = Utils.getFont(size: PXLayout.XS_FONT)
        detailLabel.textColor = itemComponent.props.lightLabelColor
        detailLabel.textAlignment = .left
        PXLayout.setHeight(owner: detailLabel, height: 20).isActive = true
        PXLayout.pinLeft(view: itemView.itemDescription!, to: itemView.itemTitle!).isActive = true
        PXLayout.pinRight(view: itemView.itemDescription!, to: itemView.itemTitle!).isActive = true
        PXLayout.pinBottom(view: itemView.itemDescription!, to: itemView.itemImage!).isActive = true
        
        
        
        
        
        
        
        
//
//        // Item quantity
//        if itemComponent.shouldShowQuantity() {
//            itemView.itemQuantity = buildQuantity(with: itemComponent.getQuantity(), labelColor: itemComponent.props.lightLabelColor)
//        }
//        if let itemQuantity = itemView.itemQuantity {
//            itemView.addSubviewToButtom(itemQuantity, withMargin: PXLayout.XS_MARGIN)
//            PXLayout.centerHorizontally(view: itemQuantity).isActive = true
//            PXLayout.matchWidth(ofView: itemQuantity, withPercentage: CONTENT_WIDTH_PERCENT).isActive = true
//        }
//
//        // Item amount
//        if itemComponent.shouldShowUnitAmount() {
//            itemView.itemAmount = buildItemAmount(with: itemComponent.getUnitAmountPrice(), title: itemComponent.getUnitAmountTitle(), labelColor: itemComponent.props.lightLabelColor)
//        }
//        if let itemAmount = itemView.itemAmount {
//            let margin = itemView.itemQuantity == nil ? PXLayout.XS_MARGIN : PXLayout.XXXS_MARGIN
//            itemView.addSubviewToButtom(itemAmount, withMargin: margin)
//            PXLayout.centerHorizontally(view: itemAmount).isActive = true
//            PXLayout.matchWidth(ofView: itemAmount, withPercentage: CONTENT_WIDTH_PERCENT).isActive = true
//        }
//
//        itemView.pinLastSubviewToBottom(withMargin: PXLayout.L_MARGIN)?.isActive = true
        return itemView
    }
    
    func render(_ itemComponent: PXItemComponent) -> PXItemContainerView {
        let itemView = PXItemContainerView()
        itemView.backgroundColor = itemComponent.props.backgroundColor
        itemView.translatesAutoresizingMaskIntoConstraints = false

        let (imageUrl, imageObj) = buildItemImageUrl(imageURL: itemComponent.props.imageURL, collectorImage: itemComponent.props.reviewScreenPreference.getCollectorIcon())
        
        itemView.itemImage = UIImageView()

        // Item icon
        if let itemImage = itemView.itemImage {
            
            if let url = imageUrl  {
                buildCircle(targetImageView: itemImage)
                itemImage.backgroundColor = ThemeManager.shared.getPlaceHolderColor()
                Utils().loadImageWithCache(withUrl: url, targetImage: itemImage, placeHolderImage: nil)
            } else {
                itemImage.image = imageObj
            }
            
            itemView.addSubview(itemImage)
            PXLayout.centerHorizontally(view: itemImage).isActive = true
            PXLayout.setHeight(owner: itemImage, height: PXItemRenderer.IMAGE_HEIGHT).isActive = true
            PXLayout.setWidth(owner: itemImage, width: PXItemRenderer.IMAGE_WIDTH).isActive = true
            PXLayout.pinTop(view: itemImage, withMargin: PXLayout.L_MARGIN).isActive = true
        }

        // Item Title
        if itemComponent.shouldShowTitle() {
            itemView.itemTitle = buildTitle(with: itemComponent.getTitle(), labelColor: itemComponent.props.boldLabelColor)
        }
        if let itemTitle = itemView.itemTitle {
            itemView.addSubviewToButtom(itemTitle, withMargin: PXLayout.S_MARGIN)
            PXLayout.centerHorizontally(view: itemTitle).isActive = true
            PXLayout.matchWidth(ofView: itemTitle, withPercentage: CONTENT_WIDTH_PERCENT).isActive = true
        }

        // Item description
        if itemComponent.shouldShowDescription() {
            itemView.itemDescription = buildDescription(with: itemComponent.getDescription(), labelColor: itemComponent.props.lightLabelColor)
        }
        if let itemDescription = itemView.itemDescription {
            itemView.addSubviewToButtom(itemDescription, withMargin: PXLayout.XS_MARGIN)
            PXLayout.centerHorizontally(view: itemDescription).isActive = true
            PXLayout.matchWidth(ofView: itemDescription, withPercentage: CONTENT_WIDTH_PERCENT).isActive = true
        }

        // Item quantity
        if itemComponent.shouldShowQuantity() {
            itemView.itemQuantity = buildQuantity(with: itemComponent.getQuantity(), labelColor: itemComponent.props.lightLabelColor)
        }
        if let itemQuantity = itemView.itemQuantity {
            itemView.addSubviewToButtom(itemQuantity, withMargin: PXLayout.XS_MARGIN)
            PXLayout.centerHorizontally(view: itemQuantity).isActive = true
            PXLayout.matchWidth(ofView: itemQuantity, withPercentage: CONTENT_WIDTH_PERCENT).isActive = true
        }

        // Item amount
        if itemComponent.shouldShowUnitAmount() {
            itemView.itemAmount = buildItemAmount(with: itemComponent.getUnitAmountPrice(), title: itemComponent.getUnitAmountTitle(), labelColor: itemComponent.props.lightLabelColor)
        }
        if let itemAmount = itemView.itemAmount {
            let margin = itemView.itemQuantity == nil ? PXLayout.XS_MARGIN : PXLayout.XXXS_MARGIN
            itemView.addSubviewToButtom(itemAmount, withMargin: margin)
            PXLayout.centerHorizontally(view: itemAmount).isActive = true
            PXLayout.matchWidth(ofView: itemAmount, withPercentage: CONTENT_WIDTH_PERCENT).isActive = true
        }

        itemView.pinLastSubviewToBottom(withMargin: PXLayout.L_MARGIN)?.isActive = true
        return itemView
    }
}

extension PXItemRenderer {

    fileprivate func buildItemImageUrl(imageURL: String?, collectorImage: UIImage? = nil) -> (String?, UIImage?) {
        if imageURL != nil {
            return (imageURL, nil)
        } else if let image = collectorImage {
            return (nil, image)
        } else {
            return (nil, MercadoPago.getImage("MPSDK_review_iconoCarrito"))
        }
    }
    
    fileprivate func buildTitle(with text: String?, labelColor: UIColor) -> UILabel? {
        guard let text = text else {
            return nil
        }

        let font = Utils.getFont(size: PXItemRenderer.TITLE_FONT_SIZE)
        return buildLabel(text: text, color: labelColor, font: font)
    }

    fileprivate func buildDescription(with text: String?, labelColor: UIColor) -> UILabel? {
        guard let text = text else {
            return nil
        }

        let font = Utils.getFont(size: PXItemRenderer.DESCRIPTION_FONT_SIZE)
        return buildLabel(text: text, color: labelColor, font: font)
    }

    func buildQuantity(with text: String?, labelColor: UIColor) -> UILabel? {
        guard let text = text else {
            return nil
        }

        let font = Utils.getFont(size: PXItemRenderer.QUANTITY_FONT_SIZE)
        return buildLabel(text: text, color: labelColor, font: font)
    }

    fileprivate func buildItemAmount(with amount: Double?, title: String?, labelColor: UIColor) -> UILabel? {
        guard let title = title, let amount = amount else {
            return nil
        }

        let font = Utils.getFont(size: PXItemRenderer.AMOUNT_FONT_SIZE)

        let unitPrice = buildAttributedUnitAmount(amount: amount, color: labelColor, fontSize: font.pointSize)
        let unitPriceTitle = NSMutableAttributedString(string: title, attributes: [NSFontAttributeName: font])
        unitPriceTitle.append(unitPrice)

        return buildLabel(attributedText: unitPriceTitle, color: labelColor, font: font)
    }

    fileprivate func buildAttributedUnitAmount(amount: Double, color: UIColor, fontSize: CGFloat) -> NSAttributedString {
        let currency = MercadoPagoContext.getCurrency()
        return Utils.getAmountFormatted(amount: amount, thousandSeparator: currency.thousandsSeparator, decimalSeparator: currency.decimalSeparator, addingCurrencySymbol: currency.symbol).toAttributedString()
    }

    fileprivate func buildLabel(text: String, color: UIColor, font: UIFont) -> UILabel {
        let label = UILabel()
        label.textAlignment = .center
        label.text = text
        label.textColor = color
        label.lineBreakMode = .byWordWrapping
        label.numberOfLines = 0
        label.font = font
        let screenWidth = PXLayout.getScreenWidth(applyingMarginFactor: CONTENT_WIDTH_PERCENT)
        let height = UILabel.requiredHeight(forText: text, withFont: font, inWidth: screenWidth)
        PXLayout.setHeight(owner: label, height: height).isActive = true
        return label
    }

    fileprivate func buildLabel(attributedText: NSAttributedString, color: UIColor, font: UIFont) -> UILabel {
        let label = UILabel()
        label.textAlignment = .center
        label.textColor = color
        label.attributedText = attributedText
        label.lineBreakMode = .byWordWrapping
        label.numberOfLines = 0
        label.font = font
        let screenWidth = PXLayout.getScreenWidth(applyingMarginFactor: CONTENT_WIDTH_PERCENT)
        let height = UILabel.requiredHeight(forAttributedText: attributedText, withFont: font, inWidth: screenWidth)
        PXLayout.setHeight(owner: label, height: height).isActive = true
        return label
    }
    
    fileprivate func buildCircle(targetImageView:UIImageView?) {
        targetImageView?.layer.masksToBounds = false
        targetImageView?.layer.cornerRadius = PXItemRenderer.IMAGE_HEIGHT/2
        targetImageView?.clipsToBounds = true
        targetImageView?.translatesAutoresizingMaskIntoConstraints = false
        targetImageView?.contentMode = .scaleAspectFill
    }
}

