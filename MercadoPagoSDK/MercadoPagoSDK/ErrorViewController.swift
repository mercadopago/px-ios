//
//  ErrorViewController.swift
//  MercadoPagoSDK
//
//  Created by Maria cristina rodriguez on 17/5/16.
//  Copyright © 2016 MercadoPago. All rights reserved.
//

import UIKit

public class ErrorViewController: MercadoPagoUIViewController {

    @IBOutlet weak var errorTitle: MPLabel!
    
    @IBOutlet weak var errorIcon: UIImageView!
    
    
    @IBOutlet weak var retryButton: MPButton!
    var error : MPError!
    var callback : (Void -> Void)?
    
    public init(error : MPError!, callback : (Void -> Void)?, callbackCancel : (Void -> Void)? = nil){
        super.init(nibName: "ErrorViewController", bundle: MercadoPago.getBundle())
        self.error = error
        self.callbackCancel = {
            self.dismissViewControllerAnimated(true, completion: {
                if callbackCancel != nil {
                    callbackCancel!()
                }
            })
        }
        self.callback = callback
    }
    
    required public init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override public func viewDidLoad() {
        super.viewDidLoad()
        self.errorTitle.text = error.message
        
        if self.error.retry! {
            self.errorIcon.image = MercadoPago.getImage("ic_refresh")
            self.retryButton.addTarget(self, action: "invokeCallback", forControlEvents: .TouchUpInside)
            self.retryButton.hidden = false
        } else {
            self.retryButton.setTitle("Salir".localized, forState: .Normal)
            self.retryButton.addTarget(self, action: "invokeCallbackCancel", forControlEvents: .TouchUpInside)
        }
    }
    
    override public func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    internal func invokeCallback(){
        if callback != nil {
            callback!()
        } else {
            if self.navigationController != nil {
                self.navigationController!.dismissViewControllerAnimated(true, completion: {})
            } else {
                self.dismissViewControllerAnimated(true, completion: {})
            }
        }
    }
    

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}
