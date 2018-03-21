//
//  FooterRenderer.swift
//  TestAutolayout
//
//  Created by Demian Tejo on 10/19/17.
//  Copyright © 2017 Demian Tejo. All rights reserved.
//

import UIKit
import AVFoundation

class PXFooterRenderer: NSObject {

    let BUTTON_HEIGHT: CGFloat = 50.0

    func render(_ footer: PXFooterComponent) -> PXFooterView {
        let fooView = PXFooterView()
        var topView: UIView = fooView
        fooView.translatesAutoresizingMaskIntoConstraints = false
        fooView.backgroundColor = .pxWhite
        if let principalAction = footer.props.buttonAction {
            let principalButton = self.buildPrincipalButton(with: principalAction, color: footer.props.primaryColor)
            fooView.principalButton = principalButton
            fooView.addSubview(principalButton)
            PXLayout.pinTop(view: principalButton, to: topView, withMargin: PXLayout.S_MARGIN).isActive = true
            PXLayout.pinLeft(view: principalButton, to: fooView, withMargin: PXLayout.S_MARGIN).isActive = true
            PXLayout.pinRight(view: principalButton, to: fooView, withMargin: PXLayout.S_MARGIN).isActive = true
            PXLayout.setHeight(owner: principalButton, height: BUTTON_HEIGHT).isActive = true
            topView = principalButton
        }
        if let linkAction = footer.props.linkAction {

            let linkButton = self.buildLinkButton(with: linkAction, color: footer.props.primaryColor)

            fooView.linkButton = linkButton
            fooView.addSubview(linkButton)
            if topView != fooView {
               PXLayout.put(view: linkButton, onBottomOf: topView, withMargin: PXLayout.S_MARGIN).isActive = true
            } else {
                PXLayout.pinTop(view: linkButton, to: fooView, withMargin: PXLayout.S_MARGIN).isActive = true
            }

            PXLayout.pinLeft(view: linkButton, to: fooView, withMargin: PXLayout.S_MARGIN).isActive = true
            PXLayout.pinRight(view: linkButton, to: fooView, withMargin: PXLayout.S_MARGIN).isActive = true
            PXLayout.setHeight(owner: linkButton, height: BUTTON_HEIGHT).isActive = true
            topView = linkButton
        }
        if topView != fooView { // Si hay al menos alguna vista dentro del footer, agrego un margen
            PXLayout.pinBottom(view: topView, to: fooView, withMargin: PXLayout.M_MARGIN).isActive = true
        }
        return fooView
    }
    
    func expressRender(_ footer: PXFooterComponent) -> PXFooterView {
        let fooView = PXFooterView()
        var topView: UIView = fooView
        fooView.translatesAutoresizingMaskIntoConstraints = false
        fooView.backgroundColor = .pxWhite
        if let principalAction = footer.props.buttonAction {
            let principalButton = self.buildPrincipalButton(with: principalAction, color: footer.props.primaryColor)
            fooView.principalButton = principalButton
            fooView.addSubview(principalButton)
            PXLayout.pinTop(view: principalButton, to: topView, withMargin: PXLayout.S_MARGIN).isActive = true
            PXLayout.pinLeft(view: principalButton, to: fooView, withMargin: PXLayout.S_MARGIN).isActive = true
            PXLayout.pinRight(view: principalButton, to: fooView, withMargin: PXLayout.S_MARGIN).isActive = true
            PXLayout.setHeight(owner: principalButton, height: BUTTON_HEIGHT).isActive = true
            topView = principalButton
        }
        
        if topView != fooView {
            PXLayout.pinBottom(view: topView, to: fooView, withMargin: PXLayout.M_MARGIN).isActive = true
        }
        
        return fooView
    }
    
    func buildPrincipalButton(with footerAction: PXComponentAction, color: UIColor? = .pxBlueMp) -> UIButton {
        let button = PXPrimaryButton()
        button.translatesAutoresizingMaskIntoConstraints = false
        button.layer.cornerRadius = 3
        button.setTitle(footerAction.label, for: .normal)
        button.add(for: .touchUpInside, footerAction.action)
        return button
    }
    func buildLinkButton(with footerAction: PXComponentAction, color: UIColor? = .pxBlueMp) -> UIButton {
        let linkButton = PXSecondaryButton()
        linkButton.translatesAutoresizingMaskIntoConstraints = false
        linkButton.setTitle(footerAction.label, for: .normal)
        linkButton.add(for: .touchUpInside, footerAction.action)
        return linkButton
    }
}

