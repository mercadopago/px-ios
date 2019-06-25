import UIKit

class BackView: CardView {

    override func setupUI(_ cardUI: CardUI) {
        super.setupUI(cardUI)
        securityCode.setup(model?.securityCode, Default(UIColor.gray))
    }

    deinit {
        removeObserver(securityCode, forKeyPath: #keyPath(model.securityCode))
    }
}
