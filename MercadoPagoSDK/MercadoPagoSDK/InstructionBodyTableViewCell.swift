//
//  InstructionBodyTableViewCell.swift
//  MercadoPagoSDK
//
//  Created by Eden Torres on 11/6/16.
//  Copyright © 2016 MercadoPago. All rights reserved.
//

import UIKit

class InstructionBodyTableViewCell: UITableViewCell {

    @IBOutlet weak var bottom: UILabel!
    @IBOutlet weak var view: UIView!

    override func awakeFromNib() {
        super.awakeFromNib()
    }
    var height = 0

    fileprivate func putReferenceLabels(_ instruction: Instruction, _ previus: inout UIView?, _ paymentResult: PaymentResult) {
        for reference in instruction.references {
            if let labelText = reference.label {
                let labelTitle = NSAttributedString(string: String(describing: labelText), attributes: getAttributes(fontSize: 12, color: UIColor.gray))
                let label = createLabel(labelAtributedText: labelTitle)

                let views = ["label": label]

                Utils.setContrainsHorizontal(views: views, constrain: 20)
                let heightConstraints: [NSLayoutConstraint]

                if  previus != nil {
                    Utils.setContrainsVertical(label: label, previus: previus, constrain: 30)
                } else {
                    heightConstraints = NSLayoutConstraint.constraints(withVisualFormat: "V:|-(30)-[label]", options: NSLayoutFormatOptions(rawValue: 0), metrics: nil, views: views)
                    NSLayoutConstraint.activate(heightConstraints)
                }

                previus = label
            }

            let labelTitle = NSAttributedString(string: String(describing: reference.getFullReferenceValue()), attributes: getAttributes(fontSize: 20, color: UIColor.black))
            let label = createLabel(labelAtributedText: labelTitle)

            let views = ["label": label]

            if paymentResult.paymentData?.getPaymentMethod()!._id == "redlink" {
                Utils.setContrainsHorizontal(views: views, constrain: 15)
            } else {
                Utils.setContrainsHorizontal(views: views, constrain: 25)
            }

            Utils.setContrainsVertical(label: label, previus: previus, constrain: 1)
            previus = label

            if let labelText = reference.comment {
                let labelTitle = NSAttributedString(string: String(describing: labelText), attributes: getAttributes(fontSize: 18, color: UIColor.gray))
                let label = createLabel(labelAtributedText: labelTitle)

                let views = ["label": label]

                Utils.setContrainsHorizontal(views: views, constrain: 20)
                let heightConstraints: [NSLayoutConstraint]

                if  previus != nil {
                    Utils.setContrainsVertical(label: label, previus: previus, constrain: 30)
                } else {
                    heightConstraints = NSLayoutConstraint.constraints(withVisualFormat: "V:|-(30)-[label]", options: NSLayoutFormatOptions(rawValue: 0), metrics: nil, views: views)
                    NSLayoutConstraint.activate(heightConstraints)
                }

                previus = label
            }

        }
    }

    fileprivate func putAccreditationMessageLabel(_ instruction: Instruction, _ previus: inout UIView?) {
        let clockImage = NSTextAttachment()
        clockImage.image = MercadoPago.getImage("iconTime")
        let clockAttributedString = NSAttributedString(attachment: clockImage)
        let labelAttributedString = NSMutableAttributedString(string: String(describing: " "+instruction.accreditationMessage), attributes: getAttributes(fontSize: 12, color: UIColor.gray))
        labelAttributedString.insert(clockAttributedString, at: 0)
        let labelTitle = labelAttributedString
        let label = createLabel(labelAtributedText: labelTitle)
        let views = ["label": label] as [String : UIView]

        if previus != nil {
            Utils.setContrainsVertical(label: label, previus: previus, constrain: 30)
        } else {
            let heightConstraints = NSLayoutConstraint.constraints(withVisualFormat: "V:|-(30)-[label]", options: NSLayoutFormatOptions(rawValue: 0), metrics: nil, views: views)
            NSLayoutConstraint.activate(heightConstraints)
        }
        Utils.setContrainsHorizontal(views: views, constrain: 20)

        let labelHeight = label.requiredHeight()
        label.frame.size.width = view.frame.width
        label.frame.size.height = labelHeight

        previus = label
    }

    fileprivate func putAccreditationComentLabels(_ instruction: Instruction, _ previus: inout UIView?) {
        for comment in instruction.accreditationComment! {
            let labelAttributedString = NSMutableAttributedString(string: String(describing: comment), attributes: getAttributes(fontSize: 12, color: UIColor.gray))
            let labelTitle = labelAttributedString
            let label = createLabel(labelAtributedText: labelTitle)
            let views = ["label": label] as [String : UIView]

        if previus != nil {
            Utils.setContrainsVertical(label: label, previus: previus, constrain: 15)
        } else {
            let heightConstraints = NSLayoutConstraint.constraints(withVisualFormat: "V:|-(30)-[label]", options: NSLayoutFormatOptions(rawValue: 0), metrics: nil, views: views)
            NSLayoutConstraint.activate(heightConstraints)
        }

            Utils.setContrainsHorizontal(views: views, constrain: 20)

            let labelHeight = label.requiredHeight()
            label.frame.size.width = view.frame.width
            label.frame.size.height = labelHeight

            previus = label
        }
    }

