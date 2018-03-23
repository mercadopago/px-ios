//
//  PXThemeObjects.swift
//  MercadoPagoSDK
//
//  Created by Juan sebastian Sanzone on 11/1/18.
//  Copyright © 2018 MercadoPago. All rights reserved.
//

import UIKit
import AVFoundation

protocol PXAnimatedButtonDelegate: NSObjectProtocol {
    func didFinishAnimation()
}

open class PXNavigationHeaderLabel: UILabel {

    override init(frame: CGRect) {
        super.init(frame: frame)
        if self.font != nil {
            self.font = Utils.getFont(size: self.font!.pointSize)
        }
    }

    required public init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        if self.font != nil {
            self.font = Utils.getFont(size: self.font!.pointSize)
        }
    }
}

open class PXSecondaryButton: UIButton {}
open class PXToolbar: UIToolbar {}
open class PXPrimaryButton: UIButton {
    weak var animationDelegate: PXAnimatedButtonDelegate?
    var progressView: JSSPogressView?
}

extension PXPrimaryButton {
    
    func startLoading(loadingText:String, retryText:String) {
        progressView = JSSPogressView(forView: self)
        progressView?.start(timeOutBlock: {
            // This is temporary. Only for now, without real payment.
            /*
                self.isEnabled = true
                self.setTitle(retryText, for: .normal)
                self.progressView?.doReset()
             */
            self.progressView?.doReset()
            self.animateFinishSuccess()
        })
        setTitle(loadingText, for: .normal)
        isEnabled = false
    }
    
    func animateFinishSuccess() {
        
        let successColor = ThemeManager.shared.getTheme().successColor()
        let successCheckImage = MercadoPago.getImage("success_image")
        let successMessage = "Guardamos el recibo en tu galeria."
        
        let newFrame = CGRect(x: self.frame.midX-self.frame.height/2, y: self.frame.midY-self.frame.height/2, width: self.frame.height , height: self.frame.height)
        
        UIView.animate(withDuration: 0.5,
                       animations: {
                        self.isUserInteractionEnabled = false
                        self.setTitle("", for: .normal)
                        self.frame = newFrame
                        self.layer.cornerRadius = self.frame.height/2
        },
                       completion: { _ in
                        
                        UIView.animate(withDuration: 0.3, animations: {
                            self.backgroundColor = successColor
                        }, completion: { _ in
                            
                            let scaleFactor: CGFloat = 0.40
                            let successImage = UIImageView(frame: CGRect(x: newFrame.width/2 - (newFrame.width*scaleFactor)/2, y: newFrame.width/2 - (newFrame.width*scaleFactor)/2, width: newFrame.width*scaleFactor, height:newFrame.height*scaleFactor))
                            
                            successImage.image = successCheckImage
                            successImage.contentMode = .scaleAspectFit
                            successImage.alpha = 0
                            
                            self.addSubview(successImage)
                            
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
                                successImage.transform = CGAffineTransform(scaleX: 1.5, y: 1.5)
                            }) { _ in
                                
                                UIView.animate(withDuration: 0.4, animations: {
                                    successImage.alpha = 0
                                }, completion: { _ in
                                    
                                    self.superview?.layer.masksToBounds = true
                                    
                                    UIView.animate(withDuration: 0.6, animations: {
                                        self.transform = CGAffineTransform(scaleX: 50, y: 50)
                                    }, completion: { _ in
                                        
                                        let successLabel: UILabel = UILabel()
                                        successLabel.translatesAutoresizingMaskIntoConstraints = false
                                        successLabel.alpha = 0
                                        successLabel.text = successMessage
                                        successLabel.numberOfLines = 2
                                        successLabel.textColor = .white
                                        successLabel.textAlignment = .center
                                        successLabel.backgroundColor = .clear
                                        successLabel.font = Utils.getFont(size: PXLayout.S_FONT)
                                        
                                        if let superView = self.superview {
                                            
                                            superView.addSubview(successLabel)
                                            
                                            PXLayout.setHeight(owner: successLabel, height: 50).isActive = true
                                            PXLayout.centerVertically(view: successLabel).isActive = true
                                            PXLayout.pinLeft(view: successLabel, withMargin: 18).isActive = true
                                            PXLayout.pinRight(view: successLabel, withMargin: 18).isActive = true
                                            
                                            UIView.animate(withDuration: 0.2, animations: {
                                                successLabel.alpha = 1
                                            }) { _ in
                                                self.animationDelegate?.didFinishAnimation()
                                            }
                                        }
                                    })
                                })
                            }
                        })
        })
    }
}
