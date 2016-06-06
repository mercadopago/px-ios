//
//  MercadoPagoUIViewController.swift
//  MercadoPagoSDK
//
//  Created by Maria cristina rodriguez on 3/2/16.
//  Copyright © 2016 MercadoPago. All rights reserved.
//

import UIKit
public class MPNavigationController : UINavigationController {
    internal func showLoading(){
        
        LoadingOverlay.shared.showOverlay(self.visibleViewController!.view, backgroundColor: UIColor(red: 217, green: 217, blue: 217), indicatorColor: UIColor.whiteColor())
    }
    
    internal func hideLoading(){
        LoadingOverlay.shared.hideOverlayView()
    }
    
}
public class MercadoPagoUIViewController: UIViewController, UIGestureRecognizerDelegate {

    internal var displayPreferenceDescription = false
    public var callbackCancel : (Void -> Void)?
    
    override public func viewDidLoad() {
        super.viewDidLoad()
        
        
        self.loadMPStyles()

    }
    
    var lastDefaultFontLabel : String?
    var lastDefaultFontTextField : String?
    var lastDefaultFontButton : String?

    static func loadFont(fontName: String) -> Bool {
        
        
        if let path = MercadoPago.getBundle()!.pathForResource(fontName, ofType: "ttf")
        {
            if let inData = NSData(contentsOfFile: path)
            {
                var error: Unmanaged<CFError>?
                let cfdata = CFDataCreate(nil, UnsafePointer<UInt8>(inData.bytes), inData.length)
                if let provider = CGDataProviderCreateWithCFData(cfdata) {
                    if let font = CGFontCreateWithDataProvider(provider) {
                        if (!CTFontManagerRegisterGraphicsFont(font, &error)) {
                            print("Failed to load font: \(error)")
                        }
                        return true
                    }
                }
            }
        }
        return false
    }
    
    
    
    public override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
    
