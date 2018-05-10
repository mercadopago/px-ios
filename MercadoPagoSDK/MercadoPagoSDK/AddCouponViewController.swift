//
//  AddCouponViewController.swift
//  MercadoPagoSDK
//
//  Created by Demian Tejo on 12/30/16.
//  Copyright © 2016 MercadoPago. All rights reserved.
//

import UIKit

@objcMembers
open class AddCouponViewController: MercadoPagoUIViewController, UITextFieldDelegate {

    @IBOutlet weak var backgroundView: UIView!
    @IBOutlet weak var textBox: HoshiTextField!

    override open var screenName: String { return "DISCOUNT_INPUT_CODE" }
    var toolbar: PXToolbar?
    var errorLabel: MPLabel?
    var viewModel: AddCouponViewModel!

    var callback : ((_ coupon: DiscountCoupon) -> Void)?

    init(amount: Double, email: String, mercadoPagoServicesAdapter: MercadoPagoServicesAdapter, callback : @escaping ((_ coupon: DiscountCoupon) -> Void), callbackCancel: (() -> Void)? = nil) {
        super.init(nibName: "AddCouponViewController", bundle: MercadoPago.getBundle())
        self.callback = callback
        self.callbackCancel = callbackCancel
        self.viewModel = AddCouponViewModel(amount: amount, email: email, mercadoPagoServicesAdapter: mercadoPagoServicesAdapter)
    }

    init (viewModel: AddCouponViewModel, callback : @escaping ((_ coupon: DiscountCoupon) -> Void), callbackCancel: (() -> Void)? = nil) {
      super.init(nibName: "AddCouponViewController", bundle: MercadoPago.getBundle())
        self.callback = callback
        self.callbackCancel = callbackCancel
        self.viewModel = viewModel
    }
    required public init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    open override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        textBox.placeholder = "Código de descuento".localized
    }
    override open func viewDidLoad() {
        super.viewDidLoad()
        self.backgroundView.backgroundColor = ThemeManager.shared.getMainColor()
        textBox.autocorrectionType = UITextAutocorrectionType.no
        setupInputAccessoryView()
        textBox.delegate = self
        textBox.addTarget(self, action: #selector(CardFormViewController.editingChanged(_:)), for: UIControlEvents.editingChanged)
        view.setNeedsUpdateConstraints()
        textBox.becomeFirstResponder()
    }

    var buttonNext: UIBarButtonItem!
    var buttonPrev: UIBarButtonItem!

    func setupInputAccessoryView() {
        let frame =  CGRect(x: 0, y: 0, width: UIScreen.main.bounds.size.width, height: 44)
        let toolbar = PXToolbar(frame: frame)

        toolbar.barStyle = UIBarStyle.default
        toolbar.isUserInteractionEnabled = true

        buttonNext = UIBarButtonItem(title: "Canejar".localized, style: .plain, target: self, action: #selector(AddCouponViewController.rightArrowKeyTapped))

        buttonPrev = UIBarButtonItem(title: "Cancelar".localized, style: .plain, target: self, action: #selector(AddCouponViewController.leftArrowKeyTapped))

        buttonNext.setTitlePositionAdjustment(UIOffset(horizontal: UIScreen.main.bounds.size.width / 8, vertical: 0), for: UIBarMetrics.default)
        buttonPrev.setTitlePositionAdjustment(UIOffset(horizontal: -UIScreen.main.bounds.size.width / 8, vertical: 0), for: UIBarMetrics.default)

        let flexibleSpace = UIBarButtonItem(barButtonSystemItem: .flexibleSpace, target: nil, action: nil)
        toolbar.items = [flexibleSpace, buttonPrev, flexibleSpace, buttonNext, flexibleSpace]

        textBox.delegate = self
        self.toolbar = toolbar
        textBox.inputAccessoryView = toolbar
        buttonNext.isEnabled = false
    }

    @objc func leftArrowKeyTapped() {
        self.exit()
    }

    @objc func rightArrowKeyTapped() {

        guard let couponCode = textBox.text else {
            return
        }
        self.showLoading()
        self.textBox.resignFirstResponder()
        self.viewModel.getCoupon(code: couponCode, success: { () in
            self.hideLoading()
            if let coupon = self.viewModel.coupon {
                let couponDetailVC = CouponDetailViewController(coupon: coupon)
                PXComponentFactory.Modal.show(viewController: couponDetailVC, title: coupon.getDescription(), dismissBlock: { [weak self]  () in
                    self?.callbackAndExit()
                })
            }
        }, failure: { (errorMessage) in
            self.hideLoading()
            self.showErrorMessage(errorMessage)
        })
    }

    @IBAction func exit() {
        self.textBox.resignFirstResponder()
        guard let callbackCancel = self.callbackCancel else {
            self.navigationController?.popViewController(animated: false)
            return
        }
        callbackCancel()
    }

    func executeCallback() {
        if let callback = self.callback {
            if let coupon = self.viewModel.coupon {
                callback(coupon)
            }
        }
    }

    func callbackAndExit() {
        self.textBox.resignFirstResponder()
        self.executeCallback()
        self.navigationController?.popViewController(animated: true)
    }

    func showErrorMessage(_ errorMessage: String) {
        errorLabel = MPLabel(frame: toolbar!.frame)
        // TODO: Implement Meli Toast component. (Meli UI library).
        self.errorLabel!.backgroundColor = UIColor.UIColorFromRGB(0xEEEEEE)
        self.errorLabel!.textColor = ThemeManager.shared.rejectedColor()
        self.errorLabel!.text = errorMessage
        self.errorLabel!.textAlignment = .center
        self.errorLabel!.font = self.errorLabel!.font.withSize(12)
        textBox.borderInactiveColor = ThemeManager.shared.rejectedColor()
        textBox.borderActiveColor = ThemeManager.shared.rejectedColor()
        textBox.inputAccessoryView = errorLabel
        textBox.setNeedsDisplay()
        textBox.resignFirstResponder()
        textBox.becomeFirstResponder()
    }

    open func editingChanged(_ textField: UITextField) {
        if (textBox.text?.count)! > 0 {
            buttonNext.isEnabled = true
        } else {
            buttonNext.isEnabled = false
        }
        hideErrorMessage()

    }

    func hideErrorMessage() {
        self.textBox.borderInactiveColor = ThemeManager.shared.secondaryColor()
        self.textBox.borderActiveColor = ThemeManager.shared.secondaryColor()
        self.textBox.inputAccessoryView = self.toolbar
        self.textBox.setNeedsDisplay()
        self.textBox.resignFirstResponder()
        self.textBox.becomeFirstResponder()
    }

}