protocol PXButtonAnimationDelegate: NSObjectProtocol {
    func didFinishAnimation()
}

class PXFooterView: UIView {
    
    public var principalButton: UIButton?
    public var linkButton: UIButton?
    weak var animationDelegate: PXButtonAnimationDelegate?
    
    func startLoading() {
        
        let successColor = ThemeManager.shared.getTheme().successColor()
        let initialFrame = self.principalButton!.frame
        let newFrame = CGRect(x: self.principalButton!.frame.midX-self.principalButton!.frame.height/2, y: self.principalButton!.frame.midY-self.principalButton!.frame.height/2, width: self.principalButton!.frame.height , height: self.principalButton!.frame.height)
        
        UIView.animate(withDuration: 0.5,
                       animations: {
                        self.principalButton?.isUserInteractionEnabled = false
                        self.principalButton?.setTitle("", for: .normal)
                        self.principalButton?.frame = newFrame
                        self.principalButton!.layer.cornerRadius = self.principalButton!.frame.height/2
        },
                       completion: { _ in
                        
                        
                        UIView.animate(withDuration: 0.3, animations: {
                            self.principalButton!.backgroundColor = successColor
                        }, completion: { _ in
                            
                            let scaleFactor: CGFloat = 0.40
                            
                            let successImage = UIImageView(frame: CGRect(x: newFrame.width/2 - (newFrame.width*scaleFactor)/2, y: newFrame.width/2 - (newFrame.width*scaleFactor)/2, width: newFrame.width*scaleFactor, height:newFrame.height*scaleFactor))
                            
                            successImage.image = MercadoPago.getImage("success_image")
                            successImage.contentMode = .scaleAspectFit
                            successImage.alpha = 0
                            
                            self.principalButton?.addSubview(successImage)
                            
                            let systemSoundID: SystemSoundID = 1109
                            AudioServicesPlaySystemSound(systemSoundID)
                            
                            if #available(iOS 10.0, *) {
                                let notification = UINotificationFeedbackGenerator()
                                notification.notificationOccurred(.success)
                            } else {
                                // Fallback on earlier versions
                            }
                            
                            UIView.animate(withDuration: 0.6, animations: {
                                successImage.alpha = 1
                                successImage.transform = CGAffineTransform(scaleX: 1.3, y: 1.3)
                            }) { _ in
                                
                                UIView.animate(withDuration: 0.3, animations: {
                                    successImage.alpha = 0
                                }, completion: { _ in
                                    
                                    UIView.animate(withDuration: 0.6, animations: {
                                        self.principalButton?.frame = initialFrame
                                        self.principalButton?.layer.cornerRadius = 10
                                    }, completion: { _ in
                                        
                                        let successLabel: UILabel = UILabel()
                                        successLabel.translatesAutoresizingMaskIntoConstraints = false
                                        successLabel.alpha = 0
                                        successLabel.text = "Guardamos el recibo en tu galeria."
                                        successLabel.numberOfLines = 2
                                        successLabel.textColor = .white
                                        successLabel.textAlignment = .center
                                        successLabel.backgroundColor = .clear
                                        successLabel.font = Utils.getFont(size: PXLayout.XS_FONT)
                                        self.principalButton?.addSubview(successLabel)
                                        
                                        PXLayout.matchHeight(ofView: successLabel).isActive = true
                                        PXLayout.pinTop(view: successLabel).isActive = true
                                        PXLayout.pinLeft(view: successLabel, withMargin: 5).isActive = true
                                        PXLayout.pinRight(view: successLabel, withMargin: 5).isActive = true

                                        UIView.animate(withDuration: 0.5, animations: {
                                            self.backgroundColor = successColor
                                        })
                                        
                                         UIView.animate(withDuration: 0.2, animations: {
                                            successLabel.alpha = 1
                                         }) { _ in
                                            self.animationDelegate?.didFinishAnimation()
                                        }
                                        
                                    })
                                })
                            }
                        })
        })
    }
}
