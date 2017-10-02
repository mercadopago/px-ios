//
//  InputComponent.swift
//  MercadoPagoSDK
//
//  Created by Demian Tejo on 9/27/17.
//  Copyright © 2017 MercadoPago. All rights reserved.
//

import UIKit
protocol SingleInputComponentListener {
    func textChangedTo(newText: String)
}
protocol CompositeInputComponentListener {
    func textChangedTo(newText: String)
}
class SimpleInputComponent: UIView, PXComponent {
    let HEIGHT: CGFloat = 83.0
    let INPUT_HEIGHT: CGFloat = 45.0
    let HORIZONTAL_MARGIN: CGFloat = 31.0
    var placeholder: String?
    var numeric: Bool = false
    var textFieldDelegate: UITextFieldDelegate!
    var inputTextField : HoshiTextField!
    var textMask: TextMaskFormater = TextMaskFormater(mask: "XXXXXXXXXXXXXXXXXXXXXX", completeEmptySpaces : false)
    init(frame: CGRect, textMask: TextMaskFormater = TextMaskFormater(mask: "XXXXXXXXXXXXXXXXXXXXXX", completeEmptySpaces : false), numeric: Bool = false, placeholder: String? = nil, textFieldDelegate: UITextFieldDelegate) {
        super.init(frame: frame)
        self.textMask = textMask
        self.numeric = numeric
        self.placeholder = placeholder
        self.textFieldDelegate = textFieldDelegate
        self.setupView()
    }
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    func getHeight() -> CGFloat {
        return HEIGHT
    }
    func getWeight() -> CGFloat {
        return self.frame.size.width
    }
    func setupView() {
        inputTextField = HoshiTextField(frame: CGRect(x: getInputX(), y: getInputY(), width: getInputWidth(), height: INPUT_HEIGHT))
        if let placeholder = placeholder {
            inputTextField.placeholder = placeholder
        }
        
        self.addSubview(inputTextField)
        self.frame.size.height = getHeight()
    }
    func getInputX() -> CGFloat {
        return HORIZONTAL_MARGIN
    }
    func getInputY() -> CGFloat {
        return (self.getHeight() - INPUT_HEIGHT) / 2
    }
    func getInputWidth() -> CGFloat {
        return self.getWeight() - HORIZONTAL_MARGIN * 2
    }
    func componentBecameFirstResponder() {
        self.inputTextField.becomeFirstResponder()
    }
    func componentResignFirstResponder() {
        self.inputTextField.resignFirstResponder()
    }
}

class CompositeInputComponent: SimpleInputComponent, UIPickerViewDataSource, UIPickerViewDelegate {
    let COMBO_WEIGHT: CGFloat = 45.0
    let MARGIN_BETWEEN_ELEMENTS: CGFloat = 14.0
    let PICKER_HEIGHT :CGFloat = 216.0
    var dropDownSelectedOptionText : String!
    var dropDownOptions : [String]!
    var dropDownPlaceholder: String?
    var dropDownTextField : HoshiTextField!
    init(frame: CGRect, textMask: TextMaskFormater = TextMaskFormater(mask: "XXXXXXXXXXXXXXXXXXXXXX", completeEmptySpaces : false), numeric: Bool = true, dropDownPlaceholder:String? = nil, dropDownOptions:[String], textFieldDelegate: UITextFieldDelegate) {
        self.dropDownSelectedOptionText = dropDownOptions[0]
        self.dropDownPlaceholder = dropDownPlaceholder
        self.dropDownOptions = dropDownOptions
        super.init(frame: frame, textMask: textMask, numeric: numeric, textFieldDelegate: textFieldDelegate)
        self.backgroundColor = .white
        self.setupView()
    }
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    override func setupView() {
        dropDownTextField = HoshiTextField(frame: CGRect(x: HORIZONTAL_MARGIN  , y: getInputY(), width: COMBO_WEIGHT, height: INPUT_HEIGHT))
        if let dropDownPlaceholder = dropDownPlaceholder {
            dropDownTextField.placeholder = dropDownPlaceholder
        }
        dropDownTextField.inputView = getPicker()
        dropDownTextField.inputAccessoryView = getToolBar()
        dropDownTextField.text = dropDownOptions[0]
        inputTextField = HoshiTextField(frame: CGRect(x: getInputX(), y: getInputY(), width: getInputWidth(), height: INPUT_HEIGHT))
        if let placeholder = placeholder {
            inputTextField.placeholder = placeholder
        }
        self.addSubview(dropDownTextField)
        self.addSubview(inputTextField)
        self.frame.size.height = getHeight()
    }
    override func getInputX() -> CGFloat {
        return HORIZONTAL_MARGIN + COMBO_WEIGHT + MARGIN_BETWEEN_ELEMENTS
    }
    override func getInputWidth() -> CGFloat {
         return self.getWeight() - HORIZONTAL_MARGIN * 2 - COMBO_WEIGHT - MARGIN_BETWEEN_ELEMENTS
    }
    func getPicker() -> UIPickerView {
        let pickerView = UIPickerView(frame: CGRect(x: 0, y: 150, width: self.frame.width, height: PICKER_HEIGHT))
        pickerView.backgroundColor = UIColor.px_white()
        pickerView.showsSelectionIndicator = true
        pickerView.backgroundColor = UIColor.px_white()
        pickerView.showsSelectionIndicator = true
        pickerView.dataSource = self
        pickerView.delegate = self
        return pickerView
    }
    func getToolBar() -> UIToolbar {
        let toolBar = UIToolbar()
        toolBar.barStyle = UIBarStyle.default
        toolBar.sizeToFit()
        let doneButton = UIBarButtonItem(title: "OK".localized, style: .plain, target: self, action: #selector(CompositeInputComponent.donePicker))
        let spaceButton = UIBarButtonItem(barButtonSystemItem: UIBarButtonSystemItem.flexibleSpace, target: nil, action: nil)
        let font = Utils.getFont(size: 14)
        doneButton.setTitleTextAttributes([NSFontAttributeName: font], for: UIControlState())
        toolBar.setItems([spaceButton, doneButton], animated: false)
        toolBar.isUserInteractionEnabled = true
        return toolBar
    }
    
    //Picker View
    open func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return 1
    }
    
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        return self.dropDownOptions.count
    }
    
    open func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        return self.dropDownOptions[row]
    }
    
    open func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        dropDownSelectedOptionText =  self.dropDownOptions[row]
        dropDownTextField.text = dropDownSelectedOptionText
        self.inputTextField.text = ""
    }
    open func donePicker() {
        dropDownTextField.resignFirstResponder()
        inputTextField.becomeFirstResponder()
    }
}
