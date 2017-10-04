//
//  PayerInfoViewController.swift
//  MercadoPagoSDK
//
//  Created by Demian Tejo on 9/29/17.
//  Copyright © 2017 MercadoPago. All rights reserved.
//

import UIKit

class PayerInfoViewController: MercadoPagoUIViewController, UITextFieldDelegate, InputComponentListener {

    let KEYBOARD_HEIGHT: CGFloat = 216.0
    let ACCESORY_VIEW_HEIGHT: CGFloat = 44.0
    let INPUT_VIEW_HEIGHT: CGFloat = 83.0

    let NAME_INPUT_TEXT = "Nombre"
    let SURNAME_INPUT_TEXT = "Apellido"
    let NUMBER_INPUT_TEXT = "Número"
    let TYPE_INPUT_TEXT = "Tipo"
    let CONTINUE_INPUT_TEXT = "Continuar"
    let BEFORE_INPUT_TEXT = "Anterior"

    var currentInput: UIView!

    // View Components
    var identificationComponent: CompositeInputComponent?
    var secondNameComponent: SimpleInputComponent?
    var firstNameComponent: SimpleInputComponent?
    var boletoComponent: BoletoComponent?

    var viewModel: PayerInfoViewModel!
    var callback : ((_ payer: Payer) -> Void)!

