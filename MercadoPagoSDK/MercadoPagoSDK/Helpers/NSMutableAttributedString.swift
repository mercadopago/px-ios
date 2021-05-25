//
//  NSMutableAttributedString.swift
//  MercadoPagoSDKV4
//
//  Created by Matheus Leandro Martins on 26/04/21.
//

extension NSMutableAttributedString {
    func with(font: UIFont) -> NSMutableAttributedString {
        self.enumerateAttribute(.font, in: NSMakeRange(0, self.length), options: .longestEffectiveRangeNotRequired, using: { (value, range, stop) in
            if let originalFont = value as? UIFont, let newFont = applyTraitsFromFont(originalFont, to: font) {
                self.addAttribute(.font, value: newFont, range: range)
            }
        })
        return self
    }
    
    func applyTraitsFromFont(_ f1: UIFont, to f2: UIFont) -> UIFont? {
        let originalTrait = f1.fontDescriptor.symbolicTraits
        if originalTrait.contains(.traitBold) {
            var traits = f2.fontDescriptor.symbolicTraits
            traits.insert(.traitBold)
            if let fd = f2.fontDescriptor.withSymbolicTraits(traits) {
                return UIFont.init(descriptor: fd, size: 0)
            }
        }
        return f2
    }
}
