//
//  MercadoPagoUIViewController.swift
//  MercadoPagoSDK
//
//  Created by Maria cristina rodriguez on 3/2/16.
//  Copyright © 2016 MercadoPago. All rights reserved.
//

import UIKit
import MercadoPagoPXTracking

open class MercadoPagoUIViewController: UIViewController, UIGestureRecognizerDelegate {

    open var callbackCancel: (() -> Void)?
    var navBarTextColor = ThemeManager.shared.getTheme().navigationBar().tintColor
    private var navBarBackgroundColor = ThemeManager.shared.getMainColor()
    var shouldDisplayBackButton = false
    var shouldHideNavigationBar = false
    var shouldShowBackArrow = true
    var tracked: Bool = false

    var pluginComponentInterface: PXPluginComponent?

    let STATUS_BAR_HEIGTH = ViewUtils.getStatusBarHeight()
    let NAV_BAR_HEIGHT = 44.0

    var hideNavBarCallback: (() -> Void)?

    open var screenName: String { return TrackingUtil.NO_NAME_SCREEN }
    open var screenId: String { return TrackingUtil.NO_SCREEN_ID }

    var loadingInstance: UIView?

    override open func viewDidLoad() {
        super.viewDidLoad()
        self.loadMPStyles()
    }

    override open func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)

        if screenName != TrackingUtil.NO_NAME_SCREEN && screenId != TrackingUtil.NO_SCREEN_ID && !tracked {
            tracked = true
            trackInfo()
        }
    }

    open override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)

        UIApplication.shared.statusBarStyle = ThemeManager.shared.getTheme().statusBarStyle()

        navigationController?.interactivePopGestureRecognizer?.isEnabled = false

        self.loadMPStyles()
        MercadoPagoCheckout.firstViewControllerPushed = true

        if shouldHideNavigationBar {
            navigationController?.setNavigationBarHidden(true, animated: false)
        }

        pluginComponentInterface?.viewWillAppear?()
    }

    open override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)

        if shouldHideNavigationBar {
            navigationController?.setNavigationBarHidden(false, animated: false)
        }

        pluginComponentInterface?.viewWillDisappear?()
    }

    open func totalContentViewHeigth() -> CGFloat {
        return UIScreen.main.bounds.height - getReserveSpace()
    }

    open func getReserveSpace() -> CGFloat {
        var totalReserveSpace: CGFloat = CGFloat(STATUS_BAR_HEIGTH)

        if !shouldHideNavigationBar {
            totalReserveSpace += CGFloat(NAV_BAR_HEIGHT)
        }
        return totalReserveSpace
    }

    func trackInfo() {
        MPXTracker.sharedInstance.trackScreen(screenId: screenId, screenName: screenName)
    }

    var lastDefaultFontLabel: String?
    var lastDefaultFontTextField: String?
    var lastDefaultFontButton: String?

    static func loadFont(_ fontName: String) -> Bool {
        if let path = MercadoPago.getBundle()!.path(forResource: fontName, ofType: "ttf") {
            if let inData = try? Data(contentsOf: URL(fileURLWithPath: path)) {
                var error: Unmanaged<CFError>?
                let cfdata = CFDataCreate(nil, (inData as NSData).bytes.bindMemory(to: UInt8.self, capacity: inData.count), inData.count)
                if let provider = CGDataProvider(data: cfdata!) {
                    let font = CGFont(provider)
                    if (!CTFontManagerRegisterGraphicsFont(font, &error)) {
                        print("Failed to load font: \(error.debugDescription)")
                    }
                    return true
                }
            }
        }
        return false
    }

    internal func loadMPStyles() {

        if self.navigationController != nil {
            var titleDict: NSDictionary = [:]
            //Navigation bar colors
            let fontChosed = Utils.getFont(size: 18)
            titleDict = [NSForegroundColorAttributeName: navBarTextColor, NSFontAttributeName: fontChosed]

            if titleDict.count > 0 {
                self.navigationController!.navigationBar.titleTextAttributes = titleDict as? [String: AnyObject]
            }
            self.navigationItem.hidesBackButton = true
            self.navigationController?.navigationBar.tintColor = navBarBackgroundColor
            self.navigationController?.navigationBar.barTintColor = navBarBackgroundColor
            self.navigationController?.navigationBar.removeBottomLine()
            self.navigationController?.navigationBar.isTranslucent = false
            self.navigationController?.view.backgroundColor = navBarBackgroundColor

            //Create navigation buttons
            displayBackButton()
        }
    }

    internal func clearMercadoPagoStyleAndGoBackAnimated() {
        self.clearMercadoPagoStyle()
        self.navigationController?.popViewController(animated: true)
    }

    internal func clearMercadoPagoStyleAndGoBack() {
        self.clearMercadoPagoStyle()
        self.navigationController?.popViewController(animated: false)
    }

    internal func clearMercadoPagoStyle() {
        //Navigation bar colors
        guard let navController = self.navigationController else {
            return
        }

        ThemeManager.shared.applyAppNavBarStyle(navigationController: navController)
    }

    internal func invokeCallbackCancelShowingNavBar() {
        if self.callbackCancel != nil {
            self.showNavBar()
            self.callbackCancel!()
        }

    }
    internal func invokeCallbackCancel() {
        if self.callbackCancel != nil {
            self.callbackCancel!()
        }
        self.navigationController!.popViewController(animated: true)
    }

    override open func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }

    override open var shouldAutorotate: Bool {
        return false
    }

    override open var supportedInterfaceOrientations: UIInterfaceOrientationMask {
        return UIInterfaceOrientationMask.portrait
    }

    open func rightButtonClose() {
        let action = self.navigationItem.rightBarButtonItem?.action
        var shoppingCartImage = MercadoPago.getImage("iconClose")
        shoppingCartImage = shoppingCartImage!.withRenderingMode(.alwaysTemplate)
        let shoppingCartButton = UIBarButtonItem()
        shoppingCartButton.image = shoppingCartImage
        shoppingCartButton.style = .plain
        shoppingCartButton.title = ""
        shoppingCartButton.target = self
        shoppingCartButton.tintColor = navBarTextColor
        if action != nil {
            shoppingCartButton.action = action!
        }
        self.navigationItem.rightBarButtonItem = shoppingCartButton
    }

    internal func displayBackButton() {
        if shouldShowBackArrow {
            let backButton = UIBarButtonItem()
            backButton.image = MercadoPago.getImage("back")
            backButton.style = .plain
            backButton.target = self
            backButton.tintColor = navBarTextColor
            backButton.action = #selector(MercadoPagoUIViewController.executeBack)
            self.navigationItem.leftBarButtonItem = backButton
        }
    }

    internal func hideBackButton() {
        self.navigationItem.leftBarButtonItem = nil
    }

    internal func executeBack() {
        if let callbackCancel = callbackCancel {
            callbackCancel()
            return
        }
        self.navigationController!.popViewController(animated: true)
    }

    internal func showLoading() {
        self.loadingInstance = LoadingOverlay.shared.showOverlay(self.view, backgroundColor: ThemeManager.shared.getTheme().loadingComponent().backgroundColor, indicatorColor: ThemeManager.shared.getTheme().loadingComponent().tintColor)
        self.view.bringSubview(toFront: self.loadingInstance!)
    }

    var fistResponder: UITextField?

    internal func hideKeyboard(_ view: UIView) -> Bool {
        if let textField = view as? UITextField {
            // if (textField.isFirstResponder()){
            fistResponder = textField
            textField.resignFirstResponder()
            //   return true
            // }
        }
        for subview in view.subviews {
            if hideKeyboard(subview) {
                return true
            }
        }
        return false
    }
    internal func showKeyboard() {
        if fistResponder != nil {
            fistResponder?.becomeFirstResponder()
        }
        fistResponder = nil
    }

    internal func hideLoading() {
        LoadingOverlay.shared.hideOverlayView()
        self.loadingInstance = nil
    }

    open func gestureRecognizerShouldBegin(_ gestureRecognizer: UIGestureRecognizer) -> Bool {

        //En caso de que el vc no sea root
        if navigationController != nil && navigationController!.viewControllers.count > 1 && navigationController!.viewControllers[0] != self {
            return true
        }
        return false
    }

    internal func requestFailure(_ error: NSError, requestOrigin: String, callback: (() -> Void)? = nil, callbackCancel: (() -> Void)? = nil) {
        let errorVC = ErrorViewController(error: MPSDKError.convertFrom(error, requestOrigin: requestOrigin), callback: callback, callbackCancel: callbackCancel)
        if self.navigationController != nil {
            self.navigationController?.present(errorVC, animated: true, completion: {})
        } else {
            self.present(errorVC, animated: true, completion: {})
        }
    }

    internal func displayFailure(_ mpError: MPSDKError) {
        let errorVC = ErrorViewController(error: mpError, callback: nil, callbackCancel: self.callbackCancel)
        if self.navigationController != nil {
            self.navigationController?.present(errorVC, animated: true, completion: {})
        } else {
            self.present(errorVC, animated: true, completion: {})
        }
    }

    var navBarFontSize: CGFloat = 18

    func showNavBar() {

        if navigationController != nil {
            self.title = self.getNavigationBarTitle()
            // self.navigationController?.navigationBar.isHidden = false
            self.navigationController?.navigationBar.setBackgroundImage(nil, for: UIBarMetrics.default)
            self.navigationController?.navigationBar.shadowImage = nil
            self.navigationController?.navigationBar.tintColor = navBarBackgroundColor
            self.navigationController?.navigationBar.backgroundColor = navBarBackgroundColor
            self.navigationController?.navigationBar.isTranslucent = false

            if self.shouldDisplayBackButton {
                self.displayBackButton()
            }

            let font: UIFont = Utils.getFont(size: navBarFontSize)
            let titleDict: NSDictionary = [NSForegroundColorAttributeName: ThemeManager.shared.getTheme().navigationBar().tintColor, NSFontAttributeName: font]
            self.navigationController?.navigationBar.titleTextAttributes = titleDict as? [String: AnyObject]
        }

    }

    func hideNavBar() {
        if navigationController != nil {
            self.title = ""

            navigationController?.navigationBar.titleTextAttributes = nil

            self.navigationController?.navigationBar.removeBottomLine()
            self.navigationController?.navigationBar.setBackgroundImage(UIImage(), for: UIBarMetrics.default)
            self.navigationController?.navigationBar.shadowImage = UIImage()
            self.navigationController!.navigationBar.backgroundColor =  UIColor(red: 0.0, green: 0.0, blue: 0.0, alpha: 0.0)
            self.navigationController?.navigationBar.isTranslucent = true

            if self.shouldDisplayBackButton {
                self.displayBackButton()
            }

            if self.hideNavBarCallback != nil {
                hideNavBarCallback!()
            }
        }
    }

    func getNavigationBarTitle() -> String {
        return ""
    }

    func setNavBarBackgroundColor(color: UIColor) {
        self.navBarBackgroundColor = color
    }

    deinit {
        #if DEBUG
            print("DEINIT - \(self)")
        #endif
    }

}

extension UINavigationController {

    override open var shouldAutorotate: Bool {
        return (self.viewControllers.count > 0 && self.viewControllers.last!.shouldAutorotate)
    }

}

extension UINavigationBar {

    func removeBottomLine() {
        self.setValue(true, forKey: "hidesShadow")
    }
    func restoreBottomLine() {
        self.setValue(false, forKey: "hidesShadow")
    }

}
extension UINavigationController {
    internal func showLoading() {
        _ = LoadingOverlay.shared.showOverlay(self.visibleViewController!.view, backgroundColor: ThemeManager.shared.getTheme().loadingComponent().backgroundColor, indicatorColor: ThemeManager.shared.getTheme().loadingComponent().tintColor)
    }

    internal func hideLoading() {
        LoadingOverlay.shared.hideOverlayView()
    }
}

extension UIImage {
    public static func imageFromColor(color: UIColor, frame: CGRect) -> UIImage {
        UIGraphicsBeginImageContextWithOptions(frame.size, false, 0)
        color.setFill()
        UIRectFill(frame)
        let image = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        return image!
    }
}
