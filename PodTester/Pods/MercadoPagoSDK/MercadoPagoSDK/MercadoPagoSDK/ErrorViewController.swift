//
//  ErrorViewController.swift
//  MercadoPagoSDK
//
//  Created by Maria cristina rodriguez on 17/5/16.
//  Copyright © 2016 MercadoPago. All rights reserved.
//

import UIKit

open class ErrorViewController: MercadoPagoUIViewController {

    @IBOutlet weak var  errorTitle: MPLabel! 
    
    @IBOutlet internal weak var errorSubtitle: MPLabel!
    
    @IBOutlet internal weak var errorIcon: UIImageView!
    
    @IBOutlet weak var exitButton: MPButton!
    
    @IBOutlet weak var retryButton: MPButton!
    var error : MPSDKError!
    var callback : ((Void) -> Void)?
    
    override open var screenName : String { get { return "ERROR" } }
    
   open static var defaultErrorCancel : ((Void) -> Void)?
    
    open var exitErrorCallback : ((Void) -> Void)!
    
    public init(error : MPSDKError!, callback : ((Void) -> Void)?, callbackCancel : ((Void) -> Void)? = nil){
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
    
    override open func viewDidLoad() {
        super.viewDidLoad()
        self.errorTitle.text = error.message
        
        let normalAttributes: [String:AnyObject] = [NSFontAttributeName : Utils.getFont(size: 14)]
                                                    
        self.errorSubtitle.attributedText = NSAttributedString(string :error.messageDetail, attributes: normalAttributes)
        self.exitButton.addTarget(self, action: #selector(ErrorViewController.invokeExitCallback), for: .touchUpInside)
        
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
    
    internal func invokeCallback(){
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
    
    internal func invokeExitCallback(){
        if let cancelCallback = ErrorViewController.defaultErrorCancel {
            cancelCallback()
        }
            self.exitErrorCallback()
        
       
    }
    
    
    
}