    fileprivate func putActionButton(_ instruction: Instruction, _ previus: inout UIView?) {
        if instruction.actions![0].tag == ActionTag.LINK.rawValue {
            let button = MPButton(frame: CGRect(x: 0, y: 0, width: 160, height: 30))
            button.titleLabel?.font = Utils.getFont(size: 16)
            button.setTitle(instruction.actions![0].label, for: .normal)
            button.setTitleColor(UIColor.px_blueMercadoPago(), for: .normal)
            button.translatesAutoresizingMaskIntoConstraints = false

            button.actionLink = instruction.actions![0].url
            button.addTarget(self, action: #selector(self.goToURL), for: .touchUpInside)
            self.view.addSubview(button)
            let views = ["label": button]
            Utils.setContrainsHorizontal(views: views, constrain: 60)

            if previus != nil {
            Utils.setContrainsVertical(label: button, previus: previus, constrain: 30)
        } else {
            let heightConstraints = NSLayoutConstraint.constraints(withVisualFormat: "V:|-(30)-[label]", options: NSLayoutFormatOptions(rawValue: 0), metrics: nil, views: views)
            NSLayoutConstraint.activate(heightConstraints)
        }
            previus = button
        }
    }

    func fillCell(instruction: Instruction, paymentResult: PaymentResult) {
        var previus: UIView?
        height = 0

        for (index, info) in instruction.info.enumerated() {
            var fontSize = 18

            if index>1 && index<5 && paymentResult.paymentData?.getPaymentMethod()!._id == "redlink" {
                fontSize = 16
            }
            let labelTitle = NSAttributedString(string: info, attributes: getAttributes(fontSize: fontSize, color: UIColor.gray))
            let label = createLabel(labelAtributedText: labelTitle)
            height += Int(label.frame.height)
            let views = ["label": label]

            Utils.setContrainsHorizontal(views: views, constrain: 20)

            let heightConstraints: [NSLayoutConstraint]

            if index == 0 {
                heightConstraints = NSLayoutConstraint.constraints(withVisualFormat: "V:|-(30)-[label]", options: NSLayoutFormatOptions(rawValue: 0), metrics: nil, views: views)
                height += 30
                NSLayoutConstraint.activate(heightConstraints)

            } else if paymentResult.paymentData?.getPaymentMethod()!._id == "redlink"{

                if instruction.info[index-1] != ""{
                    Utils.setContrainsVertical(label: label, previus: previus, constrain: 0)
                } else if index == 6 {
                    Utils.setContrainsVertical(label: label, previus: previus, constrain: 60)
                    height += 60
                } else {
                    Utils.setContrainsVertical(label: label, previus: previus, constrain: 30)
                    height += 30
                }
                if index == 4 {
                    if UIScreen.main.bounds.width <= 320 {
                        height+=21
                    }

                    ViewUtils.drawBottomLine(y: CGFloat(height+30), width: UIScreen.main.bounds.width, inView: self.view)
                }

            } else {
                Utils.setContrainsVertical(label: label, previus: previus, constrain: 30)
                height += 30
            }
            previus = label

        }
        putReferenceLabels(instruction, &previus, paymentResult)

        if instruction.hasAccreditationMessage() {
            putAccreditationMessageLabel(instruction, &previus)
        }

        if instruction.hasAccreditationComment() {
            putAccreditationComentLabels(instruction, &previus)
        }

        if instruction.hasActions() {
            putActionButton(instruction, &previus)
        }

        if previus != nil {
            let views = ["label": previus] as! [String: UIView]
            let heightConstraints = NSLayoutConstraint.constraints(withVisualFormat: "V:[label]-30-|", options: NSLayoutFormatOptions(rawValue: 0), metrics: nil, views: views)
            NSLayoutConstraint.activate(heightConstraints)
        }
    }
    func getAttributes(fontSize: Int, color: UIColor)-> [String:AnyObject] {
        return [NSFontAttributeName: Utils.getFont(size: CGFloat(fontSize)), NSForegroundColorAttributeName: color]
    }

    func goToURL(sender: MPButton!) {   if let link = sender.actionLink {
        UIApplication.shared.openURL(URL(string: link)!)
        }
    }
    func createLabel(labelAtributedText: NSAttributedString) -> UILabel {
        let label = UILabel()
        label.textAlignment = .center
        label.numberOfLines = 0
        label.attributedText = labelAtributedText
        label.sizeToFit()
        label.translatesAutoresizingMaskIntoConstraints = false
        self.view.addSubview(label)
        return label
    }

}
