import UIKit

internal extension UIView {

    func loadFromNib() {

        guard let view = Bundle(for: type(of: self)).loadNibNamed(String(describing: type(of: self)),
                                                  owner: self,
                                                  options: nil)?[0] as? UIView else { return }
        view.frame = bounds
        self.addSubview(view)
    }
}
