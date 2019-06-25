import UIKit

class Mask {
    let pad: Character = "*"
    var pattern = [Int]()
    var placeholder = ""
    var attributes = [NSAttributedString.Key: Any]()
    var length: Int { return pattern.reduce(0, +) }
    var shadow = NSShadow()

    init() {
        shadow.shadowOffset = CGSize(width: 0, height: 1)
        shadow.shadowColor = UIColor.black
        shadow.shadowBlurRadius = 2
    }

    convenience init(pattern: [Int]) {
        self.init()
        attributes[.kern] = 1.6
        self.pattern = pattern
    }

    convenience init(placeholder: String) {
        self.init()
        attributes[.kern] = 0.4
        self.placeholder = placeholder
    }

    func format(_ text: String?, _ font: Font, _ total: Int, _ color: UIColor? = nil) -> NSAttributedString {

        var text = text ?? ""
        text = pattern.isEmpty ? placeHolder(text) : pattern(text, total)

        let len = text == placeholder ? 0 : text.index(of: pad)?.encodedOffset ?? text.count
        let attributed = NSMutableAttributedString(string: text, attributes: attributes)

        attributed.addAttributes(editAtributes(font, color), range: NSRange(location: 0, length: len))

        return attributed
    }

    func editAtributes(_ font: Font, _ color: UIColor?) -> [NSAttributedString.Key: Any] {
        var editedAttributes = [NSAttributedString.Key: Any]()
        editedAttributes[.shadow] = font.shadow ? shadow : nil
        editedAttributes[.foregroundColor] = color ?? font.color

        return editedAttributes
    }

    func placeHolder(_ text: String) -> String {
        return text == placeholder || text.isEmpty ? placeholder : text
    }

    func pattern(_ text: String, _ totalPad: Int) -> String {

        var current = text.padding(toLength: length, withPad: "\(pad)", startingAt: 0)
        guard pattern.count > 1 else { return current }

        let slice = max((totalPad - length) / (pattern.count - 1), 1)

        return pattern.map({
            let group = "\(current.prefix($0))"
            current = "\((current.dropFirst($0)))"
            return group
        }).joined(separator: String(repeating: " ", count: slice))
    }
}
