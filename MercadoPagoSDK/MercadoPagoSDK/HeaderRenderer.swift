//
//  HeaderRenderer.swift
//  TestAutolayout
//
//  Created by Demian Tejo on 10/18/17.
//  Copyright © 2017 Demian Tejo. All rights reserved.
//

import UIKit

class HeaderRenderer: NSObject {

    let XXL_MARGIN : CGFloat = 50.0
    let XL_MARGIN : CGFloat = 42.0
    let L_MARGIN : CGFloat = 24.0
    let S_MARGIN : CGFloat = 16.0
    
    //Image
    let IMAGE_SIZE : CGFloat = 90.0
    
    let BADGE_IMAGE_SIZE : CGFloat = 30.0
    
    //Image Title
    let STATUS_TITLE_HEIGHT : CGFloat = 15.0
    let STATUS_FONT_SIZE : CGFloat = 14.0
    
    //Text
    let MESSAGE_FONT_SIZE : CGFloat = 26.0
    
    let CONTENT_WIDTH_PERCENT : CGFloat = 86.0
    
    func render(header : HeaderComponent ) -> UIView {
        let headerView = UIView()
        headerView.backgroundColor = header.backgroundColor
        headerView.translatesAutoresizingMaskIntoConstraints = false
        
        //IMAGE
        let image = UIImageView()
        image.translatesAutoresizingMaskIntoConstraints = false
        image.image = header.productImage
        headerView.addSubview(image)
        MPLayout.setHeight(owner: image, height: IMAGE_SIZE).isActive = true
        MPLayout.setWidth(owner: image, width: IMAGE_SIZE).isActive = true
        MPLayout.centerHorizontally(view: image, to: headerView).isActive = true
        MPLayout.pinTop(view: image, to: headerView, withMargin: XXL_MARGIN).isActive = true
        
        //BADGET IMAGE
        let badgeImage = UIImageView()
        badgeImage.translatesAutoresizingMaskIntoConstraints = false
        badgeImage.image = header.statusImage
        headerView.addSubview(badgeImage)
        MPLayout.setHeight(owner: badgeImage, height: BADGE_IMAGE_SIZE).isActive = true
        MPLayout.setWidth(owner: badgeImage, width: BADGE_IMAGE_SIZE).isActive = true
        MPLayout.pinRight(view: badgeImage, to: image).isActive = true
        MPLayout.pinBottom(view: badgeImage, to: image).isActive = true


        //IMAGE TITLE
        let statusLabel = UILabel()
        headerView.addSubview(statusLabel)
        statusLabel.textAlignment = .center
        statusLabel.translatesAutoresizingMaskIntoConstraints = false
        statusLabel.textColor = .pxWhite
        MPLayout.centerHorizontally(view: statusLabel, to: headerView).isActive = true
        MPLayout.put(view: statusLabel, onBottomOf:image, withMargin: S_MARGIN).isActive = true
        MPLayout.setWidth(ofView: statusLabel, asWidthOfView: headerView, percent: CONTENT_WIDTH_PERCENT).isActive = true
        statusLabel.text = header.title
        statusLabel.font = Utils.getFont(size: STATUS_FONT_SIZE)
        MPLayout.setHeight(owner: statusLabel, height: STATUS_TITLE_HEIGHT).isActive = true
        
        //MESSAGE
        let messageLabel = UILabel()
        headerView.addSubview(messageLabel)
        messageLabel.textAlignment = .center
        messageLabel.translatesAutoresizingMaskIntoConstraints = false
        MPLayout.centerHorizontally(view: messageLabel, to: headerView).isActive = true
        MPLayout.put(view: messageLabel, onBottomOf:statusLabel, withMargin: L_MARGIN).isActive = true
        messageLabel.text = header.subTitle
        messageLabel.textColor = .pxWhite
        messageLabel.font = Utils.getFont(size: MESSAGE_FONT_SIZE)
        messageLabel.lineBreakMode = .byWordWrapping
        messageLabel.numberOfLines = 0
        let screenSize = UIScreen.main.bounds
        let screenWidth = screenSize.width * CONTENT_WIDTH_PERCENT / 100
        let height = UILabel.requiredHight(forText: header.subTitle, withFont: messageLabel.font  , inWidth: screenWidth)
        MPLayout.setHeight(owner: messageLabel, height: height).isActive = true
        MPLayout.setWidth(ofView: messageLabel, asWidthOfView: headerView, percent: CONTENT_WIDTH_PERCENT).isActive = true
        MPLayout.pinBottom(view: messageLabel, to: headerView, withMargin: XL_MARGIN).isActive = true
        return headerView
    }
}
