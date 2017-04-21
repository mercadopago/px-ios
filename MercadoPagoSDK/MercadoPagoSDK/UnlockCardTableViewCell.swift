//
//  UnlockCardTableViewCell.swift
//  MercadoPagoSDK
//
//  Created by AUGUSTO COLLERONE ALFONSO on 3/30/17.
//  Copyright © 2017 MercadoPago. All rights reserved.
//

import UIKit

class UnlockCardTableViewCell: UITableViewCell, UITextViewDelegate {

    private static let ROW_HEIGHT = CGFloat(58)
    public static var unlockCardLink: URL!
    
    @IBOutlet weak var background: UIView!
    @IBOutlet weak var unlockCardtextView: MPTextView!
    @IBOutlet weak var warningIconImageView: UIImageView!
    
    var delegate : UnlockCardDelegate?
    
    override func awakeFromNib() {
        super.awakeFromNib()
        self.background.backgroundColor = UIColor.UIColorFromRGB(0xFFF4C3)
        self.background.layer.cornerRadius = 4
        
        self.unlockCardtextView.delegate = self
        self.unlockCardtextView.isUserInteractionEnabled = true
        self.unlockCardtextView.attributedText = UnlockCardTableViewCell.getUnlockCardText()
        
        let URLAttribute = [NSFontAttributeName : Utils.getFont(size: 14) ?? UIFont.systemFont(ofSize: 14),NSForegroundColorAttributeName: UIColor.primaryColor()]
        
        self.unlockCardtextView.linkTextAttributes = URLAttribute
        
        self.selectionStyle = .none
        
    }
    
    private static func getUnlockCardTextView() -> MPTextView {
        let textView = MPTextView()
        textView.isUserInteractionEnabled = true
        
        textView.attributedText = getUnlockCardText()
        return textView
    }
    
    private static func getUnlockCardText() -> NSMutableAttributedString{
        
        let unlockCardText = "Recuerda desbloquear tu tarjeta antes de confirmar el pago.".localized
        let normalAttributes: [String:AnyObject] = [NSFontAttributeName : Utils.getFont(size: 14),NSForegroundColorAttributeName: UIColor.UIColorFromRGB(0xA1924C)]
        
        let mutableAttributedString = NSMutableAttributedString(string: unlockCardText, attributes: normalAttributes)
        let unlockCardLinkRange = (unlockCardText as NSString).range(of: "desbloquear tu tarjeta".localized)
        
        mutableAttributedString.addAttribute(NSLinkAttributeName, value: self.unlockCardLink!, range: unlockCardLinkRange)
        
        let style = NSMutableParagraphStyle()
        style.alignment = .left
        style.lineSpacing = CGFloat(0.5)
        
        mutableAttributedString.addAttribute(NSParagraphStyleAttributeName, value: style, range: NSMakeRange(0, mutableAttributedString.length))
        return mutableAttributedString
    }
    
    func textView(_ textView: UITextView, shouldInteractWith URL: URL, in characterRange: NSRange) -> Bool {
        self.delegate?.openUnlockCard("Desbloqueo de Tarjeta".localized, url : URL)
        return false
    }
    
    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
        
    }
    
    static public func getCellHeight() -> CGFloat {
        return UnlockCardTableViewCell.ROW_HEIGHT
    }
    
}

protocol UnlockCardDelegate {
    
    func openUnlockCard(_ title : String, url : URL)
}