    init(viewModel: PayerInfoViewModel, callback: @escaping ((_ payer: Payer) -> Void)) {
        super.init(nibName: nil, bundle: nil)
        self.viewModel = viewModel
        self.callback = callback
        NotificationCenter.default.addObserver(self, selector: #selector(PayerInfoViewController.keyboardWasShown(_:)), name: NSNotification.Name.UIKeyboardWillChangeFrame, object: nil)
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        setupView()
    }

    func getAvailableHeight() -> CGFloat {
        let screenSize = UIScreen.main.bounds
        let screenHeight = screenSize.height
        var barsHeight = UIApplication.shared.statusBarFrame.height
        let navigationBarHeight = self.navigationController?.navigationBar.frame.height
        barsHeight += navigationBarHeight != nil ? navigationBarHeight! : CGFloat(0.0)
        var availableHeight = screenHeight - barsHeight
        availableHeight = keyboardFrame != nil ? availableHeight - (keyboardFrame?.height)! : availableHeight
        return availableHeight
    }

    func setupView() {
        let screenWidth = UIScreen.main.bounds.width
        let nameText = NAME_INPUT_TEXT.localized
        let surnameText = SURNAME_INPUT_TEXT.localized
        let numberText = NUMBER_INPUT_TEXT.localized
        let typeText = TYPE_INPUT_TEXT.localized

        var availableHeight = self.getAvailableHeight()

        if self.identificationComponent == nil && self.boletoComponent == nil {
            let frameIdentification = CGRect(x: 0, y: 0, width: screenWidth, height: 0)
            self.identificationComponent = CompositeInputComponent(frame: frameIdentification, numeric: true, placeholder: numberText, dropDownPlaceholder: typeText, dropDownOptions: self.viewModel.getDropdownOptions(), textFieldDelegate: self)
            self.presentIdentificationComponent()
            availableHeight -= (self.identificationComponent?.getHeight())!
            self.identificationComponent?.frame.origin.y = availableHeight
            self.secondNameComponent = SimpleInputComponent(frame: frameIdentification, numeric: false, placeholder: surnameText, textFieldDelegate: self)
            self.secondNameComponent?.frame.origin.y = availableHeight
            self.firstNameComponent = SimpleInputComponent(frame: frameIdentification, numeric: false, placeholder: nameText, textFieldDelegate: self)
            self.firstNameComponent?.frame.origin.y = availableHeight
            setupToolbarButtons()

            let frame = CGRect(x: 0, y: 0, width: screenWidth, height: availableHeight)
            let boletoComponent = BoletoComponent(frame: frame)
            self.boletoComponent = boletoComponent
            self.identificationComponent?.delegate = self
            self.firstNameComponent?.delegate = self
            self.secondNameComponent?.delegate = self
            let type = self.viewModel.identificationTypes[(self.identificationComponent?.optionSelected)!].name
            self.boletoComponent?.setType(text: type!)
            if let currentMask = self.viewModel.currentMask {
               self.identificationComponent?.setText(text: currentMask.textMasked(""))
               let maskComplete = TextMaskFormater(mask: currentMask.mask, completeEmptySpaces: true, leftToRight: false, completeEmptySpacesWith: "*")
               self.boletoComponent?.setNumberPlaceHolder(text: maskComplete.textMasked(""))
            }
            self.view.addSubview(self.boletoComponent!)
            self.view.addSubview(self.firstNameComponent!)
            self.view.addSubview(self.secondNameComponent!)
            self.view.addSubview(self.identificationComponent!)
        } else {
            availableHeight -= (self.identificationComponent?.getHeight())!
            self.identificationComponent?.frame.origin.y = availableHeight
             self.secondNameComponent?.frame.origin.y = availableHeight
            self.firstNameComponent?.frame.origin.y = availableHeight
            self.boletoComponent?.frame.size.height = availableHeight
            self.boletoComponent?.updateView()
        }
    }

    var toolbar: UIToolbar?

    func setupToolbarButtons() {

        if self.toolbar == nil {
            let frame =  CGRect(x: 0, y: 0, width: UIScreen.main.bounds.size.width, height: 44)

            let toolbar = UIToolbar(frame: frame)

            toolbar.barStyle = UIBarStyle.default
            toolbar.backgroundColor = UIColor.mpLightGray()
            toolbar.alpha = 1
            toolbar.isUserInteractionEnabled = true

            let buttonNext = UIBarButtonItem(title: "Continuar".localized, style: .done, target: self, action: #selector(PayerInfoViewController.rightArrowKeyTapped))
            let buttonPrev = UIBarButtonItem(title: "Anterior".localized, style: .plain, target: self, action: #selector(PayerInfoViewController.leftArrowKeyTapped))

            let font = Utils.getFont(size: 14)
            buttonNext.setTitleTextAttributes([NSFontAttributeName: font], for: .normal)
            buttonPrev.setTitleTextAttributes([NSFontAttributeName: font], for: .normal)

            buttonNext.setTitlePositionAdjustment(UIOffset(horizontal: UIScreen.main.bounds.size.width / 8, vertical: 0), for: UIBarMetrics.default)
            buttonPrev.setTitlePositionAdjustment(UIOffset(horizontal: -UIScreen.main.bounds.size.width / 8, vertical: 0), for: UIBarMetrics.default)

            let flexibleSpace = UIBarButtonItem(barButtonSystemItem: .flexibleSpace, target: nil, action: nil)

            toolbar.items = [flexibleSpace, buttonPrev, flexibleSpace, buttonNext, flexibleSpace]

            self.toolbar = toolbar
        }

        if self.identificationComponent != nil {
            self.identificationComponent?.setInputAccessoryView(inputAccessoryView: self.toolbar!)
        }
        if self.secondNameComponent != nil {
            self.secondNameComponent?.setInputAccessoryView(inputAccessoryView: self.toolbar!)
        }
        if self.firstNameComponent != nil {
            self.firstNameComponent?.setInputAccessoryView(inputAccessoryView: self.toolbar!)
        }
    }

    func textChangedIn(component: SimpleInputComponent) {
        guard let textField = component.inputTextField else {
            return
        }
        updateViewModelWithInput()

        if component == self.identificationComponent {
            guard self.viewModel.currentMask != nil else {
                return
            }
            textField.text! = self.viewModel.getMaskedNumber()
            let maskComplete = viewModel.getMaskedNumber(completeEmptySpaces: true)
            self.boletoComponent?.setNumber(text: maskComplete)
        } else if component == self.firstNameComponent || component == self.secondNameComponent {
            self.boletoComponent?.setName(text: self.viewModel.getFullName())
        }

    }

    func updateViewModelWithInput() {
        if let number = self.identificationComponent?.getInputText() {
            self.viewModel.update(identificationNumber: number)
        }
        if let name = self.firstNameComponent?.getInputText() {
            self.viewModel.update(name: name)
        }
        if let lastName = self.secondNameComponent?.getInputText() {
            self.viewModel.update(lastName: lastName)
        }
    }

    fileprivate func executeStep(_ currentStep: PayerInfoFlowStep) {
        switch currentStep {
        case .SCREEN_IDENTIFICATION:
             self.presentIdentificationComponent()
        case .SCREEN_NAME:
             self.presentFirstNameComponent()
        case .SCREEN_LAST_NAME:
             self.presentSecondNameComponent()
        case .CANCEL:
            self.navigationController?.popViewController(animated: true)
        case .FINISH:
            self.executeCallback()
        default:
            return
        }
    }

    func rightArrowKeyTapped() {
        let validStep = self.viewModel.validateCurrentStep()
        if validStep {
            let currentStep = self.viewModel.getNextStep()
            executeStep(currentStep)
        } else {
            // Mostrar error
        }
    }

    func leftArrowKeyTapped() {
        let currentStep = self.viewModel.getPreviousStep()
        executeStep(currentStep)
    }

    func presentIdentificationComponent() {
        self.view.bringSubview(toFront: self.identificationComponent!)
        self.identificationComponent?.componentBecameFirstResponder()
        self.currentInput = self.identificationComponent
    }
    func presentFirstNameComponent() {
        self.view.bringSubview(toFront: self.firstNameComponent!)
        self.firstNameComponent?.componentBecameFirstResponder()
        self.currentInput = self.firstNameComponent
    }
    func presentSecondNameComponent() {
        self.view.bringSubview(toFront: self.secondNameComponent!)
        self.secondNameComponent?.componentBecameFirstResponder()
        self.currentInput = self.secondNameComponent
    }

    func executeCallback() {
        callback(self.viewModel.getFinalPayer())
    }

    func textFieldDidBeginEditing(_ textField: UITextField) {
        print(textField.text)
    }
    var keyboardFrame: CGRect?

    func keyboardWasShown(_ notification: NSNotification) {
        let info = notification.userInfo!
        let keyboardFrame: CGRect = (info[UIKeyboardFrameEndUserInfoKey] as! NSValue).cgRectValue
        self.keyboardFrame = keyboardFrame
        setupView()
    }
}
