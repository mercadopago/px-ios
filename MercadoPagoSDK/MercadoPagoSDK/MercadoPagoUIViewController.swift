//
//  MercadoPagoUIViewController.swift
//  MercadoPagoSDK
//
//  Created by Maria cristina rodriguez on 3/2/16.
//  Copyright © 2016 MercadoPago. All rights reserved.
//

import UIKit


open class MercadoPagoUIViewController: UIViewController, UIGestureRecognizerDelegate, TimerDelegate {

    open var callbackCancel : ((Void) -> Void)? 
    public var timer : CountdownTimer?
    var navBarTextColor = UIColor.systemFontColor()
    
    open var screenName : String { get{ return "NO_ESPECIFICADO" } }
    
    
    override open func viewDidLoad() {
        super.viewDidLoad()
        MPTracker.trackScreenName(MercadoPagoContext.sharedInstance, screenName: screenName)
        self.loadMPStyles()
    }

    var lastDefaultFontLabel : String?
    var lastDefaultFontTextField : String?
    var lastDefaultFontButton : String?
    var timerLabel : MPLabel?
    
    override open func viewDidAppear(_ animated: Bool) {
        
        super.viewDidAppear(animated)
        if self.timer != nil {
            self.timer!.delegate = self
            self.timerLabel = MPLabel(frame: CGRect(x: 0, y: 0, width: 56, height: 20))
            self.timerLabel!.backgroundColor = MercadoPagoContext.getPrimaryColor()
            self.timerLabel!.textColor = MercadoPagoContext.getTextColor()
            self.timerLabel!.textAlignment = .right
            let button = UIButton(type: UIButtonType.custom)
            button.frame = CGRect(x: 0, y: 0, width: 56, height: 20)
            button.addSubview(timerLabel!)
            
            self.navigationItem.rightBarButtonItem = UIBarButtonItem(customView: button)
        }
    }
    
    static func loadFont(_ fontName: String) -> Bool {
        
        if let path = MercadoPago.getBundle()!.path(forResource: fontName, ofType: "ttf")
        {
            if let inData = try? Data(contentsOf: URL(fileURLWithPath: path))
            {
                var error: Unmanaged<CFError>?
                let cfdata = CFDataCreate(nil, (inData as NSData).bytes.bindMemory(to: UInt8.self, capacity: inData.count), inData.count)
                if let provider = CGDataProvider(data: cfdata!) {
                    let font = CGFont(provider)
                        if (!CTFontManagerRegisterGraphicsFont(font, &error)) {
                            print("Failed to load font: \(error)")
                        }
                        return true
                    
                }
            }
        }
        return false
    }
    
    open override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
    
        UIApplication.shared.statusBarStyle = .lightContent
        
