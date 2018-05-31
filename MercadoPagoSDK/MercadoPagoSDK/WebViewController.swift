//
//  WebViewController.swift
//  MercadoPagoSDK
//
//  Created by Maria cristina rodriguez on 22/5/16.
//  Copyright © 2016 MercadoPago. All rights reserved.
//

import UIKit

class WebViewController: MercadoPagoUIViewController, UIWebViewDelegate {

    var url: URL?
    var name: String?
    var navBarTitle: String!
    @IBOutlet weak var webView: UIWebView!
    var loadingVC: PXLoadingViewController

    init( url: URL, screenName: String, navigationBarTitle: String) {
        self.url = url
        self.name = screenName
        self.navBarTitle = navigationBarTitle
        self.loadingVC = PXLoadingViewController()
        super.init(nibName: "WebViewController", bundle: MercadoPago.getBundle())
    }
    override internal var screenName: String { return name! }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        self.loadUrl(url!)
        self.webView.delegate = self
        self.present(loadingVC, animated: false, completion: nil)
    }

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        self.showNavBar()
    }

    override func getNavigationBarTitle() -> String {
        return navBarTitle
    }

    func loadUrl(_ url: URL) {
        let requestObj = URLRequest(url: url)
        webView.loadRequest(requestObj)
    }

    func webViewDidFinishLoad(_ webView: UIWebView) {
        self.loadingVC.dismiss(animated: false, completion: nil)
    }
}
