//
//  WebViewController.swift
//  MercadoPagoSDK
//
//  Created by Maria cristina rodriguez on 22/5/16.
//  Copyright © 2016 MercadoPago. All rights reserved.
//

import UIKit

class WebViewController: MercadoPagoUIViewController, UIWebViewDelegate {
    
    var url : URL?
    override internal var screenName : String { get{ return "TERMS_AND_CONDITIONS" } }
    @IBOutlet weak var webView: UIWebView!
    init( url : URL) {
        super.init(nibName: "WebViewController", bundle: MercadoPago.getBundle())
        self.url = url
        
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.loadUrl(url!)
        self.webView.delegate = self
    }
    
    override func viewDidAppear(_ animated: Bool) {
        self.showLoading()
    }


    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func loadUrl(_ url : URL){
        let requestObj = URLRequest(url: url);
        webView.loadRequest(requestObj);
    }
    
    func webViewDidFinishLoad(_ webView: UIWebView) {
        self.hideLoading()
    }
    

}