        self.loadMPStyles()
     
        
    }
    
    open override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        self.clearMercadoPagoStyle()
  
        
    }
    
    internal func loadMPStyles(){
        
        if self.navigationController != nil {

            var titleDict: NSDictionary = [:]
            //Navigation bar colors
            if let fontChosed = UIFont(name: MercadoPago.DEFAULT_FONT_NAME, size: 18) {
                titleDict = [NSForegroundColorAttributeName: MercadoPagoContext.getTextColor(), NSFontAttributeName:fontChosed]
            }
            
            
            if self.navigationController != nil {
                self.navigationController!.navigationBar.titleTextAttributes = titleDict as? [String : AnyObject]
                self.navigationItem.hidesBackButton = true
                self.navigationController!.interactivePopGestureRecognizer?.delegate = self
                self.navigationController?.navigationBar.tintColor = UIColor.systemFontColor()
                self.navigationController?.navigationBar.barTintColor = MercadoPagoContext.getPrimaryColor()
                self.navigationController?.navigationBar.removeBottomLine()
                  self.navigationController?.navigationBar.isTranslucent = false
                //Create navigation buttons
                displayBackButton()
            }
        }

    }
    
    internal func clearMercadoPagoStyleAndGoBackAnimated(){
        self.clearMercadoPagoStyle()
        self.navigationController?.popViewController(animated: true)
    }
    
    internal func clearMercadoPagoStyleAndGoBack(){
        self.clearMercadoPagoStyle()
        self.navigationController?.popViewController(animated: false)
    }
    
    internal func clearMercadoPagoStyle(){
        //Navigation bar colors
        self.navigationController?.navigationBar.titleTextAttributes = nil
        self.navigationController?.navigationBar.barTintColor = nil
        UIApplication.shared.statusBarStyle = UIStatusBarStyle.default
        
      
    }
    
    internal func invokeCallbackCancel(){
        if(self.callbackCancel != nil){
            self.callbackCancel!()
        }

    }
    
    override open func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    override open var shouldAutorotate : Bool {
        return false
    }
    
    override open var supportedInterfaceOrientations : UIInterfaceOrientationMask {
        return UIInterfaceOrientationMask.portrait
    }
    
    open func rightButtonClose(){
        let action = self.navigationItem.rightBarButtonItem?.action
        var shoppingCartImage = MercadoPago.getImage("iconClose")
        shoppingCartImage = shoppingCartImage!.withRenderingMode(.alwaysTemplate)
        let shoppingCartButton = UIBarButtonItem()
        shoppingCartButton.image = shoppingCartImage
        shoppingCartButton.style = .plain
        shoppingCartButton.title = ""
        shoppingCartButton.target = self
        shoppingCartButton.tintColor = UIColor.white()
        if action != nil {
            shoppingCartButton.action = action!
        }
        self.navigationItem.rightBarButtonItem = shoppingCartButton
    }
    
    open func rightButtonShoppingCart(){
        let action = self.navigationItem.rightBarButtonItem?.action
        var shoppingCartImage = MercadoPago.getImage("iconCart")
        shoppingCartImage = shoppingCartImage!.withRenderingMode(.alwaysTemplate)
        let shoppingCartButton = UIBarButtonItem()
        shoppingCartButton.image = shoppingCartImage
        shoppingCartButton.title = ""
        shoppingCartButton.target = self
        shoppingCartButton.tintColor = UIColor.white()
        if action != nil {
            shoppingCartButton.action = action!
        }
        self.navigationItem.rightBarButtonItem = shoppingCartButton
        
    }
    
    internal func displayBackButton() {
        let backButton = UIBarButtonItem()
        backButton.image = MercadoPago.getImage("back")
        backButton.style = .plain
        backButton.target = self
        backButton.tintColor = UIColor.systemFontColor()
        backButton.imageInsets = UIEdgeInsets(top: 8, left: 2, bottom: 8, right: 2)
        backButton.action = #selector(MercadoPagoUIViewController.executeBack)
        self.navigationItem.leftBarButtonItem = backButton
    }
    
    internal func executeBack(){
        self.navigationController!.popViewController(animated: true)
    }
    
    internal func showLoading(){
        LoadingOverlay.shared.showOverlay(self.view, backgroundColor: UIColor(red: 217, green: 217, blue: 217), indicatorColor: UIColor.white())
    }
    
    var fistResponder : UITextField?
    
    internal func hideKeyboard(_ view: UIView) -> Bool{
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
    
    open func gestureRecognizerShouldBegin(_ gestureRecognizer: UIGestureRecognizer) -> Bool {
        
        //En caso de que el vc no sea root
        if(navigationController != nil && navigationController!.viewControllers.count > 1 && navigationController!.viewControllers[0] != self){
                return true
        }
        return false
    }
    
    internal func requestFailure(_ error : NSError, callback : ((Void) -> Void)? = nil, callbackCancel : ((Void) -> Void)? = nil) {
        let errorVC = MPStepBuilder.startErrorViewController(MPError.convertFrom(error), callback: callback, callbackCancel: callbackCancel)
        if self.navigationController != nil {
            self.navigationController?.present(errorVC, animated: true, completion: {})
        } else {
            self.present(errorVC, animated: true, completion: {})
        }
    }
    
    internal func displayFailure(_ mpError : MPError){
        let errorVC = MPStepBuilder.startErrorViewController(mpError, callback: nil, callbackCancel: self.callbackCancel)
        if self.navigationController != nil {
            self.navigationController?.present(errorVC, animated: true, completion: {})
        } else {
            self.present(errorVC, animated: true, completion: {})
        }
    }
    
    open func updateTimer() {
        if self.timerLabel != nil {
            self.timerLabel!.text = self.timer!.getCurrentTiming()
        }
    }
    
    func showNavBar() {
        
        if navigationController != nil {
            self.title = self.getNavigationBarTitle()
            self.navigationController?.navigationBar.setBackgroundImage(nil, for: UIBarMetrics.default)
            self.navigationController?.navigationBar.shadowImage = nil
            self.navigationController?.navigationBar.tintColor = nil
            self.navigationController?.navigationBar.isTranslucent = false
 
            let font : UIFont = UIFont(name:MercadoPago.DEFAULT_FONT_NAME, size: 22) ?? UIFont.systemFont(ofSize: 22)
            let titleDict: NSDictionary = [NSForegroundColorAttributeName: self.navBarTextColor, NSFontAttributeName: font]
            self.navigationController?.navigationBar.titleTextAttributes = titleDict as? [String : AnyObject]
        }
        
    }
    
    func hideNavBar(){
        if navigationController != nil {
            self.title = ""
            navigationController?.navigationBar.titleTextAttributes = nil
           self.navigationController?.navigationBar.setBackgroundImage(UIImage(), for: UIBarMetrics.default)
           self.navigationController?.navigationBar.shadowImage = UIImage()
            self.navigationController?.navigationBar.isTranslucent = true
        }
    }
    
    func getNavigationBarTitle() -> String {
        return ""
    }
    
    deinit {
        print("\(String(describing: type(of: self))) dellocated" )
    }

}

extension UINavigationController {

    override open var shouldAutorotate : Bool {
        return (self.viewControllers.count > 0 && self.viewControllers.last!.shouldAutorotate)
    }
    
    override open var supportedInterfaceOrientations : UIInterfaceOrientationMask {
        return self.viewControllers.last!.supportedInterfaceOrientations
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
extension UINavigationController {
    internal func showLoading(){
        
        LoadingOverlay.shared.showOverlay(self.visibleViewController!.view, backgroundColor: UIColor(red: 217, green: 217, blue: 217), indicatorColor: UIColor.white())
    }
    
    internal func hideLoading(){
        LoadingOverlay.shared.hideOverlayView()
    }
}
