//
//  AvailableCardsViewController.swift
//  Pods
//
//  Created by Angie Arlanti on 8/28/17.
//
//

import UIKit

open class AvailableCardsViewController: MercadoPagoUIViewController {

    let buttonFontSize: CGFloat = 18
    let MARGIN_X_SCROLL_VIEW: CGFloat = 32
    @IBOutlet weak var retryButton: UIButton!
    override open var screenName: String { get { return "AVAILABLE_CARDS_DETAIL" } }
    var availableCardsDetailView: AvailableCardsDetailView!
    var viewModel: AvailableCardsViewModel!

    init(paymentMethods: [PaymentMethod], callbackCancel: (() -> Void)? = nil) {
        super.init(nibName: "AvailableCardsViewController", bundle: MercadoPago.getBundle())
        self.callbackCancel = callbackCancel
        self.viewModel = AvailableCardsViewModel(paymentMethods: paymentMethods)

    }

    init(viewModel: AvailableCardsViewModel, callbackCancel: (() -> Void)? = nil) {
        super.init(nibName: "AvailableCardsViewController", bundle: MercadoPago.getBundle())
        self.callbackCancel = callbackCancel
        self.viewModel = viewModel
    }

    required public init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override open func viewDidLoad() {
        super.viewDidLoad()
        self.view.backgroundColor = UIColor.px_grayBaseText()
        let screenSize: CGRect = UIScreen.main.bounds
        let screenHeight = screenSize.height
        let screenWidth = screenSize.width

        let availableCardsViewWidth = screenWidth - 2 * MARGIN_X_SCROLL_VIEW
        var availableCardsViewTotalHeight = AvailableCardsDetailView.HEADER_HEIGHT + AvailableCardsDetailView.ITEMS_HEIGHT * CGFloat(self.viewModel.paymentMethods.count)
        if availableCardsViewTotalHeight > screenHeight * 0.73 {
            availableCardsViewTotalHeight = screenHeight * 0.73
        }
        let xPos = (screenWidth - availableCardsViewWidth)/2
        let yPos = (screenHeight - availableCardsViewTotalHeight)/2
        self.availableCardsDetailView = AvailableCardsDetailView(frame:CGRect(x: xPos, y: yPos, width:availableCardsViewWidth, height: availableCardsViewTotalHeight), paymentMethods: self.viewModel.paymentMethods)
        self.availableCardsDetailView.layer.cornerRadius = 4
        self.availableCardsDetailView.layer.masksToBounds = true
        self.view.addSubview(self.availableCardsDetailView)

        self.retryButton.setTitle("Ingresar tarjeta".localized, for: .normal)
        self.retryButton.titleLabel?.textColor = .white
        self.retryButton.titleLabel?.font = self.retryButton.titleLabel?.font.withSize(buttonFontSize)
    }
    override open func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }

    @IBAction func exit() {
        guard let callbackCancel = self.callbackCancel else {
            self.dismiss(animated: true, completion: nil)
            return
        }
        self.dismiss(animated: true) {
            callbackCancel()
        }

    }

}

class AvailableCardsViewModel: NSObject {
    var paymentMethods: [PaymentMethod]!
    init(paymentMethods: [PaymentMethod]) {
        self.paymentMethods = paymentMethods
    }

}
