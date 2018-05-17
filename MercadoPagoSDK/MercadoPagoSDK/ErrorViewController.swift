//
//  ErrorViewController.swift
//  MercadoPagoSDK
//
//  Created by Maria cristina rodriguez on 17/5/16.
//  Copyright © 2016 MercadoPago. All rights reserved.
//

import UIKit
import MercadoPagoPXTracking

@objcMembers
open class ErrorViewController: MercadoPagoUIViewController {

    @IBOutlet weak var  errorTitle: MPLabel!

    @IBOutlet internal weak var errorSubtitle: MPLabel!

    @IBOutlet internal weak var errorIcon: UIImageView!

    @IBOutlet weak var exitButton: UIButton!

    @IBOutlet weak var retryButton: UIButton!

    var error: MPSDKError!
    var callback: (() -> Void)?

    override open var screenName: String { return TrackingUtil.SCREEN_NAME_ERROR }
    override open var screenId: String { return TrackingUtil.SCREEN_ID_ERROR }

    open static var defaultErrorCancel: (() -> Void)?

    open var exitErrorCallback: (() -> Void)!

    public init(error: MPSDKError!, callback: (() -> Void)?, callbackCancel: (() -> Void)? = nil) {
        super.init(nibName: "ErrorViewController", bundle: MercadoPago.getBundle())
        self.error = error
        self.exitErrorCallback = {
            self.dismiss(animated: true, completion: {
                if self.callbackCancel != nil {
                    self.callbackCancel!()
                }
            })
        }
        self.callbackCancel = callbackCancel
        self.callback = callback
    }

    required public init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override open func trackInfo() {
        var metadata: [String: String] = [:]

        if let statusError = error.apiException?.status {
            metadata[TrackingUtil.METADATA_ERROR_STATUS] = String(describing: statusError)
        }
        if let causeArray = error.apiException?.cause, causeArray.count > 0 {
            if !String.isNullOrEmpty(causeArray[0].code) {
                metadata[TrackingUtil.METADATA_ERROR_CODE] = causeArray[0].code
            }
        }

        if !String.isNullOrEmpty(error.requestOrigin) {
            metadata[TrackingUtil.METADATA_ERROR_REQUEST] = error.requestOrigin
        }

        if !String.isNullOrEmpty(error.message) {
            metadata["error_message"] = error.message
        }

        MPXTracker.sharedInstance.trackScreen(screenId: screenId, screenName: screenName, properties: metadata)
    }

    override open func viewDidLoad() {
        super.viewDidLoad()
        self.errorTitle.text = error.message
        self.errorSubtitle.textColor = UIColor.pxBrownishGray

        let normalAttributes: [NSAttributedStringKey: AnyObject] = [NSAttributedStringKey.font: Utils.getFont(size: 14)]

        self.errorSubtitle.attributedText = NSAttributedString(string: error.errorDetail, attributes: normalAttributes)
        self.exitButton.addTarget(self, action: #selector(ErrorViewController.invokeExitCallback), for: .touchUpInside)

        self.exitButton.setTitle("Salir".localized, for: .normal)
        self.retryButton.setTitle("Reintentar".localized, for: .normal)

        self.exitButton.setTitleColor(ThemeManager.shared.getAccentColor(), for: .normal)
        self.retryButton.setTitleColor(ThemeManager.shared.getAccentColor(), for: .normal)

        if self.error.retry! {
            self.retryButton.addTarget(self, action: #selector(ErrorViewController.invokeCallback), for: .touchUpInside)
            self.retryButton.isHidden = false
        } else {
            self.retryButton.isHidden = true
        }
    }

    override open func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }

    @objc internal func invokeCallback() {
        if callback != nil {
            callback!()
        } else {
            if self.navigationController != nil {
                self.navigationController!.dismiss(animated: true, completion: {})
            } else {
                self.dismiss(animated: true, completion: {})
            }
        }
    }

    @objc internal func invokeExitCallback() {
        if let cancelCallback = ErrorViewController.defaultErrorCancel {
            cancelCallback()
        }
            self.exitErrorCallback()

    }

}