        UIApplication.sharedApplication().statusBarStyle = .LightContent
        MercadoPagoUIViewController.loadFont(MercadoPago.DEFAULT_FONT_NAME)
        
        
        self.loadMPStyles()
     
        
    }
    
    public override func viewWillDisappear(animated: Bool) {
        super.viewWillDisappear(animated)
        self.clearMercadoPagoStyle()
  
        
    }
    
    internal func loadMPStyles(){
        
        if self.navigationController != nil {

            
            //Navigation bar colors
            let titleDict: NSDictionary = [NSForegroundColorAttributeName: UIColor.whiteColor(), NSFontAttributeName: UIFont(name: MercadoPago.DEFAULT_FONT_NAME, size: 18)!]
            
            if self.navigationController != nil {
                self.navigationController!.navigationBar.titleTextAttributes = titleDict as? [String : AnyObject]
                self.navigationItem.hidesBackButton = true
                self.navigationController!.interactivePopGestureRecognizer?.delegate = self
                self.navigationController?.navigationBar.tintColor = UIColor.whiteColor()
                self.navigationController?.navigationBar.barTintColor = UIColor(red: 48, green: 175, blue: 226)
                self.navigationController?.navigationBar.removeBottomLine()
                  self.navigationController?.navigationBar.translucent = false
                //Create navigation buttons
                displayBackButton()
            }
        }

    }
    
    internal func clearMercadoPagoStyleAndGoBackAnimated(){
        self.clearMercadoPagoStyle()
        self.navigationController?.popViewControllerAnimated(true)
    }
    
    internal func clearMercadoPagoStyleAndGoBack(){
        self.clearMercadoPagoStyle()
        self.navigationController?.popViewControllerAnimated(false)
    }
    
    internal func clearMercadoPagoStyle(){
        //Navigation bar colors
        self.navigationController?.navigationBar.titleTextAttributes = nil
        self.navigationController?.navigationBar.barTintColor = nil
        UIApplication.sharedApplication().statusBarStyle = UIStatusBarStyle.Default
        
      
    }
    
    internal func invokeCallbackCancel(){
        if(self.callbackCancel != nil){
            self.callbackCancel!()
        }

    }
    
    override public func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    override public func shouldAutorotate() -> Bool {
        return false
    }
    
    override public func supportedInterfaceOrientations() -> UIInterfaceOrientationMask {
        return UIInterfaceOrientationMask.Portrait
    }
    
    public func rightButtonClose(){
        let action = self.navigationItem.rightBarButtonItem?.action
        var shoppingCartImage = MercadoPago.getImage("iconClose")
        shoppingCartImage = shoppingCartImage!.imageWithRenderingMode(.AlwaysTemplate)
        let shoppingCartButton = UIBarButtonItem()
        shoppingCartButton.image = shoppingCartImage
        shoppingCartButton.style = UIBarButtonItemStyle.Bordered
        shoppingCartButton.title = ""
        shoppingCartButton.target = self
        shoppingCartButton.tintColor = UIColor.whiteColor()
        if action != nil {
            shoppingCartButton.action = action!
        }
        self.navigationItem.rightBarButtonItem = shoppingCartButton
    }
    
    public func rightButtonShoppingCart(){
        let action = self.navigationItem.rightBarButtonItem?.action
        var shoppingCartImage = MercadoPago.getImage("iconCart")
        shoppingCartImage = shoppingCartImage!.imageWithRenderingMode(.AlwaysTemplate)
        let shoppingCartButton = UIBarButtonItem()
        shoppingCartButton.image = shoppingCartImage
        shoppingCartButton.title = ""
        shoppingCartButton.target = self
        shoppingCartButton.tintColor = UIColor.whiteColor()
        if action != nil {
            shoppingCartButton.action = action!
        }
        self.navigationItem.rightBarButtonItem = shoppingCartButton
        
    }
    
    internal func displayBackButton() {
        let backButton = UIBarButtonItem()
        backButton.image = MercadoPago.getImage("left_arrow")
        backButton.style = UIBarButtonItemStyle.Bordered
        backButton.target = self
        backButton.tintColor = UIColor.whiteColor()
        backButton.imageInsets = UIEdgeInsets(top: 8, left: 2, bottom: 8, right: 2)
        backButton.action = "executeBack"
        self.navigationItem.leftBarButtonItem = backButton
    }
    
    internal func executeBack(){
        self.navigationController!.popViewControllerAnimated(true)
    }
    
    internal func showLoading(){
        LoadingOverlay.shared.showOverlay(self.view, backgroundColor: UIColor(red: 217, green: 217, blue: 217), indicatorColor: UIColor.whiteColor())
    }
    
    var fistResponder : UITextField?
    
    internal func hideKeyboard(view: UIView) -> Bool{
        if let textField = view as? UITextField {
            // if (textField.isFirstResponder()){
            fistResponder = textField
            textField.resignFirstResponder()
            //   return true
            // }
        }
        for subview in view.subviews {
            if (hideKeyboard(subview)){
                return true
            }
        }
        return false
    }
    internal func showKeyboard(){
        if (fistResponder != nil){
            fistResponder?.becomeFirstResponder()
        }
        fistResponder = nil
    }
    
    
    internal func hideLoading(){
        LoadingOverlay.shared.hideOverlayView()
    }
    
    public func gestureRecognizerShouldBegin(gestureRecognizer: UIGestureRecognizer) -> Bool {
        
        //En caso de que el vc no sea root
        if(navigationController != nil && navigationController!.viewControllers.count > 1 && navigationController!.viewControllers[0] != self){
                return true
        }
        return false
    }
    
    internal func requestFailure(error : NSError, callback : (Void -> Void)? = nil) {
        let errorVC = MPStepBuilder.startErrorViewController(MPError.convertFrom(error), callback: callback)
        if self.navigationController != nil {
            self.navigationController?.presentViewController(errorVC, animated: true, completion: {})
        } else {
            self.presentViewController(errorVC, animated: true, completion: {})
        }
    }
    
    internal func displayFailure(mpError : MPError){
        let errorVC = MPStepBuilder.startErrorViewController(mpError, callback: nil, callbackCancel: self.callbackCancel)
        if self.navigationController != nil {
            self.navigationController?.presentViewController(errorVC, animated: true, completion: {})
        } else {
            self.presentViewController(errorVC, animated: true, completion: {})
        }
    }

}

extension UINavigationController {

    override public func shouldAutorotate() -> Bool {
        return (self.viewControllers.count > 0 && self.viewControllers.last!.shouldAutorotate())
    }
    
    override public func supportedInterfaceOrientations() -> UIInterfaceOrientationMask {
        return self.viewControllers.last!.supportedInterfaceOrientations()
    }

}

extension UINavigationBar {
    
    func removeBottomLine() {
        for parent in self.subviews {
            for childView in parent.subviews {
                if(childView is UIImageView) {
                    childView.removeFromSuperview()
                }
            }
        }
    }

}
